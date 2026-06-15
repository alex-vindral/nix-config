{
  writeShellApplication,
  coreutils,
  findutils,
  gnugrep,
  rclone,
}:
writeShellApplication {
  name = "pull";
  runtimeInputs = [coreutils findutils gnugrep rclone];
  text = ''
    BASE="$HOME/s3/Testresults"
    SELECTED=""

    # Invalidate the rclone VFS dir/metadata cache so freshly written
    # files (and appended log content) on S3 are visible. The S3 backend
    # can't poll for changes, so without this we'd serve cached state for
    # up to --dir-cache-time. Best-effort: if the rc API is unreachable
    # (mount not running with --rc), fall back to whatever is cached.
    refresh() {
      local rel="''${1#"$HOME"/s3/}"
      rclone rc vfs/refresh dir="$rel" recursive="''${2:-false}" \
        >/dev/null 2>&1 || true
    }

    list_folders() {
      refresh "$1"
      if [ -d "$1" ]; then
        find "$1" -mindepth 1 -maxdepth 1 -type d -printf '%f\n'
      fi
    }

    choose() {
      local prompt="$1"
      local path="$2"
      local -a options
      if [ $# -gt 2 ]; then
        options=("''${@:3}")
      else
        mapfile -t options < <(list_folders "$path")
      fi

      if [ ''${#options[@]} -eq 0 ]; then
        echo "ERROR: No entries found at $path" >&2
        exit 1
      fi

      if [ ''${#options[@]} -eq 1 ]; then
        SELECTED="''${options[0]}"
        return
      fi

      echo ""
      echo "$prompt"
      for i in "''${!options[@]}"; do
        printf "  %2d) %s\n" "$((i+1))" "''${options[$i]}"
      done

      local choice
      while true; do
        read -rp "Enter number [1-''${#options[@]}]: " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ''${#options[@]} )); then
          SELECTED="''${options[$((choice-1))]}"
          return
        fi
        echo "  Invalid choice, try again."
      done
    }

    mapfile -t _all_os < <(list_folders "$BASE")
    _os_filtered=()
    for _o in "''${_all_os[@]}"; do
      [[ "$_o" == "Linux" || "$_o" == "Windows" ]] && _os_filtered+=("$_o")
    done
    choose "Choose OS:" "$BASE" "''${_os_filtered[@]}"
    OS="$SELECTED"

    choose "Choose TYPE:" "$BASE/$OS"
    TYPE="$SELECTED"

    choose "Choose HOST:" "$BASE/$OS/$TYPE"
    HOST="$SELECTED"

    mapfile -t _all_dates < <(list_folders "$BASE/$OS/$TYPE/$HOST" | sort | tail -5)
    choose "Choose DATE:" "$BASE/$OS/$TYPE/$HOST" "''${_all_dates[@]}"
    DATE="$SELECTED"

    choose "Choose TIME:" "$BASE/$OS/$TYPE/$HOST/$DATE"
    TIME="$SELECTED"

    LOG_PATH="$BASE/$OS/$TYPE/$HOST/$DATE/$TIME"

    echo ""
    echo "$LOG_PATH"
    echo ""

    # Recursively refresh the selected run so file sizes/contents are
    # current before we read them — this is what was stale when an
    # [Error] line got appended on S3 after the dir was first cached.
    refresh "$LOG_PATH" true

    found_any=0

    for dir in "$LOG_PATH"/*/; do
      [ -d "$dir" ] || continue
      for f in "$dir"*composerLog.txt "$dir"*testRunnerLog.txt; do
        [ -f "$f" ] || continue
        errors=$(grep '\[Error\]' "$f" || true)
        if [ -n "$errors" ]; then
          found_any=1
          printf '%s:\n%s\n\n' "$(basename "''${f%.txt}")" "$errors"
        fi
      done
    done

    if [ "$found_any" -eq 0 ]; then
      echo "No [Error] lines found in any log file."
    fi
  '';
}
