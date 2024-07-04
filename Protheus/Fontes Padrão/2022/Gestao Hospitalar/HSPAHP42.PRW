#INCLUDE "HSPAHP42.ch"
#INCLUDE "protheus.ch"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHP42  บ Autor ณ MARCELO JOSE       บ Data ณ  17/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ SAIDA PROGRAMADA                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHP42()
Local cListB      	:= " "
Local nOpcA       	:= 0
Local cQuery      	:= ""
Local cCond       	:= ""
Local cExists     	:= ""
Local lAchouGSB   	:= .T.
Local nRadio      	:= 1 , oRadio
Local aOptions    	:= {STR0005, STR0006, STR0002, STR0007} //"M้dico/Data/Hora/Endere็o"###"Endere็o"###"PRONTUมRIO"###"Data/Hora"
Local oTik        	:= LoadBitmap(GetResources(), "LBTIK")
Local oNo         	:= LoadBitmap(GetResources(), "LBNO")
Local oVerde      	:= LoadBitmap(GetResources(), "BR_VERDE")
Local oVermelho   	:= LoadBitmap(GetResources(), "BR_VERMELHO")
Local cUsrSol     	:= ""
Local cUsrSai     	:= ""
Local lSeekGsa					:= .F.
Local aArea        := GetArea()

Private cPerg     := "HSPP42"

Private aAgenda   := {}, oListB, oMarcaT , oDlg
Private cCodBar   := Space(18)


HS_DtvFilt("GSA")  //desativa filtro
If !Pergunte(cPerg, .T.)
	DbSelectArea("GSA")
	DbSetOrder(2)  // GSA_FILIAL + GSA_OK + GSA_DATSOL + GSA_HORSOL + GSA_NOMPAC
	HS_AtvFilt("GSA", "GSA->GSA_OK = ' ' ")
	RestArea(aArea)
	Return(Nil)
EndIf
If !HS_VldGSC(MV_PAR07)
	Return(Nil)
	RestArea(aArea)
Endif


cQuery  := "SELECT "
cQuery += "GM8.GM8_DATAGE DATAGE, "
cQuery += "GM8.GM8_HORAGE HORAGE, "
cQuery += "GM8.GM8_REGGER REGGER, "
cQuery += "GM8.GM8_NOMPAC NOMPAC, "
cQuery += "GM8.GM8_CODPRO CODPRO, "
cQuery += "GM8.GM8_CODCRM CODCRM, "
cQuery += "GM8.GM8_CODLOC CODLOC, "
cQuery += "GM8.GM8_CODAGE CODAGE, "
cQuery += "GSB.GSB_CODEND CODEND, "
cQuery += "SRA.RA_NOME NOME, "
cQuery += "GA7.GA7_DESC DESCR "
cQuery += "FROM "  + RetSqlName("GM8") + " GM8 JOIN " + RetSQLName("GSB") + " GSB ON GSB.GSB_FILIAL = '" + xFilial("GSB") + "' AND GSB.GSB_REGGER  = GM8.GM8_REGGER AND GSB.GSB_TIPEND = '1' AND GSB.D_E_L_E_T_ <> '*'"
cQuery +=                                    " JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_FILIAL = '" + xFilial("SRA") + "' AND SRA.RA_CODIGO  = GM8.GM8_CODCRM AND SRA.D_E_L_E_T_ <> '*'"
cQuery +=                                    " JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.GA7_CODPRO = GM8.GM8_CODPRO AND GA7.D_E_L_E_T_ <> '*'"
cQuery += " WHERE "
cQuery += "GM8.GM8_FILIAL = '" + xFilial( "GM8" ) + "' AND "
cQuery += "GM8.GM8_FILAGE = '" + cFilAnt + "' AND "
cQuery += "GM8.GM8_DATAGE BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' AND "
cQuery += "GM8.GM8_REGGER <> '" + SPACE(TamSx3("GM8_REGGER")[1]) + "' AND "
If !Empty(MV_PAR04)
	cQuery += "GM8.GM8_CODCRM =  '" + MV_PAR04        + "' AND "
