
#INCLUDE "PROTHEUS.CH"
#define ANTES_LACO 1
#define COND_LACO 2
#define PROC_LACO 3
#define DEPOIS_LACO 4

Static objCENFUNLGP := CENFUNLGP():New()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSR711    บAutor  ณPaulo Carnelossi   บ Data ณ  28/10/03   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑณDescri…o ณImpressao listagem de Vidas Amarrado ao cad. usuarios (BA1) ณฑฑ
ฑฑณ          ณe cadastro de Familias (BA3)                                ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSR711()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local wnrel
Local cDesc1 := "Este programa tem como objetivo imprimir a Listagem das Vidas amarrado a Usuarios/Familia"
Local cDesc2 := ""
Local cDesc3 := ""
Local cString := "BTS"

Local aOrd := {"Codigo", "Nome"}

PRIVATE cTitulo:= "Listagem de Vidas x Usuarios x Familia"
PRIVATE cabec1
PRIVATE cabec2
Private aReturn := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
Private cPerg   := "PLR711"
Private nomeprog:= "PLSR711" 
Private nLastKey:=0
Private Tamanho := "G"
Private nTipo
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao dos cabecalhos                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cabec1:= "Mat.Vida  Nome                       Operadora                      Empresa                                   Contrato/Versao Sub-Ctr/Versao  Tipo            Inclusao Plano                   Matric. Antiga"
cabec2:= ""
//        1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//                 1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Envia controle para a funcao SETPRINT                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
wnrel := "PLR711"

Pergunte(cPerg,.F.)

wnrel := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho,,.F.)

	aAlias := {"BTS","BA1","BA0","BG9","BA3","BI3","BG1"}
	objCENFUNLGP:setAlias(aAlias)

If nLastKey == 27
   Return
End

SetDefault(aReturn,cString)

If nLastKey == 27
   Return ( NIL )
End

