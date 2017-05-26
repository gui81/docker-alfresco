BEGIN {
    FS="="
}
/=\s*@@.*@@/ {
    match($2, "@+([^@]+)@+", result)
    varname = result[1]
    value = ENVIRON[varname]
    if (value == "")
	value = $2
    printf("%s=%s\n", $1, value)
    next
}
{ print }
