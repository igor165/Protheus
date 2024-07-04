#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FWBrowse.ch'
#Include 'OGC100.ch'

#DEFINE CRLF CHR(13)+CHR(10)
Static __cTabRom	:= "" //Tabela Temporária de Romaneios

/*{Protheus.doc} OGC100VROM
Função para selecionar os romaeios
@author 	Jonisson Henckel
@since 		29/09/2017
@version 	1.0
@PARAM		(_cTabPen)->CONTRATO, (_cTabPen)->NOMFOR, (_cTabPen)->LJCOR, (_cTabPen)->TPCOM
*/
Function OGC100VROM(cFilCrt, cCodCtr, cCodCor, cLojCor, cTipoCal)
	Local aCoors      := FWGetDialogSize( oMainWnd )
	Local oSize       := {}
	Local oFWL        := ""
	Local oDlg		  := Nil
	Local aFilBrowRom := {}	
	Local nCont       := 0	
	Local aButtons    := {}
	Local nAltura 	  := aCoors[3] * 0.90
	Local nLargura 	  := aCoors[4] * 0.90
	Local lRetorno	  := .T.

	Private aRotina   := {}
	Private _cCodCtr  := cCodCtr
	Private _cFilCrt  := cFilCrt
	Private _cCodCor  := cCodCor
	Private _cLojCor  := cLojCor
	Private _cTipoCal := cTipoCal


	If !OGC100EXROM()
		Return
	EndIf

	//campos Romaneio
	aBrowRom := {   {STR0002			  , "MARK"    	    , "C" ,  1, , "@!"},; //control utilização
					{STR0007			  , "NJJ_FILIAL"    , TamSX3( "NJJ_FILIAL" )[3]	, TamSX3( "NJJ_FILIAL" )[1]	, TamSX3( "NJJ_FILIAL" )[2]	, PesqPict("NJJ","NJJ_FILIAL") 	},; //"Filial do Romaneio"
					{STR0006			  , "NJJ_CODROM"    , TamSX3( "NJJ_CODROM" )[3]	, TamSX3( "NJJ_CODROM" )[1]	, TamSX3( "NJJ_CODROM" )[2]	, PesqPict("NJJ","NJJ_CODROM") 	},; //"Romaneio"
					{STR0008			  , "NJJ_DATA"      , TamSX3( "NJJ_DATA" )[3]   , TamSX3( "NJJ_DATA" )[1]	, TamSX3( "NJJ_DATA" )[2]	, PesqPict("NJJ","NJJ_DATA") 	},; //"Data "
					{STR0003			  , "NJR_FILIAL"	, TamSX3( "NJR_FILIAL" )[3] , TamSX3( "NJR_FILIAL" )[1]	, TamSX3( "NJR_FILIAL" )[2]	, PesqPict("NJR","NJR_FILIAL") 	},; //"FILIAL DO CONTRATO"
					{STR0004			  , "NJM_DOCNUM"    , TamSX3( "NJM_DOCNUM" )[3]	, TamSX3( "NJM_DOCNUM" )[1]	, TamSX3( "NJM_DOCNUM" )[2]	, PesqPict("NJM","NJM_DOCNUM") 	},; //"Nota fiscal"
					{STR0005			  , "NJM_DOCSER"    , TamSX3( "NJM_DOCSER" )[3]	, TamSX3( "NJM_DOCSER" )[1]	, TamSX3( "NJM_DOCSER" )[2]	, PesqPict("NJM","NJM_DOCSER") 	},; //"Série Nota fiscal"
					{STR0009			  , "NJJ_CODSAF"    , TamSX3( "NJJ_CODSAF" )[3]	, TamSX3( "NJJ_CODSAF" )[1]	, TamSX3( "NJJ_CODSAF" )[2]	, PesqPict("NJJ","NJJ_CODSAF") 	},; //"Safra"
					{STR0010			  , "NJJ_PESO1"     , TamSX3( "NJJ_PESO1" )[3]	, TamSX3( "NJJ_PESO1" )[1]	, TamSX3( "NJJ_PESO1" )[2]	, PesqPict("NJJ","NJJ_PESO1") 	},; //"PESO1"
					{STR0011			  , "NJJ_PESO2"     , TamSX3( "NJJ_PESO2" )[3]	, TamSX3( "NJJ_PESO2" )[1]	, TamSX3( "NJJ_PESO2" )[2]	, PesqPict("NJJ","NJJ_PESO2") 	},; //"PESO2"
					{STR0012			  , "NJJ_PSSUBT"    , TamSX3( "NJJ_PSSUBT" )[3]	, TamSX3( "NJJ_PSSUBT" )[1]	, TamSX3( "NJJ_PSSUBT" )[2]	, PesqPict("NJJ","NJJ_PSSUBT") 	},; //"Peso Subtotal"
					{STR0013			  , "NJJ_PSLIQU"    , TamSX3( "NJJ_PSLIQU" )[3]	, TamSX3( "NJJ_PSLIQU" )[1]	, TamSX3( "NJJ_PSLIQU" )[2]	, PesqPict("NJJ","NJJ_PSLIQU") 	},; //"Peso líquido"
					{STR0014			  , "NJM_QTDFCO"    , TamSX3( "NJM_QTDFCO" )[3]	, TamSX3( "NJM_QTDFCO" )[1]	, TamSX3( "NJM_QTDFCO" )[2]	, PesqPict("NJM","NJM_QTDFCO") 	},; //"Qtd Origem"
					{STR0015			  , "NJM_QTDFIS"    , TamSX3( "NJM_QTDFIS" )[3]	, TamSX3( "NJM_QTDFIS" )[1]	, TamSX3( "NJM_QTDFIS" )[2]	, PesqPict("NJM","NJM_QTDFIS") 	},; //"Qtd Destino"
					{STR0016			  , "NJM_VLRUNI"    , TamSX3( "NJM_VLRUNI" )[3]	, TamSX3( "NJM_VLRUNI" )[1]	, TamSX3( "NJM_VLRUNI" )[2]	, PesqPict("NJM","NJM_VLRUNI") 	},; //"vALOR UNITARIO"
					{STR0017			  , "NJM_VLRTOT"    , TamSX3( "NJM_VLRTOT" )[3]	, TamSX3( "NJM_VLRTOT" )[1]	, TamSX3( "NJM_VLRTOT" )[2]	, PesqPict("NJM","NJM_VLRTOT") 	},; //"VALOR TOTAL"
					{RetTitle("NJR_MOEDA"), "NJR_MOEDA"     , TamSX3( "NJR_MOEDA" )[3]	, TamSX3( "NJR_MOEDA" )[1]	, TamSX3( "NJR_MOEDA" )[2]	, PesqPict("NJR","NJR_MOEDA") 	},; //"Moeda"
					{STR0029			  , "NJM_DOCESP"    , TamSX3( "NJM_DOCESP" )[3]	, TamSX3( "NJM_DOCESP" )[1]	, TamSX3( "NJM_DOCESP" )[2]	, PesqPict("NJM","NJM_DOCESP")  },; //"Espécie" 
					{STR0030			  , "NJJ_TIPO"      , TamSX3( "NJJ_TIPO"   )[3]	, TamSX3( "NJJ_TIPO"   )[1]	, TamSX3( "NJJ_TIPO"   )[2]	, PesqPict("NJJ","NJJ_TIPO")    },; //"Tipo"
					{STR0031			  , "N9A_OPEFUT"    , TamSX3( "N9A_OPEFUT" )[3]	, TamSX3( "N9A_OPEFUT" )[1]	, TamSX3( "N9A_OPEFUT" )[2]	, PesqPict("N9A","N9A_OPEFUT")  },; //"Global Futura"
					{STR0032			  , "NFCOMP"   	    , TamSX3( "N9A_OPEFUT" )[3]	, TamSX3( "N9A_OPEFUT" )[1]	, TamSX3( "N9A_OPEFUT" )[2]	, PesqPict("N9A","N9A_OPEFUT")  }}  //"NF de Complemento"

	Processa({|| __cTabRom := MontaTabel(aBrowRom, {{"", "NJJ_FILIAL+NJJ_CODROM"}})},STR0018) //"consultando"

	Processa({|| lRetorno := fGetDados()},STR0019) //"Processando"
 
	If lRetorno
	aCoors[3] := nAltura
	aCoors[4] := nLargura


	//tamanho da tela principal
	oSize := FWDefSize():New(.t.) //considerar o enchoice
	oSize:AddObject('DLG',100,100,.T.,.T.)
	oSize:SetWindowSize(aCoors)
	oSize:lProp 	:= .T.
	oSize:aMargins := {0,0,0,0}
	oSize:Process()

	oDlg := TDialog():New(  oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4], STR0020, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //"Romaneios"

	oPnl1:= tPanel():New(oSize:aPosObj[1,1],oSize:aPosObj[1,2],,oDlg,,,,,,oSize:aPosObj[1,4],oSize:aPosObj[1,3] - 30 /*enchoice bar*/)

	// Instancia o layer
	oFWL := FWLayer():New()

	// Inicia o Layer
	oFWL:init( oPnl1, .F. )

	// Cria as divisões horizontais
	oFWL:addLine( 'MASTER'   , 100 , .F.)
	oFWL:addCollumn( 'LEFT' ,100,.F., 'MASTER' )

	//cria as janelas
	oFWL:addWindow( 'LEFT' , 'Wnd1', ,  100 /*tamanho*/, .F., .T.,, 'MASTER' ) //"romaneios a considerar"

	// Recupera os Paineis das divisões do Layer
	oPnlWnd1:= oFWL:getWinPanel( 'LEFT' , 'Wnd1', 'MASTER' )

	//adicionando os widgets de tela
	oBrowse1 := FWMBrowse():New()
    oBrowse1:SetAlias(__cTabRom)
    oBrowse1:DisableDetails()
    oBrowse1:SetMenuDef( "OGC100" )
    oBrowse1:SetDescription(STR0021)
    oBrowse1:DisableReport(.T.)
    oBrowse1:DisableSeek(.T.)
    oBrowse1:SetProfileID("OGC0090ROM")

    oBrowse1:AddMarkColumns( { ||Iif( !Empty( (__cTabRom)->MARK = "1" ),"LBOK","LBNO" ) },{ || OGC100DB(oBrowse1),OGC100UP(oBrowse1,.F.), oBrowse1:SetFocus(), oBrowse1:GoColumn(1)  }, { || OGC100HD(oBrowse1, "B") ,OGC100UP(oBrowse1), oBrowse1:SetFocus()  } )

    For nCont := 2  to Len(aBrowRom)-3 //desconsiderar MARK
        oBrowse1:AddColumn( {aBrowRom[nCont][1]  , &("{||"+IIF(aBrowRom[nCont][3] == 'N',aBrowRom[nCont][2],alltrim(aBrowRom[nCont][2]))+"}") ,aBrowRom[nCont][3],aBrowRom[nCont][6],OGC100ALIN(aBrowRom[nCont][3]),aBrowRom[nCont][4],aBrowRom[nCont][5],.f.} )
        aADD(aFilBrowRom,  {aBrowRom[nCont][2], aBrowRom[nCont][1], aBrowRom[nCont][3], aBrowRom[nCont][4], aBrowRom[nCont][5], aBrowRom[nCont][6] } )
    Next nCont

    oBrowse1:SetFieldFilter(aFilBrowRom)
    oBrowse1:Activate(oPnlWnd1)

    //cria os botões adicionais
    oDlg:Activate( , , , .t., OGC100LOAD(oBrowse1), , EnchoiceBar(oDlg,{|| Processa({|| OGC100CROM()},"Aguarde Processando...") ,oDlg:End()}, {||   oDlg:End() } /*Fechar*/,,@aButtons) )
  
    EndIf

