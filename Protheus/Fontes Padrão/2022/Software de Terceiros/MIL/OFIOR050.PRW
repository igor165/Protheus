#INCLUDE "ofior050.ch"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ OFIOR050 บ Autor ณ Valdir F. Silva    บ Data ณ  20/06/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de habilidades do produtivo                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIOR050()
Local aOrd           := {}
Local cDesc1         := STR0001 // //"Este programa tem como objetivo imprimir as habilidades "
Local cDesc2         := STR0002 // //"do produtivo															"
Local cDesc3         := ""
Local imprime        := .T.
Local wnrel          := "OFIOR050" // Coloque aqui o nome do arquivo usado para impressao em disco
Local cString        := "VAI"
Private titulo       := STR0003 // //"Habilidades do produtivo"
Private nLin         := 80
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 80
Private tamanho      := "P"
Private Cabec1       := ""
Private Cabec2       := ""
Private nTipo        := 15
Private aReturn      := { STR0004, 1, STR0005, 1, 2, 1, "", 1} //### //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cPerg        := "VOR050"
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01

DbSelectArea("VAI")
DbSetOrder(1)

//ValidPerg()

Pergunte(cPerg,.F.)

wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
EndIf

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
EndIf

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|lEnd| OFIOR50IMP(@lEnd,wnrel,cString)},Titulo)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณOFIOR50IMPบ Autor ณ Valdir F. Silva    บ Data ณ  20/06/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar para a impressao do relatorio de 			  บฑฑ
ฑฑบ          ณ habilidades do produtivo                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIOR50IMP(lEnd,wnrel,cString)

DbSelectArea(cString)
DbSetOrder(1)
VOC->(DbSetOrder(1))
VO7->(DbSetOrder(1))
VO6->(DbSetOrder(2))
SRJ->(DbSetOrder(1))
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SetRegua(RecCount())
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMV_PAR01 = MARCA 	                           ณ
//ณMV_PAR02 = MODELO                            ณ
//ณMV_PAR03 = Produtivo							   	ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
VAI->(DbSeek(xFilial("VAI")+Trim(MV_PAR03)))
While xFilial("VAI") == VAI->VAI_FILIAL .and. !VAI->(Eof())

	If lAbortPrint .or. lEnd
		@nLin,00 PSAY STR0006 // //"*** CANCELADO PELO OPERADOR ***"
		Exit
	EndIf
   
   IncRegua()
   
	If !Empty(MV_PAR03) .and. VAI_CODTEC # MV_PAR03
		VAI->(DbSkip())		
		Loop
	EndIf
	
	If VAI_FUNPRO # "1"
		VAI->(DbSkip())		
		Loop
	EndIf

	If !VOC->(DbSeek(xFilial("VOC")+VAI->VAI_CODTEC+Trim(MV_PAR01)))
		VAI->(DbSkip())		
		Loop  	
  	EndIf

   If VOC->(DbSeek(xFilial("VOC")+VAI->VAI_CODTEC))
		If !Empty(MV_PAR02) .and.!VO7->(DbSeek(xFilial("VO7")+ FG_MARSRV(VOC->VOC_CODMAR,VOC->VOC_CODSER) + VOC->VOC_CODSER + MV_PAR02))
			VOC->(DbSkip())
			Loop
		EndIf
		SRJ->(DbSeek(xFilial("SRJ")+VAI->VAI_FUNCAO))
		Cabec1:=STR0007+VAI->VAI_CODTEC+" - "+VAI->VAI_NOMTEC+STR0007+SRJ->RJ_DESC //"Produtivo: "### //" Funcao: "
		                       //marca                              Modelo                       Cod Servico                        Qtd Exe
		Cabec2:= " "+left(STR0011+space(5),5)+"  "+left(STR0012+space(35),35)+" "+left(STR0013+space(17),17)+" "+left(STR0014+space(7),7)
		Cabec(Titulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
		nLin:=9
		While xFilial("VOC") == VOC->VOC_FILIAL .and. VOC->VOC_CODPRO == VAI->VAI_CODTEC
			If !Empty(MV_PAR01) .and. VOC->VOC_CODMAR # MV_PAR01
				VOC->(DbSkip())
				Loop
			EndIf
			If nLin > 58
				Cabec(Titulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
				nLin:=9
			EndIf
			If Empty(MV_PAR02)
				VO6->(DbSeek(xFilial("VO6")+ FG_MARSRV(VOC->VOC_CODMAR,VOC->VOC_CODSER) + VOC->VOC_CODSER ))
				@ nLin,01 PSAY VOC->VOC_CODMAR+"    "+VO6->VO6_MODVEI+"      "+VOC->VOC_CODSER+"    "+Transform(VOC->VOC_QTDEXE,'999999')
				nLin++
	      Else
				VO7->(DbSeek(xFilial("VO7")+ FG_MARSRV(VOC->VOC_CODMAR,VOC->VOC_CODSER) + VOC->VOC_CODSER +MV_PAR02))
				@ nLin,01 PSAY VOC->VOC_CODMAR+"    "+VO7->VO7_MODVEI+"      "+VOC->VOC_CODSER+"    "+Transform(VOC->VOC_QTDEXE,'999999')
				nLin++  
			EndIf
			VOC->(DbSkip())
		EndDo
	Else
		VAI->(DbSkip())
		Loop
	EndIf
	VAI->(DbSkip())
Enddo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza a execucao do relatorio...                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

SET DEVICE TO SCREEN

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If aReturn[5]==1
	DbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
EndIf

MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณVALIDPERG บ Autor ณ Valdir F. Silva    บ Data ณ  20/06/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Verifica a existencia das perguntas criando-as caso seja   บฑฑ
ฑฑบ          ณ necessario (caso nao existam).                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
Static Function ValidPerg()
Local _sAlias := Alias()
Local aRegs := {}
Local i,j

DbSelectArea("SX1")
DbSetOrder(1)
cPerg := PADR(cPerg,10)
aAdd(aRegs,{cPerg,"01",STR0008,"","","mv_ch1","C", 03,0,0,"G",          "","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","VE1",""}) //"Marca             ?"
aAdd(aRegs,{cPerg,"02",STR0009,"","","mv_ch2","C", 30,0,0,"G",          "","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","V2R",""}) //"Modelo            ?"
aAdd(aRegs,{cPerg,"03",STR0010,"","","mv_ch3","C", 06,0,0,"G",          "","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","A1C",""}) //"Produtivo         ?"

For i:=1 to Len(aRegs)
	If !DbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			EndIf
		Next
		MsUnlock()
	EndIf
Next

DbSelectArea(_sAlias)

Return
*/
