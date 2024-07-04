#include "FINR851.CH"
#include "SIGAWIN.CH"

#DEFINE _FORNECE  1
#DEFINE _LOJA     2
#DEFINE _VALOR    3
#DEFINE _MOEDA    4
#DEFINE _SALDO    5
#DEFINE _SALDO1   6
#DEFINE _EMISSAO  7
#DEFINE _VENCTO   8
#DEFINE _PREFIXO  9
#DEFINE _NUM     10
#DEFINE _PARCELA 11
#DEFINE _TIPO    12
#DEFINE _RECNO   13
#DEFINE _RETIVA  14
#DEFINE _RETIB   15
#DEFINE _NOME    16
#DEFINE _JUROS   17
#DEFINE _DESCONT 18
#DEFINE _NATUREZ 19
#DEFINE _ABATIM  20
#DEFINE _PAGAR   21
#DEFINE _MULTA   22
#DEFINE _RETIRIC 23
#DEFINE _RETSUSS 24
#DEFINE _RETSLI  25 
#DEFINE _RETISI  28


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FINR851    ³ Autor ³ Microsiga              ³ Data ³ 08/25/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descriçào ³ Relatorio de Pre-Ordem de Pago                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ AP                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR ³ DATA   ³ BOPS     ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alf. Medrano³21/02/17 ³MMI-4537  ³se inicializa las variables nTotBSUSS y ³±±
±±³             ³        ³          ³nLimiteSUSS en func Finr851  ARG        ³±±
±±³             ³21/03/17³           ³merge Main vs 12.1.14                  ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Finr851()

Local oReport

Private lMsfil := .F.
Private nTotBSUSS	:= 0   
Private nLimiteSUSS := 0

DbSelectArea("SD1")
DbSelectArea("SF1")
DbSelectArea("SE2")

lMsfil := SF1->(FieldPos("F1_MSFIL")) > 0 .And. SD1->(FieldPos("D1_MSFIL")) > 0 .AND. SE2->(FieldPos("E2_MSFIL")) > 0;
						.And. !Empty(xFilial("SF1")) .And. Empty(xFilial("SE2"))

dbSelectArea("SX1")
SX1->(dbSetOrder(1))

If !SX1->(dbSeek(Pad("FIP851",Len(SX1->X1_GRUPO))))
	Help(" ",1,"F851DCPRE")
	Return
EndIf

If FindFunction("TRepInUse") .And. TRepInUse()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport	:= ReportDef()
	oReport:PrintDialog()
EndIf

If Select("TRB") > 0
	DbSelectArea("TRB")
	DbCloseArea()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINR851   ºAutor  ³Microsiga           º Data ³  08/25/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de Pre-Ordem de Pago - Definicao do Relatorio	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ReportDef() 

Local oReport,oSection1,oSection2
Local cReport := "FINR851"
Local cTitulo := OemToAnsi(STR0001)
Local cDescri := OemToAnsi(STR0025) 

oReport  := TReport():New( cReport, STR0025, "FIP851" , { |oReport| ReportPrint( oReport, "SE2" ) }, cDescri )

oSection1 := TRSection():New( oReport,STR0002, {"SA2"}, )