Return

/*{Protheus.doc} OGC100DB
Marcação de itens por Double Click
@author Daniel Maniglia
@since 03/10/2017
@version undefined
@param oBrwObj
@type function
*/
static function OGC100DB(oBrwObj)	

    if RecLock((__cTabRom),.F.)	.and. !empty((__cTabRom)->NJJ_CODROM)
        (__cTabRom)->MARK = IIF((__cTabRom)->MARK  == "1", "", "1")
        MsUnlock()
    endif

return

/*{Protheus.doc} OGC100HD
Marcação de itens no Header do Browse
@author Daniel Maniglia
@since 11/08/2017
@version undefined
@param objBrowser
@type function
*/
Static Function OGC100HD(objBrowser)
	Local cOperDat := 0

		DbSelectArea((__cTabRom))
		DbGoTop()
		If DbSeek((__cTabRom)->NJJ_FILIAL+(__cTabRom)->NJJ_CODROM)
			cOperDat := IIF((__cTabRom)->MARK  == "1", "", "1")
			While !(__cTabRom)->(Eof())
				If RecLock((__cTabRom),.f.)
					(__cTabRom)->MARK = cOperDat
					MsUnlock()
				EndIf
				(__cTabRom)->( dbSkip() )
			enddo
		endif
return

/*{Protheus.doc} fGetDados
Popula romaeios na temporária
@author Daniel Maniglia
@since 03/10/2017
@version 1
@type function
*/
Static Function fGetDados()
	Local cTMP01		:= GetNextAlias()
	Local cTMP02		:= GetNextAlias()
	Local cQuery		:= ''
	Local cQuery2		:= ''
	Local lRetorno		:= .F.	
	Local lSE1Comp	 	:= .t.
	Local lSE2Comp   	:= .t.
	Local cSe1FilTFil	:= ' '
	Local cN8LFilTFil	:= ' '
	Local cSe2FilTFil	:= ' '
	Local cN8MFilTFil	:= ' '
	Local aAreaSf2		:= {}
	Local cParPrefix	:= ""
	Local cPrefixNF		:= ""	

	//--Deleta tudo da temporaria para realizar nova busca de romaneios
	DbSelectArea((__cTabRom))
	DbGoTop()
	If DbSeek((__cTabRom)->NJJ_FILIAL)
		While !(__cTabRom)->(Eof())

			If RecLock((__cTabRom),.f.)
				(__cTabRom)->(DbDelete())
				(__cTabRom)->(MsUnlock())
			EndIf
			(__cTabRom)->( dbSkip() )
		EndDo
	EndIF
	
	//--SELECAO DOS ROMANEIOS CONFIRMADOS E REFERENTE AO TIPO DE COMISSAO
	cQuery := " SELECT DISTINCT NJJ_FILIAL, NJJ_CODROM, NJJ_DATA, NJJ_CODSAF, NJJ_PESO1, NJJ_PESO2, NJJ_PSSUBT, NJJ_PSLIQU, "
	cQuery +=        " NJM_DOCNUM, NJM_DOCSER, NJM_QTDFCO, NJM_QTDFIS, NJM_VLRUNI, NJM_VLRTOT, NJM_DOCESP, "
	cQuery +=        " NJJ_TIPO, N9A_OPEFUT, NJM_CODENT, NJM_LOJENT, NJM_CODINE "
	cQuery +=  " FROM " + RetSqlName('NJJ')+ " NJJ "							
	cQuery += " INNER JOIN " + RetSqlName('N9A') + " N9A ON N9A.N9A_FILIAL = NJJ.NJJ_FILORG"
	cQuery +=                                         " AND N9A.N9A_CODCTR = NJJ.NJJ_CODCTR"
	cQuery +=                                         " AND N9A.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName('NJM') + " NJM ON NJM.NJM_FILIAL = NJJ.NJJ_FILIAL"
	cQuery +=                                         " AND NJM.NJM_CODROM = NJJ.NJJ_CODROM"
	cQuery +=                                         " AND NJM.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE NJJ.D_E_L_E_T_ = '' "
	cQuery +=   " AND NJJ.NJJ_FILIAL = '" + fwxfilial('NJJ') + "' "
	cQuery +=   " AND NJJ.NJJ_STATUS = '3' " //--CONFIRMADO 
	
	If .NOT. Empty(_cCodCtr)	//Tratamento caso ocorra falha
		cQuery +=" AND NJJ.NJJ_CODCTR = '" +_cCodCtr + "' "
	EndIf

	//verifica se a NF ja está na N89 e retira da consulta.
	cQuery +=   " AND NOT EXISTS (SELECT * FROM " + RetSqlName('N89') + " N89 " 
	cQuery +=   " WHERE N89.D_E_L_E_T_ = '' "
	cQuery +=   " AND N89_FILROM     = NJM.NJM_FILIAL "
	cQuery +=   " AND N89.N89_CODCTR = NJM.NJM_CODCTR "
	cQuery +=   " AND N89.N89_CODROM = NJM.NJM_CODROM "
	cQuery +=   " AND N89.N89_NF     = NJM.NJM_DOCNUM "
	cQuery +=   " AND N89.N89_SERNF  = NJM.NJM_DOCSER ) "

	cQuery += " ORDER BY NJJ_CODROM "
	cQuery := ChangeQuery( cQuery )
	
	//--Identifica se tabela esta aberta e fecha
	If Select(cTMP01) <> 0
		(cTMP01)->(dbCloseArea())
	EndIf
				
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cTMP01,.T.,.T.)
	If Select(cTMP01) <> 0
		//-- para cada romaneio 
		While (cTMP01)->( !Eof() )
			lRetorno   := .T.	

			//-- Verifica corretores
			DbSelectArea("NNF")
			DbSetOrder(1)
			If DbSeek(FWxFilial('NNF') + _cCodCtr)
				While NNF->( !Eof() ) .And. NNF->NNF_FILIAL + NNF->NNF_CODCTR == FWxFilial('NNF') + _cCodCtr		
					
					If NNF->NNF_CODENT == _cCodCor .AND. NNF->NNF_LOJENT == _cLojCor
						
						//utilizado em mais de um IF
						//Se o parametro MV_1DUPREF estiver preenchido, deve tratar para buscar o prefixo
						If !Empty(cParPrefix)	
							If Select("SF2") > 0
								aAreaSf2 := SF2->(GetArea()	)
							Else
								DbSelectArea("SF2")
							EndIf
							SF2->(DBGOTOP())
							SF2->(dbSetOrder(1))
							// ---> Posiciona no registro da SF2 para poder executar a formula do Prefixo
							IF SF2->(DbSeek( fwxfilial("SF2")+(cTMP01)->NJM_DOCNUM+(cTMP01)->NJM_DOCSER+(cTMP01)->NJM_CODENT+(cTMP01)->NJM_LOJENT ) )
								cPrefixNF := &( cParPrefix )
							EndIF
						
							cQueryPref := " AND SE1.E1_PREFIXO = '" + cPrefixNF + "'"
						Else
							cQueryPref := " AND SE1.E1_PREFIXO = '" + (cTMP01)->NJM_DOCSER + "'"
						EndIF

						If !Empty(aAreaSf2)
							RestArea(aAreaSf2)
						Else
							SF2->(DbCloseArea())
						EndIf

						//Verifica qual é o mercado para direcionar as validações
						If Posicione('NJR', 1, xFilial('NJR') + _cCodCtr, 'NJR_TIPMER') == "1" //interno

							cTipCtr := Posicione('NJR', 1, xFilial('NJR') + _cCodCtr, 'NJR_TIPO')

							//Tipo 1=Compra - Titulos a Pagar
							If cTipCtr == '1'	

							   lSE2Comp := If(Empty(FWxFilial("SE2")), .T., .F.)

							   IF lSe1Comp //Considerando que a N8l Eestara seguindo a SE1
								   cSe2FilTFil := " AND SE2.E2_FILORIG 	= '" + (cTMP01)->NJJ_FILIAL	+ "' "
								   cN8MFilTFil := " ON  N8M.N8M_FILORI 	= '" + (cTMP01)->NJJ_FILIAL	+ "' "
								Else
								   cSe2FilTFil := " AND SE2.E2_FILIAL 	= '" + (cTMP01)->NJJ_FILIAL + "' "
								   cN8MFilTFil := " ON  N8M.N8M_FILIAL	= '" + (cTMP01)->NJJ_FILIAL + "' "
								EndIF			

								cQuery2 := " SELECT E2_VALOR AS VALFAT, 'N' AS NFCOMP, E2_NUM, E2_NUM AS DOC "
								cQuery2 +=   " FROM "+ RetSqlName('SE2')+" SE2"
								cQuery2 += 		" INNER JOIN " + RetSqlName('N8M')+ " N8M "
								cQuery2 += 		cN8MFilTFil
								cQuery2 += 		" AND N8M.N8M_PREFIX   = SE2.E2_PREFIXO "
								cQuery2 += 		" AND N8M.N8M_NUM	   = SE2.E2_NUM "
								cQuery2 += 		" AND N8M.N8M_PARCEL   = SE2.E2_PARCELA "
								cQuery2 += 		" AND N8M.N8M_TIPO	   = SE2.E2_TIPO "
								cQuery2 += 		" AND N8M.D_E_L_E_T_   = SE2.D_E_L_E_T_ "				
								cQuery2 +=      " WHERE SE2.D_E_L_E_T_ = '' "
								cQuery2 +=    cSe2FilTFil 		// Tratamento especial para Conceito de gestão unificada do financeiro 
								cQuery2 +=    " AND N8M.N8M_CODCTR	= '"+_cCodCtr+"'"
								cQuery2 +=    " AND E2_PREFIXO		= '"+ (cTMP01)->NJM_DOCSER +"'"
								cQuery2 +=    " AND E2_NUM			= '"+ (cTMP01)->NJM_DOCNUM +"'"					
								cQuery2 +=    " AND E2_TIPO 	    = 'NF'"

								//--Considera Titulos Baixados
								If NNF->NNF_TITROM == '2'
									cQuery2 +=    " AND E2_SALDO = 0 "
								Else 
									cQuery2 +=    " AND E2_SALDO > 0 "
								EndIf

							//Tipo 2=Venda - Titulos a Receber	
							ElseIf cTipCtr == '2'
								If NNF->NNF_QTDCON == '1' //Considerar "Origem"
									If (cTMP01)->NJJ_TIPO == '9' //Devolução de Venda
										cQuery2 := " SELECT 'N' AS NFCOMP, F1_DOC AS DOC, F1_VALBRUT AS VALFAT "
										cQuery2 +=   " FROM "+ RetSqlName('SF1')+" SF1"
										cQuery2 +=  " WHERE SF1.D_E_L_E_T_ = '' "
										cQuery2 +=    " AND SF1.F1_FILIAL  = '" + (cTMP01)->NJJ_FILIAL	+ "' " 		// Tratamento especial para Conceito de gestão unificada do financeiro 
										cQuery2 +=    " AND SF1.F1_CODROM  = '" + (cTMP01)->NJJ_CODROM + "'"
										cQuery2 +=    " AND SF1.F1_SERIE   = '" + (cTMP01)->NJM_DOCSER + "'"
										cQuery2 +=    " AND SF1.F1_DOC     = '" + (cTMP01)->NJM_DOCNUM + "'"
										If NNF->NNF_TITROM == '2'
											cQuery2 +=    " AND F1_VALBRUT = 0 "
										Else 
											cQuery2 +=    " AND F1_VALBRUT > 0 "
										EndIf							   
									Else
										cQuery2 := " SELECT 'N' AS NFCOMP, F2_DOC AS DOC, F2_VALFAT AS VALFAT"
										cQuery2 +=   " FROM "+ RetSqlName('SF2')+" SF2"
										cQuery2 += 	" INNER JOIN " + RetSqlName('N8L')+ " N8L ON  N8L.N8L_FILORI = '" + (cTMP01)->NJJ_FILIAL + "' "
										cQuery2 += 											" AND N8L.N8L_PREFIX = SF2.F2_PREFIXO "
										cQuery2 += 											" AND N8L.N8L_NUM	 = SF2.F2_DOC "
										cQuery2 += 											" AND N8L.D_E_L_E_T_ = SF2.D_E_L_E_T_ "				
										cQuery2 +=  " WHERE SF2.D_E_L_E_T_ 	= '' "
										cQuery2 +=    " AND SF2.F2_FILIAL 	= '" + (cTMP01)->NJJ_FILIAL	+ "' " 		// Tratamento especial para Conceito de gestão unificada do financeiro 
										cQuery2 +=    " AND N8L.N8L_CODCTR	= '" + _cCodCtr + "'"
										cQuery2 +=    " AND SF2.F2_SERIE	= '" + (cTMP01)->NJM_DOCSER + "'"
										cQuery2 +=    " AND SF2.F2_DOC		= '" + (cTMP01)->NJM_DOCNUM + "'"
										//--Considera Titulos Baixados
										If NNF->NNF_TITROM == '2'
											cQuery2 +=    " AND F2_VALFAT = 0 "
										Else 
											cQuery2 +=    " AND F2_VALFAT > 0 "
										EndIf

										cQuery2 += " UNION "

										cQuery2 += " SELECT 'S' AS NFCOMP, D2_DOC AS DOC, D2_TOTAL AS VALFAT "
										cQuery2 +=   " FROM "+ RetSqlName('SD2')+" SD2"
										cQuery2 +=  " WHERE SD2.D_E_L_E_T_ 	= '' "
										cQuery2 +=    " AND SD2.D2_FILIAL 	= '" + (cTMP01)->NJJ_FILIAL	+ "' " 
										cQuery2 +=    " AND SD2.D2_SERIORI	= '" + (cTMP01)->NJM_DOCSER + "'"
										cQuery2 +=    " AND SD2.D2_NFORI	= '" + (cTMP01)->NJM_DOCNUM + "'"
									EndIf
							   Else //Considerar "Destino"

							   		If (cTMP01)->NJJ_TIPO == '9' //Devolução de Venda
										cQuery2 := " SELECT SUM(E1_VALOR) AS VALFAT, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_MOEDA, E1_CLIENTE, E1_LOJA, 'N' AS NFCOMP, E1_NUM AS DOC  "
										cQuery2 +=   " FROM "+ RetSqlName('SE1')+" SE1"

										cQuery2 += 	" INNER JOIN " + RetSqlName('SF1')+ " SF1 ON SF1.F1_SERIE   = SE1.E1_PREFIXO "
										cQuery2 += 										   " AND SF1.F1_DOC	    = SE1.E1_NUM "
										cQuery2 += 										   " AND SF1.F1_FILIAL  = SE1.E1_FILORIG "
										cQuery2 += 										   " AND SF1.D_E_L_E_T_ = SE1.D_E_L_E_T_ "				
										cQuery2 +=  " WHERE SE1.D_E_L_E_T_ = '' "
										cQuery2 +=  cQueryPref  
										cQuery2 +=    " AND SE1.E1_NUM = '"+ (cTMP01)->NJM_DOCNUM + "'"

										//--Considera Titulos Baixados
										If NNF->NNF_TITROM == '2'
											cQuery2 +=    " AND E1_SALDO = 0 "
										Else 
											cQuery2 +=    " AND E1_SALDO > 0 "
										EndIf
										cQuery2 +=    " GROUP BY E1_PREFIXO, E1_NUM, E1_PARCELA, E1_MOEDA, E1_CLIENTE, E1_LOJA"
	
							   		Else
										lSE1Comp 	:= If(Empty(FWxFilial("SE1")), .T., .F.)
										IF lSe1Comp //Considerando que a N8l Eestara seguindo a SE1
										   cSe1FilTFil := " AND SE1.E1_FILORIG 	= '" + (cTMP01)->NJJ_FILIAL	+ "' "
										   cN8LFilTFil := " ON  N8L.N8L_FILORI	= '" + (cTMP01)->NJJ_FILIAL	+ "' "
										Else
										   cSe1FilTFil := " AND SE1.E1_FILIAL 	= '" + FwxFilial("SE1") + "' "
										   cN8LFilTFil := " ON  N8L.N8L_FILORI	= '" + (cTMP01)->NJJ_FILIAL + "' "
										EndIF

										cQuery2 := " SELECT E1_VALOR AS VALFAT, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_MOEDA, E1_CLIENTE, E1_LOJA, 'N' AS NFCOMP, E1_NUM AS DOC  "
										cQuery2 +=   " FROM "+ RetSqlName('SE1')+" SE1"
										cQuery2 += 	" INNER JOIN " + RetSqlName('N8L')+ " N8L "
										cQuery2 += 		cN8LFilTFil
										cQuery2 += 		" AND N8L.N8L_PREFIX = SE1.E1_PREFIXO "
										cQuery2 += 		" AND N8L.N8L_NUM	 = SE1.E1_NUM "
										cQuery2 += 		" AND N8L.N8L_PARCEL = SE1.E1_PARCELA "
										cQuery2 += 		" AND N8L.N8L_TIPO	 = SE1.E1_TIPO "
										cQuery2 += 		" AND N8L.D_E_L_E_T_ = SE1.D_E_L_E_T_ "				
										cQuery2 +=  " WHERE SE1.D_E_L_E_T_ 	= '' "
										cQuery2 +=    cSe1FilTFil 		// Tratamento especial para Conceito de gestão unificada do financeiro 
										cQuery2 +=    " AND N8L.N8L_CODCTR	= '" + _cCodCtr + "'"

										cQuery2 +=  cQueryPref 
										cQuery2 +=    " AND SE1.E1_NUM  = '"+ (cTMP01)->NJM_DOCNUM + "'"
										cQuery2 +=    " AND SE1.E1_TIPO	= 'NF'"

										//--Considera Titulos Baixados
										If NNF->NNF_TITROM == '2'
											cQuery2 +=    " AND E1_SALDO = 0 "
										Else 
											cQuery2 +=    " AND E1_SALDO > 0 "
										EndIf
									EndIf
								EndIf							
							EndIf 
							
						Else //externo
							
							//Pega somente os valores pagos descontando os saldos
							lSE1Comp 	:= If(Empty(FWxFilial("SF2")), .T., .F.)
							IF lSe1Comp 
								cSe1FilTFil := " AND SF2.E1_FILORIG 	= '" + (cTMP01)->NJJ_FILIAL	+ "' "
							Else
								cSe1FilTFil := " AND SE1.E1_FILIAL 	= '" + FwxFilial("SE1") + "' "
							EndIF

							cQuery2 := " SELECT EEM.EEM_VLNFM AS VALFAT, "
							cQuery2 +=        " F2_SERIE, "
							cQuery2 +=        " F2_MOEDA, "
							cQuery2 +=        " F2_CLIENTE, "
							cQuery2 +=        " F2_LOJA, "
							cQuery2 +=        " 'N' AS NFCOMP, "
							cQuery2 +=        " F2_DOC AS DOC "
							cQuery2 += " FROM " + RetSqlName('SF2') + " SF2 "
							cQuery2 += " INNER JOIN EEM180 EEM ON (EEM.EEM_FILIAL     = '" + (cTMP01)->NJJ_FILIAL + "'"
							cQuery2 +=                           " AND EEM.EEM_NRNF   = SF2.F2_DOC "
							cQuery2 +=                           " AND EEM.EEM_SERIE  = SF2.F2_SERIE "
							cQuery2 +=                           " AND EEM.D_E_L_E_T_ = SF2.D_E_L_E_T_) "
							cQuery2 += " WHERE SF2.D_E_L_E_T_ = '' "
							cQuery2 += " AND SF2.F2_FILIAL    = '" + (cTMP01)->NJJ_FILIAL + "'"
							cQuery2 += " AND SF2.F2_SERIE     = '" + (cTMP01)->NJM_DOCSER + "'
							cQuery2 += " AND SF2.F2_DOC       = '" + (cTMP01)->NJM_DOCNUM + "'"
							cQuery2 += " AND EXISTS (SELECT EEC_FIM_PE " //QUERY QUE VERIFICA SE O EMBARQUE ESTÁ FINALIZADO
							cQuery2 +=                " FROM " + RetSqlName('N82') + " N82 "
							cQuery2 +=                " INNER JOIN " + RetSqlName('EEC') + " EEC ON (N82.N82_FILORI = EEC.EEC_FILIAL "
							cQuery2 +=                " AND N82.N82_PEDIDO = EEC.EEC_PEDREF "
							cQuery2 +=                " AND N82.D_E_L_E_T_ = EEC.D_E_L_E_T_) "
							cQuery2 +=              " WHERE N82.D_E_L_E_T_ = '' "
							cQuery2 +=                " AND N82.N82_FILORI = '" + (cTMP01)->NJJ_FILIAL + "'"
							cQuery2 +=                " AND N82.N82_CODINE = '" + (cTMP01)->NJM_CODINE + "'"
							cQuery2 +=                " AND EEC.EEC_FIM_PE <> '') "
							cQuery2 += " AND NOT EXISTS (SELECT SE1.E1_SALDO " //QUERY QUE VERIFICA SE TODOS OS TITULOS ESTÃO PAGOS
							cQuery2 +=                   " FROM " + RetSqlName('SE1') + " SE1 "
							cQuery2 +=                  " WHERE SE1.E1_FILIAL  = '" + (cTMP01)->NJJ_FILIAL + "'"
							cQuery2 +=                   " AND SE1.E1_NUM     = SF2.F2_DUPL "
							cQuery2 += cQueryPref
							cQuery2 +=                   " AND SE1.E1_CLIENTE = SF2.F2_CLIENTE " 
							cQuery2 +=                   " AND SE1.E1_LOJA    = SF2.F2_LOJA "
							cQuery2 +=                   " AND SE1.E1_SALDO   > 0 "
							cQuery2 +=                   " AND SE1.D_E_L_E_T_ = SF2.D_E_L_E_T_ ) "

						EndIf
						
						cQuery2 := ChangeQuery( cQuery2 )
					 	//--Identifica se tabela esta aberta e fecha
						If Select(cTMP02) <> 0
							(cTMP02)->(dbCloseArea())
						EndIf

						dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery2),cTMP02,.T.,.T.)
						
						If Select(cTMP02) <> 0
							
							While (cTMP02)->( !Eof() )

									RecLock((__cTabRom),.T.)				
										(__cTabRom)->NJR_FILIAL	:= (cTMP01)->NJJ_FILIAL
										(__cTabRom)->NJM_DOCNUM	:= (cTMP02)->DOC 
										(__cTabRom)->NJM_DOCSER	:= (cTMP01)->NJM_DOCSER
										(__cTabRom)->NJJ_CODROM := (cTMP01)->NJJ_CODROM
										(__cTabRom)->NJJ_FILIAL	:= (cTMP01)->NJJ_FILIAL
										(__cTabRom)->NJJ_DATA	:= StoD((cTMP01)->NJJ_DATA)
										(__cTabRom)->NJJ_CODSAF	:= (cTMP01)->NJJ_CODSAF
										(__cTabRom)->NJJ_PESO1	:= (cTMP01)->NJJ_PESO1
										(__cTabRom)->NJJ_PESO2	:= (cTMP01)->NJJ_PESO2
										(__cTabRom)->NJJ_PSSUBT	:= (cTMP01)->NJJ_PSSUBT
										(__cTabRom)->NJJ_PSLIQU	:= (cTMP01)->NJJ_PSLIQU
										(__cTabRom)->NJM_QTDFCO	:= (cTMP01)->NJM_QTDFCO
										(__cTabRom)->NJM_QTDFIS	:= (cTMP01)->NJM_QTDFIS										
										(__cTabRom)->NJJ_TIPO	:= (cTMP01)->NJJ_TIPO
										(__cTabRom)->NJM_VLRUNI	:= (cTMP01)->NJM_VLRUNI
										(__cTabRom)->NJM_VLRTOT	:= (cTMP02)->VALFAT //valor Faturado, utilizado somente no ME
										(__cTabRom)->NJR_MOEDA	:= Posicione('NJR', 1, xFilial('NJR') + _cCodCtr, 'NJR_MOEDA')
										(__cTabRom)->NJM_DOCESP	:= (cTMP01)->NJM_DOCESP
										(__cTabRom)->N9A_OPEFUT := (cTMP01)->N9A_OPEFUT
										(__cTabRom)->NFCOMP     := (cTMP02)->NFCOMP
									(__cTabRom)->(MsUnlock())	
								
								//--proximo registro 
								(cTMP02)->(dbSkip())
							EndDo
						EndIF
					
					EndIf
					//--proximo registro tabela NNF
					NNF->(dbSkip())
				EndDo
			EndIf
			
			//--proximo registro tabela principal
			(cTMP01)->(dbSkip())
		EndDo 
		
	EndIf
	
	If .NOT. lRetorno
		MSGINFO(STR0025)	//"Não existem romaneios para serem simulados."
	EndIf 
	
	//--Fecha tabela temporaria principal
	(cTMP01)->(dbCloseArea())
	
