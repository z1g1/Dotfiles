; Hotstrings

::aadmin::administrator

::addr::
(
9295 Tower Side Dr
Fairfax VA 22031
)

::aws::AWS

::bbiz::business

::btw::by the way

::cuz::because

:*:ec2::EC2

:*:ec@::EC2

:*:EC@::EC2

::em1::mail@zackglick.com

::em2::zglicka@gmail.com

::govt::government

::gluck::Glick

::glick::Glick

:*:iimg::<img src=""></img>

::im::I'm

::Ill::I'll

:*:llink::<a href=""></a>

::ip::IP

::mgmt::management

:*:mdlink::[]()

:*R:mdimg::![]()
; :*R: had to be used with mdimg to make sure that the ![ was sent

::nat::NAT

::pswd::password

::ppl::people

::persig::
(
Thank You,
Zack Glick
)

::prosig::
(
Thank You,
Zack Glick 
Security Services Engineer 
Amazon Web Services
)

::pubsig::
(
Sincerely,
Zack G
AWS Security
https://aws.amazon.com/security
)


::s3::S3

::S#::S3

::vpc::VPC

::vpcs::VPCs

::vpn::VPN

::vpns::VPNs

::zack::Zack

; Key Remaps

CapsLock::Ctrl

; Hotkey Macros

; Remap F1 to send the current date as yyyy/MM/dd
; Date help http://www.autohotkey.com/docs/commands/FormatTime.htm
F1::
FormatTime, TimeString, ,yyyy/MM/dd
IfWinActive Kanban.md - Notepad++
{
	Send {Home}
	Loop, 2 
		{
		Send, {Del}
		}
	Send, {Shift down}
	Send, {End}
	Send, {Shift up}
	Send, ^x
	Send, {Del}
	Send, ^{End}
	Send, {Enter}
	Send * %TimeString% 
	Send, {Space}
	Send, ^v
	Send, ^s
	Return 
}
IfWinNotActive Kanban.md - Notepad++
{
	Send %TimeString%
	Return 
}