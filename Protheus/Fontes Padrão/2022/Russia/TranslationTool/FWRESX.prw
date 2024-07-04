#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'

#XTRANSLATE Tab(<n>) => Replicate(Chr(9), <n>)

Static _cCP

Function FwResX(aData, cDir, cFile)

	Local cRet		:= GetCab()
	Local cFilePath := CurDir() + cDir + "/" + AllTrim(cFile) + ".resx"

	nHdl := FCreate(cFilePath)

	If nHdl>0
		FWrite(nHdl, cRet)
		cRet := ""
		cRet += InsData(aData, nHdl)
		cRet += GetRoda()
		FWrite(nHdl, cRet)
		FClose(nHdl)
		Conout('INFO: Gravou ' + cFile)
	Else
		Conout("Error creating file " + cFilePath)
	Endif

Return

Static Function Insdata(aData)

	Local cRet := ""
	Local nX   := 0
	Local nY   := 0

	For nX := 1 To Len(aData)
		cRet += Tab(1) + '<data name="' + aData[nX, 2] + '" xml:space="preserve">' + CRLF
		cRet += Tab(2) +	'<value>' + U_MyEncode(aData[nX, 3]) +'</value>' + CRLF
		cRet += Tab(2) +	'<comment>' + CRLF

		For nY := 1 To Len(aData[nX, 4])
			cRet += Tab(3) + U_MyEncode(aData[nX, 4, nY]) + CRLF
		Next
		cRet += Tab(2) +	'</comment>' + CRLF

		cRet += Tab(1) + '</data>' + CRLF

		If Len(cRet)/1024 >= 512
			FWrite(nHdl, cRet)
			cRet := ""
		Endif
	Next nX

Return cRet

