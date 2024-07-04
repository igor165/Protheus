#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

#define nLinMax	    1430								//-- Numero maximo de Linhas
#define nColMax		2450								//-- Numero maximo de Colunas
#define nColIni		20                                  //-- Coluna Lateral (inicial) Esquerda
#define nCol001	075
#define nCol002	405
#define nCol003	480
#DEFINE __RELIMP PLSMUDSIS(getWebDir() + getSkinPls() + "/relatorios/")

user function  PPRELUPD
PRIVATE cCodRda 	:= Paramixb[1]:rda  
PRIVATE aArea		:= GetArea()
PRIVATE cFileName		:= lower(cCodRda+"lstupd"+CriaTrab(NIL,.F.))   
PRIVATE Titulo	:= "Movimentacao"
PRIVATE cAlias	:= "BXX"
PRIVATE oFont07,oFont08n, oFont08, oFont09, oFont09n,oFont10, oFont10n
PRIVATE oFont12,oFont12n,oFont15,oFont15n, oFont21n,oFont16n
PRIVATE oPrint   
PRIVATE cPerg
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aOrderns    := {}
PRIVATE aReturn     := { "", 1, "", 1, 1, 1, "",1 }
PRIVATE dOpeDe  := ctod("")
PRIVATE dOpeAte := ctod("") 
PRIVATE cSitua  := ""
PRIVATE cTipo   := ""
PRIVATE cOpera  := ""
PRIVATE cEmpDe  := ""
PRIVATE cConDe  := ""
PRIVATE cVerCo  := ""
PRIVATE cSubDe  := ""
PRIVATE cVerSu  := ""
PRIVATE cPathSrvJ 	:= GETMV("MV_RELT")
PRIVATE cRel    := "plstarq"
PRIVATE cTitulo     := "Lista uploads"
PRIVATE cDesc1      := "Lista uploads ed acordo com os parametros selecionados."
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cTamanho    := "G"

PRIVATE lWeb 		:= .T.
PRIVATE cPathRelW 	:= __RELIMP
PRIVATE cCodInt		:= PlsIntPad()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BAU->(DbSetORder(1))
BAU->(Msseek(xFilial("BAU")+cCodRda))
cRel := SetPrint(	cAlias ,cRel ,cPerg ,@cTitulo ,cDesc1 ,cDesc2 ,cDesc3 ,lDicion ,aOrderns ,lCompres	,cTamanho ,{} ,lFiltro ,lCrystal)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se foi cancelada a operacao (padrao)                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFont07		:= TFont():New("Tahoma",07,07,,.F.,,,,.T.,.F.)
oFont08n	:= TFont():New("Tahoma",08,08,,.T.,,,,.T.,.F.)		//negrito
oFont08 	:= TFont():New("Tahoma",08,08,,.F.,,,,.T.,.F.)
oFont09n	:= TFont():New("Tahoma",09,09,,.T.,,,,.T.,.F.)	
oFont09    	:= TFont():New("Tahoma",09,09,,.F.,,,,.T.,.F.)
oFont10n 	:= TFont():New("Tahoma",10,10,,.T.,,,,.T.,.F.)
oFont10  	:= TFont():New("Tahoma",10,10,,.F.,,,,.T.,.F.)
oFontMono10	:= TFont():New("MonoAs",10,10,,.F.,,,,.T.,.F.)
oFont12		:= TFont():New("Tahoma",12,12,,.F.,,,,.T.,.F.)		//Normal s/negrito
oFont12n	:= TFont():New("Tahoma",12,12,,.T.,,,,.T.,.F.)		//Negrito
oFont15 	:= TFont():New("Tahoma",15,15,,.F.,,,,.T.,.F.)		
oFont15n	:= TFont():New("Tahoma",15,15,,.T.,,,,.T.,.F.)		//Negrito
oFont21n	:= TFont():New("Tahoma",21,21,,.T.,,,,.T.,.T.)      	//Negrito
oFont16n	:= TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)        //Negrito
     