Return lRetorno

/*
Função que monta as Temp-Tables da Rotina
@param:     Nil
@return:    cTabela
@author:    Daniel Maniglia
@since:    03/10/2017
@Uso:       OGC090 - Painel de comissão
*/
Static Function MontaTabel(aCpsBrow, aIdxTab)
    Local nCont 	:= 0
    Local cTabela	:= ''
	Local aStrTab 	:= {}	//Estrutura da tabela
	Local oArqTemp	:= Nil	//Objeto retorno da tabela

    //-- Busca no aCpsBrow as propriedades para criar as colunas
    For nCont := 1 to Len(aCpsBrow)
        aADD(aStrTab,{aCpsBrow[nCont][2], aCpsBrow[nCont][3], aCpsBrow[nCont][4], aCpsBrow[nCont][5] })
    Next nCont
   	//-- Tabela temporaria de pendencias
   	cTabela  := GetNextAlias()
   	//-- A função AGRCRTPTB está no fonte AGRUTIL01 - Funções Genericas
    oArqTemp := AGRCRTPTB(cTabela, {aStrTab, aIdxTab})

Return cTabela

/*
{Protheus.doc} OGC100CROM
Função de Update do Browse
@author Daniel Maniglia
@since 11/08/2017
@version undefined
@param Nil
@type function
*/
Function OGC100CROM()
	Local lRetorno  := .T.
	Local aRetorno  := {}
	Local aRetorn2  := {}
	Local cSeqCal   := '000'
	Local nSaveSx8  := GetSx8Len()
	Local cCodCom   := ''			//GETSXENUM('N89','N89_CODCOM')	
	Local aAreaAtu  := GetArea()
	Local cSavFil   := ''
	Local nVlrCom   := 0	
	Local nMult     := 1
	Local cTipMer   := ""
	Local cTipCtr   := ""
	Local cAliasNJ0 := GetNextAlias()
	Local lCorrExt  := .F.
	Local nPosC		:= 0
	Local cUsrName  := UsrRetName(RetCodUsr())
	
	cSavFil  := N89->( dbfilter() )
	N89->(DBClearFilter())

	//-- Retira o filtro da tabela N89 retornando o filtro inicial
	N89->(DBClearFilter())
	IF !Empty(cSavFil)		
		//-- Retorna o filtro Inicial
		N89->( DBSetFilter ( {|| &cSavFil}, cSavFil) )  // Retorna o filtro Inicial
	EndIF	
	
	//--Romaneios selecionados - para calculo.
	DbSelectArea((__cTabRom))
	DbGoTop()
	If DbSeek((__cTabRom)->NJJ_FILIAL+(__cTabRom)->NJJ_CODROM)
		
		cSeqCal := '000'
        cCodCom  := GETSXENUM('N89','N89_CODCOM')	
		ProcRegua(RecCount())

		While .NOT. (__cTabRom)->(Eof())
			If (__cTabRom)->MARK == "1"
				
				IncProc()
				nVlrCom := 0
				
				//--Corretores - do contrato
				DbSelectArea('NNF')
				DbSetOrder(1)
				If DbSeek(FWxFilial('NNF')+_cCodCtr)
					While  .Not. NNF->( Eof() ) .And. NNF->NNF_FILIAL == FWxFilial('NNF') .AND. NNF->NNF_CODCTR == _cCodCtr 
					
					lCorrExt	:= .F.
					nVlrCom		:= 0
					
					If NNF->NNF_CODENT == _cCodCor .AND. NNF->NNF_LOJENT == _cLojCor
						
						//Verifica se o Agente é Externo ou interno.
						If Select(cAliasNJ0) <> 0
							(cAliasNJ0)->(dbCloseArea())
						EndIf 
							
						cQuery := "SELECT SA2.A2_EST "
						cQuery += "FROM " + RetSqlName("NJ0")  + " NJ0 "
						cQuery += "INNER JOIN " + RetSqlName("SA2")  + "  SA2 ON (SA2.A2_FILIAL  = '" + fwxfilial("SA2") + "' AND 
						cQuery +=                                                "SA2.A2_COD     = NJ0.NJ0_CODFOR AND 
						cQuery +=                                                "SA2.A2_LOJA    = NJ0.NJ0_LOJFOR AND 
						cQuery +=                                                "SA2.D_E_L_E_T_ = NJ0.D_E_L_E_T_)
						cQuery += "WHERE NJ0.D_E_L_E_T_ = '' "
						cQuery += "AND NJ0.NJ0_FILIAL = '" + Fwxfilial("NJ0") + "' "
						cQuery += "AND NJ0.NJ0_CODENT = '" + NNF->NNF_CODENT + "' "
						cQuery += "AND NJ0.NJ0_LOJENT = '" + NNF->NNF_LOJENT + "' "
						
						cQuery := ChangeQuery(cQuery)
						
						dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery),cAliasNJ0, .F., .T.)
						
						If (cAliasNJ0)->(!Eof())
						 	If  (cAliasNJ0)->A2_EST == "EX"
								lCorrExt := .T.
							EndIf
						EndIf
						(cAliasNJ0)->(DbCloseArea())

						cTipMer	:= Posicione('NJR',1,xFilial('NJR')+_cCodCtr,'NJR_TIPMER')

						If cTipMer == "1"
						
							//Tipo de Comissao [1= % Valor Contrato ]
							If NNF->NNF_MODCOM == "1"

								cTipCtr := Posicione('NJR',1,xFilial('NJR')+_cCodCtr,'NJR_TIPO')

								//Tipo 1=Compra - Titulos a Pagar
								If cTipCtr == '1'								

									//--Verifica Se calcula com titulo baixado ou NF
									DbSelectArea("SE2")
									DbSetOrder(1) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA   
									If DbSeek(FWxFilial('SE2')+ (__cTabRom)->NJM_DOCSER + (__cTabRom)->NJM_DOCNUM )		

										If SE2->E2_ACRESC  > 0
											nVlrCom	:= SE2->E2_ACRESC
										ElseIf SE2->E2_DECRESC  > 0
											nVlrCom	:= -SE2->E2_DECRESC
										EndIf

										//Verifica se possui NF de complemento - Entrada
										DbSelectArea('SD1')
										DbSetOrder(10) 
										If DbSeek(FWxFilial('SD1')+ (__cTabRom)->NJM_DOCNUM + (__cTabRom)->NJM_DOCSER)							
											//--SE NF é de complemento
											If SD1->D1_TIPO = 'C'
												//nVlrCom += SD1->D1_VUNIT
												dbSelectArea("NKC")
												dbSetOrder(3) //NKC_FILIAL+NKC_DOCTO+NKC_SERIE
												If dbSeek(FWxFilial("NKC")+(__cTabRom)->NJM_DOCNUM + (__cTabRom)->NJM_DOCSER)

													nVlrCom += NKC->NKC_VRUN

												EndIf
											EndIf
										EndIf

										aRetorno 	:= OGX030((__cTabRom)->NJJ_FILIAL, _cCodCtr, (__cTabRom)->NJJ_CODROM , NNF->NNF_CODENT, NNF->NNF_LOJENT, NNF->NNF_MODCOM, nVlrCom )
										cSeqCal 	:= Soma1(cSeqCal)

									Else 
										aRetorno 	:= OGX030((__cTabRom)->NJJ_FILIAL, _cCodCtr, (__cTabRom)->NJJ_CODROM , NNF->NNF_CODENT, NNF->NNF_LOJENT, NNF->NNF_MODCOM, nVlrCom )
										cSeqCal 	:= Soma1(cSeqCal)
									EndIF

								ElseIf cTipCtr == '2'

									DbSelectArea("SE1")
									DbSetOrder(1)	//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
									If DbSeek(FWxFilial('SE1') + (__cTabRom)->NJM_DOCSER + (__cTabRom)->NJM_DOCNUM )		

										If SE1->E1_ACRESC  > 0
											nVlrCom	:= SE1->E1_ACRESC
										ElseIf SE1->E1_DECRESC  > 0
											nVlrCom	:= -SE1->E1_DECRESC
										EndIf

										//--Verifica se possui NF de complemento - Saída
										DbSelectArea('SD2')
										DbSetOrder(10)
										If DbSeek(FWxFilial('SD2')+ (__cTabRom)->NJM_DOCNUM + (__cTabRom)->NJM_DOCSER)							
											//--SE NF é de complemento
											If SD2->D2_TIPO = 'C'
												//nVlrCom += SD2->D2_PRCVEN
												dbSelectArea("NKC")
												dbSetOrder(3) //NKC_FILIAL+NKC_DOCTO+NKC_SERIE
												If dbSeek(FWxFilial("NKC")+ SD2->D2_DOC + SD2->D2_SERIE )

													nVlrCom += NKC->NKC_VRUN

												EndIf 
											EndIf										
										EndIf 

										aRetorno 	:= OGX030((__cTabRom)->NJJ_FILIAL, _cCodCtr, (__cTabRom)->NJJ_CODROM , NNF->NNF_CODENT, NNF->NNF_LOJENT, NNF->NNF_MODCOM, nVlrCom )
										cSeqCal 	:= Soma1(cSeqCal)
									Else 
										aRetorno 	:= OGX030((__cTabRom)->NJJ_FILIAL, _cCodCtr, (__cTabRom)->NJJ_CODROM , NNF->NNF_CODENT, NNF->NNF_LOJENT, NNF->NNF_MODCOM, nVlrCom )
										cSeqCal 	:= Soma1(cSeqCal)
									EndIF									
								EndIf
							Else
								aRetorno 	:= OGX030((__cTabRom)->NJJ_FILIAL, _cCodCtr, (__cTabRom)->NJJ_CODROM , NNF->NNF_CODENT, NNF->NNF_LOJENT, NNF->NNF_MODCOM, nVlrCom )
								cSeqCal 	:= Soma1(cSeqCal)
							EndIf 
						Else
							
							aRetorn2 := OGX030C2((__cTabRom)->NJJ_FILIAL, _cCodCtr, (__cTabRom)->NJM_VLRUNI, (__cTabRom)->NJM_QTDFIS)
							cSeqCal	 := Soma1(cSeqCal)

							//a função OGX030C2 pode retornar mais de um agente de comissão, aqui tratamos somente o corrente
							nPosC := aScan( aRetorn2, { |x| AllTrim( x[16] ) == AllTrim(NNF->NNF_CODENT + NNF->NNF_LOJENT) } )

							If nPosC > 0
								//Ajusta o retorno para a inclusão 
								aAdd(aRetorno,{'COD_CONTRATO' , _cCodCtr				})	//Posicao 01
								aAdd(aRetorno,{'COD_CORRETOR' , NNF->NNF_CODENT			})	//Posicao 02
								aAdd(aRetorno,{'LOJ_CORRETOR' , NNF->NNF_LOJENT			})	//Posicao 03
								aAdd(aRetorno,{'COD_ROMANEIO' , (__cTabRom)->NJJ_CODROM	})	//Posicao 04
								aAdd(aRetorno,{'QTD_ROMANEIO' , (__cTabRom)->NJM_QTDFIS	})	//Posicao 05
								aAdd(aRetorno,{'VLR_UNT_CTR'  , aRetorn2[nPosC][7]		})	//Posicao 06
								aAdd(aRetorno,{'UM_ROMANEIO'  , aRetorn2[nPosC][5]		})	//Posicao 07
								aAdd(aRetorno,{'UM_CORRETOR'  , NNF->NNF_UNIMED 		})	//Posicao 08
								aAdd(aRetorno,{'VLR_CONVERS'  , 0						})	//Posicao 09
								aAdd(aRetorno,{'VLR_UNITAR'   , aRetorn2[nPosC][7]		})	//Posicao 10
								aAdd(aRetorno,{'VLR_CONS_CORR', IIF(lCorrExt, aRetorn2[nPosC][11],aRetorn2[nPosC][12] ) })	//Posicao 11
								aAdd(aRetorno,{'VLR_COMISSAO' , IIF(lCorrExt, aRetorn2[nPosC][11],aRetorn2[nPosC][12] ) })	//Posicao 12
								aAdd(aRetorno,{'FATOR_CONVERS', 0						})	//Posicao 13
								aAdd(aRetorno,{'VLR_COMPLEMEN', aRetorn2[nPosC][9]		})	//Posicao 14
								aAdd(aRetorno,{'VLR_BASE' 	  , aRetorn2[nPosC][9]		})	//Posicao 15								
							EndIf

						EndIf

						If len(aRetorno) > 0
							DbSelectArea("N89")
							N89->(DbGoTop())
							N89->( dbSetOrder(1) ) //N89_FILIAL+N89_CODCTR+N89_FILROM+N89_CODROM+N89_CODCOR+N89_LOJCOR+N89_ITEM
							If .NOT. N89->(DbSeek(FWxFilial("N89") + _cCodCtr + (__cTabRom)->NJJ_FILIAL + (__cTabRom)->NJJ_CODROM + cSeqCal )) 	
								
								//assume a moeda do contrato somente se for mercado Externo e o fornecedor for Exterior, caso contrário sempre será moeda 1
								If cTipMer == "2" .AND. lCorrExt
									nMoeCtr	:= Posicione('NJR',1,xFilial('NJR')+_cCodCtr,'NJR_MOEDA')
								Else
									nMoeCtr := 1
								EndIf

								nMult := IIF((__cTabRom)->NJJ_TIPO == '9',-1,1)

								RecLock("N89",.T.)
								N89->N89_FILIAL := FwxFilial("N89")
								N89->N89_CODCOM := cCodCom 						//Código Comissão
								N89->N89_ITEM   := cSeqCal						//Sequencia
								
								N89->N89_CODCTR := _cCodCtr						//Código do Contrato
								N89->N89_FILROM	:= (__cTabRom)->NJJ_FILIAL      //Filial do Romaneio
								N89->N89_CODROM	:= (__cTabRom)->NJJ_CODROM		//Código do Romaneio
								
								N89->N89_CODCOR := NNF->NNF_CODENT              //Código do corretor
								N89->N89_LOJCOR := NNF->NNF_LOJENT	   			//Loja do corretor
								N89->N89_TPOPER := '1'      					//Tipo Operação		1=Calculo Comissão
								
								N89->N89_RUMROM	:= aRetorno[7][2]				//Unidade de Medida Romaneio
								N89->N89_RVRUNI	:= aRetorno[10][2]			 	//Valor Unitario		+ Complemento
								
								N89->N89_RPSFCO	:= (__cTabRom)->NJM_QTDFCO * nMult //Peso Fisico
								N89->N89_RPSFCL	:= (__cTabRom)->NJM_QTDFIS * nMult //Peso Fiscal
								N89->N89_VLRDOC	:= aRetorno[15][2] * nMult 		   // Valor do unit. Documento
								N89->N89_RVRTOT	:= aRetorno[14][2] * nMult	 	   //Valor Total Romaneio 	+ Complemento 
								
								N89->N89_TPCOMS	:= NNF->NNF_MODCOM				//Tipo Comissão
								N89->N89_UMCOMS	:= aRetorno[8][2]				//Unidade de Medida Comissão
								N89->N89_VRCOMS	:= aRetorno[11][2]				//Valor da Comissão -- PODE SER NEGATIVO
								N89->N89_CMOEDA	:= nMoeCtr						//Moeda Base Contrato

								N89->N89_VRCALC	:= aRetorno[12][2]				//Valor Calculada da Comissão
								N89->N89_DTCALC	:= dDataBase					//Data Calculada da Comissão
								N89->N89_USER	:= cUsrName						//Usuário
								N89->N89_CTPMER	:= cTipMer						//Tipo de Mercado Contrato							
								N89->N89_STATUS	:= '1'							//Status			1=Simulado								
								If FieldPos("N89_TIPDOC") > 0
									N89->N89_TIPDOC := (__cTabRom)->NJM_DOCESP
									If (__cTabRom)->NFCOMP == 'S'
										N89->N89_ORIGEM := STR0032 //"NF de Complemento"
									Else
										N89->N89_ORIGEM := STR0028 + IIF((__cTabRom)->N9A_OPEFUT="1"," " + STR0031,"") //"Romaneio" ###"Global Futura"
									EndIf								
								EndIf
								
								//adicionados dois novos campos - numero e Serie da NF 
								N89->N89_NF		:= (__cTabRom)->NJM_DOCNUM
								N89->N89_SERNF	:= (__cTabRom)->NJM_DOCSER
								N89->N89_TXMOED	:= NNF->NNF_TXMOED

								N89->(MsUnlock())
							EndIf
						Else
							MsgInfo(STR0033) //Parâmetros da corretagem não informados.
						EndIf
					EndIf						
						aRetorno := {}
						NNF->(DbSkip())
					EndDo

				EndIf 
			EndIf
			
			(__cTabRom)->( dbSkip() )
		EndDo

		While (GetSX8Len() > nSaveSx8)
			ConfirmSx8()
		End
	Else
		RollbackSx8()
	EndIf 			
	
	If lRetorno 
		OGC100UP(oBrowse1)
		MsgInfo( STR0022, STR0023 ) //"Romaneios relacionados com sucesso." - "Relação de Romaneios ao contrato"
	Else
		MsgInfo( STR0027, STR0026 )	//"AJUDA" - "Não foi possivel realizar a comissao!"
	EndIf

	//-- Restaura Area
	RestArea(aAreaAtu)

