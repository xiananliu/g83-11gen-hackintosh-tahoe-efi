// Pair with the four exact DSDT _PRW -> XPRW renames for RP03/RP04/RP05/RP08.
// RP03/RP04/RP05 are empty ports; RP08 hosts the Realtek SD reader. They
// appear in DarkWake reasons. macOS must not arm their GPIO wake sources.
// Other operating systems retain the firmware methods through these wrappers.
DefinitionBlock ("", "SSDT", 2, "G83FIX", "RPWAKE", 0x00000002)
{
    External (\_SB.PC00.RP03, DeviceObj)
    External (\_SB.PC00.RP04, DeviceObj)
    External (\_SB.PC00.RP05, DeviceObj)
    External (\_SB.PC00.RP03.XPRW, MethodObj)
    External (\_SB.PC00.RP04.XPRW, MethodObj)
    External (\_SB.PC00.RP05.XPRW, MethodObj)

    External (\_SB.PC00.RP08, DeviceObj)
    External (\_SB.PC00.RP08.XPRW, MethodObj)

    If (!_OSI ("Darwin"))
    {
        Scope (\_SB.PC00.RP03)
        {
            Method (_PRW, 0, NotSerialized)
            {
                Return (XPRW ())
            }
        }

        Scope (\_SB.PC00.RP04)
        {
            Method (_PRW, 0, NotSerialized)
            {
                Return (XPRW ())
            }
        }

        Scope (\_SB.PC00.RP05)
        {
            Method (_PRW, 0, NotSerialized)
            {
                Return (XPRW ())
            }
        }
        Scope (\_SB.PC00.RP08)
        {
            Method (_PRW, 0, NotSerialized)
            {
                Return (XPRW ())
            }
        }
    }
}
