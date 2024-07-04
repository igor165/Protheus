#INCLUDE "PLSR710.ch"
#include "PROTHEUS.CH"

#define ANTES_LACO 1
#define COND_LACO 2
#define PROC_LACO 3
#define DEPOIS_LACO 4

Static lautoSt := .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSR710    บAutor  ณPaulo Carnelossi   บ Data ณ  22/09/03   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime listagem de produtos (planos registrados)           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSR710(lAuto)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local wnrel
Local cDesc1 := STR0001+" ("+STR0002+")" //"Este programa tem como objetivo imprimir a Listagem de Produtos"###"Planos"
Local cDesc2 := ""
Local cDesc3 := ""
Local cString := "BI3"

Local aOrd := {STR0003, STR0004} //"Codigo"###"Descricao"

Default lAuto := .F.

PRIVATE cTitulo:= STR0005+" ("+STR0002+")" //"Listagem de Produtos"###"Planos"
PRIVATE cabec1
PRIVATE cabec2
Private aReturn := { STR0006, 1,STR0007, 2, 2, 1, "",1 } //"Zebrado"###"Administracao"
Private cPerg   := "PLR710"
Private nomeprog:= "PLSR710" 
Private nLastKey:=0
Private Tamanho := "G"
Private nTipo

lautoSt := lAuto

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao dos cabecalhos                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cabec1:= STR0003+"    "+STR0004+"                                                   "+STR0008+"      "+STR0009+"/"+STR0010+"                                "+STR0011+"                            "+STR0012+"           "+STR0013+"   "+STR0014 //"Codigo"###"Descricao"###"No.Reg."###"Segmentacao"###"Tipo de Cobertura"###"Abrangencia"###"Tipo de"###"Data de"###"Dt.Aprov."
cabec2:= "/"+STR0015+"                                                               "+STR0016+"                                                                "+STR0017+"                             "+STR0018+"       "+STR0019+"  "+STR0019 //"Versao"###"Provisorio"###"Geografica"###"Contratacao"###"Registro"###"Registro"
//        1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//                 1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Envia controle para a funcao SETPRINT                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
wnrel := "PLR710"

Pergunte(cPerg,.F.)

if !lAuto
	wnrel := SetPrint(cString,nomeprog,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho,,.F.)
endif

If !lAuto .AND. nLastKey == 27
   Return
End

if !lautoSt
	SetDefault(aReturn,cString)
endif

If !lautoSt .AND. nLastKey == 27
   Return ( NIL )
End

if !lautoSt
	RptStatus({|lEnd| PLSR710Imp(@lEnd,wnRel,cString)},cTitulo)
else
	PLSR710Imp(.F.,wnRel,cString)
endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณ Fun…o    ณPLSR710Impณ Autor ณ Paulo Carnelossi      ณ Data ณ 22/09/03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Descri…o ณImpressao listagem de produtos (planos registrados)         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Sintaxe   ณPLSR710Imp(lEnd,wnRel,cString)                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso       ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function PLSR710Imp(lEnd,wnRel,cString)
Local cbcont,cbtxt

LOCAL cSQL
Local cArqTrab  := CriaTrab(nil,.F.)
Local nTotGer := 0, aCpos, aCondFinal, nCtd
Local cTitleSub := ""
Local nTotPro := 0, cCodPro := "", nGerTotPro := 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

nTipo:=GetMv("MV_COMP")

dbSelectArea("BI3")

cSQL := "SELECT BI3.BI3_CODIGO, BI3.BI3_VERSAO, BI3.BI3_DESCRI, BI3.BI3_SUSEP,  "
cSQL += "BI3.BI3_CODSEG, BI3.BI3_ABRANG, BI3.BI3_TIPCON, "
cSQL += "BI3.BI3_DTRGPR, BI3.BI3_DTAPPR FROM "
cSQL += RetSQLName("BI3")+" BI3 "

cSQL += "WHERE "
cSQL += "BI3.BI3_FILIAL = '"+xFilial("BI3")+"' AND "
cSQL += "BI3.BI3_CODINT = '"+MV_PAR01+"' AND "
//--considerar somente registros validos
cSQL += "BI3.D_E_L_E_T_ <> '*' "
cSQL += " ORDER BY "

