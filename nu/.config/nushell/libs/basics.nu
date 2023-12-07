# vim: set filetype=nu:

export def wait-for [host: string] {
    let syms = [ '/' '|' '\' '-' ]
    mut i = 0
    loop {
        let resp = (do -s {ping -c 1 -W 1 -q $host }| complete)
        if $resp.exit_code == 0 {
            (notify-send -t 5000 $"($host)" "up" | complete )| null
            do -i {mpv /usr/share/sounds/freedesktop/stereo/complete.oga} | complete | null
            return
        }
        if $resp.exit_code == -1 {
            print "SIGINT: exiting"
            return
        }
        print -n $"\r[($syms | get ($i mod 4))] Waiting for ($host)"
        if $resp.exit_code == 2 {
            print -n $"($resp.stderr | str replace '\n' '')"
        }
        $i = $i + 1
    }
}

use std

export def mr [] {
    #--------------------
    let current_song = ([$env.MPD_DIR,(mpc current -f "%file%")] | path join )
    ^mv $current_song $"($env.HOME)/tmp"
    mpc rescan
    mpc next
    notify-send "mpd" $"'($current_song | path basename)' moved to ~/tmp" -t 5000
}

export def est [] {
    let init =  (cat /sys/class/power_supply/BAT0/energy_now | into int) / ( cat /sys/class/power_supply/BAT0/energy_full | into int)
        let init_time = (date now)
        while (true) {
            sleep 1min
                let bat_now = (cat /sys/class/power_supply/BAT0/energy_now | into int) / ( cat /sys/class/power_supply/BAT0/energy_full | into int)
                let diff_bat = $init - $bat_now
                let diff_time = ((date now) - $init_time ) / 1sec
                let rat = $diff_bat / $diff_time
                let remain = $bat_now / ($rat * 3600)
                print $"[(date now )] Remaining time ($remain) hours"
        }
}

def confirm-download [ file: string dir: path ] {
	let results = fd . -t f $dir | lines | par-each { |song | 
		{name: $song, rating: ($song 
			| path basename 
			| str replace -ra '(\(.*\)|\[.*\])' '' 
			| path parse
			| get stem
			| str distance $file)
		}
	}
	|sort-by rating | first 5 | where rating <= 10
	print $"for '($file)', matching results"
	print $results
	if (not ($results| is-empty))  and $results.0.rating == 0 {
		std log error $"($file) already exists"
		return {'continue': false, 'file': null}
	}
	let resp = (input -n 1 "Above similar songs exists, Do you want to Continue? [Y/n/e]" | str downcase)
        if $resp == 'e' {
            return {'continue': true, 'file': ($file | vipe)}
        } else if $resp == 'n' {
            return {'continue': false, 'file': null}
        } else {
            return {'continue': true, 'file': $file}
        }
}

def get-youtube-song [unparsed_link: string output_dir: path = "./"] {
    let links = ($unparsed_link | parse -r 'youtube\.com/watch\?v=(?<link>[\w-]+)' | get link)
    if ($links | length) != 1 {
        print -e $"Failed to parse link '($unparsed_link)', found ($links | length) valid link matches"
        return ""
    }
    let link = $links.0
    std log info $"Downloading from youtube: ($links)"
    try {
        let metadata = (yt-dlp --dump-json --skip-download $link | from json)
# replace all contents within () and [] and any special characters
	let title = $metadata.title | str replace -ra '(\(.*\)|\[.*\]|[^\x00-\x7f]|[\\/^%!$\|])' ''
        let resp = confirm-download $title $output_dir
	if $resp.continue {
                yt-dlp --embed-thumbnail --embed-metadata -x --audio-format mp3 --no-embed-info-json -o $"($output_dir)/($resp.file).mp3" $link
		return $"($resp.file).mp3"
	}
    } catch { |error|
        std log warning $"couldn't download ($links.0): ($error)"
    }
    return ""
}

export def get-song [link: string] {
    if not "MPD_DIR" in $env {
        print -e "Failed to get $env.MPD_DIR, is it set?"
        return
    }
    let MusicDownloadDir = $"($env.MPD_DIR)/temp/"
    let ret = if $link =~ '^(https://)?(music|www)\.youtube\.com/watch\?v=[\w-]+' {
        std log debug "matched link to youtube"
        let title = (get-youtube-song $link $MusicDownloadDir)
        if $title != "" {
            mpc update -w
            mpc add $"($MusicDownloadDir | path join $title | path relative-to $env.MPD_DIR)"
        }
    } else {
        std log error $"Failed to get the provider for the link: '($link)'"
        1
    }
    if $ret == 1 {
        std log error "Download Failed"
    }
}

export def commit-pass [] {
    cd ~/.personal/
    git add .
    git commit -m $"(date now | format date  "%d-%m-%Y")"
    git push
    cd -
}

export def tty-size [] {
    stty size | parse "{rows} {cols}" | get 0 | format 'stty rows {rows} cols {cols}' | str trim | std clip
}

export def bsource [pth: string ] {
    exec bash -c $"'source ($pth) && exec nu'"
}

export def notif [wait: duration ...params] {
    systemd-run --on-active ($wait | format duration sec | split row ' ' | get 0 ) --user notify-send $params
}

export def copy-remote [remote_id: string] {
    ssh $remote_id cat /tmp/clip | wl-copy
}
