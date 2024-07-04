
#INCLUDE "plsr910.ch"
#include "PLSMGER.CH"
#include "COLORS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSR910    บAutor  ณPaulo Carnelossi   บ Data ณ  04/09/03   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime relatorio de proposta comercial                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSR910()    
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local wnrel
Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir a Proposta de "
Local cDesc2 := STR0002 //"Vendas."
Local cDesc3 := ""
Local cString := "SUS"
Local Tamanho := "M"

PRIVATE cTitulo:= STR0003 //"P r o p o s t a   C o m e r c i a l"
PRIVATE cabec1
PRIVATE cabec2
Private aReturn := { STR0004, 1,STR0005, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
Private cPerg   := "PLR910"
Private nomeprog:= "PLSR910" 
Private nLastKey:=0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao dos cabecalhos                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cabec1:= ""
cabec2:= ""
//        123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//                 1         2         3         4         5         6         7         8         9        10        11        12        13        14        15
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Envia controle para a funcao SETPRINT                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
wnrel := "PLR910"

Pergunte(cPerg,.F.)

wnrel := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho,,.F.)

If nLastKey == 27
   Return
End

SetDefault(aReturn,cString)

If nLastKey == 27
   Return ( NIL )
End

RptStatus({|lEnd| PLSR910Imp(@lEnd,wnRel,cString)},cTitulo)

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณ Fun…o    ณPLSR910Impณ Autor ณ Paulo Carnelossi      ณ Data ณ 04/09/03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Descri…o ณImpressao Proposta Comercial                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Sintaxe   ณPLSR910Imp(lEnd,wnRel,cString)                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso       ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function PLSR910Imp(lEnd,wnRel,cString)
Local cbcont,cbtxt
Local tamanho:= "M"
Local nTipo

Local nVlrContrato := 0
Local nGrauRisco := 0
Local aGeral 
Local aHeaderA, aHeaderS, aHeaderP, aColsA, aColsS, aColsP, aTrabS, aTrabA, aTrabP, nI
Local aDadosCon, cSequen
Local aHeaderSUS, aCposSUS, aCamposSUS := { 	"US_COD", ;
								"US_LOJA", ;
								"US_NOME", ;
								"US_NREDUZ", ;
								"US_TIPO", ;
								"US_END", ;
								"US_MUN", ;
								"US_BAIRRO", ;
								"US_CEP", ;
								"US_EST", ;
								"US_DDI", ;
								"US_DDD", ;
								"US_TEL", ;
								"US_FAX", ;
								"US_EMAIL", ;
								"US_URL", ;
								"US_ULTVIS", ;
								"US_VEND", ;
								"US_CGC", ;
								"US_ORIGEM", ;
								"US_STATUS"}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

nTipo:=GetMv("MV_COMP")

Store Header "SUS" TO aCposSUS For .T.

dbSelectArea("SUS")
DbSetOrder(1)
If ! dbSeek(xFilial("SUS")+mv_par01+mv_par02)
   MsgStop(STR0006) //"Nใo encontrado cliente!"
   Return
EndIf

nI := 1
aHeaderSUS := {}
While nI <= Len(aCposSUS)
	If ASCAN(aCamposSUS, Trim(aCposSUS[nI][2])) > 0
		aAdd(aHeaderSUS, {	.T., ;              			// se imprime o campo 
									Trim(aCposSUS[nI][2]),; 	// nome do campo
									Trim(aCposSUS[nI][1]),; 	//descricao do campo
									Trim(aCposSUS[nI][1]),; 	//titulo do campo
									Trim(aCposSUS[nI][2]),; 	//nome do campo novamente
									aCposSUS[nI][4] } )     	// tamanho do campo
	EndIf
	nI++
End

dbSelectArea("BL2")
If ! dbSeek(xFilial("BL2")+mv_par01+mv_par02+mv_par03)
   MsgStop(STR0007) //"Nใo encontrado proposta para este cliente!"
   Return
EndIf

If mv_par04 == 1
	dbSelectArea("BLB")
	If ! dbSeek(xFilial("BLB")+mv_par01+mv_par02+mv_par05)
	   MsgStop(STR0008) //"Nใo Encontrado proposta para este concorrente,  portanto nใo serแ impresso. "
	   mv_par04 := 2
	EndIf
EndIf
	
INCLUI := .F.  //setado variavel Inclui como Falso p/ nao dar erro criavar cham.plsxrel

dbSelectArea("BL4")
Store Header "BL4" TO aHeaderA For .T.

BL4->(DbSetOrder(1))
aColsA := {}
If BL4->(DbSeek(xFilial("BL4")+mv_par01+mv_par02+mv_par03)) 
   Store COLS "BL4" TO aColsA FROM aHeaderA VETTRAB aTrabA ;
   While BL4->(BL4_FILIAL+BL4_CODIGO+BL4_LOJA+BL4_SEQUEN) == xFilial("BL4")+mv_par01+mv_par02+mv_par03
Endif                                  

dbSelectArea("BL3")
Store Header "BL3" TO aHeaderP For .T.

BL3->(DbSetOrder(1))
aColsP := {}
If BL3->(DbSeek(xFilial("BL3")+mv_par01+mv_par02+mv_par03)) 
   Store COLS "BL3" TO aColsP FROM aHeaderP VETTRAB aTrabP;
   While BL3->(BL3_FILIAL+BL3_CODIGO+BL3_LOJA+BL3_SEQUEN) == xFilial("BL3")+mv_par01+mv_par02+mv_par03
Endif                                  

