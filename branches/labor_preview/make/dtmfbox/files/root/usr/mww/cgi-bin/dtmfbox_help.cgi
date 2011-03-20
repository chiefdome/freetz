#!/bin/sh

# Change to fullscreen under Freetz
cat << EOF
<script>
if(document.location.href.indexOf('pkgconf.cgi?') >= 0) {
	window.open('dtmfbox.cgi?page=help');
	document.location.href = '$MAIN_CGI&page=status';
}
</script>
EOF

[ "$HELPPAGE" = "" ] && HELPPAGE="vorwort";
MAIN_CGI="dtmfbox.cgi?pkg=dtmfbox"

#
# Basiseinstellungen
#
if [ "$HELPPAGE" = "basiseinstellungen" ]; then
echo '<a name="basiseinstellungen" href="#basiseinstellungen"></a>'
show_title "Basiseinstellungen"
cat << EOF
Unter <a href="$MAIN_CGI&page=dtmfbox_cfg" target="_new">Basiseinstellungen</a> wird die Datei <i>dtmfbox.cfg</i> bearbeitet.<br><br>
Diese stellt die Grundkonfiguration des Programms dar. Standardm��ig ist die Datei so eingerichtet, <br>
dass nur wenige �nderungen vorgenommen werden m�ssen, wie z.B. die Einrichtung von <a href="$MAIN_CGI&page=help&help=accounts">Accounts</a>.<br><br>

Der Aufbau ist in <font class='code'>[Bereiche]</font> unterteilt.<br><br>

Im Text-Editor werden Kommentare mit Doppel-Slashes gekennzeichnet (<font class='code'>// Kommentar</font>). Siehe auch <a href="$MAIN_CGI&page=help&help=webinterface">hier</a>.<br>
<br>
EOF
fi

#
# Vorwort
#
if [ "$HELPPAGE" = "vorwort" ]; then
echo '<a name="vorwort" href="#vorwort"></a>'
show_title "Vorwort"
cat << EOF
	Die dtmfbox ist eine Softswitch Applikation, welche folgende Features unterst�tzt:<br>
	<ul>
	<li>SIP und CAPI</li>
	<li>Registrar-Modus f�r die Anbindung von SIP-Clients (VoIP-Gateway)</li>
	<li>Soundkartenunterst�tzung / Telefonie �ber Headset, bzw. Null-Audio</li>
	<li>STUN und ICE</li>
	<li>VAD und Echo Canceller</li>
	<li>Mixer</li>
	<li>Diverse Codecs</li>
	<li>Bei Telefonie-Ereignissen kann ein Skript und/oder ein Plugin aufgerufen werden</li>
	<li>Telefonie-Befehle lassen sich �ber die Kommandozeile, per Skript oder �ber eine Funktion ausf�hren</li>
	</ul>
	Ohne Skripte und Plugins l�sst sich die dtmfbox rein als CAPI-/SIP-Phone nutzen.
	Dabei wird der Rufaufbau entweder �ber den angebundenen SIP-Client ausgel�st (Registrar-Mode), bzw. manuell von der Konsole ausgef�hrt (<font class='code'>dtmfbox 0 -call ...</font>).
	<br><br>

	Mithife von Shell-Skripten und Plugins l�sst sich jedoch der Funktionsumfang erweitern.<br>
	Es bietet sich die M�glichkeit, automatisierte Steuerungen durchzuf�hren, wie z.B.:<br>
	<ul>
	<li>ein Gespr�ch automatisch annehmen, aufzeichnen und eine Wave-Datei abspielen (Anrufbeantworter)
	<li>ein weiteres Gespr�ch aufbauen und mit dem bestehenden Gespr�ch "verbinden" (Callthrough)
	<li>nach dem Auflegen einer bestimmten Nummer, einen R�ckruf veranlassen (Callback)
	<li>Benutzerdefinierte (Sprach-)Men�s (libmenu.plugin.so)
	<li>usw...
	</ul>
	Die <a href="$MAIN_CGI&page=help&help=ereignisse" target="_new">Telefonie-Ereignisse</a> werden als Parameter an die Skripte und Plugins �bergeben.<br>
	Die <a href="$MAIN_CGI&page=help&help=befehle" target="_new">Telefonie-Befehle</a> lassen sich �ber die Kommandozeile oder �ber eine Funktion aufrufen.
	<br><br>

	Das Webinterface der dtmfbox besteht aus einem Plugin und mehreren Skripten:<br><br>
	<i>libmenu.plugin.so</i> dient dazu, eine komfortable Men�schnittstelle zu bieten, welche sich �ber die Datei <a href="$MAIN_CGI&page=menu_cfg" target="_new">menu.cfg</a> anpassen l�sst.
	In dieser Konfiguration wird das <a href="$MAIN_CGI&page=help&help=menu_start" target="_new">Men�</a> festgelegt.
	Zudem lassen sich <a href="$MAIN_CGI&page=help&help=menu_action">Aktionen</a> (<a href="$MAIN_CGI&page=help&help=ereignisse">Ereignisse</a>) hinterlegen.
	<br><br>

	Im Standard gibt es folgende Funktionen:
	<ul>
		<li><b>Anrufbeantworter</b></li>
		    <i>Ansage/Endansage, Aufnahme-/Ansagemodus, Mailversand/FTP-Streaming, Schedule</i>
		</li><p></p>

		<li><b>Anrufbeantworter Fernabfrage und interne Abfrage</b><br>
		    <i>Aufnahmen Abspielen, Aufnahmen l�schen, Ansagen aufnehmen, AB aktivieren/deaktivieren</i>
		</li><p></p>

		<li><b>DTMF-Befehle</b><br>
		    <i>Men�-Tasten mit Shellskripten belegen</i>
		</li><p></p>

		<li><b>Callback & Callthrough</b><br>
		    <i>Callback/Callthrough-Regeln per Regular Expression. Weiterleitung zum Callthrough-Men�...</i>
		</li><p></p>

		<li><b>Sonstiges</b><br>
		    <i>Fritz!Box Infos, Wettervorhersage (Podcast), Web-Radio, CheckMailD abfragen</i>
		</li>
	</ul>
	Das Men� ist hierarchisch aufgebaut (siehe <a href="$MAIN_CGI&page=help&help=menu_start" target="_new">hier</a>).
	<a href="$MAIN_CGI&page=menu_cfg" target="_new">Men�</a> und <a href="$MAIN_CGI&page=scripts" target="_new">Skripte</a> lassen sich nach belieben erweitern und bearbeiten.<br><br>

	Einstellungen werden bei der Standalone-Version in der <i>/var/flash/debug.cfg</i> gespeichert (komprimiert). <br>
	Bei der USB-Version wird nur ein Start-Skript in die <i>/var/flash/debug.cfg</i> geschrieben.<br>
	Bei der Apache-Installation werden die Daten unkomprimiert, unter <i>/usr/bin/dtmfbox-apache</i> abgelegt.<br><br>

	<b>License:</b>
<ul>
<pre class='code' style='width:550px'>
 dtmfbox Copyright (c) 2006-2009 Marco Zissen (maz@v3v.de)

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
</pre>
</ul>
EOF
fi


#
# Getting started...
#
if [ "$HELPPAGE" = "getting_started" ]; then
echo '<a name="getting_started" href="#getting_started"></a>'
show_title "Getting started..."
cat << EOF
<ul>
	<table border="0" width="300">
	<tr><td width="200">1.) <a href="$MAIN_CGI&page=help&help=accounts">Account(s) einrichten</a></td><td>(<a href="$MAIN_CGI&page=dtmfbox_cfg" target="_new">dtmfbox.cfg</a>)</tr>
	<tr><td width="200">2.) <a href="$MAIN_CGI&page=help&help=internes_menu">Interne Men�s zuweisen</a></td><td>(<a href="$MAIN_CGI&page=dtmfbox_cfg" target="_new">dtmfbox.cfg</a>)</tr>
	<tr><td width="200">3.) <a href="$MAIN_CGI&page=help&help=skripteinstellungen">Skripteinstellungen</a></td><td>(<a href="$MAIN_CGI&page=script_cfg" target="_new">script.cfg</a>)</tr>
	<tr><td width="200">4.) <a href="$MAIN_CGI&page=help&help=status">dtmfbox starten</a></td><td>(<a href="$MAIN_CGI&page=status" target="_new">Status</a>)</tr>
	</table>