EndIf
If !Empty(MV_PAR05)
	cQuery += "GM8.GM8_CODLOC =  '" + MV_PAR05        + "' AND "
EndIf
If !Empty(MV_PAR06)
	cQuery += "GM8.GM8_CODPRO =  '" + MV_PAR06        + "' AND "
EndIf
cQuery += "GM8.D_E_L_E_T_ <> '*' "
cQuery += "ORDER BY NOMPAC, DATAGE, HORAGE, CODEND"

If MV_PAR03 == 2
	cQuery := STRTRAN(cQuery, "GM8", "GMJ")
Endif

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY",.T.,.T.)

DbSelectArea("QRY")
While !Eof()
	
	DbSelectArea("GSD")
	DbSetOrder(1) // GSD_FILIAL + GSD_CODEND + GSD_TIPEND
	DbSeek(xFilial("GSD") + QRY->CODEND)
	
	DbSelectArea("GSA")
	DbSetOrder(3) //GSA_FILIAL+GSA_OK+GSA_REGGER+GSA_CODEND
	
	Aadd(aAgenda, {	.F.,; //1
					QRY->REGGER,; //2
					QRY->NOMPAC,; //3
					QRY->CODEND,; //4
					GSD->GSD_DESEND,; //5
					GSD->GSD_ENDRUA,; //6
					GSD->GSD_NUMERO,; //7
					GSD->GSD_PRLNUM,; //8
					QRY->CODCRM,; //9
					QRY->CODLOC,; //10
					QRY->CODPRO,; //11
					QRY->CODAGE,; //12
					HS_DTOC(STOD(QRY->DATAGE)),; //13
					QRY->HORAGE,; //14
					QRY->NOME,; //15
					QRY->DESCR,; //16
					IIf(lSeekGsa := DbSeek(xFilial("GSA") + "0" + QRY->REGGER + QRY->CODEND), "0", "1"),; //17
					IIf(lSeekGsa, HS_DTOC(GSA->GSA_DATSOL), CriaVar("GSA_DATSOL", .F.)),; //18
					IIf(lSeekGsa, GSA->GSA_HORSOL, CriaVar("GSA_HORSOL", .F.)),; //19
					IIf(lSeekGsa, GSA->GSA_NOMSOL, CriaVar("GSA_NOMSOL", .F.)),; //20
					IIf(lSeekGsa, HS_DTOC(GSA->GSA_DATENT), CriaVar("GSA_DATENT", .F.)),; //21
					IIf(lSeekGsa, GSA->GSA_HORENT, CriaVar("GSA_HORENT", .F.)),; //22
					IIf(lSeekGsa, GSA->GSA_NOMENT, CriaVar("GSA_NOMENT", .F.)),; //23
					IIf(lSeekGsa, GSA->GSA_CODMOT, CriaVar("GSA_CODMOT", .F.)),; //24
					IIf(lSeekGsa, GSA->GSA_OBSERV, CriaVar("GSA_OBSERV", .F.)),; //25
					IIf(GSA->(FieldPos("GSA_REGATE")) > 0,(IIf(lSeekGsa, GSA->GSA_REGATE, CriaVar("GSA_REGATE", .F.))),"")}) //26
	
	DbSelectArea("QRY")
	Dbskip()
EndDo

DbSelectArea("QRY")
DbCloseArea()

/*===============================================================================================================*/
If Len(aAgenda) == 0
	HS_MsgInf(STR0009, STR0008, STR0001) //"Nใo foi encontrado nenhum agendamento." ###"Atencao"###"Saํda Programada"
	DbSelectArea("GSA")
	DbSetOrder(2) // GSA_FILIAL + GSA_OK + GSA_DATSOL + GSA_HORSOL + GSA_NOMPAC
	HS_AtvFilt("GSA", "GSA->GSA_OK = ' ' ")
	RestArea(aArea)
	Return(Nil)
Endif