If mv_par02 == mv_par03 .and. mv_par03 = mv_par04
 	cSQL += Monta_Order(mv_par02)
ElseIf mv_par02 == mv_par03
	cSQL += Monta_Order(mv_par02)
	cSQL += Monta_Order(mv_par04)
ElseIf mv_par03 = mv_par04
	cSQL += Monta_Order(mv_par02)
	cSQL += Monta_Order(mv_par03)
ElseIf mv_par02 = mv_par04
	cSQL += Monta_Order(mv_par02)
	cSQL += Monta_Order(mv_par03)
Else	
	cSQL += Monta_Order(mv_par02)
	cSQL += Monta_Order(mv_par03)
	cSQL += Monta_Order(mv_par04)
EndIf

If aReturn[8] == 1
	cSQL += "BI3.BI3_CODIGO"
Else
	cSQL += "BI3.BI3_DESCRI"
EndIf	

PLSQuery(cSQL,cArqTrab)


If mv_par02+mv_par03+mv_par04 > 3 
	If mv_par02 == mv_par03 .and. mv_par03 = mv_par04
		aCpos := {,}
		Monta_Cpos(aCpos, 1, mv_par02)
	ElseIf mv_par02 == mv_par03
		aCpos := {,}
		Monta_Cpos(aCpos, 1, mv_par02)
		Monta_Cpos(aCpos, 2, mv_par04)
	ElseIf mv_par03 = mv_par04 
		aCpos := {,}
		Monta_Cpos(aCpos, 1, mv_par02)
		Monta_Cpos(aCpos, 2, mv_par03)
	ElseIf mv_par02 = mv_par04 
		aCpos := {,}
		Monta_Cpos(aCpos, 1, mv_par02)
		Monta_Cpos(aCpos, 2, mv_par03)
	Else		  
	   //quando existir agrupamentos deve-se definir os campos de quebras
		aCpos := {,,}
		Monta_Cpos(aCpos, 1, mv_par02)
		Monta_Cpos(aCpos, 2, mv_par03)
		Monta_Cpos(aCpos, 3, mv_par04)
	EndIF
      
      //monta array contendo blocos de codigos que serao executados 
      // antes while - cond. while - processamento while - apos while      
      aCondFinal := {}
      
		For nCtd := 1 To Len(aCpos)
		
			If aCpos[nCtd] <> NIL .And. Len(aCpos[nCtd]) > 0
				// Elemento 1 - ANTES_LACO
		   	// Elemento 2 - COND_LACO
		   	// Elemento 3 - PROC_LACO
		   	// Elemento 4 - DEPOIS_LACO
		   	// Elemento 5 - Variavel para comparacao
		   	// Elemento 6 - Contador
				// Elemento 7 - Nome do Campo
				// Elemento 8 - Titulo do Campo

				cTitleSub += If(Len(cTitleSub)>0, "+", "")+aCpos[nCtd][2]

			   aAdd( aCondFinal, ;
					   { ;
					   	{|nCtd|aCondFinal[nCtd][5] := FieldGet(FieldPos(aCondFinal[nCtd][7]))}, ;
					   	{|nCtd|FieldGet(FieldPos(aCondFinal[nCtd][7])) == aCondFinal[nCtd][5]}, ;
					   	{|nCtd|VerProd(@cCodPro, @nTotPro, cArqTrab), aCondFinal[nCtd][6]++, Impr_Detalhe(cArqTrab, @nTotGer) }, ;
					   	{|nCtd|Impr_TotProd(@nTotPro, @cCodPro, @nGerTotPro, cArqTrab),Impr_SubTot( 030, STR0020+aCondFinal[nCtd][8], .F., If(nCtd=Len(aCondFinal),"-","="), mv_par05==1, .T., aCondFinal[nCtd][6])}; //"Sub-Total "
					   	, ,;
					   	0, ;
					   	aCpos[nCtd][1],;
					   	cTitleSub;
					   } )
			EndIf
			
		Next
		
EndIf



dbSelectArea(cArqTrab)
(cArqTrab)->(DbGoTop())