TRCell():New( oSection1, "FJK_PREOP"	,"FJK",STR0003,/*Picture*/,TamSx3("FJK_PREOP")[1]+5,/*lPixel*/,)
TRCell():New( oSection1, "A2_COD" 		,"SA2",/*X3Titulo*/	,/*Picture*/,,/*lPixel*/,)
TRCell():New( oSection1, "A2_LOJA"		,"SA2",/*X3Titulo*/	,/*Picture*/,/*Tamanho*/,/*lPixel*/,)		
TRCell():New( oSection1, "A2_NOME"		,"SA2",STR0004/*X3Titulo*/	,/*Picture*/,20/*Tamanho*/,/*lPixel*/,) 
TRCell():New( oSection1, "STATUS" 		,"",STR0005	,"@!",25,/*lPixel*/,)
TRCell():New( oSection1, "VLRPRE"	,"",STR0006,PesqPict("SE2","E2_VALOR")/*Picture*/,18/*Tamanho*/,/*lPixel*/,,"RIGHT")
TRCell():New( oSection1, "QTD" 			,"",STR0007,/*Picture*/,8/*Tamanho*/,/*lPixel*/,)
TRCell():New( oSection1, "NVALGN"	,"",STR0008,PesqPict("SE2","E2_VALOR")/*Picture*/,13/*Tamanho*/,/*lPixel*/,,"RIGHT") 
TRCell():New( oSection1, "NVALIV"	,"",STR0009,PesqPict("SE2","E2_VALOR")/*Picture*/,13/*Tamanho*/,/*lPixel*/,,"RIGHT") 
TRCell():New( oSection1, "NVALIB"	,"",STR0010,PesqPict("SE2","E2_VALOR")/*Picture*/,13/*Tamanho*/,/*lPixel*/,,"RIGHT") 
TRCell():New( oSection1, "NVALSU"	,"",STR0011,PesqPict("SE2","E2_VALOR")/*Picture*/,13/*Tamanho*/,/*lPixel*/,,"RIGHT") 
TRCell():New( oSection1, "NVALSL"	,"",STR0012,PesqPict("SE2","E2_VALOR")/*Picture*/,13/*Tamanho*/,/*lPixel*/,,"RIGHT") 
TRCell():New( oSection1, "NVALIS"	,"",STR0013,PesqPict("SE2","E2_VALOR")/*Picture*/,13/*Tamanho*/,/*lPixel*/,,"RIGHT") 

oSection1:SetNofilter({"SA2"})
oSection1:SetNofilter({"FJK"})

oReport:AddHeaderPage(oSection1) 
oSection1:lHeaderPage := .T.

oSection1:nLinesBefore := 2
                                                                                                            
oSection2 := TRSection():New( oSection1,"Itens Pre-Ordem", {"SE2"} )                                           
TRCell():New( oSection2, "A2_COD" 	,"SA2",/*X3Titulo*/	,/*Picture*/,/*Tamanho*/,/*lPixel*/,)
TRCell():New( oSection2, "A2_LOJA"	,"SA2",/*X3Titulo*/	,/*Picture*/,/*Tamanho*/,/*lPixel*/,)
TRCell():New( oSection2, "E2_PREFIXO" 	,"SE2",/*X3Titulo*/	,/*Picture*/,/*Tamanho*/,/*lPixel*/,)
TRCell():New( oSection2, "E2_NUM" 	,"SE2",/*X3Titulo*/	,/*Picture*/,/*Tamanho*/,/*lPixel*/,)
TRCell():New( oSection2, "E2_PARCELA" 	,"SE2",/*X3Titulo*/	,/*Picture*//*Tamanho*/,/*lPixel*/,)
TRCell():New( oSection2, "E2_TIPO"		,"SE2",/*X3Titulo*/	,/*Picture*/,/*Tamanho*/,/*lPixel*/,)
TRCell():New( oSection2, "E2_EMISSAO"	,"SE2",/*X3Titulo*/	,/*Picture*/,/*Tamanho*/,/*lPixel*/,)
TRCell():New( oSection2, "E2_VENCTO"	,"SE2",/*X3Titulo*/	,/*Picture*/,/*Tamanho*/,/*lPixel*/,)
TRCell():New( oSection2, "VLORIG"	,"SE2",STR0014+" "+STR0015,PesqPict("SE2","E2_VALOR"),13/*Tamanho*/,/*lPixel*/,,"RIGHT")
TRCell():New( oSection2, "E2_MOEDA"	,"SE2",/*X3Titulo*/	,/*Picture*/,/*Tamanho*/,/*lPixel*/,)
TRCell():New( oSection2, "VLMOED"	,"SE2",STR0014,PesqPict("SE2","E2_VALOR"),13,/*lPixel*/,,"RIGHT")  

oSection2:SetNofilter({"SE2"}) 

oSection2:nLinesBefore := 0 
   
oSection1:SetEdit(.F.)
oSection2:SetEdit(.F.)

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINR851   ºAutor  ³Microsiga           º Data ³  08/25/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de Pre-Ordem de Pago - Impressao				  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ReportPrint( oReport )
Local nP:=1
Local nIndex
Local lQuery	:=	.F.
Local cAliasFJK := ""
Local cAliasFJL := ""
Local cStatus	:= "" 
Local nRecnoSE2 := 0                   
Local aDados	 := {}
Local aPreOrd	 := {}
Local aTitulos := {}
Local lEfetiv	 := .F.
Local nImposto := 0
Local nOldIva	 := 0
Local nValPag	 := 0
Local cPreAnt	 :=  ""
Local cNfAnt	 := ""
Local cNatunf	:= ""
Local lGan		:= .T.
Local cTipoAtu  := ""
Local lDif 		:= .F.
      