DEFINE MSDIALOG oDlg FROM 0,0 TO 400,945 PIXEL TITLE STR0001 //"Saํda Programada"
@ 55,01 LISTBOX oListB VAR cListB FIELDS HEADER " "," ", STR0010, STR0011, STR0031, STR0002, STR0003, STR0012, STR0006, STR0013, STR0014, STR0015, "Prl" ; //"Data"###"Hora"###"M้dico"###"PRONTUARIO"###"NOME"###"Procedimento"###"Endere็o"###"Descri็ใo"###"End"###"Num"
SIZE 870, 340 OF oDlg PIXEL ON DBLCLICK(FS_Marc(oListB, aAgenda))
oListB:Align := CONTROL_ALIGN_ALLCLIENT
oListB:SetArray( aAgenda )
oListB:Refresh()
oListB:bLine := {|| { IIf( !aAgenda[oListB:nAt, 1],oNo, oTik),; //  marck
IIf( aAgenda[oListB:nAt, 17] == "0", oVermelho, oVerde),; // Data
aAgenda[oListB:nAt, 13],; // Data
aAgenda[oListB:nAt, 14],; // Hora
aAgenda[oListB:nAt, 15],; // Medico
aAgenda[oListB:nAt,  2],; // Prontuario
aAgenda[oListB:nAt,  3],; // Paciente
aAgenda[oListB:nAt, 16],; // Procedimento
aAgenda[oListB:nAt,  4],; // Endereco
aAgenda[oListB:nAt,  5],; // Descricao
aAgenda[oListB:nAt,  6],; // End
aAgenda[oListB:nAt,  7],; // Num
aAgenda[oListB:nAt,  8]}} // Prl

oPanel 	:=	tPanel():New(0, 0,, oDlg,,,,,, 60, 60)
oPanel:Align := CONTROL_ALIGN_TOP

oMarcaT := { {"Checked", {|| FS_Mtodos(oListB,aAgenda) }, STR0016, STR0017} }  //"Marca/Desmarca Todos ou Inverte sele็ใo."###"Sele็ใo"
oSay1   := tSay():New(23,10,{|| STR0018 },oPanel,,,,,,.T.,,,130,10)  //"C๓digo de Barras(Prontuแrio+Endere็o): "
oGet1   := tGet():New(20,110,{|u| if(PCount()>0, cCodBar := u , cCodBar ) }, oPanel, 70,10,"@!",{|| FS_CodBar(cCodBar) },,,,,,.T.,,,,,,,,,,"cCodBar")
oRadio  := tRadMenu():New(15,200,aOptions,{|u|if(PCount()>0,nRadio:=u,nRadio)},oPanel,,{|| FS_ORDEM(nRadio)},,,,,,100,10,,,,.T.)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, oDlg:End()  }, {|| nOpcA := 0, oDlg:End() },,oMarcaT)

If nOpcA == 1
	dbSelectArea("GSA")
	dbSetOrder(3) // GSA_FILIAL + GSA_OK + GSA_REGGER + GSA_CODEND
	Begin Transaction
	FS_GerSol()
	End Transaction
EndIf

DbSelectArea("GSA")
DbSetOrder(2) // GSA_FILIAL + GSA_OK + GSA_DATSOL + GSA_HORSOL + GSA_NOMPAC
HS_AtvFilt("GSA", "GSA->GSA_OK = ' ' ")

RestArea(aArea)

Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFS_ORDEM  ณ Autor Marcelo Jose                         Data 03/05/2005 บฑฑ
ฑฑบdefinicao:ณ Altera a ordenacao da marcbrowse                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function FS_ORDEM(nVem)
If nVem == 1
	aSort(aAgenda,,,{|x,y| x[15] + DtoS(CtoD(x[13])) + x[14]+ x[4] < y[15] + DtoS(CtoD(y[13])) + y[14] + y[4] } )
ElseIf nVem == 2
	aSort(aAgenda,,,{|x,y| x[4] < y[4]})
ElseIf nVem == 3
	aSort(aAgenda,,,{|x,y| x[2] < y[2]})