if !lautoSt
	SetRegua(RecCount())
endif

While (cArqTrab)->(! Eof())

	if !lautoSt
		IncRegua()
	endif

	If mv_par02 == 1 .And. ;
		mv_par03 == 1 .And. ;
		mv_par04 == 1  //Quando nao tem nenhuma quebra
		VerProd(@cCodPro, @nTotPro, cArqTrab)
		Impr_Detalhe(cArqTrab, @nTotGer)
	Else
		// Impressao do detalhe do relatorio com quebra
		DetalheRel(aCondFinal, 1, cArqTrab)
	EndIf	

End

If mv_par02+mv_par03+mv_par04 > 3
	Impr_SubTot(000,"*** "+STR0021+" ", .F., "-", mv_par05==1, mv_par05==1, nGerTotPro) //"Total Geral de Produtos"
Else
	Impr_SubTot(000,"*** "+STR0021+" ", .F., "-", mv_par05==1, mv_par05==1, nTotPro) //"Total Geral de Produtos"
EndIf

Impr_SubTot(000,"*** "+STR0022,.F., "=", mv_par05==1, mv_par05==1, nTotGer) //"Total Geral"

IF !lautoSt .AND. li != 80
	roda(cbcont,cbtxt,tamanho)
End

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Recupera a Integridade dos dados                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea(cArqTrab)
dbCloseArea()

dbSelectArea("BI3")

if !lautoSt
	Set Device To Screen
endif

If !lautoSt .AND. aReturn[5] = 1
   Set Printer To
	dbCommitAll()
   OurSpool(wnrel)
Endif

if !lautoSt
	MS_FLUSH()
endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpr_Detalhe บAutor  ณPaulo Carnelossi บ Data ณ  23/09/03   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime linha de detalhe do relatorio                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Impr_Detalhe(cArqTrab, nTotGer)
	
If !lautoSt .AND. li > 55
	cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
EndIf

@ li, 000 PSay (cArqTrab)->(BI3_CODIGO+"/"+BI3_VERSAO)
@ li, 010 PSay Padr((cArqTrab)->BI3_DESCRI,57)
@ li, 069 PSay Padr((cArqTrab)->BI3_SUSEP,12)
@ li, 083 PSay Padr((cArqTrab)->BI3_CODSEG+"-"+Posicione("BI6",1,xFilial("BI6")+(cArqTrab)->BI3_CODSEG,"BI6_DESCRI"),54)
@ li, 138 PSay Padr((cArqTrab)->BI3_ABRANG+"-"+Posicione("BF7",1,xFilial("BF7")+(cArqTrab)->BI3_ABRANG,"BF7_DESORI"),40)
@ li, 179 PSay Padr((cArqTrab)->BI3_TIPCON+"-"+Posicione("BII",1,xFilial("BII")+(cArqTrab)->BI3_TIPCON,"BII_DESCRI"),18)
@ li, 200 PSay (cArqTrab)->BI3_DTRGPR
@ li, 211 Psay (cArqTrab)->BI3_DTAPPR
li++

(cArqTrab)->(DbSkip())
nTotGer++

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณMonta_OrderบAutor  ณPaulo Carnelossi    บ Data ณ  23/09/03  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณfuncao que auxilia na formacao da string SQL ORDER BY       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Monta_Order(nParRel)
Local cStringSql := ""

If nParRel = 2
	cStringSql := " BI3.BI3_CODSEG, " 
ElseIf nParRel = 3
	cStringSql := " BI3.BI3_ABRANG, "
ElseIf nParRel = 4
	cStringSql := " BI3.BI3_TIPCON, "
EndIf

Return(cStringSql)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMonta_CposบAutor  ณPaulo Carnelossi    บ Data ณ  23/09/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta campos que definem quebra/ordem do relatorio          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Monta_Cpos(aCpos, nCtd, nParRel)

If nParRel = 2
	aCpos[nCtd] := {"BI3_CODSEG", STR0009}  //"Segmentacao"
ElseIf nParRel = 3
	aCpos[nCtd] := {"BI3_ABRANG", STR0011} //"Abrangencia"
