<#
    Basics of Programming
    Written by James McAfee
    Version: 1.0 - March 12th, 2018
#>


# Example Variables
[int]$varInt = 1
Write-Host "int: " $varInt

[decimal]$varDecimal = 1.2
Write-Host "decimal: " $varDecimal

[bool]$varBool = $false
Write-Host "bool: " $varBool

[char]$varChar = 'a'
Write-Host "char: " $varChar

[string]$varString = 'string!'
Write-Host "string: " $varString

[array]$varArray = "monday", "tuesday", "wednesday"
Write-Host "array: " $varArray

[HashTable]$varHashTable = @{
    "cat" = "feline"
    "dog" = "canine"
}
Write-Host "hash table cat type: " $varHashTable["cat"]

# Arithmetic Examples
Write-Host "1+2 =" [int](1+2)
Write-Host "1-2 =" [int](1-2)
write-host "1/2 =" [decimal](1/2)

[int]$incremented = 1
$incremented++
write-host "1 incremented by 1 =" $incremented

[int]$incrementedByFive = 1
$incrementedByFive += 5
write-host "1 incremented by 5 =" $incrementedByFive

[int]$decremented = 1
$decremented--
write-host "1 decremented by 1 =" $decremented

# Example control flow

for ($forI = 0; $forI -le 2; $forI++) {
    write-host "for loop 'i' =" $forI
}

$whileI = 0
while ($whileI -le 2) {
    write-host "while loop 'i' =" $whileI
    $whileI++
}

$ifBool = $true
if ($ifBool -eq $true) {
    write-host "ifBool = true"
} elseif ($ifBool-eq $false) {
    write-host "ifBool = false"
} else {
    Write-Host "ifBool is undefined!"
}

$switchVar = 'b'
switch($switchVar) {
    a { write-host "switchVar = a" }
    b { write-host "switchVar = b" }
    c { write-host "switchVar = c" }
}

function printSomething {
    Write-Host "Something! printed by printSomething"
}
printSomething

function printVariableThings {
    param( [int]$numThings )
    for ($i = 0; $i -le $numThings; $i++) {
        Write-Host "thing printed by printVariableThings"
    }
}

printVariableThings(2)