ElseIf nVem == 4
	aSort(aAgenda,,,{|x,y| DtoS(CtoD(x[13])) + x[14] <  DtoS(CtoD(y[13])) + y[14]  })
EndIf
oListB:Refresh()
Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFS_CodBar ณ Autor Marcelo Jose                         Data 03/05/2005 บฑฑ
ฑฑบdefinicao:ณ le codigo de barras do prontuario                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function FS_CodBar(cVemCodbar)
Local cRegGer := Subs(cVemCodbar,1,6), cCodEnd := Subs(cVemCodbar,7,12) //, nCtaFor := 1
Local nPos    := 0
If (nPos := aScan(aAgenda, {|x| x[2]+x[4] == cVemCodBar})) > 0
	If aAgenda[nPos, 17] == "0"
		HS_MsgInf(STR0029, STR0008, STR0001)  //"Este prontuแrio nใo se encontra no SPP no momento. Opera็ใo invแlida."###"Aten็ใo"###"Saํda Programada"
	Else
		aAgenda[nPos, 1] := !aAgenda[nPos, 1]
		oListB:Refresh()
	Endif
Else
	If !Empty(cVemcodBar)
		Hs_MsgInf(STR0032, STR0008, STR0001) //"Prontuแrio/Endere็o nใo localizado."###Aten็ใo###"Saํda Programada"
	Endif
EndIf

If !Empty( cCodBar)
	oGet1:SetFocus()
EndIf
cCodBar := space(18)

Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFS_Marc   ณ Autor Marcelo Jose                         Data 03/05/2005 บฑฑ
ฑฑบdefinicao:ณ Marca itens da marcbrowse                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function FS_Marc(oListB, aAgenda)
If Len(aAgenda) > 0
	If aAgenda[oListB:nAt, 17] == "0"
		HS_MsgInf(STR0029, STR0008, STR0001)  //"Este prontuแrio nใo se encontra no SPP no momento. Opera็ใo invแlida."###"Aten็ใo"###"Saํda Programada"
	ElseIf Empty(aAgenda[oListB:nAt,4])
		HS_MsgInf(STR0019, STR0008, STR0001)  //"Prontuแrio sem endere็o no SPP...Opera็ใo invแlida."###"Aten็ใo"###"Saํda Programada"
	Else
		aAgenda[oListB:nAt, 1] := !aAgenda[oListB:nAt, 1]
		oListB:Refresh()
	EndIf
EndIf
Return(Nil) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFS_Mtodos ณ Autor Marcelo Jose                         Data 03/05/2005 บฑฑ
ฑฑบdefinicao:ณ marca todos os itens da markbrowse                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function FS_Mtodos(oListB,aAgenda)
Local nCtaMarca
For nCtaMarca := 1 to Len(aAgenda)
	If aAgenda[nCtaMarca, 17] == "1".AND. !Empty(aAgenda[nCtaMarca,4])
		aAgenda[nCtaMarca, 1] := !aAgenda[nCtaMarca, 1]
	Endif
Next
oListB:Refresh()
oListB:nAt := 1
Return(Nil) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบFS_GerSol ณ Autor Marcelo Jose                         Data 03/05/2005 บฑฑ
ฑฑบdefinicao:ณ Gera solicitacoes de prontuarios                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function FS_GerSol()
Local nCtaFor, cCodNovo:= "", lSucesso := .F., lGeraLote := .T., cOldArq