RptStatus({|lEnd| PLSR711Imp(@lEnd,wnRel,cString)},cTitulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณ Fun…o    ณPLSR711Impณ Autor ณ Paulo Carnelossi      ณ Data ณ 28/10/03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Descri…o ณImpressao listagem de Vidas Amarrado ao cad. usuarios (BA1) ณฑฑ
ฑฑณ           ณe cadastro de Familias (BA3)                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Sintaxe   ณPLSR711Imp(lEnd,wnRel,cString)                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso       ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function PLSR711Imp(lEnd,wnRel,cString)
Local cbcont,cbtxt

LOCAL cSQL
Local cArqTrab  := CriaTrab(nil,.F.)
Local aCondFinal:= {}, nNivel, nTotGer := 0 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

nTipo:=GetMv("MV_COMP")

dbSelectArea("BA3")
dbSelectArea("BA1")
dbSelectArea("BTS")

cSql := "SELECT BTS_MATVID, BTS_NOMCAR, BA1_CODINT, BA1_CODEMP, "
cSql += "BA1_CONEMP, BA1_VERCON, BA1_SUBCON, BA1_VERSUB, BA3_TIPOUS, "
cSql += "BA1_DATINC, BA1_DATBLO, BA1_MOTBLO, BA1_MATRIC, BA3_CODPLA, BA1_MATANT "
cSql += " FROM "
cSql += RetSQLName("BTS")+" BTS, "
cSql += RetSQLName("BA1")+" BA1, "+RetSQLName("BA3")+" BA3 "
cSql += "WHERE "

//--relacionar cadastro de vidas com cad usuarios
cSql += "BTS_FILIAL = BA1_FILIAL AND "
cSql += "BTS_MATVID = BA1_MATVID AND "

//--relacionar usuario com familia
cSql += "BA1.BA1_FILIAL = BA3.BA3_FILIAL AND "
cSql += "BA1.BA1_CODINT  = BA3.BA3_CODINT AND "
cSql += "BA1.BA1_CODEMP = BA3.BA3_CODEMP AND "
cSql += "BA1.BA1_MATRIC = BA3.BA3_MATRIC AND "

//--considerar somente registros validos
cSql += "BTS.D_E_L_E_T_ <> '*' AND "
cSql += "BA1.D_E_L_E_T_ <> '*' AND BA3.D_E_L_E_T_ <> '*'  AND "

//--condicao principal 
cSql += "	BTS.BTS_FILIAL = '"+xFilial("BTS")+"' AND "
cSql += "	BA1.BA1_FILIAL = '"+xFilial("BA1")+"' AND "
cSql += "	BA3.BA3_FILIAL = '"+xFilial("BA3")+"' AND "
//--matricula da vida
cSql += "	BTS.BTS_MATVID >= '"+MV_PAR01+"' AND "
cSql += "	BTS.BTS_MATVID <= '"+MV_PAR02+"' AND "

//--nome da vida
cSql += "	BTS.BTS_NOMCAR >= '"+MV_PAR03+"' AND "
cSql += "	BTS.BTS_NOMCAR <= '"+MV_PAR04+"' AND "
                      
//--cpf da vida
cSql += "	BTS.BTS_CPFUSR >= '"+MV_PAR05+"' AND "
cSql += "	BTS.BTS_CPFUSR <= '"+MV_PAR06+"' "

//--ordem 
If aReturn[8] == 1
	cSql += " ORDER BY BTS_MATVID"
Else
	cSql += " ORDER BY BTS_NOMCAR"
EndIf

PLSQuery(cSql,cArqTrab)

dbSelectArea(cArqTrab)

//Nivel 1 (Unico)
	// Elemento 1 - ANTES_LACO
   // Elemento 2 - COND_LACO
   // Elemento 3 - PROC_LACO
   // Elemento 4 - DEPOIS_LACO
   // Elemento 5 - Variavel para comparacao
   // Elemento 6 - Contador
	// Elemento 7 - Nome do Campo
	// Elemento 8 - Titulo do Campo


aAdd( aCondFinal, ;
		   { ;
		   	{|| SetRegua(RecCount()), (cArqTrab)->(dbGotop()) }, ;
		   	{|| (cArqTrab)->(! EOF()) }, ;
		   	{|| IncRegua(),Impr_Detalhe(cArqTrab, @nTotGer) }, ;
		   	{|| .T.},;
		   	NIL,;
		   	0, ;
		   	"",;
		   	"";
		   } )
	
DetalheRel(aCondFinal, 1, cArqTrab)

IF li != 80
	roda(cbcont,cbtxt,tamanho)
End

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Recupera a Integridade dos dados                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea(cArqTrab)
dbCloseArea()

dbSelectArea("BTS")

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
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpr_Detalhe บAutor  ณPaulo Carnelossi บ Data ณ  28/10/03   บฑฑ
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
Local cNumSub, cCodFam, cDesBlo := ""
	
If li > 55
	cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
EndIf

@ li, 000 PSay objCENFUNLGP:verCamNPR("BTS_MATVID",(cArqTrab)->BTS_MATVID)
@ li, 010 PSay objCENFUNLGP:verCamNPR("BTS_NOMCAR",Substr((cArqTrab)->BTS_NOMCAR,1,25))
@ li, 037 PSay objCENFUNLGP:verCamNPR("BA1_CODINT",objCENFUNLGP:verCamNPR("BA0_NOMINT",Padr((cArqTrab)->BA1_CODINT+"-"+Posicione("BA0",1,xFilial("BA0")+(cArqTrab)->BA1_CODINT,"BA0_NOMINT"),30)))
@ li, 068 PSay objCENFUNLGP:verCamNPR("BA1_CODEMP",objCENFUNLGP:verCamNPR("BG9_DESCRI",Padr((cArqTrab)->BA1_CODEMP+"-"+Posicione("BG9",1,xFilial("BG9")+(cArqTrab)->(BA1_CODINT+BA1_CODEMP),"BG9_DESCRI"), 40)))

If ! Empty((cArqTrab)->BA1_CONEMP+(cArqTrab)->BA1_VERCON)
	@ li, 110 Psay objCENFUNLGP:verCamNPR("BA1_CONEMP",Alltrim((cArqTrab)->BA1_CONEMP))+"/"+objCENFUNLGP:verCamNPR("BA1_VERCON",Alltrim((cArqTrab)->BA1_VERCON))
EndIf	

If ! Empty((cArqTrab)->BA1_SUBCON+(cArqTrab)->BA1_VERSUB)
	@ li, 128 Psay objCENFUNLGP:verCamNPR("BA1_SUBCON",Alltrim((cArqTrab)->BA1_SUBCON))+"/"+objCENFUNLGP:verCamNPR("BA1_VERSUB",Alltrim((cArqTrab)->BA1_VERSUB))
EndIf

@ li, 142 Psay objCENFUNLGP:verCamNPR("BA3_TIPOUS",Padr(X3COMBO("BA3_TIPOUS", (cArqTrab)->BA3_TIPOUS ),15))
@ li, 158 Psay objCENFUNLGP:verCamNPR("BA1_DATINC",(cArqTrab)->BA1_DATINC)
@ li, 167 Psay objCENFUNLGP:verCamNPR("BA3_CODPLA",objCENFUNLGP:verCamNPR("BI3_DESCRI",Padr((cArqTrab)->BA3_CODPLA + "-" + Posicione("BI3",1,xFilial("BI3")+(cArqTrab)->(BA1_CODINT+BA3_CODPLA),"BI3_DESCRI"),33)))
@ li, 200 Psay objCENFUNLGP:verCamNPR("BA1_MATANT",(cArqTrab)->BA1_MATANT)


li++

If ! Empty((cArqTrab)->BA1_MOTBLO)
	//Verifica se sub-Contrato esta bloqueado
	cNumSub := xFilial("BQC")+(cArqTrab)->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)
	If (cArqTrab)->BA3_TIPOUS == "2" .And. A260BloqSubCtr(cNumSub)  //PESSOA JURIDICA
	   cDesBlo := Posicione("BQU", 1, xFilial("BQU")+(cArqTrab)->BA1_MOTBLO, "BQU_DESBLO")
   Else
		cDesBlo := Posicione("BG3", 1, xFilial("BG3")+(cArqTrab)->BA1_MOTBLO, "BG3_DESBLO")
      If Empty(cDesBlo)
			cCodFam := xFilial("BA3")+(cArqTrab)->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)
			If A260BloqFamilia(cCodFam)
				cDesBlo := Posicione("BG1", 1, xFilial("BG1")+(cArqTrab)->BA1_MOTBLO, "BG1_DESBLO")
			EndIf
		EndIf	
  	EndIf
	@ li, 000 Psay Padl("*** Bloqueado em : " +;
						objCENFUNLGP:verCamNPR("BA1_DATBLO",DTOC((cArqTrab)->BA1_DATBLO)) + "  ----> Motivo : " +;
						objCENFUNLGP:verCamNPR("BA1_MOTBLO",(cArqTrab)->BA1_MOTBLO) + "-" +;
						objCENFUNLGP:verCamNPR("BG1_DESBLO",cDesBlo), 220)
	li+=2
