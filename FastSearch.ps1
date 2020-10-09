$Source = @"
 
using System;
using System.Management.Automation;
namespace FastSearch
{
 
    public static class Search
    {
        public static object Find(PSObject[] collection, string column, string data)
        {
            foreach(PSObject item in collection)
            {
                if (item.Properties[column].Value.ToString() == data) { return item; }
            }
 
            return null;
        }
    }
}
"@
 
Add-Type -ReferencedAssemblies $Assem -TypeDefinition $Source -Language CSharp 

$StudentSection = Import-Csv -Path C:\TEMP\STUDENTS\StudentEnrollment.csv -Delimiter ';' | Group-Object -Property 'SIS ID'
$studentsDetails = (Import-Csv -Path C:\TEMP\STUDENTS\Student.csv).'SIS ID'

write-host Parallel -BackgroundColor DarkRed
write-host Starting Time: $(get-date )
Measure-Command -Expression {
    $studentsDetails[0..200] | foreach-object -parallel {
        $innerStudentSection = $using:StudentSection
        ([FastSearch.Search]::Find($innerStudentSection,"Name",$_)).Group
    } -throttlelimit 12
}
write-host End Time: $(get-date )


Write-Host Classic -BackgroundColor DarkRed
write-host Starting Time: $(get-date )
Measure-Command -Expression {
    foreach ($student in $studentsDetails[0..200]) {
        ([FastSearch.Search]::Find($StudentSection,"Name",$student)).Group
    }
}
write-host End Time: $(get-date )