dbSelectArea("GSA")
dbSetOrder(3) // GSA_FILIAL + GSA_OK + GSA_REGGER + GSA_CODEND
If Len(aAgenda) > 0
	For nCtaFor := 1 to Len(aAgenda)
		If aAgenda[nCtaFor,1]
			
			If MV_PAR08 == 1
				If lGeraLote
					cAliasOld := Alias()
					DbSelectArea("GSG")
					DbSetOrder(1) // GSG_FILIAL + GSG_LOTE
					M->GSG_LOTE := CriaVar("GSG_LOTE")
					M->GSG_LOTE := HS_VSxeNum("GSG", "M->GSG_LOTE", 1)
					RecLock("GSG", .T.)
					GSG->GSG_LOTE   := M->GSG_LOTE
					GSG->GSG_DATA   := dDataBase
					GSG->GSG_HORA   := TIME()
					GSG->GSG_LOGARQ := HS_LOGARQ()
					MsUnLock()
					DbSelectArea(cAliasOld)
					lGeraLote := .F.
				EndIf
			EndIf
			
			cCodNovo  := GetSx8Num("GSA","GSA_CODSOL")
			ConfirmSX8()
			
			RecLock("GSA", .T.)
			GSA->GSA_CODSOL := cCodNovo
			GSA->GSA_DATSOL := DDATABASE
			GSA->GSA_HORSOL := TIME()
			GSA->GSA_REGGER := aAgenda[nCtaFor,2]
			GSA->GSA_NOMPAC := aAgenda[nCtaFor,3]
			GSA->GSA_CODEND := aAgenda[nCtaFor,4]
			GSA->GSA_NOMSOL := cUserName
			GSA->GSA_LOGARQ := HS_LOGARQ()
			GSA->GSA_CODLOC := aAgenda[nCtaFor,10]
			GSA->GSA_CODCRM := aAgenda[nCtaFor,9]
			GSA->GSA_CODMOT := MV_PAR07
			GSA->GSA_CODPRO := aAgenda[nCtaFor,11]
			IF MV_PAR08 == 1
				GSA->GSA_OK     := "0"
				GSA->GSA_LOTE   := M->GSG_LOTE
				GSA->GSA_DATENT := DDATABASE
				GSA->GSA_HORENT := TIME()
				GSA->GSA_USRENT := "  "
				GSA->GSA_NOMENT := cUserName
			EndIf
			
			IF Hs_ExisDic({{"C","GSA_ORISOL"}})
				GSA->GSA_ORISOL := "1"
			EndIf
			
			GSA->GSA_OBSERV := IIf(MV_PAR03 == 1, "MA - ", "RS - ") + aAgenda[nCtaFor][13] + " " + aAgenda[nCtaFor][14]
			MsUnLock()
			
			/* Atualiza o vetor aAgenda com os dados da GSA para poder ser utilizado na impressao do Protocolo - HS_ImpSol() */
			aAgenda[nCtaFor][18] := GSA->GSA_DATSOL
			aAgenda[nCtaFor][19] := GSA->GSA_HORSOL
			aAgenda[nCtaFor][20] := GSA->GSA_NOMSOL
			aAgenda[nCtaFor][21] := GSA->GSA_DATENT
			aAgenda[nCtaFor][22] := GSA->GSA_HORENT
			aAgenda[nCtaFor][23] := GSA->GSA_NOMENT
			aAgenda[nCtaFor][24] := GSA->GSA_CODMOT
			aAgenda[nCtaFor][25] := GSA->GSA_OBSERV
			If GSA->(FieldPos("GSA_REGATE")) > 0
				aAgenda[nCtaFor][26] := GSA->GSA_REGATE
			Endif
			lSucesso := .T.
			cOldArq := Alias()
			
			If MV_PAR03 == 1 // Agenda Ambulatorial
				dbSelectArea("GM8")
				dbSetOrder(1) // GM8_FILIAL + GM8_CODAGE
				If DbSeek(xFilial("GM8") + aAgenda[nCtaFor,12] ) // GM8/1
					RecLock("GM8", .F.)
					GM8->GM8_CODSOL := cCodNovo
					MsUnLock()
				EndIf
			Else // Reserva Cir๚rgica
				dbSelectArea("GMJ")
				dbSetOrder(1) // GMJ_FILIAL + GMJ_CODAGE
				If DbSeek(xFilial("GMJ") + aAgenda[nCtaFor,12] ) // GMJ/1
					RecLock("GMJ", .F.)
					GMJ->GMJ_CODSOL := cCodNovo
					MsUnLock()
				EndIf
			Endif
			DbSelectArea(cOldArq)
		EndIf
	Next
EndIf

