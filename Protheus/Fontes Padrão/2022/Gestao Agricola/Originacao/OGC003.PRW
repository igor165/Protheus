#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "OGC003.CH"

#DEFINE CR Chr(13) + Chr(10)

/* 
############################################################################
# Função    : OGC003                                                       #
# Descrição : Consulta Romaneios			                               #
# Autor     : Ana Laura Olegini                                            #
# Data      : 08/12/2014                                                   #
############################################################################
*/
	
Function OGC003( pcCodCtr, pcCodIE )
	Private _cCodIE  := ""
	Private aArqRom := {}	
	Private vVetRom := {}
	Private aAlT1,aAlT2,aAlT3
	Private cAlt1,cAlT2,cAlT3
	Private cNoT1,cNoT2,cNoT3
	Private aOpcRot := {}
	//  Campo, Tipo, Tamanho, Decimal, Título, Picture
	Private aCamTot := { { "TOTAIS"			, "C", 60, 0, STR0056, "@!" },;	//"TOTAIS"
	{ "NJM_QTDFCO"},;  
	{ "NJM_QTDFIS"},;
	{ "NJM_VLRTOT"},;
	{ "BRANCO"			, "C", 60, 0, " ", "@!" } }

	Private aTotDad := {}

	Private aLegRom  := { { "NJJ_STATUS=='0'", X3CboxDesc( "NJJ_STATUS", "0" ), "VO" },;	//Pendente
	{ "NJJ_STATUS=='1'", X3CboxDesc( "NJJ_STATUS", "1" ), "AO" },;	//Completo
	{ "NJJ_STATUS=='2'", X3CboxDesc( "NJJ_STATUS", "2" ), "LA" },;	//Atualizado
	{ "NJJ_STATUS=='3'", X3CboxDesc( "NJJ_STATUS", "3" ), "VE" },;	//Confirmado
	{ "NJJ_STATUS=='4'", X3CboxDesc( "NJJ_STATUS", "4" ), "XX" } }	//Cancelado
	
	Default pcCodIE := ""
	_cCodIE := pcCodIE

	aAdd( aOpcRot, { STR0050, {|| OGX001Rom( (cAlT2)->NJJ_FILIAL, (cAlT2)->NJJ_CODROM ) }, , 2, 0 } )	//"Visualizar Rom."
	aAdd( aOpcRot, { STR0051, {|| OGX001Mov( (cAlT2)->NJM_IDMOV ) }, , 2, 0 } )							//"Movimentação"
	aAdd( aOpcRot, { STR0055, {|| OGX001Ctr( (cAlT2)->NJJ_FILIAL, (cAlT2)->NJM_CODCTR ) }, , 2, 0 } )	//"Contrato"
	aAdd( aOpcRot, { STR0062, {|| OGA440NFE(2) }, , 2, 0 } )	//"SpedNF-e"
	aAdd( aOpcRot, { STR0064, {|| OGC003ATCF() }, , 2, 0 } )	//"Atualizar/Confirmar Romaneio"

	/*+==========================+
	|| ARQUIVO TEMPORARIO 		||
	+===========================*/

	aadd(vVetRom , {"NJJ_FILIAL"} )
	aadd(vVetRom , {"NJM_IDMOV"} )
	aadd(vVetRom , {"NJJ_CODROM"} )
	aadd(vVetRom , {"TIPO"	  		, "C",53,0,STR0042, "@!"} )	//"Tipo Romaneio"
	aadd(vVetRom , {"TIPO2"	  	, "C",30,0,"Tipo Romaneio", "@!"} ) //"Tipo Romaneio"
	aadd(vVetRom , {"TIPENT"	  	, "C",20,0,STR0024, "@!"} )	//"Tipo Controle"         
	aadd(vVetRom , {"NJJ_DATA"}	)	
	aadd(vVetRom , {"NJM_DTRANS"} )
	aadd(vVetRom , {"NJM_CODENT"  	, "C",TamSX3("NJ0_CODENT")[1],0,STR0046, "@!" }	)		
	aadd(vVetRom , {"ENTIDADE"		, "C",TamSX3("NJ0_NOME")[1],0,STR0025, "@!" } )	//"Entidade"
	aadd(vVetRom , {"NJM_LOJENT"} )
	aadd(vVetRom , {"NJM_NLJENT"} )	//"Nome Loja"
	aadd(vVetRom , {"NJ0_INSCR"} )	//"IE Loja"
	aadd(vVetRom , {"NJM_CODCTR"} )
	aadd(vVetRom , {"NJM_CODAUT"} )  //Autorizacao
	aadd(vVetRom , {"CODENTTERC"   , "C",TamSX3("NJ0_CODENT")[1],0,STR0047, "@!" } ) //"Ent Terceiro"
	aadd(vVetRom , {"NOMENTTERC"	, "C",TamSX3("NJ0_NOME")[1],0,STR0048, "@!"} )	//"Nome Terceiro"    
	aadd(vVetRom , {"NJM_CODSAF"} )
	aadd(vVetRom , {"STATUS"		, "C",20,0,STR0026, "@!"} )	//"Situação"
	aadd(vVetRom , {"STATUSNFE"	, "C",20,0,STR0063, "@!"} )	//"Status NFe"
	aadd(vVetRom , {"PRODUTO"		, "C",TamSX3("B1_DESC")[1],0,STR0027, "@!"}	)	//"Produto"
	aadd(vVetRom , {"NJJ_PLACA"} )
	aadd(vVetRom , {"B5_CULTRA"} )
	aadd(vVetRom , {"B5_CTVAR"} )
	aadd(vVetRom , {"DESCRICAO"    , "C",TamSX3("NP4_DESCRI")[1],0,"Desc. Cult.", "@!"} )  //
	aadd(vVetRom , {"NJM_LOCAL"		, "C",TamSX3("NNR_DESCRI")[1],0,STR0028, "@!"} )	//"Local"
	aadd(vVetRom , {"NJM_TALHAO"} )
	aadd(vVetRom , {"NJJ_PESO1"} )
	aadd(vVetRom , {"NJJ_DATPS1"} )
	aadd(vVetRom , {"NJJ_HORPS1"} ) 
	aadd(vVetRom , {"NJJ_MODPS1"} )
	aadd(vVetRom , {"NJJ_PESO2"} ) 
	aadd(vVetRom , {"NJJ_DATPS2"} ) 
	aadd(vVetRom , {"NJJ_HORPS2"} ) 
	aadd(vVetRom , {"NJJ_MODPS2"} ) 
	aadd(vVetRom , {"NJJ_PSSUBT"} ) 
	aadd(vVetRom , {"NJJ_PSLIQU"} ) 
	aadd(vVetRom , {"NJM_PERDIV"} )
	aadd(vVetRom , {"NJM_QTDFCO"} ) 
	aadd(vVetRom , {"NJM_QTDFIS"} )
	aadd(vVetRom , {"NJM_UM1PRO"} )
	aadd(vVetRom , {"NJM_VLRUNI"} )
	aadd(vVetRom , {"NJM_VLRTOT"} )
	aadd(vVetRom , {"FORMPROP"		, "C",10,0,STR0045, "@!"} ) //"Form.Prop."
	aadd(vVetRom , {"NJM_DOCNUM"} )
	aadd(vVetRom , {"NJM_DOCSER"} )
	aadd(vVetRom , {"NJM_DOCEMI"} )
	aadd(vVetRom , {"NJM_NFPNUM"} )
	aadd(vVetRom , {"NJM_NFPSER"} )
	aadd(vVetRom , {"NJM_PEDIDO"} ) //Número do Pedido   
	aadd(vVetRom , {"ENTENTREGA"	, "C",TamSX3("NJ0_NOME")[1],0,"Entidade Entrega", "@!" } )	//"Entidade Entrega"
	aadd(vVetRom , {"NJJ_STATUS"} )
	aadd(vVetRom , {"NJM_SUBTIP", "C",30,0,STR0060, "@!"} )	//"Subtipo Romaneio"
	aadd(vVetRom , {"NJM_CODINE"} ) //instrução de embarque
	aadd(vVetRom , {"NJJ_RECNO"	, "N",10,0,"RECNO_NJJ", "@E 9999999999" } )
	aadd(vVetRom , {"NJM_RECNO"	, "N",10,0,"RECNO_NJM", "@E 9999999999" } )
	aadd(vVetRom , {"NJJ_TPCLAS", "C",10,0,"Classificado", "@!" } )
	aadd(vVetRom , {"NJM_TES"} )


	vVetInd := { "NJJ_FILIAL+NJJ_CODROM", "NJJ_FILIAL+NJM_CODCTR+NJJ_CODROM", "NJJ_FILIAL+TIPO+NJJ_CODROM"}
	//--Funcao Monta Tela de Consulta de Romaneio		
	fMontaTela( pcCodCtr, pcCodIE )