</ul>
EOF
fi

#
# Status
#
if [ "$HELPPAGE" = "status" ]; then
echo '<a name="status" href="#status"></a>'
show_title "Status"
cat << EOF
Auf der <a href="$MAIN_CGI&page=status" target="_new">Statusseite</a> befindet sich der aktuelle Dienste-Status der dtmfbox.<br><br>
Hier kann die dtmfbox manuell gestartet und gestoppt werden.<br>
Zus�tzlich kann die Programmausgabe mitgeloggt werden.<br><br>

Die Befehle f�r die Konsole sehen folgenderma�en aus:
<pre class='code'>
rc.dtmfbox start|stop|restart	# starten, stoppen, neu starten.
rc.dtmfbox foreground		# im Vordergrund starten, mit Skriptausgaben, f�r Tests.
rc.dtmfbox log			# geloggt starten, ohne Skriptausgaben.
</pre>

Ist die dtmfbox gestartet, werden alle Accounts (mit Registrierungsstatus), alle aktuellen Verbindungen und alle angemeldeten Clients angezeigt.
Falls Nachrichten auf den Anrufbeantworter vorhanden sein sollten, werden diese ebenfalls auf der Seite "<a href='$MAIN_CGI&page=status' target='_new'>Status</a>" angezeigt.
<br><br>

<i>Hinweis:</i><br>
echo-Ausgaben in Skripten erscheinen nicht im Log!<br>
Skriptausgaben werden angezeigt, wenn die dtmfbox im Vordergrund gestartet wird: <font class='code'>./rc.dtmfbox foreground</font>
EOF
fi


#
# Accounts einrichten
#
if [ "$HELPPAGE" = "accounts" ]; then
echo '<a name="accounts" href="#accounts"></a>'
show_title "Accounts einrichten"
cat << EOF
	Grundvorraussetzung ist das Einrichten von Accounts.<br><br>
	Unter <a href="$MAIN_CGI&page=dtmfbox_cfg" target="_new">Basiseinstellungen</a> k�nnen bis zu 10 Accounts eingerichtet werden.
	Die Bereiche fangen bei <font class='code'>[acc1]</font> an und h�ren bei  <font class='code'>[acc10]</font> auf.<br>
	Einzelne Accounts k�nnen mittels <font class='code'>'active='</font> aktiviert (<font class='code'>1</font>), bzw. deaktiviert (<font class='code'>0</font>) werden.
	<p>
	Es gibt vier Arten, Accounts einzurichten:
	<ul>
		<a name="m1" href="#m1"></a>
		<li><b>ISDN/Analog (�ber CAPI)</b><p></p>

		Bei ISDN ist dies die optimale Wahl. Bei Analog gibt es gewisse Einschr�nkungen (siehe unten).<br><br>

<i>Beispiel (ISDN):</i><br>
<pre class='code'>
[acc1]
active=1				// 1=aktiviert, 0=deaktiviert
name=ISDN1				// Name (beliebig)
number=1234567				// Rufnummer (MSN ohne Vorwahl!)
type=capi				// Account-Typ (type=capi)
capi_controller_out=1			// Standardcontroller f�r ausgehende Verbindungen
</pre>

<i>Beispiel (Analog):</i><br>
<pre class='code'>
[acc1]
active=1				// 1=aktiviert, 0=deaktiviert
name=1234567				// Name (Anschlussnummer ohne Vorwahl!)
number=unknown				// Rufnummer (unknown)
type=capi				// Account-Typ (type=capi)
capi_controller_out=4			// Standardcontroller f�r ausgehende Verbindungen
</pre>
		Bei Analog wie auch ISDN wird die Nummer immer OHNE VORWAHL angegeben!<br>
		Bei ISDN darf der <font class='code'>name=</font> beliebig sein und <font class='code'>number=</font> muss der MSN entsprechen.<br>
		Bei Analog muss <font class='code'>number=</font> auf <font class='code'>'unknown'</font> gestellt werden. Die Anschlussnummer wird unter <font class='code'>name=</font> festgelegt.<br>
		<font class='code'>capi_controller_out=</font> ist der Standardcontroller, der f�r ausgehende Verbindungen verwendet wird (ISDN=1, Analog=4).<br><br>

		Die Accounts stehen unter <a href="$MAIN_CGI&page=status" target="_new">Status</a> solange auf "Pending", bis ein Anruf eingeht, bzw. ein Anruf durchgef�hrt wird.<br><br>

		<i>Einschr�nkungen Analog:</i><br>
		Da der POTS-Anschluss der FritzBox nicht wie der S0-Bus arbeitet, werden nur eingehende Gespr�che erkannt, aber keine Ausgehenden.<br>
		Dies bedeutet, dass man das Men� nicht intern, �ber eine Kurzwahl, erreichen kann. <br>
		Um dennoch das Men� abzuh�ren, k�nnen Analog-Telefone �ber SIP-Registrar angebunden werden:
		</li><p></p>

		<a name="m2" href="#m2"></a>
		<li><b>ISDN/Analog (�ber SIP-Registrar)</b><p></p>
		Analog/ISDN-Telefone k�nnen optional �ber SIP angemeldet werden.<br>
		Dazu muss der Registrar-Modus der dtmfbox aktiviert und die Anmeldedaten des Clients hinterlegt werden:<p></p>

<i>Beispiel (Analog):</i><br>
<pre class='code'>
[voip]
voip=1					// VoIP aktivieren!
voip_registrar=1			// Registrar-Modus an!
voip_max_clients=4			// Anzahl der Clients, die sich anmelden d�rfen
voip_realm=fritz.box			// Realm f�r den Registrar
voip_udp_port=5061			// Port, f�r SIP
voip_rtp_start=4000			// Start-Port, f�r RTP/RTCP
<a href="$MAIN_CGI&page=help&help=basiseinstellungen">// ...			 		// siehe auch Basiseinstellungen</a>

[acc1]
active=1				// Analog-Account
name=1234567
number=unknown
type=capi
capi_controller_out=4
registrar_active=1			// Aktiviert die Anmeldung an die dtmfbox
registrar_user=1234567			// Username
registrar_pass=secret			// Passwort
</pre>

		Im AVM-WebIf wird nun ein Internettelefonie-Account angelegt.<br>
		In diesem Beispiel w�rde man als Registrar "127.0.0.1:5061" oder "fritz.box:5061" angeben mit dem Usernamen "1234567" und dem Passwort "secret".<br><br>
		Bei erfolgreicher Anmeldung wird der Client unter <a href="$MAIN_CGI&page=status" target="_new">Status</a> angezeigt.<br>
		</li><p></p>

		<a name="m3" href="#m3"></a>
		<li><b>VoIP (�ber CAPI)</b><p></p>
		Um die bereits registrierten Internettelefonie-Accounts des voipd zu verwenden, kann man diese ebenfalls �ber CAPI registrieren.<br>
		Hierbei ist wichtig, welche Position der Internettelefonie-Account in der Liste hat (AVM-WebIf).<p></p>

<i>Beispiel (1. Internettelefonie-Account):</i><br>
<pre class='code'>
[acc1]
active=1				// 1=aktiviert, 0=deaktiviert
name=1234567				// Beliebiger Name
number=0#1234567			// 0# = Erster Account, 1234567=Internetrufnummer
type=capi				// type=capi
capi_controller_out=5			// Standardcontroller f�r ausgehende Verbindungen
</pre>

<i>Beispiel (4. Internettelefonie-Account):</i><br>
<pre class='code'>
[acc1]
active=1				// 1=aktiviert, 0=deaktiviert
name=7654321				// Beliebiger Name
number=3#7654321			// 3# = Vierter Account, 7654321=Internetrufnummer
type=capi				// type=capi
capi_controller_out=5			// Standardcontroller f�r ausgehende Verbindungen
</pre>
		</li><p></p>

		<a name="m4" href="#m4"></a>
		<li><b>VoIP (�ber SIP)</b><p></p>
		Um SIP-Accounts direkt �ber die dtmfbox zu registrieren, m�ssen die Provider-Daten des Registrars eingetragen werden<p></p>