If lSucesso
	HS_MsgInf(STR0004, STR0008, STR0001) //"Prontuแrio(s) Selecionado(s) com sucesso. "###Aten็ใo###"Saํda Programada"
	If MV_PAR08 == 1
		//HS_ImpSol(M->GSG_LOTE)
		HS_ImpSol(M->GSG_LOTE, aAgenda, .T.)
	EndIf
EndIf
Return(Nil)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบHS_ImpSol ณ Autor Marcelo Jose                         Data 03/05/2005 บฑฑ
ฑฑบdefinicao:ณ Cabecalho de impressao da checagem de solicitacoes/retornosบฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
	/*
	Posicoes do aAgenda:
	----------------------------
	01 Nใo deletado ?
	02 Prontuario
	03 Nome do Paciente
	04 Codigo do endereco
	05 Nome do endereco
	06 Rua (Endereco)
	07 Numero (Endereco)
	08 Prateleira (Endereco)
	09 CRM medico
	10 Codigo do setor
	11 Codigo do procedimento
	12 Codigo do agendamento
	13 Data do agendamento
	14 Hora do agendamento
	15 Nome do profissional
	16 Descricao do procedimento
	17 0 = Atendida; 1 = Retornada
	18 Data da solicitacao
	19 Hora da solicitacao
	20 Nome do solicitante
	21 Data de Entrega/Retorno
	22 Hora de Entrega/Retorno
	23 Nome de Entrega/Retorno
	24 Codigo do motivo
	25 Observacao
	----------------------------
	*/
FUNCTION HS_ImpSol(cVemLote, aAgenda, lAtende)
Local cDesc1         	:= STR0020 //"Este programa tem como objetivo imprimir relat๓rio "
Local cDesc2         	:= STR0021 //"de acordo com os parโmetros informados pelo usuแrio."
Local cDesc3         	:= STR0022 //"S A M E"
Local cPict          	:= ""
Local Titulo         	:= ""
Local nLin           	:= 80

Local Cabec1         	:= ""
Local Cabec2         	:= ""
Local imprime        	:= .T.
Local aOrd           	:= {}
Local aConfigUsr						:= {}

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220
Private tamanho      := "G"
Private nomeprog     := "HSPAHP42" /* Coloque aqui o nome do programa para impressao no cabecalho*/
Private nTipo        := 15
Private aReturn      := {STR0023 , 1, STR0024, 2, 2, 1, "", 1}  //"Zebrado"###"Administra็ใo"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "HSPAHP42"
Private cString      := "GSA"
Private cPerg        := "HSPP39"
Private nOrder       := 0

IF ExistBlock("HSImpSol")
	Execblock("HSImpSol",.F.,.F.,{cVemLote, aAgenda, lAtende})
	Return(Nil)
EndIf

Default lAtende 						:= .T.

//Atende
If lAtende
	//"0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1
	//"0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	Cabec1 := STR0034 //"Data Sol Hora   Endere็o      Nome                                              M้dico                          Procedimento                                     Usuแrio Solicit Data Saํda Hora  Usuแrio Saํda    Visto"
	Cabec2 := STR0037 //"                                                                        Motivo Solicita็ใo                      Obs Solicita็ใo                                                                                         "
	Titulo	:= STR0035 //"PROTOCOLO DE PRONTUARIO(S) SOLICITADO(S) E ATENDIDO(S) No. " + cVemLote
	
	//Retorna
Else
	Cabec1 := STR0036 //"Data Sol Hora   Endere็o      Nome                                              M้dico                          Procedimento                                     Usuแrio Solicit Data Retor Hora  Usuแrio Retor    Visto"
	Cabec2 := STR0037 //"                                                                        Motivo Solicita็ใo                      Obs Solicita็ใo                                                                                         "
	Titulo := STR0038 //"PROTOCOLO DE PRONTUARIO(S) RETORNADO(S)"
EndIf