dbSelectArea("BL8")
Store Header "BL8" TO aHeaderS For .T.
aColsS := {}

BL8->(DbSetOrder(1))
If BL8->(DbSeek(xFilial("BL8")+mv_par01+mv_par02)) //+mv_par03
   Store COLS "BL8" TO aColsS FROM aHeaderS VETTRAB aTrabS ;
   While BL8->(BL8_FILIAL+BL8_CODIGO+BL8_LOJA) == xFilial("BL8")+mv_par01+mv_par02 //+mv_par03
Endif                                  

aGeral := aClone(Plsa910BL9(aHeaderA,aColsA,aHeaderS,aColsS,aHeaderP,aColsP,mv_par03,BL2->BL2_FAIFAM))
If	SUS->(FieldPos("US_FORMULA")) > 0
    M->US_FORMULA := SUS->US_FORMULA
Endif    
PlsVlrCont(@nVlrContrato, @nGrauRisco, aGeral)
	
cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
cTitSUS := "+"+PadC(STR0009, 130, "-")+"+" //"[  D  a  d  o  s     d  o     C  l  i  e  n  t  e  ]"
PlsRelCab(@Li,,"SUS",cTitSUS, aHeaderSUS)  
Li += 2

cTitBL2 := "+"+PadC(STR0010, 130, "-")+"+" //"[  P R O P O S T A    C O M E R C I A L  ]"
PlsRelCab(@Li,,"BL2",cTitBL2,)
Li += 2

@ Li, 000 PSay Repl("-", 132)
Li++
@ Li, 000 PSay STR0011 //"FAIXA ETARIA  TIPO              MASC.    %  FEM.    %   GERAL    %         VALOR  VL.UNI.MASC.   VL.UNI.FEM."
Li++
@ Li, 000 PSay Repl("-", 132)
Li++

For nI := 1 TO Len(aGeral)
	@ Li, 000 PSay Left(aGeral[nI,1],14) + aGeral[nI,9] + Str(aGeral[nI,3],3)+;
	Space(2)+ Str(aGeral[nI,4],3)+Space(3)+ Str(aGeral[nI,5],3) +Space(2)+;
	Str(aGeral[nI,6],3)+Space(5)+ Str(aGeral[nI,7],3) +Space(2)+ Str(aGeral[nI,8],3)+;
 	TransForm(aGeral[nI,11],"@E 999,999,999.99") + If(aGeral[nI,2] <> "999", Space(1)+;
 	TransForm(aGeral[nI,Len(aGeral[nI]) - 1],"@E 999,999,999.99") + Space(1) +;
 	TransForm(aGeral[nI,Len(aGeral[nI])],"@E 999,999,999.99"), "")
	Li++
Next


If mv_par04 == 1
	
	cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)

	aDadosCon := Plsa910BLC(SUS->US_COD,SUS->US_LOJA)
	//Criar no array aGeral a Coluna 12
	For nI := 1 to Len(aGeral)  // adiciona mais uma coluna para se colocar
	                            //  o valor da concorrencia
	   aadd(aGeral[nI],0.00)

	Next
	cSequen = mv_par05
	Plsa910Con(aGeral,cSequen,aDadosCon,BL2->BL2_FAIFAM,12)


	cTitBLB := "+"+PadC(STR0012, 130, "-")+"+" //"[  PROPOSTA CONCORRENTE  ]"
	PlsRelCab(@Li,,"BLB",cTitBLB,)
	Li += 2
   
   @ Li, 000 PSay Repl("-", 132)
   Li++
   @ Li, 000 PSay STR0013+If(mv_par06 = 1, STR0014, STR0015) //"FAIXA ETARIA  TIPO              MASC.    %  FEM.    %   GERAL    %      "###"N/ VALOR VLR.CONCORRENTE  COMPARATIVO"###"VLR.CONCORRENTE"
   Li++
   @ Li, 000 PSay Repl("-", 132)
   Li++

   For nI := 1 TO Len(aGeral)
      @ Li, 000 PSay Left(aGeral[nI,1], 14) + aGeral[nI,9] + Str(aGeral[nI,3],3)+Space(2)+ Str(aGeral[nI,4],3)+Space(3)+ Str(aGeral[nI,5],3) +Space(2)+ Str(aGeral[nI,6],3)+Space(5)+ Str(aGeral[nI,7],3) +Space(2)+ Str(aGeral[nI,8],3) + If(mv_par06 = 1,  TransForm(aGeral[nI,11],"@E 999,999,999.99") +Space(2)+ TransForm(aGeral[nI,12],"@E 999,999,999.99")+Space(2)+CompPreco(aGeral, nI), TransForm(aGeral[nI,12],"@E 999,999,999.99"))
		Li++
   Next

EndIf	

IF li != 80
	roda(cbcont,cbtxt,tamanho)
End

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Recupera a Integridade dos dados                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู


dbSelectArea("SUS")

Set Device To Screen

If aReturn[5] = 1
   Set Printer To
	dbCommitAll()
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCompPreco บAutor  ณPaulo Carnelossi    บ Data ณ  05/09/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Devolve string para ser impresso na coluna COMPARATIVO     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CompPreco(aGeral, nI)
Local cSinal := "  "
If aGeral[nI,11] > aGeral[nI,12]
	cSinal := STR0016 //">> - Maior"
ElseIf aGeral[nI,11] < aGeral[nI,12]
	cSinal := STR0017 //"<< - Menor"
ElseIf aGeral[nI,11] = aGeral[nI,12]
	cSinal := STR0018 //"== - Igual"
EndIf


Return(cSinal)	