<i>Beispiel (SIP-Account):</i><br>
<pre class='code'>
[voip]
<a href="$MAIN_CGI&page=help&help=basiseinstellungen">// ...	 				// siehe Basiseinstellungen</a>

[acc1]
active=1				// 1=aktiviert, 0=deaktiviert
name=SIP Account			// Beliebiger Name (wird als Display-Name verwendet)
number=1234567  			// Internetrufnummer
type=voip				// type=voip

voip_registrar=sip.registrar.de	// Registrar-Server
voip_realm=registrar.de		// SIP-Realm (* f�r automatische Suche)
voip_user=MeinUsername			// Username
voip_pass=MeinPasswort			// Passwort
voip_do_not_register=0			// 1=Keine Registrierung, 0=Registrieren
voip_id=				// Optional: SIP-ID (MeinUsername@sip.registrar.de)
voip_proxy=				// Optional: Proxy
voip_contact=				// Optional: SIP-Contact
</pre>

		Manchmal wird f�r die Registrierung ein STUN-Server ben�tigt. Bei NAT-Problemen ist manchmal auch die Aktivierung von ICE n�tig (z.B. One-Way Audio).
		N�heres siehe auch <a href="$MAIN_CGI&page=help&help=basiseinstellungen">Basiseinstellungen</a>.<br><br>
		Provider-Beispiele:<p></p>

<i>Beispiel (1&1):</i><br>
<pre class='code'>
[voip]
<a href="$MAIN_CGI&page=help&help=basiseinstellungen">// ...	 				// siehe Basiseinstellungen</a>
voip_stun=stun.1und1.de
voip_stun_port=3478
voip_ice=1

[acc1]
active=1				// 1=aktiviert, 0=deaktiviert
name=49123456789			// Beliebiger Name (wird als Display-Name verwendet)
number=49123456789  			// Internetrufnummer
type=voip				// type=voip

voip_registrar=sip.1und1.de		// Registrar-Server (oder IP direkt: 212.227.15.197)
voip_realm=1und1.de			// SIP-Realm (* f�r automatische Suche)
voip_user=49123456789			// Username
voip_pass=MeinPasswort			// Passwort
voip_do_not_register=0			// 1=Keine Registrierung, 0=Registrieren
voip_id=49123456789@1und1.de		// Optional: SIP-ID (MeinUsername@sip.registrar.de)
voip_proxy=				// Optional: Proxy
voip_contact=				// Optional: SIP-Contact
</pre>

<i>Beispiel (Sipgate):</i><br>
<pre class='code'>
[voip]
<a href="$MAIN_CGI&page=help&help=basiseinstellungen">// ...	 				// siehe Basiseinstellungen</a>
voip_stun=stun.1und1.de
voip_stun_port=3478
voip_ice=1

[acc1]
active=1				// 1=aktiviert, 0=deaktiviert
name=49123456789			// Beliebiger Name (wird als Display-Name verwendet)
number=49123456789  			// Internetrufnummer
type=voip				// type=voip

voip_registrar=sipgate.de		// Registrar-Server
voip_realm=sipgate.de			// SIP-Realm (* f�r automatische Suche)
voip_user=55112233			// Username
voip_pass=MeinPasswort			// Passwort
voip_do_not_register=0			// 1=Keine Registrierung, 0=Registrieren
voip_id=55112233@sipgate.de		// Optional: SIP-ID (MeinUsername@sip.registrar.de)
voip_proxy=				// Optional: Proxy
voip_contact=				// Optional: SIP-Contact
</pre>
		</li>
	</ul>
EOF
fi

#
# Kurzwahlen einrichten
#
if [ "$HELPPAGE" = "internes_menu" ]; then
echo '<a name="internes_menu" href="#internes_menu"></a>'
show_title "Kurzwahlen einrichten"
cat << EOF
Das Men� kann �ber Kurzwahlen erreicht werden.<br>
Dies gilt f�r ISDN-Accounts, wie auch Accounts, welche �ber den Registrar-Modus angebunden sind (SIP-Clients angemeldet an dtmfbox).<br><br>

Damit das Telefon auf die Kurzwahl reagiert, m�ssen zwei Eintr�ge unter <font class='code'>[accX]</font> eingef�gt werden:<br><br>

<i>Beispiel:</i><br>
<pre class='code'>
[acc1]
<a href="$MAIN_CGI&page=help&help=accounts">// ...	 					// siehe Accounts</a>
menu_keycode=*800				// Kurzwahl (hier *800)
menu_entry=menu:main				// Men�-Einstiegspunkt (menu:main ist das Hauptmen�)
</pre>

Von Au�erhalb kann das Men� �ber den Anrufbeantworter, bzw. �ber Callback/Callthrough erreicht werden.<br><br>

<i>Hinweis:</i><p>
Es kann vorkommen, dass das Telefon nicht auf die Kurzwahl reagiert. Dies kann mit verschiedenen Dingen zusammenh�ngen (FW-Version, Telefone, usw.).<p>

Man sollte zun�chst pr�fen, ob �berhaupt DTMF-Zeichen empfangen werden, wenn gew�hlt wird. Dies kann mithilfe des Logs festgestellt werden.<br>
Wenn abgenommen wird (Log: Hook up), aber kein Ton zu h�ren ist oder die Navigation per DTMF nicht m�glich sein sollte, liegt das oft an dem Format der Kurzwahl.<br>
<br>
Man sollte daher folgende Kurzwahlen durchprobieren:
<ul>
<li><font class='code'>800</font></li>
<li><font class='code'>*800</font></li>
<li><font class='code'>**800</font></li>
<li><font class='code'>**##800</font></li>
</ul>
800 ist nur ein Beispiel. Testweise sollte man auch andere Nummern verwenden.<p>

Falls immer noch kein Ton zu h�ren ist, bzw. die Navigation nicht funktioniert, kann man im AVM-WebIf unter Telefonieger�te\Festnetz eine zus�tzliche Rufnummer hinterlegen (in dem Fall die gew�nsche Kurzwahl, z.B. 800). Danach nochmal die oberen Kombinationen ausprobieren.<p>

Falls dieser Versuch ebenfalls scheitert, bleibt noch die M�glichkeit, die ISDN-Telefone per SIP-Registrar anzubinden (siehe auch <a href='http://fritz.box:6767/cgi-bin/dtmfbox.cgi?pkg=dtmfbox&page=help&help=accounts'>Accounts einrichten</a>).<br>
Die Kurzwahl darf in dem Fall aber kein # oder * enthalten! Beim ersten Internet-Telefonieaccount w�rde man <font class='code'>*121#800</a> w�hlen.
EOF

fi

#
# Das Men�
#
if [ "$HELPPAGE" = "menu_start" ]; then
show_title "Das Men�"
cat << EOF
In der dtmfbox-Standardkonfiguration ist ein vorgefertigtes Men� integriert, welches bei Bedarf ge�ndert werden kann.<br>
Das Men� kann �ber drei Wege erreicht werden:
<ul>
<li><b>Intern �ber die  Kurzwahl des Accounts</b><br>
Dies gilt f�r ISDN-Accounts, wie auch Accounts, welche �ber den Registrar-Modus angebunden sind (SIP-Clients angemeldet an dtmfbox). Das Einstiegsmen� kann unter <a href='$MAIN_CGI&page=dtmfbox_cfg' target='_new'>Basiseinstellungen</a> ge�ndert werden (Standardm��ig <font class='code'>[menu:main]</font>)</li><br>

<li><b>Extern �ber den Anrufbeantworter</b><br>
Sobald der Anrufbeantworter abhebt, wird der AB-Pin eingegeben. Das Einstiegsmen� ist <font class='code'>[menu:main]</font></li><br>

<li><b>Extern �ber Callback/Callthrough.</b><br>
Das Einstiegsmen� ist <font class='code'>[menu:callthrough_pin]</font></li><br>
</ul>