Return

/*
############################################################################
# Função   : fMontaTela                                                    #
# Descrição: Funcao Monta Tela de Consulta de Romaneio                     #
# Autor    : Ana Laura Olegini                                             #
# Data     : 08/12/2014                                                    #  
############################################################################
*/
Static Function fMontaTela( pcCodCtr, pcCodIE )

	Local cRotF12 		:= iIf( Empty( pcCodCtr ) .and. Empty(pcCodIE), "OGC03F12()", "")
	
	Default pcCodCtr	:= ""

	Private cPergSX1	:= "OGC003" 
	Private aMatSX1 	:= {}
	Private _lExterno	:= .F.

	If Empty(pcCodCtr) .and. Empty(_cCodIE)
		_lExterno := .T.
	EndIf
	aadd(aMatSX1, {STR0001					,'C', TamSX3("NJJ_FILIAL")[1]	,0, 	                   ,     ,'G',   ,'.OGC00301.',,,,,,,PesqPict("NJJ","NJJ_FILIAL") 	} )	//"Filial De"
	aadd(aMatSX1, {STR0002					,'C', TamSX3("NJJ_FILIAL")[1]	,0, 	                   ,     ,'G',   ,'.OGC00302.',,,,,,,PesqPict("NJJ","NJJ_FILIAL") 	} )	//"Filial Ate"	
	aadd(aMatSX1, {STR0003					,'C', TamSX3("NJJ_CODROM")[1]	,0, 	                   ,'NJJ','G',   ,'.OGC00303.',,,,,,,PesqPict("NJJ","NJJ_CODROM")	} )	//"Romaneio De"
	aadd(aMatSX1, {STR0004					,'C', TamSX3("NJJ_CODROM")[1]	,0, 	                   ,'NJJ','G',   ,'.OGC00304.',,,,,,,PesqPict("NJJ","NJJ_CODROM")	} )	//"Romaneio Ate"		
	aadd(aMatSX1, {STR0005					,'D', TamSX3("NJJ_DATA")[1]		,0,	 	                   ,     ,'G',   ,'.OGC00305.',,,,,,,PesqPict("NJJ","NJJ_DATA")	    } ) //"Data do Romaneio De"
	aadd(aMatSX1, {STR0006					,'D', TamSX3("NJJ_DATA")[1]		,0,		                   ,     ,'G',   ,'.OGC00306.',,,,,,,PesqPict("NJJ","NJJ_DATA")	    } )	//"Data do Romaneio Ate" 	
	aadd(aMatSX1, {STR0007					,'D', TamSX3("NJM_DTRANS")[1]	,0,		                   ,     ,'G',   ,'.OGC00307.',,,,,,,PesqPict("NJJ","NJM_DTRANS")	} )	//"Data da Transação De" 
	aadd(aMatSX1, {STR0008					,'D', TamSX3("NJM_DTRANS")[1]	,0, 	                   ,     ,'G',   ,'.OGC00308.',,,,,,,PesqPict("NJJ","NJM_DTRANS")	} )	//"Data da Transação Ate" 	
	aadd(aMatSX1, {STR0009					,'C', TamSX3("NJR_CODCTR")[1]	,0,		                   ,'NJR','G',   ,'.OGC00309.',,,,,,,PesqPict("NJR","NJR_CODCTR")	} )	//"Contrato De"	
	aadd(aMatSX1, {STR0010					,'C', TamSX3("NJR_CODCTR")[1]	,0,		                   ,'NJR','G',   ,'.OGC00310.',,,,,,,PesqPict("NJR","NJR_CODCTR")	} )	//"Contrato Ate"
	aadd(aMatSX1, {STR0011					,'C', TamSX3("NJ0_CODENT")[1]	,0,		                   ,'NJ0','G',   ,'.OGC00311.',,,,,,,PesqPict("NJ0","NJ0_CODENT")	} )	//"Entidade De"
	aadd(aMatSX1, {STR0013					,'C', TamSX3("NJ0_LOJENT")[1]	,0,		                   ,     ,'G',   ,'.OGC00312.',,,,,,,PesqPict("NJ0","NJ0_LOJENT")	} )	//"Loja De"
	aadd(aMatSX1, {STR0012					,'C', TamSX3("NJ0_CODENT")[1]	,0,		                   ,'NJ0','G',   ,'.OGC00313.',,,,,,,PesqPict("NJ0","NJ0_CODENT")	} )	//"Entidade Ate"
	aadd(aMatSX1, {STR0014					,'C', TamSX3("NJ0_LOJENT")[1]	,0,		                   ,     ,'G',   ,'.OGC00314.',,,,,,,PesqPict("NJ0","NJ0_LOJENT")	} )	//"Loja Ate"
	aadd(aMatSX1, {STR0015					,'C', TamSX3("NJU_CODSAF")[1]	,0,		                   ,'NJU','G',   ,'.OGC00315.',,,,,,,PesqPict("NJU","NJU_CODSAF")	} )	//"Safra De"
	aadd(aMatSX1, {STR0016					,'C', TamSX3("NJU_CODSAF")[1]	,0,		                   ,'NJU','G',   ,'.OGC00316.',,,,,,,PesqPict("NJU","NJU_CODSAF")	} )	//"Safra Ate"
	aadd(aMatSX1, {STR0017					,'C', TamSX3("B1_COD")[1]		,0,		                   ,'SB1','G',   ,'.OGC00317.',,,,,,,PesqPict("SB1","B1_COD")		} )	//"Produto De"
	aadd(aMatSX1, {STR0018					,'C', TamSX3("B1_COD")[1]		,0,		                   ,'SB1','G',   ,'.OGC00318.',,,,,,,PesqPict("SB1","B1_COD")		} )	//"Produto Ate"
	aadd(aMatSX1, {STR0019					,'C', TamSX3("NNI_CODIGO")[1]	,0,		                   ,'NNI','G',   ,'.OGC00319.',,,,,,,PesqPict("NNI","NNI_CODIGO")	} )	//"Tabela De"
	aadd(aMatSX1, {STR0020					,'C', TamSX3("NNI_CODIGO")[1]	,0,		                   ,'NNI','G',   ,'.OGC00320.',,,,,,,PesqPict("NNI","NNI_CODIGO")	} )	//"Tabela Ate"
	aadd(aMatSX1, {AGRTITULO("NJM_CODAUT")    ,'C',80			    			,0,'AGRSEQUEPV(mv_par21,3)',' '  ,'G',' ','',,,,,,, }  )
	aadd(aMatSX1, {AGRTITULO("N7Q_CODINE")	,'C', TamSX3("N7Q_CODINE")[1]	,0,		                   ,'N7Q','G',   ,'.OGC00322.',,,,,,,PesqPict("N7Q","N7Q_CODINE")	} )
	aadd(aMatSX1, {STR0061					,'N',1	                  		,0,                        ,     ,'C',   ,'.OGC00323.',,"Sim","Não",,,,"@!"} )

	If _lExterno //se não for externo trata os parametros.
		// Carrega as perguntas mas não mostra a tela
		If !Pergunte( cPergSX1, .T. ) 
			Return .F.
		EndIf
	EndIf

	//-- Carrega dados e cria arquivos temporários
	Processa( { || fLoadDados(pcCodCtr) }, STR0021 )	//"Aguarde..."

	ARGSETIFARQUI(cAlT2)		//FUNCAO DO AGRUTIL01
	AGRCONPAD(STR0022,cAlT2,cNoT2,aAlT2,vVetInd,,,,,"OGX001VRom( (cAlT2)->NJJ_RECNO )" ,aOpcRot , aCamTot, aTotDad,"OGC03FTT()", cRotF12,, aLegRom )  //"Consulta Romaneio/Classificacao"-- FUNCAO MONTA TELA --- FUNCAO DO AGRUTIL01
	AGRDELETRB(cAlT2,cNoT2)	//FUNCAO DO AGRUTIL01