return .T.

/*
{Protheus.doc} OGC100LOAD
Marca os romaneios antes selecionados
@author Daniel Maniglia
@since 03/10/2017
@version undefined
@param objBrowser
@type function
*/
Function OGC100LOAD(oBrowse1)
	Local cCtr  := ''

	//Atualiza a temporária com os valores da N89 ()anteriormente selecionados)
	DbSelectArea((__cTabRom))
	DbGoTop()
	If DbSeek((__cTabRom)->NJJ_FILIAL)
		While !(__cTabRom)->(Eof())
			cCtr := GetDataSql("SELECT N89_CODCTR FROM " + RetSqlName("N89") +" N89 WHERE N89_FILIAL = '" + xFilial("N89")  + "'" +  " AND N89_CODCTR = '" + _cCodCtr + "' AND N89_CODROM = '" + (__cTabRom)->NJJ_CODROM + "' AND N89_CODCOR = '" + _cCodCor + "' AND N89_LOJCOR = '" + _cLojCor + "' AND D_E_L_E_T_ = ' ' ") 
			If !Empty(cCtr)
				RecLock("N89",.F.)

				(__cTabRom)->MARK := "1"
				MsUnlock()
			EndIf
			cCtr  := ''
			(__cTabRom)->( dbSkip() )		
		enddo
	endif
    OGC100UP(oBrowse1)