Local oSection1 := oReport:Section(1)
Local oSection2 := oSection1:Section(1) 

//Declaracao de variaveis Multimoeda
Local cMoedaTx,nA,nC	:=	MoedFin()

Private cOrdPago	:= ""
Private lCalcRet	:= .F.      
Private nDecs
Private nCondAgr	:=	1
Private nMoeda		:= 1 
Private aSE2		:=	{}
Private aRecnoSE2	:=	{}
Private aTxMoedas	:=	{}
Private nMoedaCor	:=	1
Private lRetPA	:=	(GetNewPar("MV_RETPA","N") == "S")
Private aRetIvAcm	:= Array(3)

If !Empty(oReport:uParam)
	Pergunte(oReport:uParam,.F.)
EndIf	
oReport:SetTitle(OemToAnsi(STR0001))

//Inicializar Array com as cotacoes e Nomes de Moedas segundo o arquivo SM2
Aadd(aTxMoedas,{"",1,PesqPict("SM2","M2_MOEDA1")})
For nA	:=	2	To nC
	cMoedaTx	:=	Str(nA,IIf(nA <= 9,1,2))
	If !Empty(GetMv("MV_MOEDA"+cMoedaTx))
		Aadd(aTxMoedas,{GetMv("MV_MOEDA"+cMoedaTx),RecMoeda(dDataBase,nA),PesqPict("SM2","M2_MOEDA"+cMoedaTx) })
	Else
		Exit
	Endif
Next

#IFDEF TOP
	If TcSrvType()<>"AS/400"
		lQuery	:=	.T.
	Endif
#ENDIF

lEnd    := .F.
cDesc1  := OemToAnsi(STR0025) // "Imprime inf. de ordenes de pago previas"
cDesc2  := ""
cDesc3  := ""
cString := "SE2"

//+------------------------------------+
//¦ Verifica as perguntas selecionadas ¦
//+------------------------------------+

//+-----------------------------------------+
//¦ Variaveis utilizadas para parametros    ¦
//¦ mv_par01       // Fornecedor de         ¦
//¦ mv_par02       // Fornecedor ate 		¦
//¦ mv_par03       // Loja de 				¦
//¦ mv_par04       // Loja ate		        ¦
//¦ mv_par05       // Status			    ¦
//¦ mv_par06       // Calcula Retencao?     ¦
//¦ mv_par07       // Moeda		            ¦
//¦ mv_par08       // Tipo			        ¦
//+-----------------------------------------+
//+---------------------------------------+
//¦ Envia controle para a funçäo SETPRINT ¦
//+---------------------------------------+
Titulo := OemToAnsi(STR0001) // "Informe de PRE-Ordenes de pago"

dBaixa := dDataBase

lSint  		:= If( mv_par08 == 1,.F.,.T.)
lCalcRet 	:= If(cPaisLoc <> "ARG",.F.,If( mv_par06 == 1,.T.,.F.))
nMoedaCor   := mv_par07
nDecs       := MsDecimais(mv_par07)

//+-----------------------------------------------------------+
//¦ Variáveis utilizadas para Impressäo do Cabeçalho e Rodapé ¦
//+-----------------------------------------------------------+
//+--------------------------+
//¦ Definiçäo dos cabeçalhos ¦
//+--------------------------+
//                      1         2         3         4         5         6         7         8         9        10        11        12        13
//             12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901