Return( NIL )

/*
############################################################################
# Função   : OGC03FTT                                                    #
# Descrição: Carrega array de totais da tela quando usa os filtros         #
# Autor    : claudineia.reinert                                            #
# Data     : 15/10/2020                                                    #  
############################################################################
*/
Function OGC03FTT()
	oBrowsX:ExecuteFilter(.t.)
	oBrowsX:SetUseFilter(.T.)
	ARGSETIFARQUI(cAlT2)	
	FTotaisTela()
	vVetPar := aTotDad
	AGRMOSTOTAIS(aMatCam,vVetPar,,@oBrowsX)
	ARGSETIFARQUI(cAlT2)
	
Return nil

/*
############################################################################
# Função   : fLoadDados                                                    #
# Descrição: Filtra tabelas, cria e carrega arquivos temporários           #
# Autor    : Ana Laura Olegini                                             #
# Data     : 31/10/2014                                                    #  
############################################################################
*/
Static Function fLoadDados(pcCodCtr)
	Local nRecCount 	:= 0
	Local cDesdesNJK  	:= ""
	Local cClass    	:= ""
	Local cSubTip		:= ""
	Local cTipoRo		:= ""
	Private aClass		:= {}
	Private cQryFixo	:= GetNextAlias() 
	Private cQryDina	:= GetNextAlias() 

	aTotDad := {}

	cQuery := " SELECT NJJ.*, NJM.*, B5_CULTRA, B5_CTVAR, NJJ.R_E_C_N_O_ as NJJ_RECNO , NJM.R_E_C_N_O_ as NJM_RECNO"
	cQuery +=   " FROM "+ RetSqlName("NJJ") + " NJJ "
	cQuery +=  " INNER JOIN "+ RetSqlName("NJM") + " NJM ON NJM.D_E_L_E_T_ = '' "
	cQuery +=                                      " AND NJM.NJM_FILIAL = NJJ.NJJ_FILIAL "
	cQuery +=                                      " AND NJM.NJM_CODROM = NJJ.NJJ_CODROM "
	If _lExterno
		
		cQuery +=                                      " AND NJM.NJM_CODCTR >= '" + MV_PAR09  + "'"
		cQuery +=                                      " AND NJM.NJM_CODCTR <= '" + MV_PAR10  + "'"
		cQuery +=                                      " AND NJM.NJM_CODENT >= '" + MV_PAR11  + "'"
		cQuery +=                                      " AND NJM.NJM_LOJENT >= '" + MV_PAR12  + "'"
		cQuery +=                                      " AND NJM.NJM_CODENT <= '" + MV_PAR13  + "'"
		cQuery +=                                      " AND NJM.NJM_LOJENT <= '" + MV_PAR14  + "'"
	
		//considera autorização
		If !empty(mv_par21)
			cQuery += "  AND NJM.NJM_CODAUT IN (" + AGRMULTOPQRY(mv_par21) + ")"
		Endif

		If !Empty(MV_PAR07)
			cQuery +=    " AND NJM.NJM_DTRANS >= '" + dTOs(MV_PAR07)  + "'"
		EndIf
		If !Empty(MV_PAR08)
			cQuery +=    " AND NJM.NJM_DTRANS <= '" + dTOs(MV_PAR08)  + "'"
		EndIf
		If !Empty(MV_PAR22)
			cQuery +=    " AND NJM.NJM_CODINE = '" + MV_PAR22  + "'"
		EndIf

		cQuery +=   " LEFT JOIN "+ RetSqlName("SB5") + " SB5 ON SB5.D_E_L_E_T_ = '' "
		cQuery +=                                         " AND SB5.B5_FILIAL = '"+ xFilial( "SB5" ) +"' "
		cQuery +=                                         " AND SB5.B5_COD    = NJJ.NJJ_CODPRO "	
		cQuery +=  " WHERE NJJ.D_E_L_E_T_ = '' "
		cQuery +=    " AND NJJ.NJJ_FILIAL >= '" + MV_PAR01  + "'"
		cQuery +=    " AND NJJ.NJJ_FILIAL <= '" + MV_PAR02  + "'"
		cQuery +=    " AND NJJ.NJJ_CODROM >= '" + MV_PAR03  + "'"
		cQuery +=    " AND NJJ.NJJ_CODROM <= '" + MV_PAR04  + "'"

		If !Empty(MV_PAR05) 
			cQuery +=    " AND NJJ.NJJ_DATA	  >= '" + dTOs(MV_PAR05)  + "'"
		EndIf
		If !Empty(MV_PAR06)
			cQuery +=    " AND NJJ.NJJ_DATA	  <= '" + dTOs(MV_PAR06)  + "'"
		EndIf
		cQuery +=    " AND NJJ.NJJ_CODSAF >= '" + MV_PAR15  + "'"
		cQuery +=    " AND NJJ.NJJ_CODSAF <= '" + MV_PAR16  + "'"
		cQuery +=    " AND NJJ.NJJ_CODPRO >= '" + MV_PAR17  + "'"
		cQuery +=    " AND NJJ.NJJ_CODPRO <= '" + MV_PAR18  + "'"
		cQuery +=    " AND NJJ.NJJ_TABELA >= '" + MV_PAR19  + "'"
		cQuery +=    " AND NJJ.NJJ_TABELA <= '" + MV_PAR20  + "'"
		If cValtochar(MV_PAR23) = "2" //não lista os romaneios cancelados
			cQuery +=    " AND NJJ.NJJ_STATUS <> '4' "
		EndIf
	Else		
		If !Empty(pcCodCtr)
            cQuery +=                                      " AND NJM.NJM_CODCTR = '" + pcCodCtr  + "'"            
        EndIf
        
        If !Empty(_cCodIE)
            cQuery += " INNER JOIN " + RetSqlName("N9E") + " N9E ON N9E.D_E_L_E_T_ = '' "+;
                            " AND N9E.N9E_FILIAL = NJM.NJM_FILIAL "+;
                            " AND N9E.N9E_CODROM = NJM.NJM_CODROM "+;
                            " AND N9E.N9E_CODINE =  '" + _cCodIE + "'"+;
                      " INNER JOIN " + RetSqlName("N7S") + " N7S ON N7S.D_E_L_E_T_ = '' "+;
                            " AND N7S.N7S_FILIAL = N9E.N9E_FILIAL "+;
                            " AND N7S.N7S_CODINE = N9E.N9E_CODINE "+;
                            " AND N7S.N7S_CODCTR = N9E.N9E_CODCTR "+;
                            " AND N7S.N7S_QTDREM > 0 "
        EndIf 

		cQuery +=   " LEFT JOIN "+ RetSqlName("SB5") + " SB5 ON SB5.D_E_L_E_T_ = '' "
		cQuery +=                                         " AND SB5.B5_FILIAL = '"+ xFilial( "SB5" ) +"' "
		cQuery +=                                         " AND SB5.B5_COD    = NJJ.NJJ_CODPRO "	
		cQuery +=  " WHERE NJJ.D_E_L_E_T_ = '' "

		If !Empty(pcCodCtr)
			cQuery +=  " AND NJJ.NJJ_FILIAL LIKE '" + Alltrim(xFilial("NJR"))  + "%' "
		ElseIf !Empty(_cCodIE)
			cQuery +=  " AND NJJ.NJJ_FILIAL LIKE '" + Alltrim(xFilial("N7Q"))  + "%' "
		Else
			cQuery +=  " AND NJJ.NJJ_FILIAL = '" + xFilial("NJJ")  + "' "
		EndIf
	EndIf
	cQuery := ChangeQuery(cQuery)
	If Select(cQryFixo) <> 0
		(cQryFixo)->(dbCloseArea())
	EndIf

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQryFixo,.T.,.T.)

	Count To nRecCount			//Contando o registro da query

	Procregua( nRecCount )

	vVetDim := {	{"NJK_CODROM"} , ;
	{"NJK_CODDES"} , ;
	{"NJK_DESDES"} , ;
	{"NJK_PERDES"} , ;		
	{"NJK_READES"} , ;
	{"BASDES", "N",14,2,STR0033, "@!"} , ;	//"Peso Base"
	{"NJK_DESRES"} , ;
	{"QTDRES", "N",12,2,STR0057, "@!"} ,;	//"Desconto"
	{"NJK_TPCLAS"}} 	

	If (cAlT3) <> Nil
		DbselectArea(cAlT3)
		Zap
	EndIf 		

	vVetDim := AGRCRIATRB(,vVetDim,{"NJK_CODROM+NJK_CODDES"},"OGC003",.T.) 
	cNoT3 := vVetDim[3]	//INDICE
	cAlT3 := vVetDim[4]	//ALIAS        
	aAlT3 := vVetDim[5]	//ARRAY 	

	dbSelectArea(cQryFixo)
	(cQryFixo)->(dbGoTop())

	While (cQryFixo)->(!Eof())  

		//Busca os registros de classificacao - DINAMICO
		c2Query := " SELECT NJK_CODROM, NJK_CODDES, NJK_PERDES, NJK_READES, NJK_QTDDES, NJK_DESRES, NJK_BASDES, NJK_TPCLAS "
		c2Query +=   " FROM "+ RetSqlName("NJK") + " NJK "
		c2Query +=  " WHERE NJK.D_E_L_E_T_ = '' " 
		c2Query +=  " AND NJK_FILIAL = '" + (cQryFixo)->NJJ_FILIAL  + "'" 
		c2Query +=  " AND NJK_CODROM = '" + (cQryFixo)->NJJ_CODROM  + "'" 
		If SuperGetMV("MV_AGOCLAS",.F.,.F.)
			c2Query +=  " AND NJK_TPCLAS = '" + (cQryFixo)->NJJ_TPCLAS  + "'" 
		EndIf

		c2Query := ChangeQuery(c2Query)
		If Select(cQryDina) <> 0
			(cQryDina)->(dbCloseArea())
		EndIf
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,c2Query),cQryDina,.T.,.T.)

		dbSelectArea(cQryDina)
		(cQryDina)->(dbGoTop())	

		While (cQryDina)->(!Eof())  
			cCodDesc := Alltrim((cQryDina)->NJK_CODDES)
			If !Empty(cCodDesc)
				cCodDesc := strtran(cCodDesc," ","_")
				AGRGRAVA2T(cAlT3,cQryDina)

				cDesdesNJK := POSICIONE('NNH',1,XFILIAL('NNH')+(cQryDina)->NJK_CODDES,'NNH_DESCRI')

				aadd (vVetRom, {"C"+cCodDesc		, "N",TamSx3("NJK_PERDES")[1],TamSx3("NJK_PERDES")[2],cDesdesNJK					    , PesqPict('NJK',"NJK_PERDES")} )
				aadd (vVetRom, {"C"+cCodDesc+"1"	, "N",TamSx3("NJK_READES")[1],TamSx3("NJK_READES")[2],substr(cDesdesNJK,1,3)+STR0030	, PesqPict('NJK',"NJK_READES")} )	//" % Desc"
				aadd (vVetRom, {"C"+cCodDesc+"2"	, "N",TamSx3("NJK_BASDES")[1],TamSx3("NJK_BASDES")[2],substr(cDesdesNJK,1,3)+STR0033	, PesqPict('NJK',"NJK_BASDES")} )	//" Peso Base"	
				aadd (vVetRom, {"C"+cCodDesc+"3"	, "C",TamSx3("NJK_DESRES")[1],TamSx3("NJK_DESRES")[2],substr(cDesdesNJK,1,3)+STR0032	, PesqPict('NJK',"NJK_DESRES")} )	//" Desc Result"
				aadd (vVetRom, {"C"+cCodDesc+"4"	, "N",TamSx3("NJK_QTDDES")[1],TamSx3("NJK_QTDDES")[2],substr(cDesdesNJK,1,3)+STR0031	, PesqPict('NJK',"NJK_QTDDES")} )	//" Desconto"
			EndIf 

			Reclock(cAlt3, .F.)
			(cAlT3)->BASDES := (cQryDina)->NJK_BASDES * ((cQryFixo)->NJM_PERDIV / 100)
			(cAlT3)->QTDRES := (cQryDina)->NJK_QTDDES * ((cQryFixo)->NJM_PERDIV / 100)
			MsUnlock()

			(cQryDina)->(dbSkip())
		EndDo

		(cQryFixo)->(dbSkip())
	EndDo	

	//(cQryDina)->(dbCloseArea())

	If (cAlT2) <> Nil
		DbselectArea(cAlT2)
		Zap
	EndIf 	

	vVetR := AGRCRIATRB( , vVetRom, vVetInd, "OGC003", .T.) // Cria tabela temporária	
	cNoT2 := vVetR[3] //INDICE
	cAlT2 := vVetR[4] //ALIAS        
	aAlT2 := vVetR[5] //ARRAY 	

	dbselectarea(cQryFixo)
	dbgotop()
	While (cQryFixo)->(!Eof())  
		IncProc()	

		cTipoRo   := ""
		cSubTip  := ""
				
		cTipoRo  := Upper(Posicione("SX5",1,xFilial("SX5")+"K5"+(cQryFixo)->NJJ_TIPO,"X5DESCRI()"))
		cSubTip  := Upper(Posicione("SX5",1,xFilial("SX5")+"K0"+(cQryFixo)->NJM_SUBTIP,"X5DESCRI()"))

		If Empty(cSubTip)
			cSubTip := cTipoRo
		EndIf
		
		If (cQryFixo)->NJJ_TPCLAS = "1" .Or. (cQryFixo)->NJJ_TPCLAS = ""
			cClass := STR0058
		Else
			cClass := STR0059
		EndIf

		Reclock(cAlt2, .T.)  
		(cAlT2)->NJJ_FILIAL 	:= (cQryFixo)->NJJ_FILIAL
		(cAlT2)->NJM_IDMOV 		:= (cQryFixo)->NJM_IDMOV
		(cAlT2)->NJJ_CODROM 	:= (cQryFixo)->NJJ_CODROM
		(cAlT2)->TIPO 			:= 	Upper( cTipoRo )
		(cAlT2)->TIPO2 			:= (cQryFixo)->NJJ_TIPO
		(cAlT2)->TIPENT 		:= 	Upper( X3CboxDesc( "NJJ_TIPENT", (cQryFixo)->NJJ_TIPENT ) )
		(cAlT2)->NJJ_DATA 		:= StoD((cQryFixo)->NJJ_DATA)
		(cAlT2)->NJM_DTRANS		:= StoD((cQryFixo)->NJM_DTRANS)
		(cAlT2)->NJM_CODENT 	:= (cQryFixo)->NJM_CODENT
		(cAlT2)->ENTIDADE 		:= Alltrim(Posicione( "NJ0", 1, xFilial( "NJ0" ) + (cQryFixo)->( NJM_CODENT+NJM_LOJENT ), "NJ0_NOME" ))
		(cAlT2)->NJM_LOJENT 	:= (cQryFixo)->NJM_LOJENT
		(cAlT2)->NJM_NLJENT  	:= POSICIONE('NJ0',1,XFILIAL('NJ0')+(cQryFixo)->NJM_CODENT+(cQryFixo)->NJM_LOJENT,'NJ0_NOMLOJ')
		(cAlT2)->NJ0_INSCR		:= Alltrim(Posicione( "NJ0", 1, xFilial( "NJ0" ) + (cQryFixo)->( NJM_CODENT+NJM_LOJENT ), "NJ0_INSCR" ))
		(cAlT2)->NJM_CODCTR		:= (cQryFixo)->NJM_CODCTR
		(cAlT2)->NJM_CODAUT		:= (cQryFixo)->NJM_CODAUT
		(cAlT2)->CODENTTERC		:= upper( Alltrim(Posicione( "NJP", 1, xFilial( "NJP" ) + (cQryFixo)->( NJM_CODCTR+NJM_CODAUT ), "NJP_CODTER" )) )
		(cAlT2)->NOMENTTERC		:= upper( Alltrim(Posicione( "NJ0", 1, xFilial( "NJ0" ) + Posicione( "NJP", 1, xFilial( "NJP" ) + (cQryFixo)->( NJM_CODCTR+NJM_CODAUT ), "NJP_CODTER" )+ Posicione( "NJP", 1, xFilial( "NJP" ) + (cQryFixo)->( NJM_CODCTR+NJM_CODAUT ), "NJP_LOJTER" ), "NJ0_NOME" )) )			
		(cAlT2)->NJM_CODSAF		:= (cQryFixo)->NJM_CODSAF
		(cAlT2)->STATUS			:= upper( X3CboxDesc( "NJJ_STATUS", (cQryFixo)->NJJ_STATUS ) )
		(cAlT2)->STATUSNFE		:= fLegNfe(2)
		(cAlT2)->PRODUTO		:= Alltrim((cQryFixo)->NJM_CODPRO)+" - "+Posicione( "SB1", 1, xFilial( "SB1" ) + (cQryFixo)->NJM_CODPRO, "B1_DESC" )
		(cAlT2)->NJJ_PLACA		:= (cQryFixo)->NJJ_PLACA
		(cAlT2)->B5_CULTRA		:= (cQryFixo)->B5_CULTRA
		(cAlT2)->B5_CTVAR		:= (cQryFixo)->B5_CTVAR
		(cAlT2)->DESCRICAO   	:= Posicione( "NP4", 1, xFilial( "NP4" ) + (cQryFixo)->B5_CTVAR, "NP4_DESCRI" )
		(cAlT2)->NJM_LOCAL			:= Alltrim((cQryFixo)->NJM_LOCAL) +" - "+ Posicione( "NNR", 1, xFilial( "NNR" ) + (cQryFixo)->NJM_LOCAL, "NNR_DESCRI" )
		(cAlT2)->NJM_TALHAO		:= (cQryFixo)->NJM_TALHAO
		(cAlT2)->NJJ_PESO1		:= (cQryFixo)->NJJ_PESO1
		(cAlT2)->NJJ_DATPS1		:= StoD((cQryFixo)->NJJ_DATPS1)
		(cAlT2)->NJJ_HORPS1		:= (cQryFixo)->NJJ_HORPS1
		(cAlT2)->NJJ_MODPS1		:= (cQryFixo)->NJJ_MODPS1
		(cAlT2)->NJJ_PESO2		:= (cQryFixo)->NJJ_PESO2
		(cAlT2)->NJJ_DATPS2		:= StoD((cQryFixo)->NJJ_DATPS2)
		(cAlT2)->NJJ_HORPS2		:= (cQryFixo)->NJJ_HORPS2
		(cAlT2)->NJJ_MODPS2		:= (cQryFixo)->NJJ_MODPS2
		(cAlT2)->NJJ_PSSUBT  	:= (cQryFixo)->NJJ_PSSUBT
		(cAlT2)->NJJ_PSLIQU		:= (cQryFixo)->NJJ_PSLIQU
		(cAlT2)->NJM_PERDIV		:= (cQryFixo)->NJM_PERDIV
		(cAlT2)->NJM_QTDFCO		:= (cQryFixo)->NJM_QTDFCO
		(cAlT2)->NJM_QTDFIS		:= (cQryFixo)->NJM_QTDFIS
		(cAlT2)->NJM_UM1PRO		:= (cQryFixo)->NJM_UM1PRO
		(cAlT2)->NJM_VLRUNI		:= (cQryFixo)->NJM_VLRUNI
		(cAlT2)->NJM_VLRTOT		:= (cQryFixo)->NJM_VLRTOT
		(cAlT2)->FORMPROP 		:=	Upper( X3CboxDesc( "NJM_TPFORM", (cQryFixo)->NJM_TPFORM ) )
		(cAlT2)->NJM_DOCNUM		:= (cQryFixo)->NJM_DOCNUM
		(cAlT2)->NJM_DOCSER		:= (cQryFixo)->NJM_DOCSER
		(cAlT2)->NJM_DOCEMI		:= StoD((cQryFixo)->NJM_DOCEMI)
		(cAlT2)->NJM_NFPNUM		:= (cQryFixo)->NJM_NFPNUM
		(cAlT2)->NJM_NFPSER		:= (cQryFixo)->NJM_NFPSER
		(cAlT2)->NJM_PEDIDO		:= (cQryFixo)->NJM_PEDIDO
		(cAlT2)->ENTENTREGA 	:= Alltrim(Posicione( "NJ0", 1, xFilial( "NJ0" ) + (cQryFixo)->NJJ_ENTENT, "NJ0_NOME" ))	
		(cAlT2)->NJJ_STATUS		:= (cQryFixo)->NJJ_STATUS
		(cAlT2)->NJM_SUBTIP		:= cSubTip
		(cAlT2)->NJM_CODINE		:= Alltrim(Posicione( "N7Q", 1, xFilial( "N7Q" ) + (cQryFixo)->NJM_CODINE, "N7Q_DESINE" ))
		(cAlT2)->NJJ_RECNO		:= (cQryFixo)->NJJ_RECNO
		(cAlT2)->NJM_RECNO		:= (cQryFixo)->NJM_RECNO
		(cAlT2)->NJJ_TPCLAS		:= cClass//(cQryFixo)->NJJ_TPCLAS
		(cAlT2)->NJM_TES		:= (cQryFixo)->NJM_TES
		MsUnlock()

		(cQryFixo)->(dbSkip())
	EndDo
	(cQryFixo)->(dbCloseArea())

	FTotaisTela()
	
	dbselectarea(cAlT2)
	aEstrD := DbStruct()

	dbselectarea(cAlT2)
	dbgotop()
	While (cAlT2)->(!Eof())  
		dbselectarea(cAlT2)
		If AGRIFSEETRB(cAlT3,(cAlT2)->NJJ_CODROM,1,.F.) 
			While (cAlT3)->(!Eof()) .AND. (cAlT3)->NJK_CODROM = (cAlT2)->NJJ_CODROM
				dbselectarea(cAlT2) 
				//For nx := 1 To Fcount()

					nPos  := aScan(aEstrD,{|x| AllTrim(x[1]) == "C" + Alltrim((cAlT3)->NJK_CODDES) })

					If nPos > 0
						a := (cAlT3)->NJK_PERDES
						b := cAlT2+"->"+Fieldname(nPos)
						&b. := a

						c := (cAlT3)->NJK_READES
						d := cAlT2+"->"+Fieldname(nPos+1)
						&d. := c	

						e := (cAlT3)->BASDES
						f := cAlT2+"->"+Fieldname(nPos+2)
						&f. := e	

						g := (cAlT3)->NJK_DESRES
						h := cAlT2+"->"+Fieldname(nPos+3)
						&h. := g		

						x := (cAlT3)->QTDRES
						y := cAlT2+"->"+Fieldname(nPos+4)
						&y. := x			      
					EndIf
				//Next nx 
				AGRDBSELSKIP(cAlT3)
			EndDo
		EndIf
		AGRDBSELSKIP(cAlT2)
	EndDo

	//-- MONTA GRIDS
	ARGSETIFARQUI(cAlT2)	//FUNCAO DO AGRUTIL01