// Caso o paramentro MV_SPPIPRO seja .T. imprime diretamente sem exibir dialogo de impressao
If GetMV("MV_SPPIPRO",, .F.)
	PswOrder(2)
	//		If PswSeek(SUBS(cUsuario,7,15),.T.)
	If PswSeek(cUserName,.T.)
		aConfigUsr :=	PswRet(2)
		aReturn				:= {STR0013 , 1, STR0014, aConfigUsr[1][9], aConfigUsr[1][8], aConfigUsr[1][12], "", 1} //"Descri็ใo"###"End"
	Else
		aReturn				:= {STR0013 , 1,STR0014, 2, 3, "LPT1", "", 1} //"Descri็ใo"###"End"
	EndIf
	nOrder := 1 // Por setor
Else
	If !Pergunte(cPerg,.T.)
		return
	EndIf
	nOrder := MV_PAR01
	wnrel 	:= SetPrint(cString, NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .T., Tamanho,, .F.)
EndIf

If nLastKey == 27
	Return(Nil)
Endif

SetDefault(aReturn, cString)

If nLastKey == 27
	Return(Nil)
Endif

nTipo := If(aReturn[4] == 1, 15, 18)

RptStatus({|| RunReport(Cabec1, Cabec2, Titulo, nLin, aAgenda, lAtende)}, Titulo)

Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบRunReport ณ Imprime relatorio  Autor Marcelo Jose     Data 03/05/2005  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin, aAgenda, lAtende)

Local nCtaFor := 1, cFunc := "", nPosVetLoc := 0
Local cQuebra := ""
Local nTotal  := 0

If lAbortPrint
	@ nLin, 00 Psay STR0025 //"INTERROMPIDO PELO USUมRIO"
	Return(Nil)
EndIf

nLin := 80

If Len(aAgenda) > 0
	
	If nOrder == 1 	//Por Setor
		aSort(aAgenda,,,{|x,y| x[10] + x[15] + DtoS(CtoD(x[13])) + x[14] < y[10] + y[15] + DtoS(CtoD(y[13])) + y[14] } ) //Setor+medico+Data+Hora
	Else 											// Por Medico
		aSort(aAgenda,,,{|x,y| x[15] + DtoS(CtoD(x[13])) + x[14] < y[15] + DtoS(CtoD(y[13])) + y[14] } ) //Medico+Data+Hora
	EndIf
	
	cQuebra := ""
	DbSelectArea("GSA")
	DbSetOrder(1) // GSA_FILIAL + GSA_OK + GSA_REGGER + GSA_DATSOL
	
	For nCtaFor := 1 to Len(aAgenda)
		If aAgenda[nCtaFor, 1]
			
			If nLin > 55 .Or. cQuebra # IIF(nOrder == 1, aAgenda[nCtaFor,10], aAgenda[nCtaFor,15])
				
				If nLin > 55
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin    := 8
				EndIf
				
				If cQuebra # IIF(nOrder == 1, aAgenda[nCtaFor,10], aAgenda[nCtaFor,15])
					
					If !Empty(cQuebra)
						nLin := nLin+1
						@ nLin,02 Psay IIF(nOrder == 1, STR0026, STR0030) + AllTrim(Str(nTotal,4,0))  //"==> Total do Setor: "###"==> Total do Medico: "
					EndIf
					
					cQuebra := IIF(nOrder == 1, aAgenda[nCtaFor,10], aAgenda[nCtaFor,15])
					nTotal  := 0
					nLin := nLin+2
					@ nLin,00 Psay IIF(nOrder == 1, STR0027, STR0031) + IIf(nOrder == 1, HS_IniPadR('GCS', 1, cQuebra, 'GCS_NOMLOC',, .F.), cQuebra)   //"Setor: "###"M้dico: "
					nLin++
					@ nLin,00 Psay " "
					nLin++
				EndIf
				
			EndIf
			
			/*
			No caso de um procolo de solicitacoes atendidas existe apenas um prontuario atendido, ja no caso do protocolo de retorno, pode
			ser que na GSA ja exista um prontuario com as mesmas caracteristicas do que esta sendo retornado no momento, por isso
			utiliza as variaveis do vetor, pois alguns campos como observacao e motivo pode ser diferentes.
			*/
			
			If Empty(aAgenda[nCtaFor, 4])
				aAgenda[nCtaFor, 4] := Space(12)
			EndIf
			
			@ nLin, 000 Psay aAgenda[nCtaFor][18]            					// Data da solicitacao
			@ nLin, 009 Psay aAgenda[nCtaFor][19]                	// Hora
			@ nLin, 016 Psay aAgenda[nCtaFor][04]               		// Endereco
			@ nLin, 030 Psay aAgenda[nCtaFor][02]                	// Pront.
			@ nLin, 037 Psay aAgenda[nCtaFor][26]                	// Regate
			@ nLin, 044 Psay SubStr(aAgenda[nCtaFor][03],1 , 40)	// Paciente
			@ nLin, 080 Psay SubStr(aAgenda[nCtaFor][15],1 , 30)	// Medico
			@ nLin, 112 Psay SubStr(aAgenda[nCtaFor][16],1 , 48) // Nome do Procedimento
			@ nLin, 161 Psay aAgenda[nCtaFor][20]               		// Nome do Solicitante
			@ nLin, 177 Psay aAgenda[nCtaFor][21]            					// Data de saํda (Entrega)/ Retorno
			@ nLin, 188 Psay aAgenda[nCtaFor][22]                 // Hora de saํda (Entrega)/ Retorno
			@ nLin, 194 Psay SubStr(aAgenda[nCtaFor][23],1 ,15)  // Usuแrio saํda (Entrega)/ Retorno
			@ nLin, 211 Psay "|____|"
			nLin++
			@ nLin,072 Psay SubStr(HS_IniPadR("GSC", 1, aAgenda[nCtaFor][24], "GSC_DESMOT",, .F.),1 ,39)	//Motivo Solicitacao
			@ nLin,112 Psay SubStr(aAgenda[nCtaFor][25], 1, 48)  																																									//Obs Solicitacao
			nTotal++
			nLin++
			
		EndIf
	Next
	nLin++
	@ nLin,02 Psay IIF(nOrder == 1, STR0026, STR0030) + AllTrim(Str(nTotal,4,0)) //"==> Total do Setor: "###"==> Total do M้dico: "
	nLin++
	@ nLin,00 Psay Replicate("_",limite)
