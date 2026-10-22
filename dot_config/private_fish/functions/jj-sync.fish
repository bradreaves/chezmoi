function jj-sync --description "Fetch upstream and rebase local strip commit onto trunk"
    jj git fetch $argv
    and jj rebase -s 'roots(mutable())' -d 'trunk()'
end
