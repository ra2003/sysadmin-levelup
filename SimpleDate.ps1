#Author: uniquegeek@gmail.com
#Purpose:  *** This script in progress ***
  # Given an input of a day of the week (ex. Monday), and military time (2330), 
  #    it calculates the which date is meant, as a proper System.DateTime object.
  # (To be used in another script for setting scheduled tasks, such as "Schedule-Restart <hostname> <dayofweek> <militaryhours>")
  # Day can be "Monday" or "Tuesday", etc., or "today".
  # Hours input as "0400", "1300", "2330" etc.
  #Since it is dependent on day of week, it can be run within the next 6 days only.
        #i.e. if today is Friday and you type Friday, it will run it today.

#Input: *** in progress ***
  #creating staticly with no passed vars first

#Output: Output of created System.DateTime object

function SimpleDate {
#======= Input (creating staticly with no passed vars first) =======
#TODO: Make these variables as passed-in parameters
#user-input day of week:
$dow_i = "Saturday" 
$dow_i = $dow_i.ToLower()
$time_i = "2320"

#get user-input hours, minutes
$time_ih = $time_i.Substring(0,2)
$time_im = $time_i.Substring(2,2)

#======= Validate Input, then calculate Date & Time to use =======
#TODO: add error checking for scheduling for today's day for a time that is already passed

$dowvalidate = ($dow_i -eq ("monday" -or "tuesday" -or "wednesday" -or "thursday" -or "friday" -or "saturday" -or "sunday" -or "today"))
$timevalidate = (($time_i -is [int]) -and ($time_i.Length -eq "4") -and ($time_i -ge "0000") -and ($time_i -lt "2400"))
$validate = $dowvalidate -and $timevalidate

if ($validate -eq "false") {
    Write-Host "You must fully type the name of the day or use 'today', and type the time in military hours (0000-2359)"
        Write-Host "Example: Saturday 2330"
} else {
#Get a System.DateTime object
#set restart date = today, and increase restart date until the day of of week matches the input date
#  (You can also cast a string object into System.DateTime with [DateTime] but I don't want to.)
    $rdate = $today = Get-Date
    #translate "today" into a day of the week 
    if ($dow_i -eq $today) { $dow_i = $today.DayOfWeek }
    while ($rdate.DayOfWeek -ne $dow_i) {
        $rdate = $rdate.AddDays(1)
    }      
    #correct time of System.DateTime object to 0:00.00.000
    $rdate = $rdate.AddHours(-$rdate.Hour)
    $rdate = $rdate.AddMinutes(-$rdate.Minute)
    $rdate = $rdate.AddSeconds(-$rdate.Second)
    $rdate = $rdate.AddMilliseconds(-$rdate.Millisecond)
    
    #add input time
    $rdate = $rdate.AddHours($time_ih)
    $rdate = $rdate.AddMinutes($time_im)

    Write-Host "Input day $dow_i, input time $time_i "
    Write-Host "Calculated date $rdate "

}

}
SimpleDate