<b>Men�struktur:</b><br>
<pre class='code'>
Hauptmen�
|
|- 1 = Anrufbeantworter
|  |
|  |- X# = Nachricht X abh�ren
|  |- 0# = Einstellungen
|  |  |
|  |  |- 1 = Aktivieren / Deaktivieren
|  |  |- 2 = Aufnahmen l�schen
|  |  |  |
|  |  |  |- 1 = Alle Aufnahmen l�schen
|  |  |  |- * = Zur�ck
|  |  |
|  |  |- * = Zur�ck
|  |
|  |- * = Zur�ck
|
|- 2 = DTMF-Befehle
|  |
|  |- X = Eigene Befehle, Shellskripte, etc.
|  |- * = Zur�ck
|
|- 3 = Callthrough
|  |
|  |- 1234# = Pineingabe (Pin kann im Men� bearbeitet werden)
|  |     |
|  |     |- X# = Account 1-10 oder 0# f�r die Wahl �ber den internen S0 Bus
|  |        |
|  |        |- NUMMER#   = Nummer eingeben und w�hlen (#)
|  |        |- NUMMER*#  = Nummer eingeben und korrigieren (verw�hlt)
|  |        |- #         = Auflegen
|  |        |- *         = Zur�ck
|  |
|  |- * = Zur�ck
|
|- 4 = Sonstiges
   |
   |- 1 = Fritz!Box
   |  |
   |  |- 1 = IP-Adresse
   |  |- 2 = Letzter Reboot
   |  |- 3 = Uhrzeit
   |  |- * = Zur�ck
   |
   |- 2 = Wettervorhersage
   |  |
   |  |- 1 = Wetter-Podcast abspielen
   |  |- * = Zur�ck
   |
   |- 3 = Checkmaild
   |  |
   |  |- X = Mailanzahl von Checkmail-Account X (1-3) abfragen
   |  |- * = Zur�ck
   |
   |- 4 = Radio
      |
      |- X = Radiostream 1-9
      |- * = Zur�ck
</pre>

EOF
fi

#
# Men� bearbeiten
#
if [ "$HELPPAGE" = "menu" ]; then
show_title "Men� bearbeiten"
cat << EOF
Das Men� kann individuell bearbeitet werden.<br>
Es ist ebenfalls in <font class='code'>[Bereiche]</font> unterteilt, jedoch werden diese anders interpretiert.<br><br>

Es gibt vier Bereiche:
<ul>
	<li><a href="$MAIN_CGI&page=help&help=menu_menu"><b>[menu: ... ]</b></a><br>
	Stellt ein Men� dar.<br>
	Es k�nnen DTMF-Zeichen hinterlegt werden, welche ein Men� <font class='code'>[menu:]</font> , ein Skript <font class='code'>[script:]</font> oder eine Library-Funktion <font class='code'>[lib:] aufrufen.</font>
	</li><p></p>

	<li><a href="$MAIN_CGI&page=help&help=menu_script"><b>[script: ... ]</b></a><br>
	F�hrt ein Skript aus, wenn der Bereich aufgerufen wird.<br>
	Es kann ein Skript hinterlegt werden, welches ausgef�hrt werden soll (inkl. Parameter).
	</li><p></p>

	<li><a href="$MAIN_CGI&page=help&help=menu_lib"><b>[lib: ... ]</b></a><br>
	F�hrt eine Funktion in einer Library aus, wenn der Bereich aufgerufen wird.<br>
	Es kann eine Library und ein Funktionsname hinterlegt werden (inkl. Parameter).
	</li><p></p>

	<li><a href="$MAIN_CGI&page=help&help=menu_action"><b>[action: ... ]</b></a><br>
	F�hrt einen <font class='code'>[script:]</font> oder <font class='code'>[lib:]</font> Bereich aus, bei bestimmten Ereignissen.<br>
	Es werden die Ereignisse und ein <font class='code'>[script:]</font> oder <font class='code'>[lib:]</font> Bereich angegeben.
	</li><p></p>
</ul>

Alle Men�-, Skript- und Library-Bereiche m�ssen einen eindeutigen Namen besitzen.<br>
Der Name wird nach dem Doppelpunkt gesetzt. Z.B. <font class='code'>[menu:my_menu1], [script:my_script1]</font>, usw...<br><br>

Es k�nnen beim Aufruf der Bereiche auch Parameter �bergeben werden (bis zu 32):
<pre class='code'>
[menu:main]
say=Hauptmenue
1=script:myscript("Hallo", "Test")		     // "Hallo" und "Test" an Skript �bergeben
2=menu:zweites_menu("Hallo2")			     // "Hallo2" an Men� �bergeben

[menu:zweites_menu]
say=Zweites Menue
1=script:myscript("%\$1%", "Test2")		     // %\$1%="Hallo2" u. "Test2" an Skript �bergeben
*=menu:main

[script:myscript]				     // 1. und 2. Argument an Skript �bergeben
cmd=/var/script/myscript.sh(/var/script/myscript.sh, "%\$1%", "%\$2%")
</pre>
Die Parameter stehen dann als Argumente innerhalb des Bereiches zur Verf�gung (von <font class='code'>%\$1%</font> bis <font class='code'>%\$32%</font>)<br><br>

<a href='$MAIN_CGI&page=help&help=ereignisse'>Ereignisse</a> k�nnen ebenfalls als Parameter �bergeben werden.
EOF
fi

#
# [menu: ... ]
#
if [ "$HELPPAGE" = "menu_menu" ];
then
echo '<a name="menu_menu" href="#menu_menu"></a>'
show_title "[menu: ... ]"
cat << EOF
Ein <font class='code'>[menu:XYZ]</font> stellt einen Men�-Bereich dar. In dem Fall mit dem eindeutigen Namen XYZ.<br><br>

Ein Men� kann beliebig lang sein. Es k�nnen einzelne DTMF-Zeichen mit Untermen�s, Skripten und Library-Funktionen verkn�pft werden.
Ganze DTMF-Zeichenfolgen sind ebenfalls m�glich.<br><br>

<i>Beispiel (einzelne DTMF-Zeichen):</i>
<pre class='code'>
[menu:main]
say=1 Erstes Menue, 2 Zweites Menue
1=menu:menu_1
2=menu:menu_2

[menu:menu_1]
say=Menu 1. Zurueck mit *
*=menu:main

[menu:menu_2]
say=Menu 2. Zurueck mit *
*=menu:main
</pre>

<i>Beispiel (mehrere DTMF-Zeichen):</i>
<pre class='code'>
[menu:main]
say=101# Erstes Menue, 102# Zweites Menue
101#=menu:menu_1
102#=menu:menu_2

[menu:menu_1]
say=Menu 1. Zurueck mit *
*=menu:main

[menu:menu_2]
say=Menu 2. Zurueck mit *
*=menu:main
</pre>

Wird <font class='code'>say=</font> mit angegeben, wird das <font class='code'>text2speech=</font> Skript ausgef�hrt, welches unter den <a href="$MAIN_CGI&page=dtmfbox_cfg" target="_new">Basiseinstellungen</a> hinterlegt ist. <br>
Der angegebende Text wird auf das Telefon ausgegeben, solange <a href="http://espeak.sourceforge.net/" target="_new">eSpeak</a> verwendet wird (<a href="$MAIN_CGI&page=script_cfg" target="_new">Skripteinstellungen > <font class='code'>ESPEAK_INSTALLED=X</font></a>).
EOF
fi

#
# [script: ... ]
#
if [ "$HELPPAGE" = "menu_script" ];
then
echo '<a name="menu_script" href="#menu_script"></a>'
show_title "[script: ... ]"
cat << EOF
Ein <font class='code'>[script:XYZ]</font> stellt einen Skript-Bereich dar. In dem Fall mit dem eindeutigen Namen XYZ.<br><br>
Skripte k�nnen von Men�s <font class='code'>[menu:]</font> und Aktionen <font class='code'>[action:]</font> aufgerufen werden.
<br><br>
<i>Beispiel 1:</i>
<pre class='code'>
[menu:main]
say=1 Erste Skript Funktion, 2 Zweite Skript Funktion.
1=script:myscript(1)		// 1 �bergeben
2=script:myscript(2)		// 2 �bergeben

