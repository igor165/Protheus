// ษออออออออหออออออออป
// บ Versao บ 04     บ
// ศออออออออสออออออออผ
#INCLUDE "OFIgr080.ch"

#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOFIgR080  บ Autor ณ Ricardo Farinelli  บ Data ณ  28/06/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Duplicidade de Deb/Cred cupom Rev.            บฑฑ
ฑฑบ          ณ 																			                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIGR080()
Local aOrd           := {}
Local cDesc1         := STR0001 // //"Este programa tem como objetivo imprimir os lancamentos "
Local cDesc2         := STR0002 // //"de credito e devito dos cupons de revisao    para analise"
Local cDesc3         := STR0003 // //"de possiveis duplicidades"
Local imprime        := .T.
Local wnrel          := "OFIGR080" // Coloque aqui o nome do arquivo usado para impressao em disco
Local cString        := "VGB"
Local cCondicao      := ""
Local cChave         := ""
Local cIndice        := ""
Local nIndice        := ""

Private titulo       := STR0004 // //"Duplic.C/D Cupom Revisao"
Private nLin         := 80
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 80
Private tamanho      := "P"
Private Cabec1       := STR0005 // //" [Ord.Sr] [Movim] [Rev.] [Chassi do Veiculo------] [Lcto] [Dt.Mvto] [Valor-----]"
Private Cabec2       := ""
Private nTipo        := 15
Private aReturn      := { STR0006, 1, STR0007, 1, 2, 1, "", 1} //### //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cPerg        := "OFG080"
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01

DbSelectArea("VGB")
DbSetOrder(1)


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

cIndice := CriaTrab(nil,.F.)

cMontadora     := MV_PAR01

cCondicao += "VGB_CODMAR=='"+cMontadora+"' "

If !Empty(MV_PAR02)
  cCondicao += ".AND. DTOS(VGB_DATMOV)>='"+DTOS(MV_PAR02)+"' "
Endif

If !Empty(MV_PAR03)
  cCondicao += ".and. DTOS(VGB_DATMOV)<='"+DTOS(MV_PAR03)+"'"
Endif

cChave := "VGB_FILIAL+DTOS(VGB_DATMOV)+VGB_CODMAR+VGB_CHASSI"

IndRegua("VGB",cIndice,cChave,,cCondicao,STR0008) //"Aguarde Selecionando Registro para Impressao"

DbSelectArea("VGB")
nIndice := RetIndex("VGB")
#IFNDEF TOP
   dbSetIndex(cIndice+ordBagExt())
#ENDIF
dbSetOrder(nIndice+1)

RptStatus({|lEnd| OFIGR80IMP(@lEnd,wnrel,cString)},Titulo)

DbSelectArea("VGB")
RetIndex()

#IFNDEF TOP
   If File(cIndice+OrdBagExt())
      fErase(cIndice+OrdBagExt())
   Endif
#ENDIF

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณOFIGR80IMPบ Autor ณ Ricardo Farinelli  บ Data ณ  28/06/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar para a impressao do relatorio de cred/deb  บฑฑ
ฑฑบ          ณ de garantia                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao de Concessionarias                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIGR80IMP(lEnd,wnrel,cString)
Local nValTot := 0 // totalizador do relatorio 

DbselectArea(cString)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SetRegua(RecCount())
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMV_PAR01 = Data Inicial                      ณ
//ณMV_PAR02 = Data Final                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nLin > 58
	Cabec(Titulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
	nLin:=8
EndIf

Dbseek(xFilial("VGB"))

While xFilial("VGB") == VGB->VGB_FILIAL .and. !VGB->(Eof())

	If lAbortPrint .or. lEnd
		@nLin,00 PSAY STR0009 // //"*** CANCELADO PELO OPERADOR ***"
		Exit
	EndIf
   
  IncRegua()
   
	If nLin > 58
		Cabec(Titulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
		nLin:=8
	EndIf

	@ nLin,01 PSAY VGB->VGB_NUMOSV
	@ nLin,10 PSAY IIF(VGB->VGB_TIPMOV=="C",STR0010,STR0011) //### //"Credito"###"Debito"
	@ nLin,20 PSAY VGB->VGB_CODREV
	@ nLin,25 PSAY VGB->VGB_CHASSI
	@ nLin,51 PSAY VGB->VGB_LANCTO
	@ nLin,58 PSAY VGB->VGB_DATMOV
	@ nLin,68 PSAY Transform(VGB->VGB_VALLAN,"@E 9,999,999.99")
  nLin++  
	If nLin > 58
		Cabec(Titulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
		nLin:=8
	EndIf
  nValTot += VGB->VGB_VALLAN
	VGB->(DbSkip())
Enddo

@ nLin,01 PSAY STR0012+Transform(nValTot,"@E 999,999,999.99") // //"Total Geral.: "

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
