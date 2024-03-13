# 6 bits of entropy. 22 chars reach 128 entropy.
function password
  if [ -z "$argv" ]; set argv 22; end
  cat /dev/urandom | base64 | head -c "$argv" | tr + = | tr '\n' -d
end

# ~5.2 bits of entropy. 25 chars reach 128 entropy.
function passwordl
  if [ -z "$argv" ]; set argv 25; end
  password $argv | tr \[:upper:\] \[:lower:\]
end

# 6.5 bits of entropy, 7.7% higher. 20 chars reach 128 entropy.
function password91
  if [ -z "$argv" ]; set argv 20; end
  cat /dev/urandom | head -c "$argv" | base91 --encode | head -c "$argv"
end