[script:myscript]
say=Skript %\$1% ausf�hren	// say "Skript X ausf�hren"
cmd=/var/dtmfbox/script/myscript1.sh(/var/dtmfbox/script/myscript1.sh, "%\$1%", "%src_id%")
</pre>
In dem obigen Beispiel wird zweimal das selbe Skript aufgerufen, jedoch mit unterschiedlichen Parametern (1 und 2). <br>
Zus�tzlich wird der Platzhalter <font class='code'>"%src_id%"</font> an das Skript <font class='code'>"myscript1.sh"</font> �bergeben.<br>
Im Skript stehen die Parameter dann als Argumente zur Verf�gung (\$1="1" oder "2" und \$2="%src_id%").<br><br>

Auch hier kann <font class='code'>say=</font> angegeben werden, um einen Text auszugeben.<br><br>

<i>Beispiel 2 (selbes Skript wie oben, nur dynamisch):</i>
<pre class='code'>
[menu:main]
say=Skript-Funktion aufrufen
#=script:myscript(%dtmf%)	// DTMF-Zeichen �bergeben

[script:myscript]
say=Skript %\$1% ausf�hren	// say "Skript X ausf�hren"
cmd=/var/dtmfbox/script/myscript1.sh(/var/dtmfbox/script/myscript1.sh, "%\$1%", "%src_id%")
</pre>
In dem obigen Beispiel wird ebenfalls das Skript aufgerufen, jedoch etwas dynamischer.<br>
Anstelle einzelne Skriptaufrufe f�r bestimmte Tasten festzulegen, wird beim Dr�cken der #-Taste der ganze DTMF-Buffer an das Skript �bergeben.
Solange # nicht eingegeben wurde, werden die DTMF-Zeichen "gesammelt".<br>
Wird z.B. <font class='code'>100#</font> eingegeben, so steht in <font class='code'>%dtmf%</font> ebenfalls <font class='code'>"100#"</font>. In <font class='code'>%data%</font> steht immer das letzte Zeichen, welches in dem Fall <font class='code'>"#"</font> w�re.
<br><br>
In <font class='code'>cmd=</font> wird das eigentliche Skript angegeben. Der Aufruf ist wie bei der Funktion 'execl' unter C.<br>
Die Skriptdatei wird vor der Klammer und als erster Parameter angegeben.
EOF
fi

#
# [lib: ... ]
#
if [ "$HELPPAGE" = "menu_lib" ];
then
echo '<a name="menu_lib" href="#menu_lib"></a>'
show_title "[lib: ... ]"
cat << EOF
Ein <font class='code'>[lib:XYZ]</font> stellt einen Library-Bereich dar. In dem Fall mit dem eindeutigen Namen XYZ.<br><br>

Libraries k�nnen von Men�s <font class='code'>[menu:]</font> und Aktionen <font class='code'>[action:]</font> aufgerufen werden.<br>
Hierbei wird gezielt eine Funktion in einer Library aufgerufen. Die Libraries m�ssen nicht zwingend als Plugin eingebunden werden.<br><br>

<i>Beispiel:</i>
<pre class='code'>
[menu:main]
1=lib:speak("Hallo 1")
2=lib:speak("Hallo 2")
3=lib:speak("Hallo 3")

[lib:speak]
library=/var/dtmfbox/menu.plugin.so
function=speak(%src_id%,"%\$1%")
</pre>
Es k�nnen char*-und integer-Datentypen �bergeben werden. Integer-Werte werden ohne Anf�hrungsstriche angegeben.<br>
In dem obigen Beispiel wird die Funktion "speak()" in der Library menu.plugin.so aufgerufen. Der erste Parameter ist ein Integer, der Zweite ein char*.
EOF

fi

#
# [action: ... ]
#
if [ "$HELPPAGE" = "menu_action" ];
then
echo '<a name="menu_action" href="#menu_action"></a>'
show_title "[action: ... ]"
cat << EOF
Ein <font class='code'>[action:XYZ]</font> stellt eine Aktion dar, die bei bestimmten Ereignissen ausgel�st wird. In dem Fall mit dem eindeutigen Namen XYZ.<br><br>
Stimmen die angegebenen Ereignisse der Aktion �berein, wird ein Skript oder eine Library aufgerufen. <br>
Im Gegensatz zu den anderen Bereichen, wird eine Aktion nicht von Men�s verwendet.<br><br>

<i>Beispiel:</i>
<pre class='code'>
[action:action_1]
event=CONNECT
//type=
direction=INCOMING
//src_id=
//dst_id=
//src_no=
dst_no=0049301234567
//data=
action=script:action_hookup

[script:action_hookup]
cmd=/var/action_hookup.sh(/var/action_hookup.sh, "%event%", "%type%", "%direction%", "%src_id%", "%dst_id%")
</pre>
Wenn:<br>
<font class='code'>%event%="CONNECT"</font> und <font class='code'>%direction%="INCOMING"</font> und <font class='code'>%dst_no%="0049301234567"</font>, <br>
Dann:<br>
<font class='code'>"action_hookup.sh"</font> ausf�hren (und Platzhalter �bergeben).<br><br>
Innerhalb des Skriptes k�nne man z.B. die Verbindung annehmen (<font class='code'>\$DTMFBOX \$4 -hook up</font>).
<p></p>
<i>Hinweis:</i><br>
Bei mehrere Aktionen werden diese nacheinander ausgef�hrt (nach Namen sortiert).<br>
Eine Erl�uterung zu den Ereignissen befindet sich <a href="$MAIN_CGI&page=help&help=ereignisse">hier</a>. Eine Erl�uterung zu den Befehlen, <a href="$MAIN_CGI&page=help&help=befehle">hier</a>.
EOF
fi


#
# Skripteinstellungen
#
if [ "$HELPPAGE" = "skripteinstellungen" ];
then
echo '<a name="skripteinstellungen" href="#skripteinstellungen"></a>'
show_title "Skripteinstellungen"

cat << EOF
Unter <a href='$MAIN_CGI&page=script_cfg' target='_new'>Skripteinstellungen</a> werden die Einstellungen zu den Skripten vorgenommen.<br><br>

Alle Skripte binden diese Datei ein, wie auch das Webinterface, um Einstellungen am Text-Editor vorzunehmen zu k�nnen (Zeilen/Wrap).<br>
<br>
<ul>
	<li><b>Autostart</b><p>
	Gibt an, ob die dtmfbox beim Booten automatisch gestartet werden soll.</li><br>

	<li><b>Anrufbeantworter</b<p>
	Die Einstellungen f�r den Anrufbeantworter. Diese gelten f�r alle Accounts gleicherma�en.<br>
	Um accountspezifische Einstellungen zu hinterlegen, muss man im <a href="$MAIN_CGI?pkg=dtmfbox&page=script_cfg&direct_edit=1" target="_new">Text-Editor</a> die jeweiligen Eintr�ge hinzuf�gen, mit dem Pr�fix <font class='code'>ACCX_</font> (X=Account ID). Globale Einstellungen fangen mit dem Pr�fix <font class='code'>GLOBAL_</font> an.<br>
	Um z.B. die Ansage von Account 5 zu �ndern, folgende Zeile hinzuf�gen:<br>
<pre class='code'><font class='code'>ACC5_AM_ANNOUNCEMENT_START=/var/dtmfbox/play/ansage.wav  # Ansage f�r Account Nr. 5</font></pre>
	Als Ansage und Endansage kann man auch eine URL angeben, wie z.B. http://www.url.de/ansage.wav oder ftp://www.url.de/ansage.wav.<br>
	Wichtig ist, dass die PCM-Wave vom Format 8000hz, 16bit, Mono ist.<br>
	<br>
	Aufnahmen k�nnen per eMail verschickt oder auf einen FTP-Server abgelegt werden.<br>
	Beim eMail-Versand werden die Aufnahme als Wave-Datei versendet. Beim FTP-Streaming werden PCM-Dateien ohne Wave-Header geschrieben, welche ebenfalls �ber das AB-Men� abgeh�rt werden k�nnen (RAW 8000hz, 16bit, Mono).
	</li><br>

	<li><b>Callthrough</b><p>
	Callthrough Regeln bestehen aus max. zwei Teilen, welche durch Schr�gstriche getrennt werden:<br>
	<pre class='code'><font class='code'>Trigger-Nr./[Trigger-Accout]</font></pre>
	Die Trigger-Nr. muss angegeben werden. Sie ist die Nummer, die den Callthrough ausl�sen soll. Als Trigger-Nummer kann man eine Regular-Expression verwenden, um z.B. beliebigen Nummern den Zugang zum Callthrough zu erm�glichen.<br>
	Der Trigger-Account ist optional. Dies kann die Account-ID oder die Nummer des Accounts sein, welcher auf Callthroughs reagieren soll.<br>
	Wenn kein Trigger-Account angegeben wird, ist die Callthrough-Regel f�r alle Accounts aktiv.<br>
	<br>
	<i>Beispiel:</i><br>
	Account 1 soll bei einem Anruf der Nummer 004922112345 das Gespr�ch annehmen und an das Callthrough Men� weiterleiten:<br>