Return

/* 
+=================================================================================================+
| Função    : FTotaisTela()                                                                       |
| Descrição : Gera array de dados para a grid Totais								              |
| Autor     : claudineia.reinert                                                                  |
| Data      : 15/10/2020                                                                          |
+=================================================================================================+                                                                           |  
*/
Static Function FTotaisTela()
	Local nPos := 0

	aTotDad := {}

	dbselectarea(cAlT2)
	dbgotop()
	While (cAlT2)->(!Eof())  
					
		///// Totais da tela
		nPos := aScan( aTotDad, {|x| AllTrim(x[1]) == AllTrim((cAlT2)->(NJM_SUBTIP)) })
		
		If nPos == 0
			aAdd( aTotDad, { AllTrim((cAlT2)->(NJM_SUBTIP)), 0, 0, 0, "" } )
			nPos := aScan( aTotDad, {|x| AllTrim(x[1]) == AllTrim((cAlT2)->(NJM_SUBTIP)) })
		EndIf		
		
		If NJR->( NJR_OPEFUT ) == '1' 
			If Posicione('SF4',1,fwxFilial("SF4")+(cAlT2)->( NJM_TES ),'F4_ESTOQUE') == "S" //movimenta
				aTotDad[nPos,2] += (cAlT2)->(NJM_QTDFCO)				
			Else
				aTotDad[nPos,3] += (cAlT2)->(NJM_QTDFIS)
				aTotDad[nPos,4] += (cAlT2)->(NJM_VLRTOT)
			EndIf
		Else
			aTotDad[nPos,2] += (cAlT2)->(NJM_QTDFCO)
			aTotDad[nPos,3] += (cAlT2)->(NJM_QTDFIS)
			aTotDad[nPos,4] += (cAlT2)->(NJM_VLRTOT)
		EndIf

		AGRDBSELSKIP(cAlT2)
	EndDo

	If Len( aTotDad ) == 0
		aAdd( aTotDad, { " ", 0, 0, 0, "" } )
	EndIf
	