return

/*{Protheus.doc} OGC100UP
Função de Update do Browse
@author Daniel Maniglia
@since 03/10/2017
@version undefined
@param objBrowser lUpdAll
@type function
*/
Function OGC100UP(objBrowser, lUpdAll)

	Default lUpdAll := .T.

	if lUpdAll
		objBrowser:UpdateBrowse() //reconstroi tudo
	else
		objBrowser:LineRefresh() //só refaz a linha
	endif
	objBrowser:GoColumn(1)

return .T.

/*{Protheus.doc} OGC100ALIN
Função retorna o alinhamento do campo do browse
@author Daniel Maniglia
@since 03/10/2017
@version undefined
@param NIL
@return: 1 (direita) ou 2 (esquerda)
@type function
*/
Function OGC100ALIN(ntipo)

	Local nAlinha

	If ntipo == 'C' //char
		nAlinha := 0 //Centralizado
	Else
		nAlinha := 2 //Alinhado a direita
	EndIf

Return nAlinha


static function OGC100EXROM()
	Local cAliasNJJ	 := GetNextAlias()
	Local cFiltro    := ""	
	Local lExisteRom 	:= .F.

	If !empty(_cCodCtr)
		cFiltro += "AND NJJ.NJJ_CODCTR = '"+_cCodCtr+" ' AND NJJ_STATUS = '3' "
	Endif

	cFiltro := "%" + cFiltro + "%"

	BeginSql Alias cAliasNJJ

	SELECT NJJ_STATUS
     FROM %Table:NJJ% NJJ inner join %Table:NJM% NJM on NJJ.NJJ_FILIAL = NJM.NJM_FILIAL
     										        AND NJJ.NJJ_CODROM = NJM.NJM_CODROM
     										        AND NJM.%notDel%
    WHERE NJJ.%notDel%
		      %exp:cFiltro%
	EndSQL

	DbselectArea( cAliasNJJ )
	DbGoTop()
	if !Empty((cAliasNJJ)->NJJ_STATUS)
		lExisteRom 	:= .T.
	EndiF

	(cAliasNJJ)->(dbCloseArea())

	If !lExisteRom
		Alert(STR0024)
	EndIf

return lExisteRom
