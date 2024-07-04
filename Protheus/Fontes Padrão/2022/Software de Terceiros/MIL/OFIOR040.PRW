#INCLUDE "ofior040.ch"
#Include "protheus.ch"
#Include "Fileio.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ Ofior040 ³ Autor ³ Andre                 ³ Data ³ 22/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Bloqueto de pagamento Bancario                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOR040(aAutom)
Local i := 0
Private nLin := 1
Private aPag := 1
Private nIte := 1
Private aReturn  := { OemToAnsi(STR0001), 1,OemToAnsi(STR0002), 2, 2, 2,,1 }  //### //"Zebrado"###"Administracao"
Private lA1_IBGE := If(SA1->(FieldPos("A1_IBGE"))>0,.t.,.f.)

if aAutom # Nil
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Variaveis utilizadas para parametros                         ³
   //³ mv_par01        //  Numero do Boleto                         ³
   //³ mv_par02        //  Cliente                                  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   //PERGUNTE("OFR040")

   mv_par01 := aAutom[1]  //Nro do Bloqueto
   mv_par02 := aAutom[2]  //Cliente
   mv_par03 := aAutom[3]  //Loja
   mv_par03 := aAutom[4]  //Nome do Cliente
   mv_par05 := aAutom[5]  //Parcela
   mv_par06 := aAutom[6]  //Obs 1
   mv_par07 := aAutom[7]  //Obs 2
   mv_par08 := aAutom[8]  //Obs 3
   mv_par09 := aAutom[9]  //Banco
Endif
cAlias   := "SE1"
NomeRel  := STR0008
cPerg   := "OFR040"
cDesc1   := STR0003 //"Boleto de Pagamento"
aOrdem   := {STR0004} //"Grupo+Cota"
lHabil   := .f.
cTamanho := "P"
nOpca    := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Ambientais                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cbTxt    := Space(10)
cbCont   := 0
cString  := "SE1"
Li       := 80
m_Pag    := 1
wnRel    := NomeRel
cTitulo  := STR0005 //"Emissao do Boleto de Pagamento"
cabec1   := ""
cabec2   := ""
nomeprog := "OFIOR040"
tamanho  := "M"
nCaracter:= 18
//nLin     := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
NomeRel := SetPrint(cAlias,NomeRel,cPerg,@cTitulo,cDesc1,,,lHabil,aOrdem,,cTamanho)
if nLastKey == 27
	Return
Endif

If Empty(MV_PAR01).or. Empty(MV_PAR03) .or.  Empty(MV_PAR04) .or.  Empty(MV_PAR05) .or. Empty(MV_PAR09)
  Help("  ",1,"R010FALPAR")                                     
  return .f.
EndIf

aClientes := {}
DbSelectArea("SE1")
DbSetOrder(1)
DbSeek(xFilial("SE1")+"001"+mv_par01)        //Numero do Bloqueto
Do While !EOF() .and. xFilial("SE1")==SE1->E1_FILIAL .and. (SE1->E1_NUM  == mv_par01)
   DbSelectArea("SA1")
   DbSetOrder(1)
   DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)
   if mv_par05 = Nil .or. (SE1->E1_PREFIXO == mv_par05)
		If lA1_IBGE
			VAM->(DbSetOrder(1))	
			VAM->(Dbseek(xFilial("VAM")+SA1->A1_IBGE))
			aadd(aClientes,{SA1->A1_COD,SA1->A1_LOJA,SA1->A1_NOME,SA1->A1_END,VAM->VAM_DESCID,VAM->VAM_ESTADO,SE1->E1_NUM,SE1->E1_PREFIXO,SE1->E1_VENCREA,SE1->E1_VALOR,SE1->E1_DESCONT,SE1->E1_VALOR,mv_par06,mv_par07})
		Else
			aadd(aClientes,{SA1->A1_COD,SA1->A1_LOJA,SA1->A1_NOME,SA1->A1_END,SA1->A1_MUN,SA1->A1_EST,SE1->E1_NUM,SE1->E1_PREFIXO,SE1->E1_VENCREA,SE1->E1_VALOR,SE1->E1_DESCONT,SE1->E1_VALOR,mv_par06,mv_par07})
		EndIf
   Endif
   DbSelectArea("SE1")
   DbSkip()
Enddo

SetDefault(aReturn,cAlias)

Set Printer to &NomeRel
Set Printer On
Set Device  to Printer

if mv_par09 == 1  // Banco do Brasil

	For i:=1 to Len(aClientes)

		@ nLin + 002,057  pSay aClientes[i,09]
		@ nLin + 005,010  pSay dDataBase
		@ nLin + 005,035  pSay aClientes[i,4]

		@ nLin + 007,062  pSay aClientes[i,12]
		@ nLin + 009,002  pSay mv_par06
		@ nLin + 010,002  pSay mv_par07
		@ nLin + 011,002  pSay mv_par08
		@ nLin + 012,002  pSay aClientes[i,13]
		@ nLin + 013,002  pSay aClientes[i,14]

		@ nLin + 014,002  pSay aClientes[i,2]
		@ nLin + 014,010  pSay aClientes[i,3]
		@ nLin + 015,002  pSay aClientes[i,4]
		@ nLin + 015,045  pSay aClientes[i,5]
		@ nLin + 015,070  pSay aClientes[i,6]

      Eject

	Next

Elseif mv_par09 == 2  // Bradesco

	For i:=1 to Len(aClientes)

		@ nLin + 002,057  pSay aClientes[i,09]
		@ nLin + 005,010  pSay dDataBase
		@ nLin + 005,032  pSay aClientes[i,7]

		@ nLin + 007,062  pSay aClientes[i,1]
		@ nLin + 009,002  pSay mv_par06
		@ nLin + 010,002  pSay mv_par07
		@ nLin + 011,002  pSay mv_par08
		@ nLin + 012,002  pSay aClientes[i,13]
		@ nLin + 013,002  pSay aClientes[i,14]

		@ nLin + 014,002  pSay aClientes[i,2]
		@ nLin + 014,010  pSay aClientes[i,3]
		@ nLin + 015,002  pSay aClientes[i,4]
		@ nLin + 015,045  pSay aClientes[i,5]
		@ nLin + 015,070  pSay aClientes[i,6]

		Eject

	Next

Elseif mv_par09 == 3  // Banco Real

	For i:=1 to Len(aClientes)

		@ nLin + 002,057  pSay aClientes[i,09]
		@ nLin + 005,010  pSay dDataBase
		@ nLin + 005,032  pSay aClientes[i,7]

		@ nLin + 007,062  pSay aClientes[i,8]
		@ nLin + 009,002  pSay mv_par06
		@ nLin + 010,002  pSay mv_par07
		@ nLin + 011,002  pSay mv_par08
		@ nLin + 012,002  pSay aClientes[i,13]
		@ nLin + 013,002  pSay aClientes[i,14]

		@ nLin + 014,002  pSay aClientes[i,2]
		@ nLin + 014,010  pSay aClientes[i,3]
		@ nLin + 015,002  pSay aClientes[i,4]
		@ nLin + 015,045  pSay aClientes[i,5]
		@ nLin + 015,070  pSay aClientes[i,6]

		Eject

	Next

Endif

MsgInfo(STR0006,STR0007) //"Bloqueto Emitido ..."###"Atencao!"

SetPrc(0,0)        // (Zera o Formulario)
MS_FLUSH()

Set Print to
Set Device to Screen

Return .T.