Return nil

/* 
+=================================================================================================+
| Função    : OGC03F12()                                                                          |
| Descrição : Nova filtragem da base e alimentação do arquivo temporário (VIA F12)                |
| Autor     : Inácio Luiz Kolling                                                                 |
| Data      : 15/10/2014                                                                          |
+=================================================================================================+                                                                           |  
*/
Function OGC03F12(lMostra)
	Local pcCodCtr := ""
	Default lMostra := .T.
	// Abre a tela de parâmetros de perguntas
	If _lExterno	
		IF !Pergunte(cPergSX1, lMostra ) 			
			Return .F.
		EndIf
	else
		pcCodCtr := NJR->NJR_CODCTR
	EndIf
	DbSelectArea(cAlt3)
	zap
	DbSelectArea(cAlt2)
	zap
	oBrowsX:oFwFilter:CleanFilter(.T.)

	//-- Carrega dados e cria arquivos temporários
	fLoadDados(pcCodCtr)
	oDlgX:End()
	ARGSETIFARQUI(cAlt2)
	AGRCONPAD(STR0022,cAlT2,cNoT2,aAlT2,vVetInd,,,,,"OGX001VRom( (cAlT2)->NJJ_RECNO )" ,aOpcRot , aCamTot, aTotDad, "OGC03FTT()", "OGC03F12()",, aLegRom  )  //"Consulta Romaneio/Classificacao"-- FUNCAO MONTA TELA --- FUNCAO DO AGRUTIL01
