'//// UTILITY FUNCTIONS /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Type Utility
    Function Clamp:Int(valueToClamp:Int, minValue:Int, maxValue:Int)
        If valueToClamp < minValue Then
            Return minValue
        ElseIf valueToClamp > maxValue Then
            Return maxValue
        EndIf
        Return valueToClamp
    EndFunction
EndType