If lQuery
	
	cQuery	:= "SELECT * FROM "+RetSqlName('FJK')+" FJK "
	
	cQuery	+= " WHERE "
	
	cQuery	+= " FJK_FILIAL ='"+xFilial("FJK")+"' AND "
	cQuery	+= " (FJK_FORNEC >= '"+mv_par01+"' AND FJK_FORNEC <= '"+mv_par02+"') AND "
	cQuery	+= " (FJK_LOJA >= '"+mv_par03+"' AND FJK_LOJA <= '"+mv_par04+"')  AND "
	cQuery	+= " (FJK_DTDIG >= '"+DtoS(mv_par09)+"' AND FJK_DTDIG <= '"+DtoS(mv_par10)+"')  AND "
	
	//Status
	Do Case
		Case mv_par05 == 1 //Aprovada
			cQuery	+= " FJK_DTANLI <> '' AND FJK_DTCANC = '' AND FJK_ORDPAG = '' AND "
		Case mv_par05 == 2 //Efetivada
			cQuery	+= " FJK_ORDPAG <> '' AND "	
		Case mv_par05 == 3 //Original
			cQuery	+= " FJK_DTANLI = '' AND FJK_DTCANC = '' AND FJK_ORDPAG = '' AND "
		Case mv_par05 == 4 //Reprovada/Cancelada
			cQuery	+= " FJK_DTCANC <> '' AND "
	EndCase
	
	cQuery	+= " FJK.D_E_L_E_T_ = '' " 
	
	cQuery := ChangeQuery(cQuery)
	
	cAliasFJK := "FJKQRY"
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasFJK)
	
Else
	cKey := "FJK_FILIAL+FJK_FORNEC+FJK_LOJA+FJK_PREOP"
 	cCondicao	:= " FJK_FILIAL =='"+xFilial("FJK")+"' .AND. "
	cCondicao	+= " (FJK_FORNEC >= '"+mv_par04+"' .AND. FJK_FORNEC <= '"+mv_par05+"') .AND. "
	cCondicao	+= " (FJK_LOJA >= '"+mv_par06+"' .AND. FJK_LOJA <= '"+mv_par07+"') .AND. "
	cCondicao	+= " (FJK_DTDIG >= "+mv_par09+" .AND. FJK_DTDIG <= "+mv_par10+")"

	//Status
	Do Case
		Case mv_par05 == 1 //Aprovada
			cCondicao	+= " .AND. !Empty(FJK_DTANLI) .AND. Empty(FJK_DTCANC) .AND. Empty(FJK_ORDPAG)"
		Case mv_par05 == 2 //Efetivada
			cCondicao	+= " .AND. !Empty(FJK_ORDPAG)"	
		Case mv_par05 == 3 //Original
			cCondicao	+= " .AND. Empty(FJK_DTANLI) .AND. Empty(FJK_DTCANC) .AND. Empty(FJK_ORDPAG)"
		Case mv_par05 == 4 //Reprovada/Cancelada
			cCondicao	+= " .AND. !Empty(FJK_DTCANC)"
	EndCase
	 	 
	cAliasFJK := "FJK"
	
	cArqTrab := CriaTrab(Nil,.F.)
	IndRegua(cAliasFJK,cArqTrab,cKey,,cCondicao,OemToAnsi(STR0016))  //"Filtrando registros..."
	DbSelectArea(cAliasFJK)
	nIndex   := RetIndex(cAliasFJK)
	(cAliasFJK)->(DbSetIndex(cArqTrab+OrdBagExt()))
	(cAliasFJK)->(DbSetOrder(nIndex+1))
Endif 

(cAliasFJK)->(DbGoTop())

