// Dynabook firmware declares a control-method power button in FADT.
// EC _Q10 notifies \_SB.PWRB, but the original PWRB device has no _PRW.
// The EC _GPE was verified as 0x6E on this machine.
// Add only the missing Darwin wake declaration. No GPIO/MMIO writes.
DefinitionBlock ("", "SSDT", 2, "G83FIX", "PWRWAKE", 0x00000001)
{
    External (\_SB.PWRB, DeviceObj)

    If (_OSI ("Darwin"))
    {
        Scope (\_SB.PWRB)
        {
            Method (_PRW, 0, NotSerialized)
            {
                Return (Package (0x02)
                {
                    0x6E,
                    0x03
                })
            }
        }
    }
}