<pre class='code'>
004922112345/1          # Mit Angabe der Account-ID
004922112345/322423     # Mit Angabe der Account-Nummer
004922112345            # Ohne Angabe der Account-ID. Callthrough ist f�r alle Accounts aktiv.
.*2112345               # Callthrough mithilfe von Regular Expressions
</pre>
	<i>Hinweis:</i><br>
	<ul>
	<li>Bei ISDN ist es ratsam, unter den <a href='$MAIN_CGI?pkg=dtmfbox&page=dtmfbox_cfg' target='_new'>Basiseinstellungen</a> die Landes und Ortsvorwahl zu hinterlegen.
	<li>Es lassen sich beliebig viele Callthrough-Regeln �ber den <a href='$MAIN_CGI?pkg=dtmfbox&page=script_cfg&direct_edit=1' target="_new">Text-Editor</a> hinzuf�gen.
	<li>Die Callthrough-Regeln werden nacheinander abgearbeitet. Sobald eine leere Callthrough-Regel gefunden wird, bricht das Skript die weitere Pr�fung ab.
	</ul>
	</li>

	<li><b>Callback</b><p>
	Callback Regeln bestehen aus zwei bis f�nf Teilen, welche ebenfalls durch Schr�gstriche getrennt werden:<br>
	<pre class='code'><font class='code'>Trigger-Nr./R�ckruf-Nr./[Trigger-Account]/[R�ckruf-Account]/[CAPI-Controller]</font></pre>
	Die Trigger- und R�ckruf-Nr. muss angegeben werden. Die Trigger-Nr. ist die Nummer, welche den Callback ausl�sen soll. R�ckruf-Nr. ist die Nummer, auf welche nach dem Auflegen zur�ckgerufen werden soll.<br>
	Optional k�nnen noch Trigger- und R�ckruf-Account und ein CAPI Controller angegeben werden. Trigger-Account ist, wie beim Callthrough auch, die Einschr�nkung des Callbacks auf einen bestimmten Account.<br>
	R�ckruf-Account ist der Account, welcher den R�ckruf durchf�hren soll. Hier kann die Account-ID, aber auch die Nummer angegeben werden. Der CAPI-Controller bestimmt den ausgehenden Controller f�r den Callback und sollte bei VoIP-Accounts nicht angegeben werden.<br>
	<br>
	<i>Beispiel:</i><br>
	Der Callback soll auf die Rufnummer 004922112345 reagieren. Die Nummer, auf die zur�ckgerufen werden soll, ist die 0160555555555. Als MSN soll 3322211 verwendet werden (Account 1).
<pre class='code'>
004922112345/0160555555555/3322211      # Es wird hier die Nummer direkt angegeben.
004922112345/0160555555555/1            # Es wird hier die Nummer als ID �bergeben.
004922112345/0160555555555              # Ohne Accountangabe. Callback f�r alle Accounts aktiv.
.*22112345/0160555555555                # R�ckruf mithilfe von RegEx.
\(.*22112345\)/\1                       # R�ckruf mithilfe von RegEx auf Trigger-Nr.
                                        # Trigger-Nr wird als R�ckrufnummer verwendet. Nicht 0160555555555
</pre>
	<i>Hinweis:</i><br>
	<ul>
	<li>Bei ISDN ist es ratsam, unter den <a href='$MAIN_CGI?pkg=dtmfbox&page=dtmfbox_cfg' target='_new'>Basiseinstellungen</a> die Landes und Ortsvorwahl zu hinterlegen.
	<li>Es lassen sich beliebig viele Callback-Regeln �ber den <a href='$MAIN_CGI?pkg=dtmfbox&page=script_cfg&direct_edit=1' target="_new">Text-Editor</a> hinzuf�gen.
	<li>Die Callback-Regeln werden nacheinander abgearbeitet. Sobald eine leere Callback-Regel gefunden wird, bricht das Skript die weitere Pr�fung ab.
	</ul>
	</li>

	<li><b>Webradio</b><p>
	Das Webradio kann man im Men� unter "(4) Sonstiges -> (4) Radio" erreichen. Vorraussetzung f�r das Abspielen von MP3-Streams ist das Programm 'madplay' (siehe auch: "Programme & Pfade").<br><br>
	Es k�nnen bis zu neun MP3-Streams hinterlegt werden (URLs). Durch eine entsprechende <a href='$MAIN_CGI?pkg=dtmfbox&page=menu_cfg' target='_new'>Men��nderung</a> lassen sich aber mehr Streams einf�gen.<br>
	<br>
	<i>Beispiel:</i><br>

<pre class='code'>[menu:misc_radio]
say=Radio
1#=script:misc_radio(1)
...
50#=script:misc_radio(50)</pre>
oder:
<pre class='code'>[menu:misc_radio]
say=Radio
01=script:misc_radio(1)
...
50=script:misc_radio(50)</pre>
	</li><br>

	<li><b>R�ckw�rtssuche</b><p>
	Die R�ckw�rtssuche erm�glicht das Anzeigen von Name und Adresse auf dem ISDN-Telefon als Display-Message.<br>
	Den Accounts wird dabei eine Pseudo-MSN zugeordnet. Im Telefon wird die original Empfangs-MSN durch die Pseudo-MSN ersetzt. Die Sende-MSN bleibt unver�ndert!<p>

	<i>Hinweise:</i>
	<ul>
		<li>Die R�ckw�rtssuche funktioniert nur mit Telefonen, die am internen S0-Bus angeschlossen sind.<br>Fon1-3 und das interne DECT der FB werden nicht unterst�tzt!</li>
		<li>Das Skript <i>action_revers.sh</i> ruft zun�chst die Funktion <i>revers_lookup1()</i> auf, welche als benutzerdefinierte Funktion dient. Hier kann man selbst Telefonnummern hinterlegen und Namen/Adresse ausgeben.
		Wird kein Eintrag ausgegeben, so wird die Funktion <i>revers_lookup2()</i> aufgerufen, welche eine R�ckw�rtssuche �ber "dasoertliche.de" durchf�hrt.</li>
	</ul>
	</li><br>

	<li><b>Anti-Callcenter</b><p>
	Das Anti-Callcenter Skript dient dazu, unbekannte Anrufer direkt anzunehmen und zur Rufnummerneingabe aufzufordern.<p>
	Jedem Account kann eine Weiterleitungs-Rufnummer hinterlegt werden:<br>
	Bei ISDN ist es die MSN (bei aktiver R�ckw�rtssuche, die Pseudo-MSN).<br>
	Bei Analog und VoIP kann eine SIP-Adresse angegeben werden, wie z.B. 12345@fritz.box (siehe auch <a href='$MAIN_CGI&page=help&help=accounts'>Accounts einrichten /  SIP-Registrar</a>).<br><br>
	Es wird das Skript <i>action_anticallcenter.sh</i> aufgerufen.<p>

	<i>Hinweis:</i><br>
	Analog-Telefone m�ssen nicht unbedingt per SIP angebunden werden. Es reicht aus, im AVM-Webif einen Internet-Telefonieaccount anzulegen und einem FON-Anschluss zuzuordnen.
	Die Einstellungen des Internet-Telefonieaccount k�nnten folgenderma�en aussehen:<br>
	<ul>
	Internetrufnummer: 9000<br>
	Benutzername: 9000<br>
	Passwort: 9000<br>
	Registrar: localhost<br>
	Rufnummernformat anpassen: (alle Haken rausnehmen)<br>
	</ul>
	Der angelegte Telefonieaccount wird anschlie�end dem FON-Anschluss als zus�tzliche Empfangsrufnummer zugeordnet.<br><br>
	Im dtmfbox-Webif wird die Weiterleitung <font class='code'>9000@fritz.box:5060</font> oder <font class='code'>9000@192.168.178.1</font> hinterlegt. Der jeweilige FON-Anschluss l�sst sich �ber diese SIP-Uri direkt ansprechen.<br>
	</li><br>

	<li><b>Text2Speech (eSpeak)</b><p>
	Hier k�nnen die Einstellungen zu eSpeak ver�ndert werden.<br>
	Es gibt drei Modis:
	<ul>
		<li><b>Installiert</b><br>
		eSpeak ist installiert. Entweder auf USB oder im Flash (Einstellungen zur Pfadangabe unten beachten!)</li><br>

		<li><b>Webstream</b><br>
		eSpeak �ber Webstream abrufen. Eine Installation von eSpeak ist nicht n�tig.</li><br>

		<li><b>Beep</b><br>
		eSpeak deaktivieren. Nur Beep.</li>
	</ul>
	<i>Hinweis:</i><br>
	Der Typ: f5 und m5 (mbrola) ist nur als Webstream verf�gbar.<br>
	</li><br>

	<li><b>Programme & Pfadangaben</b><p>
        Bei der USB-Version finden sich espeak, madplay usw. unter <font class='code'>/var/dtmfbox/extras</font>, sodass dieser Pfad hier voreingestellt ist.<br>
	Bei Freetz liegen die Programme an anderen Orten: <br>
	<ul>
		<li>eSpeak: <font class='code'>/usr/bin</font>
		<li>madplay: <font class='code'>/usr/bin</font>
		<li>checkmaild: <font class='code'>/mod/etc</font>
	</ul>
	</li><br>

	<li><b>Webinterface</b><p>
	Das Speicherverhalten kann auf "Diff + Patch + GZip" oder nur "GZip" eingestellt werden. Erstere Methode spart etwas Flash-Speicher, falls die dtmfbox im RAM installiert wurde.<br>
	</li><br>
