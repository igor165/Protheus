#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณhspahm51  บ Autor ณAlessandro Freire   บ Data ณ  15/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Faz o fechamento da conta para guias particulares          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHM51()

Local cFiltro					:= ""

Private cDelFunc		:= ".T."
Private cCadastro	:= "Fechamento de contas particulares"
Private aRotina			:= {	{"Pesquisar"				,"AxPesqui",0,1} ,;
             										{"Visualizar"			,"AxVisual",0,2} ,;
             										{"Fechar conta"	,"hs_m51fecha",0,3} }


cFiltro	:= "GCZ_STATUS BETWEEN '0' AND '2' AND "
cFiltro += "GCZ_NUMORC <> ' ' AND EXISTS "
cFiltro += "(SELECT GCM_CODCON, GCMCODPLA FROM "+RetSqlName("GCM")
cFiltro += " WHERE GCM_CODCON = GCZ_CODCON AND "
cFiltro += "       GCM_CODPLA = GCZ_CODPLA AND "
cFiltro += "       GCM_TIPCON = '1' )"

dbSelectArea("GCZ")
dbSetOrder(1)
mBrowse(06, 01, 22, 75, "GCZ",,GCZ->GCZ_NUMORC,,,,,,,,,,,, cFiltro)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_MP12RcPบAutor  ณ ALESSANDRO FREIRE  บ Data ณ  15/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera o or็amento no SL1,SL2 e SL4 para contas particulares บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_MP12RcP() // Receb. Conta Particular
Local cRegAte	:= GCZ->GCZ_REGATE
Local lOkConv	:= .f.
Local cMsg				:= ""
Local	aArea			:= HS_SavArea({ {"GCZ", 0, 0}, {"GCM", 0, 0} })

If GCZ->GCZ_STATUS > '2'
	MsgInfo("Esta guia jแ tem faturas geradas","Aten็ใo")
	Return(nil)
EndIf

If ! Empty("GCZ_NUMORC")
	MsgInfo("Esta guia jแ possui or็amento gerado.", "Or็amento No. " + GCZ->GCZ_NUMORC )
	Return(Nil)
EndIf

dbSelectArea("GCM")
dbSeek(xFilial("GCM")+GCZ->GCZ_CODCON+GCZ->GCZ_CODPLA,.t.)
While ! Eof() .and. GCM->GCM_FILIAL == xFilial("GCM")

	cMsg	:= ""
	
	If GCM->GCM_CODCON+GCM->GCM_CODPLA != GCZ->GCZ_CODCON+GCZ->GCZ_CODPLA
		Exit
	EndIf
	
	// se a data da vigencia for maior que a data base, sai do loop
	If GCM->GCM_DATVIG > dDataBase
		Exit
	EndIf
	
	If GCM->GCM_TIPCON != '1'
		lOkConv	:= .f.
		cMsg				:= "Este plano nใo ้ particular. Nใo serแ possํvel gerar um or็amento para ele."
		Exit
	EndIf
	
	lOkConv	:= .t.

	dbSkip()
Enddo

dbSelectArea("GCZ")

// Verifica se deve ou nao continuar a rotina
If ! lOkConv
	If ! Empty(cMsg)
		MsgInfo(cMsg, "Aten็ใo")
		Return(nil)
	EndIf
EndIF

If GCZ->GCZ_STATUS <= '1'
	dbSeek(xFilial("GCZ")+GCZ->GCZ_REGATE)
	While ! Eof() .and. xFilial("GCZ") == GCZ->GCZ_FILIAL .and. GCZ->GCZ_REGATE == cRegAte
		hs_gerfat({{GCZ->GCZ_NRSEQG,"X"}})
		dbSelectArea("GCZ")
		dbSkip()
	Enddo
EndIf 

// gera o orcamento no SL1, SL2 e SL4
HS_IntLoja(cRegAte)

HS_ResArea( aArea )

Return(nil)