cPathSrvJ 	:= cPathRelW
SetPrintFile(cRel)
oPrint := FWMSPrinter():New (cFileName,6,.F.,nil,.T.,nil,nil,nil,nil,.F.)
oPrint:lInJob  := lWeb
oPrint:lServer := lWeb	
oPrint:cPathPDF := cPathSrvJ
oPrint:setDevice(IMP_PDF)
oPrint:SetPortrait()					//--Modo paisagem
oPrint:SetPaperSize(9)
oPrint:StartPage() 						//--Inicia uma nova pagina
plPrtUpl(cCodRda,cCodInt)
oPrint:Preview()
MS_FLUSH()             // Libera fila de relatorios em spool

RestArea(aArea)    
Return {cFileName+".pdf",""}

STATIC function plPrtUpl(cCodRda,cCodInt)
Local cSql  := ""
Local nPage := 1
Local li 	:= 0

cSql := " select R_E_C_N_O_ REC from "+RetSqlName("BXX")
cSql += " where "
cSql += " BXX_FILIAL = '"+xFilial("BXX")+"' "
cSql += " AND BXX_CODINT = '"+cCodInt+"' "
cSql += " AND BXX_CODRDA = '"+cCodRda+"' " 
cSql += " AND BXX_TPNFS = '1' "
cSql += " AND BXX_DATMOV >= '"+dtos(dDatabase-GetNewPar("MV_PLDIXML",30))+"'"
cSql += " AND D_E_L_E_T_ = ' ' "
cSql += " ORDER BY BXX_DATMOV desc"
PlsQuery(cSql,'trbBXX')
		 
trbBXX->( dbGotop() )
    
	fImpCabec(@li,@nPage)
	cTipOpe := ""   
    
    While !trbBXX->( Eof() )
    
    	BXX->(dbGoto(trbBXX->(REC))) 	

    	If li > 800
	   		oPrint:EndPage() // Finaliza a pagina
			oPrint:StartPage()
			nPage++
			fImpCabec(@li,@nPage)
	   	EndIf

		li += 15 
			
		oPrint:say(li, nColIni, AllTrim(dtoc(BXX->BXX_DATMOV)), oFont10)
		oPrint:say(li, nColIni+nCol001, Alltrim(BXX->BXX_ARQIN), oFont07)
		oPrint:say(li, nColIni+nCol002, AllTrim(BXX->BXX_CODPEG), oFont10)
		oPrint:say(li, nColIni+nCol003, AllTrim(X3COMBO("BXX_STATUS",BXX->BXX_STATUS)), oFont10)
		
	    	
		trbBXX->(DbSkip())
					   				   	
   	EndDo
   	            
trbBXX->(DbCloseArea())
		
return                      
 
Static Function fImpCabec(li,nPage)

Local aBMP			:= {"lgrlpr.bmp"}
//  -- CABECALHO DA GUIA  -- //

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³Carrega e Imprime Logotipo da Empresa                         ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca Bmp da empresa.³// Logo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If File("lgrlpr" + FWGrpCompany() + FWCodFil() + ".bmp")
	aBMP := { "lgrlpr" + FWGrpCompany() + FWCodFil() + ".bmp" }
ElseIf File("lgrlpr" + FWGrpCompany() + ".bmp")
	aBMP := { "lgrlpr" + FWGrpCompany() + ".bmp" }
EndIf


If !Empty(aBMP[1])
	oPrint:SayBitmap(15,20, aBMP[1],130,75) 		//-- Tem que estar abaixo do RootPath 
Endif

li := 25

// Titulo
oPrint:say(li, 150, OemToAnsi(alltrim(BAU->BAU_NOME)+" - CNPJ/CPF: "+alltrim(BAU->BAU_CPFCGC)), oFont12n)
li+=15
oPrint:say(li+25, 250, OemToAnsi("RELATÓRIO DE ARQUIVOS ENVIADOS"), oFont12n)

oPrint:say(li+=65, nColIni, "Data" , oFont10)
oPrint:say(li, nCol001+20, "Arquivo" , oFont10)
oPrint:say(li, nCol002+20, "Protocolo" , oFont10)
oPrint:say(li, nCol003+20, "Status" , oFont10)

oPrint:line(li+=10,nColIni,li,nColIni+520)

Return(nil)