EndIf

(cArqTrab)->(DbSkip())
nTotGer++

Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpr_SubTot บAutor ณPaulo Carnelossi   บ Data ณ  28/10/03   บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime linha de sub-total/total geral                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Static Function Impr_SubTot(nCol,cTexto,lAlinDir, cSinal, lImprTot, lImprLinSep, nQuant)

nCol := If(nCol == NIL, 000, nCol)
lAlinDir := If(lAlinDir == NIL, .T., lAlinDir)
cTexto := If(cTexto == NIL, "Total", cTexto)
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
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDetalheRel บAutor ณPaulo Carnelossi    บ Data ณ  28/10/03   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime detalhe do relatorio quando existir agrupamentos    บฑฑ
ฑฑบ          ณde acordo com aCondFinal (array contendo blocos de codigos) บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DetalheRel(aCondFinal, nNivel, cArqTrab)

AEVAL(aCondFinal,;
				{|cX, nX| (cArqTrab)->(Eval(aCondFinal[nX][ANTES_LACO],nX)) } ,  1,  nNivel)

//zerar contador
aCondFinal[nNivel][6] := 0

While (cArqTrab)->( ! Eof() .And. AvaliaCondicao(aCondFinal, nNivel, cArqTrab) )
		
		If nNivel < Len(aCondFinal)  // avanca para proximo nivel
			DetalheRel(aCondFinal, nNivel+1, cArqTrab)
		EndIf	
      
      If nNivel == Len(aCondFinal)     // somente no ultimo nivel imprime linha detalhe
			(cArqTrab)->(Eval(aCondFinal[nNivel][PROC_LACO], nNivel))
	   EndIf
	   
End
	
If	nNivel == Len(aCondFinal) .Or. ;
	(nNivel < Len(aCondFinal ) .And. aCondFinal[nNivel][6] <> aCondFinal[nCtd+1][6])
	(cArqTrab)->(Eval(aCondFinal[nNivel][DEPOIS_LACO],nNivel))
EndIf

If nNivel > 1
	aCondFinal[nNivel-1][6] += aCondFinal[nNivel][6]
EndIf
						
Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณAvaliaCondicaoบAutor ณPaulo Carnelossi    บ Data ณ 28/10/03 บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณavalia condicao while (auxiliar a funcao DetalheRel()       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AvaliaCondicao(aCondFinal, nNivel, cArqTrab)
Local aAux := {}, lCond := .T., lRet := .T., nY
AEVAL(aCondFinal,;
				{|cX, nX| aAdd(aAux,lCond:=(cArqTrab)->(Eval(aCondFinal[nX][COND_LACO], nX))) } ,  1,  nNivel) 

For nY := 1 TO Len(aAux)
    If ! aAux[nY]
    	 lRet := .F.
    	 Exit
    EndIf
Next    

Return(lRet)



