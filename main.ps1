$sessions = query user | ForEach-Object {
    $fields = $_ -split '\s+'
    [PSCustomObject]@{
        UserName = If($fields[3] -eq "Disc") {$fields[1]} Else {$fields[0]}
        SessionName = If($fields[3] -eq "Disc") {""} Else {$fields[1]}
        ID = $fields[2]
        State = $fields[3]
        IdleTime = $fields[4]
        LogonTime = "$($fields[5]) $($fields[6])"
    }
};

$directoryPath = 'C:\task-schedules\pwll-session-disconection';
$listOfRestricted = Get-Content -Path "$($directoryPath)/restricted.txt";

Write-Output ">>> Inicio >> $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') " | Out-File -Append "$($directoryPath)/logs.txt";

foreach ($session in $sessions) {
    # Si el Estado de la Sesión No es Desconectado, no hacer nada.
    if(!($session.State -eq "Disc")){continue};
    # Si la Sesión es uno de los restringidos, no hacer nada.
    if ($listOfRestricted -contains $session.UserName) {continue;}
    # Elimiando la sesión por ID.
    $closedSession = logoff $session.ID
    
    Write-Output "> $($session.UserName) - desconectado" | Out-File -Append "$($directoryPath)/logs.txt";
}

Write-Output ">>> Fin >> $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File -Append "$($directoryPath)/logs.txt";