EndIf

DbSelectArea("GSA")
DbSetOrder(2) // GSA_FILIAL + GSA_OK + GSA_DATSOL + GSA_HORSOL + GSA_NOMPAC

/* Finaliza a execucao do relatorio...*/
SET DEVICE TO SCREEN

/* Se impressao em disco, chama o gerenciador de impressao...*/
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()
Return(Nil) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบHS_VldDtIniณValida data da pergunta Autor:Marcelo Jose Data 03/05/2005  บฑฑ
ฑฑศอออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function HS_VldDtIni()
Local lRet := .T.
If MV_PAR01 < DATE()
	HS_MsgInf(STR0028, STR0008, STR0001) //"A Data Inicial deve ser Maior ou Igual a Data Atual."###"Aten็ใo"###"Saํda Programada"
	lRet := .F.
EndIf
Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบHS_VldGSC ณValida pergunta 07 Motivo?    Andr้ Cruz   Data 03/05/2005 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function HS_VldGSC(cMotivo)
Local lRet := .F.
Local aArea := {}
Local aGSCArea := {}

If !Empty(cMotivo)
	aArea := GetArea()
	aGSCArea := GSC->(GetArea())
	DbSelectArea("GSC")
	DbSetOrder(1)  // GSC_FILIAL + GSC_CODMOT
	If !(lRet := DbSeek(xFilial("GSC")+cMotivo))
		HS_MsgInf(STR0033, STR0008, STR0001) //"Nใo foi preenchido o motivo da solicita็ใo."###"Aten็ใo"###"Saํda Programada"
	EndIf
	GSC->(RestArea(aGSCArea))
	RestArea(aArea)
EndIf
Return(lRet)