</ul>
EOF
fi

#
# Skripte bearbeiten
#
if [ "$HELPPAGE" = "skripte_bearbeiten" ];
then
echo '<a name="skripte_bearbeiten" href="#skripte_bearbeiten"></a>'
show_title "Skripte bearbeiten"

cat << EOF
Skripte lassen unter <a href='$MAIN_CGI&page=scripts'>Skripte bearbeiten</a> �ndern und erweitern.<br><br>
Es handelt sich hierbei um Shellskripte, welche die eigentlichen Funktionen der dtmfbox implementieren (Anrufbeantworter, Callback/Callthrough, ...).<br>
<br>
Alle Skripte werden durch das Men�-Plugin ausgef�hrt. Die einzelnen Skriptaufrufe stehen in den Bereichen <a href="$MAIN_CGI&page=help&help=menu_script"><font class='code'>[script:X]</font></a>.<p>

Jedem Skript k�nnen Parameter mitgegeben werden, die in den Variablen \$1 bis \$32 zur Verf�gung stehen. Dies k�nnen <a href='$MAIN_CGI&page=help&help=ereignisse'>Ereignisse</a> sein, aber auch benutzerdefinierte Parameter.<p>
Man kann weitere Skripte unter <font class='code'>/var/dtmfbox/script</font> ablegen, welche automatisch mitgespeichert werden.
EOF

fi

#
# Nachrichten
#
if [ "$HELPPAGE" = "nachrichten" ];
then
echo '<a name="nachrichten" href="#nachrichten"></a>'
show_title "Nachrichten"
cat << EOF
Der Men�punkt "<a href='$MAIN_CGI&page=am_messages' target='_new'>Nachrichten</a>" zeigt die Aufnahmen auf dem Anrufbeantworter an.<br><br>
Es kann zwischen den einzelnen Accounts gewechselt werden. Aufnahmen lassen sich abh�ren und l�schen.<br><br>

Wird das "FTP-Streaming" verwendet, werden die Dateien auf dem FTP-Server abgelegt und stehen dort als RAW-PCM zur verf�gung (8000hz/16bit/mono). Das sind ganz normale Wave-Dateien, jedoch ohne Header.
Gespeicherte Aufnahmen sind im WAV-PCM Format (8000hz/16bit/mono).
EOF
fi

#
# Webphone
#
if [ "$HELPPAGE" = "webphone" ];
then
echo '<a name="webphone" href="#webphone"></a>'
show_title "Webphone"
cat << EOF
Unter "<a href='$MAIN_CGI&page=webphone' target='_new'>Webphone</a>" befindet sich ein Java-Applet, womit es m�glich ist, �ber die Weboberfl�che, per Headset, zu telefonieren.<br><br>

Es wird das Standard-Sounddevice verwendet. Account ausw�hlen, Zielrufnummer eingeben und w�hlen.<br><br>

<i>Achtung:</i> Alpha!! ;-)<br><br>

F�r das Webphone wird die Java Runtime Engine ben�tigt.<br>
Download hier: <a href="http://www.java.com/de/download/" target="_new">http://www.java.com/de/download/</a><br>

EOF
fi

#
# dtmfbox Befehle
#
if [ "$HELPPAGE" = "befehle" ];
then
echo '<a name="befehle" href="#befehle"></a>'
show_title "Befehle"
cat << EOF
Die dtmfbox und die Plugins stellen eine Reihe von Befehlen zur Verf�gung, welche �ber Kommandozeile oder �ber eine Funktion innerhalb der Plugins augerufen werden k�nnen.<br><br>
Um Befehle auszuf�hren, muss die dtmfbox gestartet sein.<br><br>
EOF

echo "Standard-Befehle (<font class='code'>dtmfbox</font>):"
echo -n "<pre class='code'>"
if [ ! -z "$(pidof "dtmfbox")" ]; then
	/var/dtmfbox/dtmfbox
else
	echo -n "dtmfbox wurde nicht gestartet!"
fi
echo "</pre>"
echo "<br>Plugins (<font class='code'>dtmfbox -list plugins</font>):"
echo -n "<pre class='code'>"
if [ ! -z "$(pidof "dtmfbox")" ]; then
	/var/dtmfbox/dtmfbox -list plugins
else
	echo -n "dtmfbox wurde nicht gestartet!"
fi
echo -n "</pre>"

fi

#
# dtmfbox Webinterface
#
if [ "$HELPPAGE" = "webinterface" ];
then
echo '<a name="webinterface" href="#webinterface"></a>'
show_title "Webinterface"
cat << EOF
Die Einstellungen der dtmfbox werden zur Laufzeit ausgelesen und dynamisch angezeigt.<br><br>
Dies trifft haupts�chlich auf die Dateien <i>dtmfbox.cfg</i> und <i>script.cfg</i> zu, wobei Letzere interessant sein kann, um benutzerdefinierte Skripteinstellungen zu hinterlegen.<br>
<br>
Jeder Einstellung wird im Text-Editor ein Kommentar zugewiesen:<br>
<ul>
<li><b>dtmfbox.cfg:</b> <font class='code'>Einstellung=Wert // Kommentar</font>
<li><b>script.cfg:</b> <font class='code'>Einstellung="Wert" # Kommentar</font>
</ul>
Dieser Kommentar wird als Bezeichnung f�r die Einstellung verwendet. Klickt man nun auf "Speichern" und verl�sst den Text-Editor, stellt man fest, das die Einstellung mit dem jeweiligen Kommentar, als Textbox, angezeigt wird.<br><br>
Es gibt weitere Flags, um die Darstellung und das Verhalten von Einstellungen zu ver�ndern.<br>
Diese werden ebenfalls im Kommentarteil angegeben:
<ul>
<li><pre class="code">[HTML:X]<br></pre>
HTML-Code angeben, f�r �berschriften, Javascript, etc. (X = HTML-Code)</li>

<li><pre class="code">[HIDE:1]<br></pre>
Einstellung verbergen</li>

<li><pre class="code">[WIDTH:X]<br></pre>
Textbox Breite (in px)</li>