Static Function GetCab()
	Local cCab := ""

	cCab += '<?xml version="1.0" encoding="utf-8"?>' + CRLF
	cCab += '<root>' + CRLF
	cCab += Tab(1) + '<!-- ' + CRLF
	cCab += Tab(2) +	'Microsoft ResX Schema ' + CRLF
	cCab += Tab(2) +	'' + CRLF
	cCab += Tab(2) +	'Version 2.0' + CRLF
	cCab += Tab(2) +	'' + CRLF
	cCab += Tab(2) +	'The primary goals of this format is to allow a simple XML format ' + CRLF
	cCab += Tab(2) +	'that is mostly human readable. The generation and parsing of the ' + CRLF
	cCab += Tab(2) +	'various data types are done through the TypeConverter classes ' + CRLF
	cCab += Tab(2) +	'associated with the data types.' + CRLF
	cCab += Tab(2) +	'' + CRLF
	cCab += Tab(2) +	'-->' + CRLF
	cCab += Tab(1) + '<xsd:schema id="root" xmlns="" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata">' + CRLF
	cCab += Tab(2) +	'<xsd:import namespace="http://www.w3.org/XML/1998/namespace" />' + CRLF
	cCab += Tab(2) +	'<xsd:element name="root" msdata:IsDataSet="true">' + CRLF
	cCab += Tab(3) +		'<xsd:complexType>' + CRLF
	cCab += Tab(4) +			'<xsd:choice maxOccurs="unbounded">' + CRLF
	cCab += Tab(5) +				'<xsd:element name="metadata">' + CRLF
	cCab += Tab(6) +					'<xsd:complexType>' + CRLF
	cCab += Tab(7) +						'<xsd:sequence>' + CRLF
	cCab += Tab(8) +							'<xsd:element name="value" type="xsd:string" minOccurs="0" />' + CRLF
	cCab += Tab(7) +						'</xsd:sequence>' + CRLF
	cCab += Tab(7) +						'<xsd:attribute name="name" use="required" type="xsd:string" />' + CRLF
	cCab += Tab(7) +						'<xsd:attribute name="type" type="xsd:string" />' + CRLF
	cCab += Tab(7) +						'<xsd:attribute name="mimetype" type="xsd:string" />' + CRLF
	cCab += Tab(7) +						'<xsd:attribute ref="xml:space" />' + CRLF
	cCab += Tab(6) +					'</xsd:complexType>' + CRLF
	cCab += Tab(5) +				'</xsd:element>' + CRLF
	cCab += Tab(5) +				'<xsd:element name="assembly">' + CRLF
	cCab += Tab(6) +					'<xsd:complexType>' + CRLF
	cCab += Tab(7) +						'<xsd:attribute name="alias" type="xsd:string" />' + CRLF
	cCab += Tab(7) +						'<xsd:attribute name="name" type="xsd:string" />' + CRLF
	cCab += Tab(6) +					'</xsd:complexType>' + CRLF
	cCab += Tab(5) +				'</xsd:element>' + CRLF
	cCab += Tab(5) +				'<xsd:element name="data">' + CRLF
	cCab += Tab(6) +					'<xsd:complexType>' + CRLF
	cCab += Tab(7) +						'<xsd:sequence>' + CRLF
	cCab += Tab(8) +							'<xsd:element name="value" type="xsd:string" minOccurs="0" msdata:Ordinal="1" />' + CRLF
	cCab += Tab(8) +							'<xsd:element name="comment" type="xsd:string" minOccurs="0" msdata:Ordinal="2" />' + CRLF
	cCab += Tab(7) +						'</xsd:sequence>' + CRLF
	cCab += Tab(7) +						'<xsd:attribute name="name" type="xsd:string" use="required" msdata:Ordinal="1" />' + CRLF
	cCab += Tab(7) +						'<xsd:attribute name="type" type="xsd:string" msdata:Ordinal="3" />' + CRLF
	cCab += Tab(7) +						'<xsd:attribute name="mimetype" type="xsd:string" msdata:Ordinal="4" />' + CRLF
	cCab += Tab(7) +						'<xsd:attribute ref="xml:space" />' + CRLF
	cCab += Tab(6) +					'</xsd:complexType>' + CRLF
	cCab += Tab(5) +				'</xsd:element>' + CRLF
	cCab += Tab(5) +				'<xsd:element name="resheader">' + CRLF
	cCab += Tab(6) +					'<xsd:complexType>' + CRLF
	cCab += Tab(7) +						'<xsd:sequence>' + CRLF
	cCab += Tab(8) +							'<xsd:element name="value" type="xsd:string" minOccurs="0" msdata:Ordinal="1" />' + CRLF
	cCab += Tab(7) +						'</xsd:sequence>' + CRLF
	cCab += Tab(7) +						'<xsd:attribute name="name" type="xsd:string" use="required" />' + CRLF
	cCab += Tab(6) +					'</xsd:complexType>' + CRLF
	cCab += Tab(5) +				'</xsd:element>' + CRLF
	cCab += Tab(4) +			'</xsd:choice>' + CRLF
	cCab += Tab(3) +		'</xsd:complexType>' + CRLF
	cCab += Tab(2) +	'</xsd:element>' + CRLF
	cCab += Tab(1) + '</xsd:schema>' + CRLF
	cCab += Tab(1) + '<resheader name="resmimetype">' + CRLF
	cCab += Tab(2) +	'<value>text/microsoft-resx</value>' + CRLF
	cCab += Tab(1) + '</resheader>' + CRLF
	cCab += Tab(1) + '<resheader name="version">' + CRLF
	cCab += Tab(2) +	'<value>2.0</value>' + CRLF
	cCab += Tab(1) + '</resheader>' + CRLF
	cCab += Tab(1) + '<resheader name="reader">' + CRLF
	cCab += Tab(2) +	'<value>System.Resources.ResXResourceReader, System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089</value>' + CRLF
	cCab += Tab(1) + '</resheader>' + CRLF
	cCab += Tab(1) + '<resheader name="writer">' + CRLF
	cCab += Tab(2) +	'<value>System.Resources.ResXResourceWriter, System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089</value>' + CRLF
	cCab += Tab(1) + '</resheader>' + CRLF

Return cCab