Return

/*/{Protheus.doc} OGC003ATCF
// Atualiza e confirma o romaneio.
@author brunosilva
@since 09/02/2019
@version 1.0

@type function
/*/
Static Function OGC003ATCF()
	Local aArea := GetArea()
	
	//0=Pendente;1=Completo;2=Atualizado;3=Confirmado;4=Cancelado;5=Pendente Aprovação;6=Previsto  
	if (cAlT2)->NJJ_STATUS = '1' // Confirmado
	
		DbSelectArea("NJJ")
		NJJ->(DbSetorder(1)) //NJJ_FILIAL+NJJ_CODROM
		If NJJ->(DbSeek( (cAlT2)->NJJ_FILIAL  + (cAlT2)->NJJ_CODROM) )
			lRet := OGA250ATUC()
			
			//Caso o parametro nao atualize automatico ou não exista na base
			//	a confirmação já é automatica.
			If !(SuperGetMV( "MV_OG250FE", .F., .F. )) .and. lRet
				lRet := OGA250NF( Alias(), Recno(), 4, .t. )
			EndIf
		else
			lRet := .F.
		endIf
	elseif (cAlT2)->NJJ_STATUS = '2' //Atualizado
		DbSelectArea("NJJ")
		NJJ->(DbSetorder(1)) //NJJ_FILIAL+NJJ_CODROM
		If NJJ->(DbSeek( (cAlT2)->NJJ_FILIAL  + (cAlT2)->NJJ_CODROM) )
			lRet := OGA250NF( Alias(), Recno(), 4, .t. )
		endIf
	else
		AGRHELP("AJUDA","Status do romaneio não permite a atualização/confirmação","Somente romaneios atualizados/confirmados permitem esta operação.")
		lRet := .F.
	endIf
	
	OGC03F12(.F.)	
	
	RESTAREA(aArea)
Return lRet