<li><pre class="code">[OPTION:X1|Y1|X2|Y2 ...]<br></pre>
Kombobox anzeigen mit vorgegebenen Optionen.<br>
X1/X2 = Wert, der gespeichert wird<br>
Y1/Y2 = Wert, der angezeigt wird
</li>

<li><pre class="code">[TYPE:X]<br></pre>
Input-Type direkt angeben (z.B. X=password)</li>

<li><pre class="code">[ONCHANGE:function()]<br></pre>
Javascript-Funktion aufrufen, wenn der Wert ge�ndert wird. Eine Javascript-Funktion kann mittels [HTML:X]-Tag angegeben werden.
</li>

<li><pre class="code">[SECTION:X]<br></pre>
Einen neuen Bereich erzwingen (X = Bereichsname)</li>
EOF
fi

#
# dtmfbox Befehle
#
if [ "$HELPPAGE" = "ereignisse" ];
then
echo '<a name="ereignisse" href="#ereignisse"></a>'
show_title "Ereignisse"
cat << EOF
Ereignisse geben Auskunft �ber den aktuellen Zustand einer Verbindung.<br><br>
Hier�ber kann man feststellen, ob eine Verbindung gerade aufgebaut wird (<font class='code'>CONNECT</font>), ob ein DTMF-Zeichen empfangen wurde (<font class='code'>DTMF</font>), ob aufgelegt wurde (<font class='code'>DISCONNECT</font>), usw...
Zudem stehen einem noch weitere Informationen zur Verf�gung, wie die Account-ID, Account-MSN/-Nummer, die Anrufernummer, Connection-ID, usw.<br><br>

In Men�s k�nnen Ereignisse als Parameter an <a href='$MAIN_CGI&page=help&help=menu_script'>Skripte</a> und <a href='$MAIN_CGI&page=help&help=menu_lib'>Libraries</a> �bergeben werden.<br>
Zudem k�nnen Ereignisse genutzt werden, um Skripte bei bestimmten Verbindungszust�nden auszuf�hren (<a href='$MAIN_CGI&page=help&help=menu_action'>Aktionen</a>).<p>

�bersicht der Ereignisse:<br>
<pre class='code'>
%event%       // Aktuelles Ereignis (DDI, EARLY, CONNECT, CONFIRMED, DTMF, UNCONFIRMED, DISCONNECT)
%direction%   // Verbindungsrichtung (INCOMING, OUTGOING)
%type%        // Verbindungstyp (CAPI, VOIP, USER)
%src_id%      // Source Connection-ID (eigene Verbindungs-ID)
%dst_id%      // Target Connection-ID (Gespr�chspartner-ID)
%src_no%      // Rufnummer (Account/MSN)
%dst_no%      // Anrufer oder Zielrufnummer
%acc_id%      // Account-ID
%data%        // DTMF-Zeichen, wenn %event%=DTMF (Aktuell, einzelnes Zeichen), bzw. Statuscode
%dtmf%        // DTMF-Zeichen (Buffer, gesammelte Zeichen).
</pre>
<ul>
<li><font class='code'>%event%</font> ist der aktuelle Verbindungsstatus:
<ul>
	<li><font class='code'>DDI</font> tritt beim W�hlen auf, bevor die Verbindung aufgebaut wird</li>
	<li><font class='code'>EARLY</font> tritt bei ausgehenden Verbindungen auf, nachdem gew�hlt wurde</li>
	<li><font class='code'>CONNECT</font> signalisiert einen neuen ankommenden, bzw. ausgehenden Anruf</li>
	<li><font class='code'>CONFIRMED</font> wird ausgel�st, sobald eine Sprachverbindung aufgebaut wurde</li>
	<li><font class='code'>UNCONFIRMED</font> wird ausgel�st, sobald eine Sprachverbindung abgebaut wurde</li>
	<li><font class='code'>DISCONNECT</font> signalisiert das Beenden einer Verbindung</li>
</ul></li>
<li><font class='code'>%direction%</font> ist die Richtung der Verbindung. <font class='code'>INCOMING</font>, <font class='code'>OUTGOING</font>.</li><br>
<li><font class='code'>%type%</font> ist der Verbindungstyp. <font class='code'>CAPI</font>, <font class='code'>VOIP</font> oder <font class='code'>USER</font>. <font class='code'>USER</font> ist die Verbindung eines angemeldeten SIP-Clients.</li><br>
<li><font class='code'>%src_id%</font> ist einer der wichtigsten Parameter. Es ist die eigene Verbindungs-ID, welche f�r fast alle Befehle gebraucht wird. Damit kann man Befehle auf die aktuelle Verbindung anwenden, wie z.B. Wave-Datei abspielen/aufnehmen, Gespr�ch annehmen/auflegen, usw.</li><br>
<li><font class='code'>%dst_id%</font> ist die Verbindungs-ID des Gespr�chspartners, mit dem man verbunden ist. Bei mehreren Gespr�chspartnern, wird immer nur der Erste �bergeben.</li><br>
<li><font class='code'>%src_no%</font> ist die Rufnummer der aktuellen Verbindung. Normalerweise die Rufnummer des Accounts.</li><br>
<li><font class='code'>%dst_no%</font> ist die Rufnummer des Gespr�chspartners</li><br>
<li><font class='code'>%acc_id%</font> ist die Account-ID der aktuellen Verbindung</li><br>
<li><font class='code'>%data%</font> gibt zus�tzlich bei <font class='code'>%event%="DISCONNECT"</font> den Grund f�r den Verbindungsabbau/-abbruch an (SIP/CAPI Statuscode).<br>Ansonsten dient <font class='code'>%data%</font> dazu, das aktuell �bertragene DTMF-Zeichen zur�ckzuliefern (<font class='code'>%event%="DTMF"</font>).</li><br>
<li><font class='code'>%dtmf%</font> ist der komplette DTMF-Buffer (<font class='code'>%event%="DTMF"</font>)</li><br>
</ul><br>
EOF
fi

#
# Inhalt / Men�leiste
#
cat << EOF
  </td>
  <td valign="top" width="20%">
<br>
<b>Hilfe</b>
<hr color="black">
  <ul>
	<li><a href="$MAIN_CGI&page=help&help=vorwort">Vorwort</a></li>
	<li><a href="$MAIN_CGI&page=help&help=getting_started">Getting started...</a></li>
	<br>
	<li><a href="$MAIN_CGI&page=help&help=status">Status</a></li>
	<li><a href="$MAIN_CGI&page=help&help=basiseinstellungen">Basiseinstellungen</a></li>
	<ul>
		<li><a href="$MAIN_CGI&page=help&help=accounts">Accounts einrichten</a></li>
		<li><a href="$MAIN_CGI&page=help&help=internes_menu">Kurzwahlen einrichten</a></li>
	</ul>

	<li><a href="$MAIN_CGI&page=help&help=skripteinstellungen">Skripteinstellungen</a></li>
	<br>
	<li><a href="$MAIN_CGI&page=help&help=menu_start">Das Men�</a></li>
	<li><a href="$MAIN_CGI&page=help&help=menu">Men� bearbeiten</a></li>
	<ul>
		<li><a href="$MAIN_CGI&page=help&help=menu_menu">menu:</a></li>
		<li><a href="$MAIN_CGI&page=help&help=menu_script">script:</a></li>
		<li><a href="$MAIN_CGI&page=help&help=menu_lib">lib:</a></li>
		<li><a href="$MAIN_CGI&page=help&help=menu_action">action:</a></li>
	</ul>

	<li><a href="$MAIN_CGI&page=help&help=skripte_bearbeiten">Skripte bearbeiten</a></li>
	<br>
	<li><a href="$MAIN_CGI&page=help&help=nachrichten">Nachrichten</a></li>
	<li><a href="$MAIN_CGI&page=help&help=webphone">Webphone</a></li>
	<br>
	<li><a href="$MAIN_CGI&page=help&help=befehle">dtmfbox Befehle</a></li>
	<li><a href="$MAIN_CGI&page=help&help=ereignisse">dtmfbox Ereignisse</a></li>
	<li><a href="$MAIN_CGI&page=help&help=webinterface">dtmfbox Webinterface</a></li>
  </ul><br>

  </td></tr></table>
  </body>
  </html>
EOF