Static Function GetRoda()

Return	'</root>' + CRLF

/*
Static Function MyEncode(cString)
Local cRet := ""
Local nX
Local aCodes := {}
Local cChar := ""
If _cCP=='CP1252'
	UTF2CP1252()
ElseIf 	_cCP=='CP1251'
	UTF2CP1251()
Endif

For nX := 1 To Len(cString)
	cChar := Substr(cString, nX, 1)
	If Asc(cChar) > 127 .Or. cChar$"&#;<>/\[]"
		nPos := Ascan(aCodes, {|x| x[1]==Asc(cChar)})
		cRet += "&#" + AllTrim(StrZero(aCodes[nPos, 2], 4)) + ";"
	Else
		cRet += cChar
	Endif
Next
Return cRet

Static Function UTF2CP1251()
Local aRet := {;
{0, 0}, ; //#NULL
{1, 1}, ; //#START OF HEADING
{2, 2}, ; //#START OF TEXT
{3, 3}, ; //#END OF TEXT
{4, 4}, ; //#END OF TRANSMISSION
{5, 5}, ; //#ENQUIRY
{6, 6}, ; //#ACKNOWLEDGE
{7, 7}, ; //#BELL
{8, 8}, ; //#BACKSPACE
{9, 9}, ; //#HORIZONTAL TABULATION
{10, 10}, ; //#LINE FEED
{11, 11}, ; //#VERTICAL TABULATION
{12, 12}, ; //#FORM FEED
{13, 13}, ; //#CARRIAGE Return
{14, 14}, ; //#SHIFT OUT
{15, 15}, ; //#SHIFT IN
{16, 16}, ; //#DATA LINK ESCAPE
{17, 17}, ; //#DEVICE CONTROL ONE
{18, 18}, ; //#DEVICE CONTROL TWO
{19, 19}, ; //#DEVICE CONTROL THREE
{20, 20}, ; //#DEVICE CONTROL FOUR
{21, 21}, ; //#NEGATIVE ACKNOWLEDGE
{22, 22}, ; //#SYNCHRONOUS IDLE
{23, 23}, ; //#END OF TRANSMISSION BLOCK
{24, 24}, ; //#CANCEL
{25, 25}, ; //#END OF MEDIUM
{26, 26}, ; //#SUBSTITUTE
{27, 27}, ; //#ESCAPE
{28, 28}, ; //#FILE SEPARATOR
{29, 29}, ; //#GROUP SEPARATOR
{30, 30}, ; //#RECORD SEPARATOR
{31, 31}, ; //#UNIT SEPARATOR
{32, 32}, ; //#SPACE
{33, 33}, ; //#EXCLAMATION MARK
{34, 34}, ; //#QUOTATION MARK
{35, 35}, ; //#NUMBER SIGN
{36, 36}, ; //#DOLLAR SIGN
{37, 37}, ; //#PERCENT SIGN
{38, 38}, ; //#AMPERSAND
{39, 39}, ; //#APOSTROPHE
{40, 40}, ; //#LEFT PARENTHESIS
{41, 41}, ; //#RIGHT PARENTHESIS
{42, 42}, ; //#ASTERISK
{43, 43}, ; //#PLUS SIGN
{44, 44}, ; //#COMMA
{45, 45}, ; //#HYPHEN-MINUS
{46, 46}, ; //#FULL STOP
{47, 47}, ; //#SOLIDUS
{48, 48}, ; //#DIGIT ZERO
{49, 49}, ; //#DIGIT ONE
{50, 50}, ; //#DIGIT TWO
{51, 51}, ; //#DIGIT THREE
{52, 52}, ; //#DIGIT FOUR
{53, 53}, ; //#DIGIT FIVE
{54, 54}, ; //#DIGIT SIX
{55, 55}, ; //#DIGIT SEVEN
{56, 56}, ; //#DIGIT EIGHT
{57, 57}, ; //#DIGIT NINE
{58, 58}, ; //#COLON
{59, 59}, ; //#SEMICOLON
{60, 60}, ; //#LESS-THAN SIGN
{61, 61}, ; //#EQUALS SIGN
{62, 62}, ; //#GREATER-THAN SIGN
{63, 63}, ; //#QUESTION MARK
{64, 64}, ; //#COMMERCIAL AT
{65, 65}, ; //#LATIN CAPITAL LETTER A
{66, 66}, ; //#LATIN CAPITAL LETTER B
{67, 67}, ; //#LATIN CAPITAL LETTER C
{68, 68}, ; //#LATIN CAPITAL LETTER D
{69, 69}, ; //#LATIN CAPITAL LETTER E
{70, 70}, ; //#LATIN CAPITAL LETTER F
{71, 71}, ; //#LATIN CAPITAL LETTER G
{72, 72}, ; //#LATIN CAPITAL LETTER H
{73, 73}, ; //#LATIN CAPITAL LETTER I
{74, 74}, ; //#LATIN CAPITAL LETTER J
{75, 75}, ; //#LATIN CAPITAL LETTER K
{76, 76}, ; //#LATIN CAPITAL LETTER L
{77, 77}, ; //#LATIN CAPITAL LETTER M
{78, 78}, ; //#LATIN CAPITAL LETTER N
{79, 79}, ; //#LATIN CAPITAL LETTER O
{80, 80}, ; //#LATIN CAPITAL LETTER P
{81, 81}, ; //#LATIN CAPITAL LETTER Q
{82, 82}, ; //#LATIN CAPITAL LETTER R
{83, 83}, ; //#LATIN CAPITAL LETTER S
{84, 84}, ; //#LATIN CAPITAL LETTER T
{85, 85}, ; //#LATIN CAPITAL LETTER U
{86, 86}, ; //#LATIN CAPITAL LETTER V
{87, 87}, ; //#LATIN CAPITAL LETTER W
{88, 88}, ; //#LATIN CAPITAL LETTER X
{89, 89}, ; //#LATIN CAPITAL LETTER Y
{90, 90}, ; //#LATIN CAPITAL LETTER Z
{91, 91}, ; //#LEFT SQUARE BRACKET
{92, 92}, ; //#REVERSE SOLIDUS
{93, 93}, ; //#RIGHT SQUARE BRACKET
{94, 94}, ; //#CIRCUMFLEX ACCENT
{95, 95}, ; //#LOW LINE
{96, 96}, ; //#GRAVE ACCENT
{97, 97}, ; //#LATIN SMALL LETTER A
{98, 98}, ; //#LATIN SMALL LETTER B
{99, 99}, ; //#LATIN SMALL LETTER C
{100, 100}, ; //#LATIN SMALL LETTER D
{101, 101}, ; //#LATIN SMALL LETTER E
{102, 102}, ; //#LATIN SMALL LETTER F
{103, 103}, ; //#LATIN SMALL LETTER G
{104, 104}, ; //#LATIN SMALL LETTER H
{105, 105}, ; //#LATIN SMALL LETTER I
{106, 106}, ; //#LATIN SMALL LETTER J
{107, 107}, ; //#LATIN SMALL LETTER K
{108, 108}, ; //#LATIN SMALL LETTER L
{109, 109}, ; //#LATIN SMALL LETTER M
{110, 110}, ; //#LATIN SMALL LETTER N
{111, 111}, ; //#LATIN SMALL LETTER O
{112, 112}, ; //#LATIN SMALL LETTER P
{113, 113}, ; //#LATIN SMALL LETTER Q
{114, 114}, ; //#LATIN SMALL LETTER R
{115, 115}, ; //#LATIN SMALL LETTER S
{116, 116}, ; //#LATIN SMALL LETTER T
{117, 117}, ; //#LATIN SMALL LETTER U
{118, 118}, ; //#LATIN SMALL LETTER V
{119, 119}, ; //#LATIN SMALL LETTER W
{120, 120}, ; //#LATIN SMALL LETTER X
{121, 121}, ; //#LATIN SMALL LETTER Y
{122, 122}, ; //#LATIN SMALL LETTER Z
{123, 123}, ; //#LEFT CURLY BRACKET
{124, 124}, ; //#VERTICAL LINE
{125, 125}, ; //#RIGHT CURLY BRACKET
{126, 126}, ; //#TILDE
{127, 127}, ; //#DELETE
{128, 1026}, ; //#CYRILLIC CAPITAL LETTER DJE
{129, 1027}, ; //#CYRILLIC CAPITAL LETTER GJE
{130, 8218}, ; //#SINGLE LOW-9 QUOTATION MARK
{131, 1107}, ; //#CYRILLIC SMALL LETTER GJE
{132, 8222}, ; //#DOUBLE LOW-9 QUOTATION MARK
{133, 8230}, ; //#HORIZONTAL ELLIPSIS
{134, 8224}, ; //#DAGGER
{135, 8225}, ; //#DOUBLE DAGGER
{136, 8364}, ; //#EURO SIGN
{137, 8240}, ; //#PER MILLE SIGN
{138, 1033}, ; //#CYRILLIC CAPITAL LETTER LJE
{139, 8249}, ; //#SINGLE LEFT-POINTING ANGLE QUOTATION MARK
{140, 1034}, ; //#CYRILLIC CAPITAL LETTER NJE
{141, 1036}, ; //#CYRILLIC CAPITAL LETTER KJE
{142, 1035}, ; //#CYRILLIC CAPITAL LETTER TSHE
{143, 1039}, ; //#CYRILLIC CAPITAL LETTER DZHE
{144, 1106}, ; //#CYRILLIC SMALL LETTER DJE
{145, 8216}, ; //#LEFT SINGLE QUOTATION MARK
{146, 8217}, ; //#RIGHT SINGLE QUOTATION MARK
{147, 8220}, ; //#LEFT DOUBLE QUOTATION MARK
{148, 8221}, ; //#RIGHT DOUBLE QUOTATION MARK
{149, 8226}, ; //#BULLET
{150, 8211}, ; //#EN DASH
{151, 8212}, ; //#EM DASH
{153, 8482}, ; //#TRADE MARK SIGN
{154, 1113}, ; //#CYRILLIC SMALL LETTER LJE
{155, 8250}, ; //#SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
{156, 1114}, ; //#CYRILLIC SMALL LETTER NJE
{157, 1116}, ; //#CYRILLIC SMALL LETTER KJE
{158, 1115}, ; //#CYRILLIC SMALL LETTER TSHE
{159, 1119}, ; //#CYRILLIC SMALL LETTER DZHE
{160, 160}, ; //#NO-BREAK SPACE
{161, 1038}, ; //#CYRILLIC CAPITAL LETTER SHORT U
{162, 1118}, ; //#CYRILLIC SMALL LETTER SHORT U
{163, 1032}, ; //#CYRILLIC CAPITAL LETTER JE
{164, 164}, ;  //#CURRENCY SIGN
{165, 1168}, ; //#CYRILLIC CAPITAL LETTER GHE WITH UPTURN
{166, 166}, ; //#BROKEN BAR
{167, 167}, ; //#SECTION SIGN
{168, 1025}, ; //#CYRILLIC CAPITAL LETTER IO
{169, 169}, ; //#COPYRIGHT SIGN
{170, 1028}, ; //#CYRILLIC CAPITAL LETTER UKRAINIAN IE
{171, 171}, ; //#LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
{172, 172}, ; //#NOT SIGN
{173, 173}, ; //#SOFT HYPHEN
{174, 174}, ; //#REGISTERED SIGN
{175, 1031}, ; //#CYRILLIC CAPITAL LETTER YI
{176, 176}, ; //#DEGREE SIGN
{177, 177}, ; //#PLUS-MINUS SIGN
{178, 1030}, ; //#CYRILLIC CAPITAL LETTER BYELORUSSIAN-UKRAINIAN I
{179, 1110}, ; //#CYRILLIC SMALL LETTER BYELORUSSIAN-UKRAINIAN I
{180, 1169}, ; //#CYRILLIC SMALL LETTER GHE WITH UPTURN
{181, 181}, ; //#MICRO SIGN
{182, 182}, ; //#PILCROW SIGN
{183, 183}, ; //#MIDDLE DOT
{184, 1105}, ; //#CYRILLIC SMALL LETTER IO
{185, 8470}, ; //#NUMERO SIGN
{186, 1108}, ; //#CYRILLIC SMALL LETTER UKRAINIAN IE
{187, 187}, ; //#RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
{188, 1112}, ; //#CYRILLIC SMALL LETTER JE
{189, 1029}, ; //#CYRILLIC CAPITAL LETTER DZE
{190, 1109}, ; //#CYRILLIC SMALL LETTER DZE
{191, 1111}, ; //#CYRILLIC SMALL LETTER YI
{192, 1040}, ; //#CYRILLIC CAPITAL LETTER A
{193, 1041}, ; //#CYRILLIC CAPITAL LETTER BE
{194, 1042}, ; //#CYRILLIC CAPITAL LETTER VE
{195, 1043}, ; //#CYRILLIC CAPITAL LETTER GHE
{196, 1044}, ; //#CYRILLIC CAPITAL LETTER DE
{197, 1045}, ; //#CYRILLIC CAPITAL LETTER IE
{198, 1046}, ; //#CYRILLIC CAPITAL LETTER ZHE
{199, 1047}, ; //#CYRILLIC CAPITAL LETTER ZE
{200, 1048}, ; //#CYRILLIC CAPITAL LETTER I
{201, 1049}, ; //#CYRILLIC CAPITAL LETTER SHORT I
{202, 1050}, ; //#CYRILLIC CAPITAL LETTER KA
{203, 1051}, ; //#CYRILLIC CAPITAL LETTER EL
{204, 1052}, ; //#CYRILLIC CAPITAL LETTER EM
{205, 1053}, ; //#CYRILLIC CAPITAL LETTER EN
{206, 1054}, ; //#CYRILLIC CAPITAL LETTER O
{207, 1055}, ; //#CYRILLIC CAPITAL LETTER PE
{208, 1056}, ; //#CYRILLIC CAPITAL LETTER ER
{209, 1057}, ; //#CYRILLIC CAPITAL LETTER ES
{210, 1058}, ; //#CYRILLIC CAPITAL LETTER TE
{211, 1059}, ; //#CYRILLIC CAPITAL LETTER U
{212, 1060}, ; //#CYRILLIC CAPITAL LETTER EF
{213, 1061}, ; //#CYRILLIC CAPITAL LETTER HA
{214, 1062}, ; //#CYRILLIC CAPITAL LETTER TSE
{215, 1063}, ; //#CYRILLIC CAPITAL LETTER CHE
{216, 1064}, ; //#CYRILLIC CAPITAL LETTER SHA
{217, 1065}, ; //#CYRILLIC CAPITAL LETTER SHCHA
{218, 1066}, ; //#CYRILLIC CAPITAL LETTER HARD SIGN
{219, 1067}, ; //#CYRILLIC CAPITAL LETTER YERU
{220, 1068}, ; //#CYRILLIC CAPITAL LETTER SOFT SIGN
{221, 1069}, ; //#CYRILLIC CAPITAL LETTER E
{222, 1070}, ; //#CYRILLIC CAPITAL LETTER YU
{223, 1071}, ; //#CYRILLIC CAPITAL LETTER YA
{224, 1072}, ; //#CYRILLIC SMALL LETTER A
{225, 1073}, ; //#CYRILLIC SMALL LETTER BE
{226, 1074}, ; //#CYRILLIC SMALL LETTER VE
{227, 1075}, ; //#CYRILLIC SMALL LETTER GHE
{228, 1076}, ; //#CYRILLIC SMALL LETTER DE
{229, 1077}, ; //#CYRILLIC SMALL LETTER IE
{230, 1078}, ; //#CYRILLIC SMALL LETTER ZHE
{231, 1079}, ; //#CYRILLIC SMALL LETTER ZE
{232, 1080}, ; //#CYRILLIC SMALL LETTER I
{233, 1081}, ; //#CYRILLIC SMALL LETTER SHORT I
{234, 1082}, ; //#CYRILLIC SMALL LETTER KA
{235, 1083}, ; //#CYRILLIC SMALL LETTER EL
{236, 1084}, ; //#CYRILLIC SMALL LETTER EM
{237, 1085}, ; //#CYRILLIC SMALL LETTER EN
{238, 1086}, ; //#CYRILLIC SMALL LETTER O
{239, 1087}, ; //#CYRILLIC SMALL LETTER PE
{240, 1088}, ; //#CYRILLIC SMALL LETTER ER
{241, 1089}, ; //#CYRILLIC SMALL LETTER ES
{242, 1090}, ; //#CYRILLIC SMALL LETTER TE
{243, 1091}, ; //#CYRILLIC SMALL LETTER U
{244, 1092}, ; //#CYRILLIC SMALL LETTER EF
{245, 1093}, ; //#CYRILLIC SMALL LETTER HA
{246, 1094}, ; //#CYRILLIC SMALL LETTER TSE
{247, 1095}, ; //#CYRILLIC SMALL LETTER CHE
{248, 1096}, ; //#CYRILLIC SMALL LETTER SHA
{249, 1097}, ; //#CYRILLIC SMALL LETTER SHCHA
{250, 1098}, ; //#CYRILLIC SMALL LETTER HARD SIGN
{251, 1099}, ; //#CYRILLIC SMALL LETTER YERU
{252, 1100}, ; //#CYRILLIC SMALL LETTER SOFT SIGN
{253, 1101}, ; //#CYRILLIC SMALL LETTER E
{254, 1102}, ; //#CYRILLIC SMALL LETTER YU
{255, 1103}; //#CYRILLIC SMALL LETTER YA
}

Return aRet

Static Function UTF2CP1252()
Local aRet
aRet := {;
{128, 8364}, ;//EURO SIGN
{130, 8218}, ;//SINGLE LOW-9 QUOTATION MARK
{131, 402}, ;//LATIN SMALL LETTER F WITH HOOK
{132, 8222}, ;//DOUBLE LOW-9 QUOTATION MARK
{133, 8230}, ;//HORIZONTAL ELLIPSIS
{134, 8224}, ;//DAGGER
{135, 8225}, ;//DOUBLE DAGGER
{136, 710}, ;//MODIFIER LETTER CIRCUMFLEX ACCENT
{137, 8240}, ;//PER MILLE SIGN
{138, 352}, ;//LATIN CAPITAL LETTER S WITH CARON
{139, 8249}, ;//SINGLE LEFT-POINTING ANGLE QUOTATION MARK
{140, 338}, ;//LATIN CAPITAL LIGATURE OE
{142, 381}, ;//LATIN CAPITAL LETTER Z WITH CARON
{145, 8216}, ;//LEFT SINGLE QUOTATION MARK
{146, 8217}, ;//RIGHT SINGLE QUOTATION MARK
{147, 8220}, ;//LEFT DOUBLE QUOTATION MARK
{148, 8221}, ;//RIGHT DOUBLE QUOTATION MARK
{149, 8226}, ;//BULLET
{150, 8211}, ;//EN DASH
{151, 8212}, ;//EM DASH
{152, 732}, ;//SMALL TILDE
{153, 8482}, ;//TRADE MARK SIGN
{154, 353}, ;//LATIN SMALL LETTER S WITH CARON
{155, 8250}, ;//SINGLE RIGHT-POINTING ANGLE QUOTATION MARK
{156, 339}, ;//LATIN SMALL LIGATURE OE
{158, 382}, ;//LATIN SMALL LETTER Z WITH CARON
{159, 376};//LATIN CAPITAL LETTER Y WITH DIAERESIS
}
Return aRet

*/
// Russia_R5