ElseIf nParRel = 4
	aCpos[nCtd] := {"BI3_TIPCON", STR0023}  //"Tp.Contratacao"
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDetalheRel บAutor ณPaulo Carnelossi    บ Data ณ  23/09/03   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime detalhe do relatorio quando existir agrupamentos    บฑฑ
ฑฑบ          ณde acordo com aCondFinal (array contendo blocos de codigos) บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DetalheRel(aCondFinal, nCtd, cArqTrab)

AEVAL(aCondFinal,;
				{|cX, nX| (cArqTrab)->(Eval(aCondFinal[nX][ANTES_LACO],nX)) } ,  1,  nCtd)

//zerar contador
aCondFinal[nCtd][6] := 0

While (cArqTrab)->( ! Eof() .And. AvaliaCondicao(aCondFinal, nCtd, cArqTrab) )
		
		If nCtd < Len(aCondFinal)  // avanca para proximo nivel
			DetalheRel(aCondFinal, nCtd+1, cArqTrab)
		EndIf	
      
      If nCtd == Len(aCondFinal)     // somente no ultimo nivel imprime linha detalhe
			(cArqTrab)->(Eval(aCondFinal[nCtd][PROC_LACO], nCtd))
	   EndIf
	   
End
	
If	nCtd == Len(aCondFinal) .Or. ;
	(nCtd < Len(aCondFinal ) .And. aCondFinal[nCtd][6] <> aCondFinal[nCtd+1][6])
	(cArqTrab)->(Eval(aCondFinal[nCtd][DEPOIS_LACO],nCtd))
EndIf

If nCtd > 1
	aCondFinal[nCtd-1][6] += aCondFinal[nCtd][6]
EndIf
						
Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณAvaliaCondicaoบAutor ณPaulo Carnelossi    บ Data ณ 23/09/03 บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณavalia condicao while (auxiliar a funcao DetalheRel()       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AvaliaCondicao(aCondFinal, nCtd, cArqTrab)
Local aAux := {}, lCond := .T., lRet := .T., nY
AEVAL(aCondFinal,;
				{|cX, nX| aAdd(aAux,lCond:=(cArqTrab)->(Eval(aCondFinal[nX][COND_LACO], nX))) } ,  1,  nCtd) 

For nY := 1 TO Len(aAux)
    If ! aAux[nY]
    	 lRet := .F.
    	 Exit
    EndIf
Next    

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpr_SubTot บAutor ณPaulo Carnelossi   บ Data ณ  23/09/03   บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime linha de sub-total/total geral                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Impr_SubTot(nCol,cTexto,lAlinDir, cSinal, lImprTot, lImprLinSep, nQuant)

nCol := If(nCol == NIL, 000, nCol)
lAlinDir := If(lAlinDir == NIL, .T., lAlinDir)
cTexto := If(cTexto == NIL, STR0024, cTexto) //"Total"
cSinal := If(cSinal == NIL, "-", cSinal)
lImprTot := If(lImprTot == NIL, .T., lImprTot)

If lImprTot
	li++
	If lAlinDir
		@ li, nCol Psay PadR(cTexto+"................: "+Str(nQuant,10),220-nCol)
	Else
		@ li, nCol Psay PadL(cTexto+"................: "+Str(nQuant,10),220-nCol)
	EndIf
EndIf	

If lImprLinSep
	li++
	@ li, 000 Psay Repl(cSinal,220)
	
	li++
	li++
EndIf	

Return NIL

Static Function Impr_TotProd(nTotPro, cCodPro, nGerTotPro, cArqTrab)

Impr_SubTot(000,STR0025+" ", .F., "=", mv_par05==1, .F., nTotPro) //"Total de Produtos"
//incrementa total geral de produtos e zera contador produtos
nGerTotPro += nTotPro
cCodPro := ""
nTotPro := 0 

Return NIL	

Static Function VerProd(cCodPro, nTotPro, cArqTrab)

If cCodPro <> (cArqTrab)->BI3_CODIGO
	cCodPro := (cArqTrab)->BI3_CODIGO
	nTotPro++
EndIf	


Return NIL