While !(cAliasFJK)->(Eof())

    //Busca os registros da pre-ordem
	If lQuery

		cQuery	:= "SELECT "
		cQuery	+= "FVC.*, "
		cQuery	+= "SE2.E2_MOEDA, "
		cQuery	+= "SE2.E2_EMISSAO, "
		cQuery	+= "SE2.E2_VENCTO, "
		cQuery	+= "FJL_TIPO, "
		cQuery	+= "FJL_FORNEC, "
		cQuery	+= "FJL_LOJA, "
		cQuery	+= "FJL_PREFIX, "
		cQuery	+= "FJL_NUM, "
		cQuery	+= "FJL_PARCEL, "
		cQuery	+= "FJL_VLRPRE, "
		cQuery	+= "FJK_DTCANC, "
		cQuery	+= "SE2.R_E_C_N_O_ RECSE2 "
		cQuery	+= "FROM "+ RetSqlName('FJK') +" FJK "
		cQuery	+= "LEFT JOIN " + RetSqlName('FJL') + " FJL " 
		cQuery	+= "ON  FJK_FILIAL = FJL_FILIAL "
		cQuery	+= "AND FJK_PREOP = FJL_PREOP  "
		cQuery	+= "AND FJK_FORNEC = FJL_FORNEC " 
		cQuery	+= "AND FJK_LOJA = FJL_LOJA "
		cQuery	+= "LEFT JOIN "+ RetSqlName('FVC') +" FVC "
		cQuery	+= "ON  FJL_FILIAL = FVC_FILIAL "
		cQuery	+= "AND FJL_PREOP = FVC_PREOP  "
		cQuery	+= "AND FJL_FORNEC = FVC_FORNEC " 
		cQuery	+= "AND FJL_LOJA = FVC_LOJA "		
		cQuery	+= "LEFT JOIN "+ RetSqlName('FVC') +" FVCAUX "
		cQuery	+= "ON  FJL_FILIAL = FVCAUX.FVC_FILIAL "
		cQuery	+= "AND FJL_PREOP = FVCAUX.FVC_PREOP  "
		cQuery	+= "AND FJL_FORNEC = FVCAUX.FVC_FORNEC " 
		cQuery	+= "AND FJL_LOJA = FVCAUX.FVC_LOJA "
		cQuery	+= "AND FVCAUX.FVC_NFISC= ''  "			
		cQuery	+= "LEFT JOIN " + RetSqlName('SE2') + " SE2 "
		cQuery	+= "ON FJL_FILIAL = E2_FILIAL "
		cQuery	+= "AND FJL_PREOP = E2_PREOP "
		cQuery	+= "AND FJL_FORNEC = E2_FORNECE "
		cQuery	+= "AND FJL_LOJA = E2_LOJA "
		cQuery	+= "AND FJL_NUM = E2_NUM "
		cQuery	+= "AND (FJL_NUM = E2_NUM "
		cQuery	+= "OR FJL_NUM = '') "
		cQuery	+= "AND FJL_TIPO = E2_TIPO "
		cQuery	+= "WHERE FJK_PREOP = '" +(cAliasFJK)->FJK_PREOP+ "' "
		cQuery	+= "AND (FJK_FORNEC >= '"+mv_par01+"' "
		cQuery	+= "AND FJK_FORNEC <= '"+mv_par02+"') "
		cQuery	+= "AND (FJK_LOJA >= '"+mv_par03+"' "
		cQuery	+= "AND FJK_LOJA <= '"+mv_par04+"') "
		If CvalToChar(mv_par05) $ '4' // REPROVADAS
			cQuery	+= " AND  FJK_DTCANC <> ''  "
		EndIf		
		If CvalToChar(mv_par05) $ '1' // APROVADAS
			cQuery	+= " AND FJK_DTCANC = '' "
		EndIf	 

		cQuery	+= "AND FJK.D_E_L_E_T_ = '' "


		cQuery := ChangeQuery(cQuery)
		
		cAliasFJL := "FJLQRY"
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasFJL)
		
	Else
		cKey := "FJL_FILIAL+FJL_PREOP+FJL_FORNEC+FJK_LOJA+FJL_PREFIX+FJL_NUM+FJL_PARCEL+FJL_TIPO"
		cQuery	+= " FJL_FILIAL =='"+xFilial("FJL")+"' .AND. "
		cQuery	+= " FJL_PREOP == '"+(cAliasFJK)->FJK_PREOP+"'"
		 
		cAliasFJL := "FJL"
		
		cArqTrab := CriaTrab(Nil,.F.)
		IndRegua(cAliasFJL,cArqTrab,cKey,,cCondicao,OemToAnsi(STR0016))  //"Filtrando registros..."
		DbSelectArea(cAliasFJL)
		nIndex   := RetIndex(cAliasFJL)
		(cAliasFJL)->(DbSetIndex(cArqTrab+OrdBagExt()))
		(cAliasFJL)->(DbSetOrder(nIndex+1))
	Endif 
	
	aRecnoSE2 := {} 
	aPreOrd	  := Array(14)
	/*---------------------------------
		aPreOrd - Pre-Ordem 
	  ---------------------------------
		1 - Fornecedor
		2 - Loja
		3 - Nome Forn.
		4 - Pre-Ordem
		5 - Status
		6 - Valor
		7 - Titulos - Array
		8 - Ganancia
		9 - IVA
		10 - IB
		11 - SUSS
		12 - SLI
		13 - ISI
	  ---------------------------------*/
	
	//Status de cada pre-ordem
	If Empty((cAliasFJK)->FJK_ORDPAG) .And. Empty((cAliasFJK)->FJK_DTCANC) .And. Empty((cAliasFJK)->FJK_DTANLI)
		cStatus := STR0017 //"Original"
		lPagar  := .T.
	ElseIf !Empty((cAliasFJK)->FJK_DTANLI) .And. Empty((cAliasFJK)->FJK_DTCANC) .And. Empty((cAliasFJK)->FJK_ORDPAG)	
		cStatus := STR0018 //"Aprovada"
	ElseIf !Empty((cAliasFJK)->FJK_DTCANC)
		cStatus := STR0019 //"Reprovada/Cancelada"	
	ElseIf !Empty((cAliasFJK)->FJK_ORDPAG)
		cStatus  := STR0020 //"Efetivada"
		lEfetiv  := .T.
		cOrdPago := (cAliasFJK)->FJK_ORDPAG	
	EndIf
	
	aPreOrd[1] := (cAliasFJK)->FJK_FORNEC
	aPreOrd[2] := (cAliasFJK)->FJK_LOJA
	
	dbSelectArea("SA2")
	SA2->(dbSetOrder(1)) 
		
	If SA2->(dbSeek(xFilial("SA2")+(cAliasFJK)->(FJK_FORNEC+FJK_LOJA)))
		aPreOrd[3] := SA2->A2_NREDUZ	
	EndIf
	
	aPreOrd[4] := (cAliasFJK)->FJK_PREOP
	aPreOrd[5] := cStatus 
	aPreOrd[6] := 0
	aPreOrd[7] := {} 
	
	aPreOrd[8] := 0
	aPreOrd[9] := 0
	aPreOrd[10] := 0
	aPreOrd[11] := 0
	aPreOrd[12] := 0
	aPreOrd[13] := 0
		
		
	While !(cAliasFJL)->(Eof())
	    
		If (cAliasFJL)->FJL_TIPO $ MVPAGANT + "/" + MV_CPNEG
			nSigno	:= -1                                                                           
		Else
			nSigno	:=	 1
		Endif
	    
	    //Itens que serão impressos no relatório - Detalhe
	    aAdd(aTitulos, (cAliasFJL)->FJL_FORNEC)
	    aAdd(aTitulos, (cAliasFJL)->FJL_LOJA)	    
	    aAdd(aTitulos, (cAliasFJL)->FJL_PREFIX)
	    aAdd(aTitulos, (cAliasFJL)->FJL_NUM)
	    aAdd(aTitulos, (cAliasFJL)->FJL_PARCEL)
	    aAdd(aTitulos, (cAliasFJL)->FJL_TIPO)
		
		If lQuery
			cRecnoSE2 := (cAliasFJL)->RECSE2
			aAdd(aTitulos, StoD((cAliasFJL)->E2_EMISSAO))
			aAdd(aTitulos, StoD((cAliasFJL)->E2_VENCTO))
			aAdd(aTitulos, (cAliasFJL)->E2_MOEDA)
			nMoeda := (cAliasFJL)->E2_MOEDA
		Else
			dbSelectArea("SE2")
			SE2->(dbSetOrder(1))
			
			If SE2->(dbSeek(xFilial("SE2")+(cAliasFJL)->(FJL_PREFIX,+FJL_NUM+FJL_PARCELA+FJL_TIPO+FJL_FORNEC+FJL_LOJA)))
				cRecnoSE2 := SE2->(Recno())
				aAdd(aTitulos, SE2->E2_EMISSAO)
				aAdd(aTitulos, SE2->E2_VENCTO)
				aAdd(aTitulos, SE2->E2_MOEDA)
				nMoeda := SE2->E2_MOEDA		
			EndIf
		EndIf
		
		nValor := (cAliasFJL)->FJL_VLRPRE * nSigno
	    aAdd(aTitulos, nValor) //Valor Original
	    
	    nValor := Round(xMoeda(nValor,nMoeda,nMoedaCor),nDecs)
	    aAdd(aTitulos, nValor) //Valor Convertido
		
		aAdd(aTitulos, (cAliasFJL)->FVC_RETENC)
		aAdd(aTitulos, (cAliasFJL)->FVC_TIPO)
		If aTitulos[4]<> cNfAnt 
			aPreOrd[6] += nValor
			cNfAnt:= aTitulos[4] 
		EndIf
		//Inclui os itens da pre-ordem
		aAdd(aPreOrd[7],aTitulos)
		aTitulos := {}   
	
		//Monta o array aRecnoSE2 caso seja necessário recalculo de imposto
		AAdd(aRecNoSE2,{xFilial("SE2"),(cAliasFJL)->FJL_FORNEC,(cAliasFJL)->FJL_LOJA,(cAliasFJL)->FJL_PREFIX,(cAliasFJL)->FJL_NUM,;
		(cAliasFJL)->FJL_PARCELA,(cAliasFJL)->FJL_TIPO,cRecnoSE2,(cAliasFJL)->FJL_VLRPRE,(cAliasFJK)->FJK_FORNEC,(cAliasFJK)->FJK_LOJA})
		
		(cAliasFJL)->(DbSkip())
	Enddo
	
	If Select(cAliasFJL) > 0
		dbSelectArea(cAliasFJL)
		(cAliasFJL)->(dbCloseArea())
	EndIf
	lGan:= .T.
	cPreAnt:= ""
	
		For nA:=1	To Len(aPreOrd[7])					 			
			cTipoAtu := aPreOrd[7][nA][6]		 
			//Atualiza o Imposto Iva
			If aPreOrd[7][nA][13] = 'I'
				If aPreOrd[7][nA][6] == cTipoAtu .and. !lDif  						
					aPreOrd[9] 	+= aPreOrd[7][nA][12]				
					aPreOrd[6] 	-= aPreOrd[7][nA][12]	
				Else
					lDif:= .T. 	
				EndIf				
			EndIf					 
			    
			//Atualiza o Imposto IB
			If aPreOrd[7][nA][13] = 'B' 
				If aPreOrd[7][nA][6] == cTipoAtu .and. !lDif 
					aPreOrd[10] += aPreOrd[7][nA][12]
					aPreOrd[6] 	-= aPreOrd[7][nA][12]													
				Else
					lDif:= .T. 	
				EndIf								
			EndIf					
				
			//Atualiza o Imposto SUSS
			If aPreOrd[7][nA][13] = 'S'
				If  aPreOrd[7][nA][6] == cTipoAtu .and. !lDif
					aPreOrd[11] += aPreOrd[7][nA][12]
					aPreOrd[6] 	-= aPreOrd[7][nA][12]		
				Else
					lDif:= .T. 	
				EndIf			
			EndIf					
				
			//Atualiza o Imposto SLI
			If aPreOrd[7][nA][13] = 'SL'
				aPreOrd[12] += aPreOrd[7][nA][12]
				aPreOrd[6] 	-= aPreOrd[7][nA][12]				
			EndIf					
				
			//Atualiza o Imposto ISI
			If aPreOrd[7][nA][13] = 'IS'	
				aPreOrd[13] += aPreOrd[7][nA][12]
				aPreOrd[6] 	-= aPreOrd[7][nA][12]				
			EndIf					
			    
			//Atualiza o Imposto Ganancias
			If aPreOrd[7][nA][13] = 'G' .and. lGan  
				If aPreOrd[4] <> cPreAnt .and. !lDif  
					aPreOrd[8] 	 += aPreOrd[7][nA][12]
					aPreOrd[6] 	-= aPreOrd[7][nA][12]				
					cPreAnt := aPreOrd[4] 
					lGan    := .F.
					lDif:= .T.						
				EndIf			
			EndIf												
		Next nA		
	
	aAdd(aDados,aPreOrd)
	aPreOrd := {}
	lDif:= .F.
	(cAliasFJK)->(dbSkip())
	
