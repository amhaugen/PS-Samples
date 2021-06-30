<#
    Convert an integer value to Roman Numerals.
    Convert Roman Numerals to an Integer.    

    Bare-nuts and no frills. Very little in the form of input validation. This was mearly an excercise to keep the creative juices moving. There are probably way more efficient
    and elegant ways to accomplish this. 

    Basic Rules:
    Largest contigious string = 3 (III = OK, IIII = Not OK)
    Only one symbol of lower value preceeding a higher value. (IX = OK, IIX = Not OK)

    Helpful tips: Instead of attempting to do logic for the subtracting etc. Simply include the symbol combinations into the array.
    Use an array instead of a orderd dict or even hastable. The latter two types were very difficult to work with when I needed to walk backward through the collection.

    Reference for doing psuedo overloading of a function in powershell: https://codepyre.com/2012/08/ad-hoc-polymorphism-in-powershell/

    Change Log
    2021-06-30 - v1.0 - amh - Initial creation.
#>


function Convert-Roman
{
    [CmdletBinding()]
    param (
        [Parameter(Position=0,Mandatory=$true,ParameterSetName="RomanToInteger")]
        [String]
        $RomanNumeral,
        [Parameter(Position=0,Mandatory=$true,ParameterSetName="IntegerToRoman")]
        [Int]
        $Integer
    )
    
    $arrRoman = @(  
    ,(1,"I")    #0
    ,(4,"IV")   #1
    ,(5,"V")    #2
    ,(9,"IX")   #3
    ,(10,"X")   #4
    ,(40,"XL")  #5
    ,(50,"L")   #6
    ,(90,"XC")  #7
    ,(100,"C")  #8
    ,(400,"CD") #9
    ,(500,"D")  #10
    ,(900,"CM") #11
    ,(1000,"M") #12
)
    
    switch ($PSCmdlet.ParameterSetName) {
        "IntegerToRoman" 
        {  
            $tempNum = $Integer
            $r = '';        #String of Roman Symbols
            $i=0;           #Index numnber, used to reference the index value for te collection as we iterate.
            $ti = 0;        #TempIndex used when walking back
            $LoopLimit=500; #Safety feature to limit a runaway condition from looping forever.
            $LoopCount=0;   #Keeps track of how many loops are actually performed.
            $KeepGoing=$True;   #Tells the loop we are happy and need to be done.
            while ($KeepGoing -and ($LoopCount -lt $LoopLimit))
            {
                #Not needed# $i = $i % ($arrRoman.Count) #Out of range safety...since we just keep looping.
                
                #"Looking at Index [$i]: Integer Value = $($arrRoman.Item($i)[0])   Roman Symbol = $($arrRoman.Item($i)[1]) "
                                              
                #Is the number we are looking for already in the arry...lesser than or bigger than...
                if ($arrRoman.Item($i)[0] -eq $tempNum) 
                {
                    $r= $r + $arrRoman.Item($i)[1];   #Set the roman number.
                    $KeepGoing=$False           #Stop the loop
                }
                else
                {
                    <#Not an exact match - so lets look to see if we are below or above the vlue...#>
                    if ($arrRoman.Item($i)[0] -le $tempNum)
                    {
                        #Are we at the end of the range and not found a matching value yet
                        if ($i -eq $($arrRoman.Count - 1))
                        {
                            #"Smaller - but end of Range"
                            $r= $r + $arrRoman.Item($i)[1];     #Set the roman number.
                            $tempNum = $tempNum - $arrRoman.Item($i)[0]; #Subtract the amount we need to find
                            $i = 0;                    
                            $KeepGoing=$True           #Not needed but let's us know the intent of this part.
                        }
                        else 
                        {
                            #"Smaller"
                            $i++;
                            $KeepGoing=$True           #Not needed but let's us know the intent of this part.    
                        }
                    }
                    else
                    {
                        #"Bigger - What's the previous item?"
                        $ti = $i-1; #Store the index# of the previous item.
                        #"Index [$ti]: Integer Value = $($arrRoman.Item($ti)[0])   Roman Symbol = $($arrRoman.Item($ti)[1]) "

                        $r = $r + $arrRoman.Item($ti)[1]; #Store the previous roman numeral so we can iteravly add to it.
                        $tempNum = $tempNum - $arrRoman.Item($ti)[0]; #Store the remaining integer value that need to get found on subsiquent iterations.
                        $i = 0; #Set back to zero so we can find the next roman values by looping again, this time with the newly calculated integer value.
                        $KeepGoing=$True           #Not needed but let's us know the intent of this part.
                    }


                }

                $LoopCount++;   #Must be the last operation of the loop and must be able to fire each time the loop is iterated.
            }

            "Best guess for $Integer is $r"
            

        }
        "RomanToInteger" 
        { 
            <# Find the numerical value #>

            <#Go backwards through the string.#>
            $CalculatedVaule = 0;
            $CurrentValue = 0;
            $PreviousValue = 0;
            $SubtractCount = 0; #How many time have we subtracted?

            #iterate the string in reverse...
            for ($i=$RomanNumeral.Length-1; $i -ge 0; $i--)
            {
                ##$CurrentValue = $htGetNumber[$inputString.Substring($i,1)];

                foreach($item in $arrRoman)
                {
                    if ($RomanNumeral.Substring($i,1) -eq $item[1] ) 
                    {
                        $CurrentValue=$item[0];
                        break;
                    }
                }

                #write-host "Position number $i   Roman $($inputString.Substring($i,1))  Numerical Value $CurrentValue  Number of subtractions $SubtractCount"


                if ($PreviousValue -gt $CurrentValue)
                {
                    <#Validation error - Are we subtracting unneccesarily e.g. 50 from 100?#>
                    if(($PreviousValue -gt 0) -and ($CurrentValue -gt 0))
                    {
                        if (($PreviousValue - $CurrentValue) -eq $PreviousValue ) { Write-Error "ERROR: $RomanNumeral is not valid (2)." -ErrorAction stop }
                    }
                            
                    #$CalculatedVaule -= $ht[$inputString.Substring($i,1)];
                    foreach($item in $arrRoman)
                    {
                        if ($RomanNumeral.Substring($i,1) -eq $item[1] ) 
                        {
                            $CalculatedVaule -= $item[0];
                            break;
                        }
                    }

                    $SubtractCount += 1;

                    <#Validation error - Have we subtracted already? #>
                    #if ($SubtractFlag) { Write-Error "ERROR: $inputString is not valid (1)." -ErrorAction stop }
                }
                else 
                {
                    #$CalculatedVaule += $ht[$inputString.Substring($i,1)];
                    foreach($item in $arrRoman)
                    {
                        if ($RomanNumeral.Substring($i,1) -eq $item[1] ) 
                        {
                            $CalculatedVaule += $item[0];
                            break;
                        }
                    }
                }

                <#Last op in the loop to record the valuse for comparison on the next go-around#>
                $PreviousValue = $CurrentValue;
            }

            write-host "Best guess for $RomanNumeral is $CalculatedVaule"
        }
    }
}

#Convert-Roman -RomanNumeral 'x'
#Convert-Roman -Integer 12
#Convert-Roman "V"
#Convert-Roman 1001
#Convert-Roman 2000