EndDo

//Alias FJK
If Select(cAliasFJK) > 0
	dbSelectArea(cAliasFJK)
	(cAliasFJK)->(dbCloseArea())
EndIf 

//Impressao
If Len(aDados) > 0

	If lSint
		oSection1:Init()
		oSection2:lHeaderPage := .F.
	Else
		oReport:AddHeaderPage(oSection2)
		oSection2:lHeaderPage := .T.   
		
		oReport:bOnPageBreak := {|| oReport:SkipLine(2) }
	EndIf	
	
	For nA := 1 to Len(aDados)
		
		If !lSint
			oSection1:Init() 
		EndIf
	
		oSection1:Cell("FJK_PREOP"):SetBlock({|| OemToAnsi(aDados[nA][4])})
		oSection1:Cell("A2_COD"):SetBlock({|| OemToAnsi(aDados[nA][1]+aDados[nA][2])})		   
		oSection1:Cell("A2_NOME"):SetBlock({|| aDados[nA][3] })
		oSection1:Cell("STATUS"):SetBlock({|| OemToAnsi(aDados[nA][5])}) 
		oSection1:Cell("VLRPRE"):SetBlock({|| aDados[nA][6]})
		If lSint
			oSection1:Cell("QTD"):SetBlock({|| Len(aDados[nA][7])})
		Else
			oSection1:Cell("QTD"):Disable()	
		EndIf 
	
		If lCalcRet                     
			oSection1:Cell("NVALGN"):SetBlock({|| aDados[nA][8] })
			oSection1:Cell("NVALIV"):SetBlock({|| aDados[nA][9] })
			oSection1:Cell("NVALIB"):SetBlock({|| aDados[nA][10] })
			oSection1:Cell("NVALSU"):SetBlock({|| aDados[nA][11] })
			oSection1:Cell("NVALSL"):SetBlock({|| aDados[nA][12] })
			oSection1:Cell("NVALIS"):SetBlock({|| aDados[nA][13] })
		Else
			oSection1:Cell("NVALGN"):Disable()
			oSection1:Cell("NVALIV"):Disable()
			oSection1:Cell("NVALIB"):Disable()
			oSection1:Cell("NVALSU"):Disable()
			oSection1:Cell("NVALSL"):Disable()
			oSection1:Cell("NVALIS"):Disable()	
		EndIf
		
		oSection1 :PrintLine()
		
		If !lSint
		
			oReport:ThinLine()
			oSection1:Finish()
			oSection2:Init() 
			If Len(aDados) > 0 
			  If Len(aDados[na][7]) <> 0 				
					
					For nC := 1 to Len(aDados[nA][7]) 
						If cNatunf <> aDados[nA][7][nC][4]					 		
							oSection2:Cell("A2_COD"):SetBlock({|| aDados[nA][7][nC][1] })
							oSection2:Cell("A2_LOJA"):SetBlock({|| aDados[nA][7][nC][2] })
							oSection2:Cell("E2_PREFIXO"):SetBlock({|| aDados[nA][7][nC][3] })		   
							oSection2:Cell("E2_NUM"):SetBlock({|| aDados[nA][7][nC][4] })
							oSection2:Cell("E2_PARCELA"):SetBlock({|| aDados[nA][7][nC][5] })
							oSection2:Cell("E2_TIPO"):SetBlock({|| aDados[nA][7][nC][6] })
							oSection2:Cell("E2_EMISSAO"):SetBlock({|| aDados[nA][7][nC][7] })
							oSection2:Cell("E2_VENCTO"):SetBlock({|| aDados[nA][7][nC][8] })
							oSection2:Cell("VLORIG"):SetBlock({|| aDados[nA][7][nC][10] })
							oSection2:Cell("E2_MOEDA"):SetBlock({|| aDados[nA][7][nC][9] })
							oSection2:Cell("VLMOED"):SetBlock({|| aDados[nA][7][nC][11] })		
							If cNatunf <> aDados[nA][7][nC][4] .and. aDados[nA][7][nC][13] <> "G"
								oSection2:PrintLine()
								cNatunf:= aDados[nA][7][nC][4]
							Else
								natunf:= aDados[nA][7][nC][4]
								oSection2 :PrintLine()
							EndIf
						EndIf																		
						Next					
					EndIf					
				  oSection2:Finish()			
		    EndIf		  			
		EndIf
	Next
		                     		           
	If lSint
		oSection1:Finish()		
	EndIf 
	oReport:SkipLine(2)
	If lCalcRet
		oReport:PrintText(OemToAnsi(STR0021))
		oReport:PrintText(OemToAnsi(STR0022))
		oReport:PrintText(OemToAnsi(STR0023))
		oReport:PrintText(OemToAnsi(STR0024))
	Endif
		
	dbSelectArea("SE2")
	dbClearFilter()
	RetIndex( "SE2" )
	dbSetOrder(1)

EndIf

Return
