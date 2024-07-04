#include 'protheus.ch'
#INCLUDE "ogc110.ch"
#include 'parmtype.ch'
#INCLUDE "FWBROWSE.CH"
#INCLUDE "fwMvcDef.ch"

/*{Protheus.doc} OGC110
Painel de Comiss�es Simuladas
@author jean.schulze
@since 16/11/2017
@version 1.0
@return ${return}, ${return_description}
@type function
*/
function OGC110()
	Local aFilBrowCtr 	:= {}
	Local nCont       	:= 0

	Private _cFiltro 	:= nil
	Private _cTabCom 	:= nil
	Private _oBrowse 	:= nil
	Private _aCpsBrowCt := nil

	//-- Prote��o de C�digo
	If .Not. TableInDic('N89') 
		MsgNextRel() //-- � necess�rio a atualiza��o do sistema para a expedi��o mais recente
		Return()
	Endif

	// Abre a tela de par�metros de perguntas
	If !Pergunte("OGC110", .T. )
		Help( ,,STR0001,, STR0002, 1, 0 )   //"Sem pergunta cadastrada"       
		Return
	EndIf

	_cFiltro := fMntFiltro() //apropria filtro

	//campos blocos
	_aCpsBrowCt := {{STR0003 , "COM_STATUS"	, "C", 1, 0	, "@!"	},;	//"Status da Comiss�o"
					{STR0004 , "N89_CTPMER"	, TamSX3( "N89_CTPMER" )[3]	, TamSX3( "N89_CTPMER" )[1]	, TamSX3( "N89_CTPMER" )[2]	, PesqPict("N89","N89_CTPMER") 	},;
					{STR0005 , "N89_CMOEDA"	, TamSX3( "N89_CMOEDA" )[3]	, TamSX3( "N89_CMOEDA" )[1]	, TamSX3( "N89_CMOEDA" )[2]	, PesqPict("N89","N89_CMOEDA") 	},;
					{STR0006 , "N89_FILIAL"	, TamSX3( "N89_FILIAL" )[3]	, TamSX3( "N89_FILIAL" )[1]	, TamSX3( "N89_FILIAL" )[2]	, PesqPict("N89","N89_FILIAL") 	},;
					{STR0028 , "N89_CODCOM"	, TamSX3( "N89_CODCOM" )[3]	, TamSX3( "N89_CODCOM" )[1]	, TamSX3( "N89_CODCOM" )[2]	, PesqPict("N89","N89_CODCOM") 	},;
					{STR0007 , "N89_CODCTR"	, TamSX3( "N89_CODCTR" )[3]	, TamSX3( "N89_CODCTR" )[1]	, TamSX3( "N89_CODCTR" )[2]	, PesqPict("N89","N89_CODCTR") 	},;
					{STR0008 , "N89_CODCOR"	, TamSX3( "N89_CODCOR" )[3]	, TamSX3( "N89_CODCOR" )[1]	, TamSX3( "N89_CODCOR" )[2]	, PesqPict("N89","N89_CODCOR") 	},;
					{STR0009 , "N89_LOJCOR"	, TamSX3( "N89_LOJCOR" )[3]	, TamSX3( "N89_LOJCOR" )[1]	, TamSX3( "N89_LOJCOR" )[2]	, PesqPict("N89","N89_LOJCOR") 	},;
					{STR0010 , "NOMECORRET"	, TamSX3( "A2_NOME" )[3]	, TamSX3( "A2_NOME" )[1]	, TamSX3( "A2_NOME" )[2]	, PesqPict("SA2","A2_NOME") 	},;
					{STR0004 , "TPMERCADO"	, "C"	, 10	, , "@!"	},;
			  		{STR0011 , "N89_VRCALC"	, TamSX3( "N89_VRCALC" )[3]	, TamSX3( "N89_VRCALC" )[1]	, TamSX3( "N89_VRCALC" )[2]	, PesqPict("N89","N89_VRCALC") 	},;					
					{STR0005 , "NOMEMOEDA"	, "C"	, 3	, , "@!"	},;
					{STR0012 , "N89_DTCALC"	, TamSX3( "N89_DTCALC" )[3]	, TamSX3( "N89_DTCALC" )[1]	, TamSX3( "N89_DTCALC" )[2]	, PesqPict("N89","N89_DTCALC") 	},;  //ValorBase */
					{RetTitle("N89_TXMOED") , "N89_TXMOED"	, TamSX3( "N89_TXMOED" )[3]	, TamSX3( "N89_TXMOED" )[1]	, TamSX3( "N89_TXMOED" )[2]	, PesqPict("N89","N89_TXMOED") 	}}  //Tx. Calculo


	Processa({|| _cTabCom := MontaTabel(_aCpsBrowCt, {{"", "N89_FILIAL+N89_CODCTR+N89_CODCOR+N89_LOJCOR"}})},STR0013)

	Processa({|| fLoadDados(_cFiltro)},STR0014)

	//atalho de pesquisa
	SetKey( VK_F12, { || OGC110F12(.t.) } )

	//Criando o Browser de Visualiza��o
	_oBrowse := FWMBrowse():New()
    _oBrowse:SetAlias(_cTabCom)
    _oBrowse:SetDescription(STR0015 )
    _oBrowse:DisableDetails()
    _oBrowse:SetMenuDef( "OGC110" ) //verifica para coloca as op��es de menu aqui - fixar, contrato, etc.
    _oBrowse:SetProfileID("OGC110BRW1")

    //legenda
    _oBrowse:AddLegend( "COM_STATUS == '1'", "RED"    , STR0016)  //"Simulada"
    _oBrowse:AddLegend( "COM_STATUS == '2'", "BR_VIOLETA" , STR0017)  //"Em aprova��o"
    _oBrowse:AddLegend( "COM_STATUS == '3'", "YELLOW" , STR0018)  //"Aprovada"
    _oBrowse:AddLegend( "COM_STATUS == '4'", "GREEN"  , STR0057)  //"Finalizada/Pedido gerado"
	_oBrowse:AddLegend( "COM_STATUS == '5'", "BLUE"   , STR0019)  //"Em revisao"

    For nCont := 4  to Len(_aCpsBrowCt) //desconsiderar STATUS e Tipo
       	_oBrowse:AddColumn( {_aCpsBrowCt[nCont][1]  , &("{||"+_aCpsBrowCt[nCont][2]+"}") ,_aCpsBrowCt[nCont][3],_aCpsBrowCt[nCont][6],iif(_aCpsBrowCt[nCont][3] == "N",2,1),_aCpsBrowCt[nCont][4],_aCpsBrowCt[nCont][5],.f.} )
	    aADD(aFilBrowCtr,  {_aCpsBrowCt[nCont][2], _aCpsBrowCt[nCont][1], _aCpsBrowCt[nCont][3], _aCpsBrowCt[nCont][4], _aCpsBrowCt[nCont][5], _aCpsBrowCt[nCont][6] } )
	Next nCont

    _oBrowse:SetFieldFilter(aFilBrowCtr)
    _oBrowse:Activate()
    
return

/*{Protheus.doc} MenuDef
Menu do Browser de Comiss�es
@author jean.schulze
@since 16/11/2017
@version 1.0
@return ${return}, ${return_description}
@type function
*/
Static Function MenuDef()
	Local aRotina 	:= {}

	aAdd( aRotina, { STR0020 , "OGC110CFR()"  , 0, 4, 0, .f. } ) // Confirmar comiss�o
	aAdd( aRotina, { STR0021 , "OGC110VIEW()" , 0, 2, 0, .f. } ) // Detalhar
	aAdd( aRotina, { STR0022 , "OGC110DELT()" , 0, 5, 0, .f. } ) // Excluir
	aAdd( aRotina, { STR0023 , "OGC110ESTO()" , 0, 5, 0, .f. } ) // Estornar Comiss�o
	aAdd( aRotina, { STR0056 , "OGC110GPDC()" , 0, 4, 0, .f. } ) // Gerar pedido

Return( aRotina )


/*{Protheus.doc} fLoadDados
Consulta para popular tts do browser de dados
@author jean.schulze
@since 16/11/2017
@version 1.0
@return ${return}, ${return_description}
@param cFiltro, characters, descricao
@type function
*/
Static Function fLoadDados(cFiltro)
	Local cAliasN89 	:= GetNextAlias()
	
	DbSelectArea(_cTabCom)
	ZAP
	
	//trata o filtro
	cFiltro := "%" + cFiltro + "%"
	
	//verificado que devemos quebrar por N89_DTCALC****
	BeginSql Alias cAliasN89
		SELECT N89_STATUS, 
			   N89_FILIAL, 
			   N89_CODCOM, 
			   N89_CODCTR, 
			   N89_CODCOR, 
		       N89_LOJCOR, 
			   N89_CTPMER, 
			   SUM(N89_VRCALC) N89_VRCALC, 
			   N89_CMOEDA, 
			   N89_DTCALC 
	  	  FROM %Table:N89% N89
		 WHERE N89.%notDel%
		  %exp:cFiltro% 		
		  AND N89_FILIAL = %exp:FwxFilial("N89")% 
		GROUP BY N89_STATUS, N89_FILIAL, N89_CODCOM, N89_CODCTR, N89_CODCOR, N89_LOJCOR, N89_CTPMER, N89_CMOEDA, N89_DTCALC 
	EndSQL

	DbselectArea(cAliasN89)
	DbGoTop()
	while (cAliasN89)->( !Eof() )

		If Reclock(_cTabCom, .T.)		
					
			(_cTabCom)->COM_STATUS := ( cAliasN89 )->N89_STATUS  
			(_cTabCom)->N89_FILIAL := ( cAliasN89 )->N89_FILIAL 
			(_cTabCom)->N89_CODCOM := ( cAliasN89 )->N89_CODCOM
			(_cTabCom)->N89_CODCTR := ( cAliasN89 )->N89_CODCTR
			(_cTabCom)->N89_CODCOR := ( cAliasN89 )->N89_CODCOR
			(_cTabCom)->N89_LOJCOR := ( cAliasN89 )->N89_LOJCOR
			(_cTabCom)->NOMECORRET := Posicione( "SA2", 1, xFilial( "SA2" ) + ( cAliasN89 )->N89_CODCOR + ( cAliasN89 )->N89_LOJCOR, "A2_NOME" ) 
			(_cTabCom)->N89_CTPMER := ( cAliasN89 )->N89_CTPMER 
			(_cTabCom)->TPMERCADO  := iif(( cAliasN89 )->N89_CTPMER == "1", STR0024, STR0025)
			(_cTabCom)->N89_VRCALC := ( cAliasN89 )->N89_VRCALC			
			(_cTabCom)->N89_CMOEDA := ( cAliasN89 )->N89_CMOEDA
			(_cTabCom)->NOMEMOEDA  := AGRMVSIMB(( cAliasN89 )->N89_CMOEDA)
			(_cTabCom)->N89_DTCALC := StoD(( cAliasN89 )->N89_DTCALC)

	 		(_cTabCom)->(MsUnlock())

		EndIf
		( cAliasN89 )->( dbSkip() )
	Enddo

	( cAliasN89 )->( dbCloseArea() )

Return .T.


/*{Protheus.doc} fMntFiltro
Monta o Filtro de Busca de Dados
@author jean.schulze
@since 09/10/2017
@version undefined
@type function
*/
Static Function fMntFiltro()
	Local cFiltro := ""

	//trata os filtros
	cFiltro :=  "  AND N89.N89_CODCTR >= '" + MV_PAR01  + "'"
	cFiltro +=  "  AND N89.N89_CODCTR <= '" + MV_PAR02  + "'"
	cFiltro +=  "  AND N89.N89_CODCOR >= '" + MV_PAR03  + "'"
	cFiltro +=  "  AND N89.N89_LOJCOR >= '" + MV_PAR04  + "'"
	cFiltro +=  "  AND N89.N89_CODCOR <= '" + MV_PAR05  + "'"
	cFiltro +=  "  AND N89.N89_LOJCOR <= '" + MV_PAR06  + "'"
	
	if MV_PAR07 == 1
		cFiltro +=  "  AND N89.N89_CTPMER >= '1'" //interno
	elseif MV_PAR07 == 2
		cFiltro +=  "  AND N89.N89_CTPMER >= 'E'" //externo
	endif
		
	if !Empty(MV_PAR15)
		cFiltro +=  "  AND N89.N89_DTCALC   >= '" + dTOs(MV_PAR08)  + "'"
	endif

	if !Empty(MV_PAR16)
		cFiltro +=  "  AND N89.N89_DTCALC   <= '" + dTOs(MV_PAR09)  + "'"
	endif

	
return cFiltro

/*{Protheus.doc} MontaTabel
Cria Temp-table de dados
@author jean.schulze
@since 17/11/2017
@version 1.0
@return ${return}, ${return_description}
@param aCpsBrow, array, descricao
@param aIdxTab, array, descricao
@type function
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
   	//-- A fun��o AGRCRTPTB est� no fonte AGRUTIL01 - Fun��es Genericas
    oArqTemp := AGRCRTPTB(cTabela, {aStrTab, aIdxTab})
Return cTabela

/*{Protheus.doc} OGC110F12
Reexecuta o Filtro de Busca
@author jean.schulze
@since 09/10/2017
@version undefined
@type function
*/
Function OGC110F12(lPergunta)
	// Abre a tela de par�metros de perguntas
	If lPergunta .and. !Pergunte("OGC110", .T.)
		Return
	Else
		Pergunte("OGC110", .F.)
	EndIf

	//monta filtro
	_cFiltro := fMntFiltro() //apropria filtro

	//limpa o filtro
	_oBrowse:oFwFilter:CleanFilter(.T.)

	//-- Carrega dados e cria arquivos tempor�rios
	Processa( { || fLoadDados(_cFiltro) }, STR0014)	

	_oBrowse:UpdateBrowse()

Return(.t.)

/*{Protheus.doc} OGC110CFR
fun��o para confirmar a comiss�o e gerar a al�ada de aprova��o
@author jean.schulze
@since 17/11/2017
@version 1.0
@return ${return}, ${return_description}
@type function
*/
function OGC110CFR()

	Local aArea			:= GetArea()
	Local lRet 			:= .T.
	Local aValidConf	:= OGX110VPED() // Retorno de valida��es | aValidConf[1] = .T. ou .F. | aValidConf[2] = Mensagem de erro
	Local cGrpAprov	   	:= SuperGetMv("MV_AGRO016")	
	
	//somente com status 1 e 5 pode excluir
	If (_cTabCom)->COM_STATUS <> "1" 
		RestArea(aArea)
		Help('',1, "OGC110GEALC") //Altera��o n�o permitida. Somente comiss�o com status Simulada pode ser Confirmada.  Aten��o
		Return .F.
	EndIf
	
	If !aValidConf[1]
		RestArea(aArea)
		MsgInfo(aValidConf[2], STR0001) // # Ajuda
		Return lRet
	EndIf
	
	If !Empty(cGrpAprov) //se o parametro estiver em branco ou vazio nao utiliza a al�ada
	
		If MaAlcDoc({(_cTabCom)->N89_CODCOM,"A2", (_cTabCom)->N89_VRCALC,,,cGrpAprov,,(_cTabCom)->N89_CMOEDA,(_cTabCom)->N89_TXMOED,dDataBase,""},dDataBase,1)
		   	
		   	//se retornar true � que nao foi necess�rio gerar al�ada, documento foi aprovado direto
		   	OGC110ALST((_cTabCom)->(RECNO()), (_cTabCom)->N89_FILIAL, (_cTabCom)->N89_CODCOM , "3")
			
			MsgInfo( STR0059, STR0050 ) //"Comiss�o Aprovada"###"Aten��o"
		
		Else
		   	//se retornar false � que foi necess�rio gerar al�ada, documento ficar� pendente
		    OGC110ALST((_cTabCom)->(RECNO()), (_cTabCom)->N89_FILIAL, (_cTabCom)->N89_CODCOM , "2")
			
			Help('',1, "OGC110PDCAPR") //Comiss�o em aprova��o. Aguarde a Libera��o do controle de al�adas para prosseguir.
		   
		EndIf
		
	Else	
	   Help('',1, "OGC110MV16EMPT") //Parametro MV_AGRO016 n�o prenchido. Para realizar a confirma��o � necess�rio vincular no parametro MV_AGRO016 o grupo de aprova��o.
	EndIf
	
	RestArea(aArea)
	
return lRet

/*{Protheus.doc} OGC110VIEW
fun��o para detalahar o calc
@author jean.schulze
@since 17/11/2017
@version 1.0
@return ${return}, ${return_description}
@type function
*/
function OGC110VIEW(cNumDoc)
	Local aArea		:= GetArea()	
	Local cFilDetal := ""
	Local oDlg      := Nil
	Local oSize     := Nil
	Local aCoors    := FWGetDialogSize( oMainWnd )
	Local aFieldBrw := {}
	Local aButtons  := {}
	Local lIntCom	:=  IsInCallStack("AGRXCOM1") //Integra��o com o compras
	
	Private oBrwDetal := nil
	
	If lIntCom //Se chamada da tela de aprova��o
		cFilDetal := "@ N89_FILIAL = '"+FwxFilial("N89")+"' AND N89_CODCOM = '"+ cNumDoc +"'" // varial cNumDoc vem da integracao com o compras
	Else
		cFilDetal := "@ N89_FILIAL = '"+FwxFilial("N89") + "'" + ;
		             " AND N89_CODCTR = '" + (_cTabCom)->N89_CODCTR + "'" +;
		             " AND N89_CODCOR = '" + (_cTabCom)->N89_CODCOR + "'" +;
					 " AND N89_CODCOM = '" + (_cTabCom)->N89_CODCOM + "'" +;
					 " AND N89_LOJCOR = '" + (_cTabCom)->N89_LOJCOR + "'" +;
					 " AND N89_CTPMER = '" + (_cTabCom)->N89_CTPMER + "'" +;
					 " AND N89_CMOEDA = '" + alltrim(str((_cTabCom)->N89_CMOEDA)) + "'" +;
					 " AND N89_DTCALC = '" + dTOs((_cTabCom)->N89_DTCALC) + "' " 
	EndIf
	  		
	oSize := FWDefSize():New() //desconsiderar o enchoice
	oSize:AddObject('DLG',100,100,.T.,.T.)
	oSize:SetWindowSize(aCoors)
	oSize:lProp 	:= .T.
	oSize:aMargins := {0,0,0,0}
	oSize:Process()

	aFieldBrw := {{STR0008 					, "N89_CODCOR"	, TamSX3( "N89_CODCOR" )[3]	, TamSX3( "N89_CODCOR" )[1]	, TamSX3( "N89_CODCOR" )[2]	, PesqPict("N89","N89_CODCOR") 	},; //"Qtd. Take-Up"
				  {STR0009 					, "N89_LOJCOR"	, TamSX3( "N89_LOJCOR" )[3]	, TamSX3( "N89_LOJCOR" )[1]	, TamSX3( "N89_LOJCOR" )[2]	, PesqPict("N89","N89_LOJCOR") 	},;
				  {STR0026 					, "N89_CODROM"	, TamSX3( "N89_CODROM" )[3]	, TamSX3( "N89_CODROM" )[1]	, TamSX3( "N89_CODROM" )[2]	, PesqPict("N89","N89_CODROM") 	},;
				  {STR0027 					, "N89_FILROM"	, TamSX3( "N89_FILROM" )[3]	, TamSX3( "N89_FILROM" )[1]	, TamSX3( "N89_FILROM" )[2]	, PesqPict("N89","N89_FILROM") 	},;
				  {STR0028 					, "N89_CODCOM"	, TamSX3( "N89_CODCOM" )[3]	, TamSX3( "N89_CODCOM" )[1]	, TamSX3( "N89_CODCOM" )[2]	, PesqPict("N89","N89_CODCOM") 	},; //"Qtd. Take-Up"
				  {AgrTitulo("N89_RPSFCO")  , "N89_RPSFCO"	, TamSX3( "N89_RPSFCO" )[3]	, TamSX3( "N89_RPSFCO" )[1]	, TamSX3( "N89_RPSFCO" )[2]	, PesqPict("N89","N89_RPSFCO") 	},;
				  {AgrTitulo("N89_RPSFCL")  , "N89_RPSFCL"	, TamSX3( "N89_RPSFCL" )[3]	, TamSX3( "N89_RPSFCL" )[1]	, TamSX3( "N89_RPSFCL" )[2]	, PesqPict("N89","N89_RPSFCL") 	},;
				  {AgrTitulo("N89_VLRDOC")  , "N89_VLRDOC"	, TamSX3( "N89_VLRDOC" )[3]	, TamSX3( "N89_VLRDOC" )[1]	, TamSX3( "N89_VLRDOC" )[2]	, PesqPict("N89","N89_VLRDOC") 	},;
				  {STR0005 					, "N89_CMOEDA"	, TamSX3( "N89_CMOEDA" )[3]	, TamSX3( "N89_CMOEDA" )[1]	, TamSX3( "N89_CMOEDA" )[2]	, PesqPict("N89","N89_CMOEDA"),	0},;
				  {AgrTitulo("N89_UMCOMS")  , "N89_UMCOMS"	, TamSX3( "N89_UMCOMS" )[3]	, TamSX3( "N89_UMCOMS" )[1]	, TamSX3( "N89_UMCOMS" )[2]	, PesqPict("N89","N89_UMCOMS") 	},;
				  {STR0029 					, "N89_VRCOMS"	, TamSX3( "N89_VRCOMS" )[3]	, TamSX3( "N89_VRCOMS" )[1]	, TamSX3( "N89_VRCOMS" )[2]	, PesqPict("N89","N89_VRCOMS") 	},;
				  {STR0030 					, "N89_VRCALC"	, TamSX3( "N89_VRCALC" )[3]	, TamSX3( "N89_VRCALC" )[1]	, TamSX3( "N89_VRCALC" )[2]	, PesqPict("N89","N89_VRCALC") 	},;				  
				  {STR0012 					, "N89_DTCALC"	, TamSX3( "N89_DTCALC" )[3]	, TamSX3( "N89_DTCALC" )[1]	, TamSX3( "N89_DTCALC" )[2]	, PesqPict("N89","N89_DTCALC") 	},; //"Qtd. Take-Up"
				  {STR0031 					, "N89_USER"	, TamSX3( "N89_USER"   )[3]	, TamSX3( "N89_USER"   )[1]	, TamSX3( "N89_USER"   )[2]	, PesqPict("N89","N89_USER") 	},;
				  {STR0058 					, "N89_NUMDOC"	, TamSX3( "N89_NUMDOC" )[3]	, TamSX3( "N89_NUMDOC" )[1]	, TamSX3( "N89_NUMDOC" )[2]	, PesqPict("N89","N89_NUMDOC") 	}}				  
	
	oDlg := TDialog():New(  oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4], STR0033, , , , , CLR_BLACK, CLR_WHITE, , , .t. )

	oPnl1:= tPanel():New(oSize:aPosObj[1,1],oSize:aPosObj[1,2],,oDlg,,,,,,oSize:aPosObj[1,4],oSize:aPosObj[1,3] -30)	
	
	oBrwDetal := FWMBrowse():New()
    oBrwDetal:SetAlias("N89")
    oBrwDetal:SetMenuDef("")	
	oBrwDetal:AddLegend( "N89_TPCOMS=='1' .AND. N89_TPOPER=='1'", "BR_AZUL", X3CboxDesc( "N89_TPCOMS", "1" )   ) 
	oBrwDetal:AddLegend( "N89_TPCOMS=='2' .AND. N89_TPOPER=='1'", "BR_VERDE", X3CboxDesc( "N89_TPCOMS", "2" )   )
	oBrwDetal:AddLegend( "N89_TPCOMS=='3' .AND. N89_TPOPER=='1'", "BR_AMARELO", X3CboxDesc( "N89_TPCOMS", "3" )   )
	oBrwDetal:AddLegend( "N89_TPOPER=='2'", "BR_CINZA", X3CboxDesc( "N89_TPOPER", "2" )   )
	oBrwDetal:SetFields(aFieldBrw)
	oBrwDetal:SetDescription(STR0033) //Detalhes do c�lculo
    oBrwDetal:DisableReport(.T.)
    oBrwDetal:SetDoubleClick({|| OGC110VISU()}) 
    oBrwDetal:DisableConfig()
    oBrwDetal:DisableDetails()  
    oBrwDetal:SetProfileID("OGC110DETL")
    oBrwDetal:SetFilterDefault(cFilDetal) 
    oBrwDetal:SetIgnoreaRotina(.T.)   
    
    //cria os bot�es adicionais
    If !lIntCom //n�o exibe este bot�e na tela de apro��o
    	Aadd( aButtons, {STR0040, {|| OGC110INC() }, STR0038, STR0038, {|| .T.}} )   //Incluir  Incluir Ajuste
    	Aadd( aButtons, {STR0053, {|| OGC110ALT() }, STR0052, STR0052, {|| .T.}} )   //Alterar  Alterar
    	Aadd( aButtons, {STR0041, {|| OGC110EXC() }, STR0039, STR0039, {|| .T.}} )	//Excluir  Excluir Ajuste
    EndIf
    
    oBrwDetal:Activate(oPnl1)
	
	oDlg:Activate( , , , .t., , ,EnchoiceBar(oDlg, {|| .F.}, {||  oDlg:End() } /*Fechar*/,,@aButtons, /*nRecno*/, /*cAlias*/ , .F., .F., .F., .F., .F.) )	
	
	Restarea(aArea)
	
	If !lIntCom //n�o exibe este bot�e na tela de apro��o
		OGC110UPDC() // Atualiza o valor calculado conforme ajustes
		_oBrowse:Refresh()
	EndIf
	
Return .T.

/*{Protheus.doc} OGC110DELT
fun��o para deleta simula��o
@author jean.schulze
@since 17/11/2017
@version 1.0
@return ${return}, ${return_description}
@type function
*/
function OGC110DELT()
	Local aArea		:= GetArea()
	Local aItensBrw := {}
	Local cAliasN89 := GetNextAlias()
	Local nX        := 0
	Local lReturn   := .t.
	
	if (_cTabCom)->COM_STATUS <> "1"
		Help( , , STR0001, , STR0034, 1, 0 )
		return .f.
	endif
	
	//busca todos os recnos do SUM
	BeginSql Alias cAliasN89

		SELECT R_E_C_N_O_ N89_RECNO
	  	  FROM %Table:N89% N89
		WHERE N89.%notDel%		
		  AND N89_FILIAL = %exp:FwxFilial("N89")% 
		  AND N89_CODCTR = %exp:(_cTabCom)->N89_CODCTR% 
		  AND N89_CODCOR = %exp:(_cTabCom)->N89_CODCOR% 
		  AND N89_LOJCOR = %exp:(_cTabCom)->N89_LOJCOR% 
		  AND N89_CTPMER = %exp:(_cTabCom)->N89_CTPMER% 
		  AND N89_CMOEDA = %exp:(_cTabCom)->N89_CMOEDA% 
		  AND N89_DTCALC = %exp:(_cTabCom)->N89_DTCALC%  
		  AND N89_CODCOM =  %exp:(_cTabCom)->N89_CODCOM%  
		  
	EndSQL

	DbselectArea( cAliasN89 )
	DbGoTop()
	while ( cAliasN89 )->( !Eof() )
					
		aAdd(aItensBrw, ( cAliasN89 )->N89_RECNO)
	
		( cAliasN89 )->( dbSkip() )
	Enddo

	( cAliasN89 )->( dbCloseArea() )
	
	//pergunta se deseja deletar os itens
	if len(aItensBrw) > 0 .and. MsgYesNo(STR0035)
		
		BEGIN TRANSACTION //begin transaction
			
			DbSelectArea( "N89" )
			For nX := 1 to Len( aItensBrw )
				if lReturn
					DbGoTo( aItensBrw[ nX ] ) 	//posiciona no recno
					If lReturn := RecLock( "N89", .f. )
						N89->(dbdelete()) //deleta
						msUnLock()
					EndIf
				endif
			Next nX
			
			//verifcia erros
			if lReturn
				MsgInfo(STR0036, STR0036) //mensagem de sucesso
			else
				DisarmTransaction()
				Help( , , STR0001, ,STR0037, 1, 0 )
				lReturn := .f.	
			endif
			
		END TRANSACTION
		
	endif
	
	Restarea(aArea)
		
	//reload no browser
	OGC110F12(.f.)		 

return .t.

/*{Protheus.doc} OGC110ESTO
funcao para estornar pedido de compra
@author Mauricio.joao
@since 07/08/2017
@version 1.0
@return ${return}, ${return_description}
@type function
*/
function OGC110ESTO()

	Local aAreaN89		:= GetArea('N89') 
	Local aAreaSC7		:= GetArea('SC7') 
	Local aAreaSCR		:= GetArea('SCR') 
	Local cGrpAprov	   	:= SuperGetMv("MV_AGRO016")	
	
If (_cTabCom)->COM_STATUS == '1' //simulado
	MsgAlert(STR0074) // Estorno n�o disponivel para Comiss�es com status de Simulado
	
ElseIf (_cTabCom)->COM_STATUS == '2' //pendente aprova��o
	If MsgYesNo(STR0075) //O Estorno rejeitar� a pendencia de Aprova��o de Al�adas, Deseja continuar?
		SCR->(DbSetOrder(1))
		If SCR->(DbSeek(xFilial('SCR') + 'A2' +(_cTabCom)->N89_CODCOM))
			MaAlcDoc({(_cTabCom)->N89_CODCOM,"A2", (_cTabCom)->N89_VRCALC,,,;
					cGrpAprov,,(_cTabCom)->N89_CMOEDA,(_cTabCom)->N89_TXMOED,dDataBase,""},;
					dDataBase,7)
		
			MsgAlert(STR0078) //Estorno concluido!
		EndIf
	EndIf

ElseIf (_cTabCom)->COM_STATUS == '3' //aprovado
	
	OGC110ALST((_cTabCom)->(RECNO()), (_cTabCom)->N89_FILIAL, (_cTabCom)->N89_CODCOM , "1")
	
	MsgAlert(STR0078) //Estorno concluido!

ElseIf (_cTabCom)->COM_STATUS == '4' //finalizado/pedido gerado

	If MsgYesNo(STR0076) //O Estorno excluir� o Pedido de Compras Gerado e rejeitar� a Pendencia de Aprova��o de Al�adas, Deseja continuar?
		
		N89->(DbSetOrder(3))
		If N89-> (DbSeek(xFilial('N89') + (_cTabCom)->N89_CODCOM) )
			//Procura Pedido
			If !Empty( N89->N89_NUMDOC )
				//Verifica se o pedido j� possui nota fiscal vinculada
				SC7->(DbSetOrder(1))
				If SC7->(DbSeek(xfilial('SC7') + N89->N89_NUMDOC))
					If !Empty(SC7->C7_ENCER)
						MsgAlert(STR0077) //Documento fiscal vinculado ao Pedido de Comiss�o, n�o � possivel Estornar

					Else	
						//Valida se tem controle de al�adas
						SCR->(DbSetOrder(1))
						If SCR->(DbSeek(xFilial('SCR') + 'A2' +(_cTabCom)->N89_CODCOM))			
							//Estorna Ala�ada/deleta
							MaAlcDoc({(_cTabCom)->N89_CODCOM,"A2", (_cTabCom)->N89_VRCALC,,,;
										cGrpAprov,,(_cTabCom)->N89_CMOEDA,(_cTabCom)->N89_TXMOED,dDataBase,""},;
										dDataBase,7)											
						EndIf
						
						//Exclui Pedido
						N89->(DbSetOrder(3))
						If N89->(DbSeek(xFilial('N89')+(_cTabCom)->N89_CODCOM))
							OGC110DPC(N89->N89_NUMDOC)
						EndIf						
						
						N89->(DbSetOrder(3))
						If N89-> (DbSeek(xFilial('N89') + (_cTabCom)->N89_CODCOM) )
							While N89->(!EOF()) .AND. ;
									N89->N89_FILIAL == FWxFilial("N89") .AND. ;
									N89->N89_CODCOM == PadR(AllTrim((_cTabCom)->N89_CODCOM),TamSx3('N89_CODCOM')[1] )

								If RecLock("N89",.F.)											
									N89->N89_STATUS := '1'
									N89->N89_NUMDOC := ""
									N89->(msUnLock())
								EndIf

								N89->(dbSkip())
							EndDo
						EndIf

						MsgAlert(STR0078) //Estorno concluido!

					EndIf
				EndIf
			EndIf 
		EndIf
	EndIf

EndIf

	RestArea(aAreaN89)
	RestArea(aAreaSC7)	
	RestArea(aAreaSCR)

	Pergunte('OGC110',.F.)

	//reload no browser
	OGC110F12(.f.)

return 

/*/{Protheus.doc} OGC110DPC
	Exclui pedido de Compras passado no parametro.
	@type  Function
	@author Mauricio.joao
	@since 08/08/2018
	@version 1.0
	@param cPedido, Character, C�digo do Pedido de Compras
/*/

Function OGC110DPC(cPedido)

Local aAliasSC7 	:= GetArea('SC7')
Local aLinha 		:= {}
Local lMsErroAuto 	:= .T.

DbSelectArea('SC7')
SC7->(DbSetOrder(1))
If SC7->(DbSeek(xfilial('SC7')+cPedido))
   
    aCabec := {}
    aItens := {}

    aadd(aCabec,{"C7_NUM"       ,SC7->C7_NUM})
    aadd(aCabec,{"C7_EMISSAO"   ,SC7->C7_EMISSAO})
    aadd(aCabec,{"C7_FORNECE"   ,SC7->C7_FORNECE})
    aadd(aCabec,{"C7_LOJA"      ,SC7->C7_LOJA})
    aadd(aCabec,{"C7_COND"      ,SC7->C7_COND})
    aadd(aCabec,{"C7_CONTATO"   ,SC7->C7_CONTATO})
    aadd(aCabec,{"C7_FILENT"    ,SC7->C7_FILENT})

    While SC7->(!Eof()) .AND. Alltrim(SC7->C7_NUM) == Alltrim(cPedido)

        aadd(aLinha,{"C7_ITEM",SC7->C7_ITEM,Nil})
        aadd(aLinha,{"C7_PRODUTO",SC7->C7_PRODUTO,Nil})
        aadd(aLinha,{"C7_QUANT",SC7->C7_QUANT,Nil})
        aadd(aLinha,{"C7_PRECO",SC7->C7_PRECO,Nil})
        aadd(aLinha,{"C7_TOTAL",SC7->C7_TOTAL,Nil})

        aadd(aLinha,{"C7_REC_WT" ,SC7->(RECNO()) ,Nil})

        aadd(aItens,aLinha)

        SC7->(DbSkip())
    
    EndDo

Else
    MsgAlert(STR0079) //Pedido n�o encontrato!
EndIf

MATA120(1,aCabec,aItens,5)

If !lMsErroAuto
	MsgAlert(STR0080) //Pedido Excluido com Sucesso
EndIf

RestArea(aAliasSC7)

Return 


/** {Protheus.doc} ModelDef
Fun��o que retorna o modelo padrao para a rotina

@param:     Nil
@return:    oModel - Modelo de dados
@author:    Equipe Agroindustria
@since:     01/01/2015
@Uso:       OGA700 - Negocia��es
*/
Static Function ModelDef()
	Local oStruN89 := FWFormStruct( 1, 'N89' )
	Local oModel 	 := MPFormModel():New( 'OGC110', /*bPre */, /*bPos*/, {|oModel| GrvModelo(oModel)}, {|oModel| SairModel(oModel)})	

	oStruN89:setProperty("N89_VRCALC", MODEL_FIELD_OBRIGAT, .T.)	
	
	oStruN89:AddField(; // Ord. Tipo Desc.
					  STR0042, ; 						// [01] C Titulo do campo  //"Nome Corretor"
					  STR0043, ;   						// [02] C Descri��o do campo //"Nome do Corretor"									
					  "N89_DCORR", ; 					// [03] C identificador (ID) do								
					  TamSX3("A2_NOME")[3]  , ;			// [04] C Tipo do campo
					  TamSX3("A2_NOME")[1] , ; 			// [05] N Tamanho do campo
					  TamSX3("A2_NOME")[2] , ;			// [06] N Decimal do campo
					  nil, ; 							// [07] B Code-block de valida��o do campo
					  {||} , ; 							// [08] B Code-block de								
					  NIL, ;				 			// [09] A Lista de valores permitido do campo combo
					  .F. , ; 							// [10] L Indica se o campo tem preenchimento obrigat�rio
					  {||} , ; 							// [11] B Code-block de inicializacao do campo
					  NIL    , ; 						// [12] L Indica se trata de um campo chave
					  NIL , ; 							// [13] L Indica se o campo pode receber valor em uma opera��o de update.
					  .T. )										
	
	oStruN89:AddField(; // Ord. Tipo Desc.
					  STR0044, ; 						// [01] C Titulo do campo  		//Des. Moeda
					  STR0045, ;   						// [02] C Descri��o do campo	//Descri��o da Moeda			 						
					  "N89_DMOEDA", ; 					// [03] C identificador (ID) do								
					  "C" , ;							// [04] C Tipo do campo
					  6 , ; 							// [05] N Tamanho do campo
					  0, ;								// [06] N Decimal do campo
					  nil, ; 							// [07] B Code-block de valida��o do campo
					  {||} , ; 							// [08] B Code-block de								
					  NIL, ;				 			// [09] A Lista de valores permitido do campo combo
					  .F. , ; 							// [10] L Indica se o campo tem preenchimento obrigat�rio
					  {||} , ; 							// [11] B Code-block de inicializacao do campo
					  NIL    , ; 						// [12] L Indica se trata de um campo chave
					  NIL , ; 							// [13] L Indica se o campo pode receber valor em uma opera��o de update.
					  .T. )	
					  
	oModel:AddFields( 'MODEL_N89' , /*cOwner*/ , oStruN89 )	
	
	oModel:SetDescription( STR0046 ) //Inclus�o de Ajuste da Comiss�o
	
	oModel:GetModel( 'MODEL_N89' ):SetPrimaryKey( { 'N89_CODROM', 'N89_CODCTR', 'N89_FILROM'} )
	
	If IsInCallStack("OGC110INC") 
		oStruN89:SetProperty("N89_CODCOM",MODEL_FIELD_INIT, {|| N89->N89_CODCOM} )
		oStruN89:SetProperty("N89_DTCALC",MODEL_FIELD_INIT, {|| N89->N89_DTCALC} )
		oStruN89:SetProperty("N89_USER",  MODEL_FIELD_INIT, {|| UsrRetName(RetCodUsr())} )
		oStruN89:SetProperty("N89_STATUS",MODEL_FIELD_INIT, {|| "1"} )   //Simulada
		oStruN89:SetProperty("N89_TPOPER",MODEL_FIELD_INIT, {|| "2"} ) //Altera��o Comiss�o
		oStruN89:SetProperty("N89_ITEM",  MODEL_FIELD_INIT, {|| GetNextSeq()} )
	EndIf
	
	oStruN89:SetProperty("N89_DCORR", MODEL_FIELD_INIT, {|| POSICIONE("SA2",1,xFilial("SA2")+N89->N89_CODCOR,"A2_NOME")})	
	oStruN89:SetProperty("N89_CODCTR",MODEL_FIELD_INIT, {|| N89->N89_CODCTR} )
	oStruN89:SetProperty("N89_FILROM",MODEL_FIELD_INIT, {|| N89->N89_FILROM} ) 
	oStruN89:SetProperty("N89_CODCOR",MODEL_FIELD_INIT, {|| N89->N89_CODCOR} )
	oStruN89:SetProperty("N89_LOJCOR",MODEL_FIELD_INIT, {|| N89->N89_LOJCOR} )
	oStruN89:SetProperty("N89_CMOEDA",MODEL_FIELD_INIT, {|| N89->N89_CMOEDA} )
	oStruN89:SetProperty("N89_CTPMER",MODEL_FIELD_INIT, {|| N89->N89_CTPMER} )
	oStruN89:SetProperty("N89_TPCOMS",MODEL_FIELD_INIT, {|| N89->N89_TPCOMS} )	
	oStruN89:SetProperty("N89_DMOEDA",MODEL_FIELD_INIT, {|| AgrMvSimb(N89->N89_CMOEDA)	} )
		
	oStruN89:SetProperty("N89_VRCALC",MODEL_FIELD_TITULO, STR0047 ) //Vl. Comiss�o 
	oStruN89:SetProperty("N89_TPOPER",MODEL_FIELD_TITULO, STR0048 ) //Origem
	
Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View
@return oView - Objeto da View MVC
@author Rafael V�ltz
@since 03/04/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel 	 := FWLoadModel( 'OGC110' )
	
	Local oStruN89 	 := Nil
	Local oView 	 := FWFormView():New()
	Local lVisCalc	 := IsInCallStack("OGC110VISU") .AND. N89->N89_TPOPER != '2' // Visualiza��o e registro diferente de um inser��o manual
	
	If lVisCalc
		oStruN89 := FWFormStruct( 2, 'N89', { |x| !ALLTRIM(x) $ 'N89_CODROM, N89_ITEM, N89_VRCOMS,N89_RUMROM, N89_RVRUNI, N89_RVRTOT, N89_TPCOMS, N89_VRCOMS, N89_DTCALC, N89_USER, N89_CTPMER, N89_NUMDOC, N89_STATUS'} )
	Else
		oStruN89 := FWFormStruct( 2, 'N89', { |x| !ALLTRIM(x) $ 'N89_CODROM, N89_ITEM, N89_VRCOMS,N89_RUMROM, N89_RVRUNI, N89_RPSFCO, N89_RPSFCL, N89_RVRTOT, N89_TPCOMS, N89_UMCOMS, N89_VRCOMS, N89_DTCALC, N89_USER, N89_CTPMER, N89_NUMDOC, N89_STATUS, N89_VLRDOC'} )
	EndIf

	oView:SetModel( oModel )
	
	oStruN89:AddField( ; 							 	// Ord. Tipo Desc.
						"N89_DCORR" , ;   				// [01] C Nome do Campo
						"3" , ;  			 			// [02] C Ordem
						STR0042, ; 						// [03] C Titulo do campo   	//Nome Corretor
						STR0043, ;   					// [04] C Descri��o do campo	//Nome do Corretor
						nil, ; 							// [05] A Array com Help
						TamSX3("A2_NOME")[3]  , ; 		// [06] C Tipo do campo
						X3PICTURE("A2_NOME") , ; 		// [07] C Picture
						{||} , ; 						// [08] B Bloco de Picture Var
						nil , ; 						// [09] C Consulta F3
						.F.    , ; 						// [10] L Indica se o campo � edit�vel
						Nil , ; 						// [11] C Pasta do campo
						NIL , ; 						// [12] C Agrupamento do campo
						NIL      , ; 					// [13] A Lista de valores permitido  do campo combo
						NIL   , ; 						// [14] N Tamanho M�ximo da maior						
						NIL , ; 						// [15] C Inicializador de Browse
						.T. , ; 						// [16] L Indica se o campo � virtual
						NIL ) 
	
	oStruN89:AddField( ; 							 	// Ord. Tipo Desc.
						"N89_DMOEDA" , ;   				// [01] C Nome do Campo
						"4" , ;  			 			// [02] C Ordem
						STR0044, ; 						// [03] C Titulo do campo	//Des. Moeda
						STR0045, ;   					// [04] C Descri��o do campo //Descri��o da MOeda
						nil, ; 							// [05] A Array com Help
						"C"  , ; 						// [06] C Tipo do campo
						nil , ; 						// [07] C Picture
						{||} , ; 						// [08] B Bloco de Picture Var
						nil , ; 						// [09] C Consulta F3
						.F.    , ; 						// [10] L Indica se o campo � edit�vel
						Nil , ; 						// [11] C Pasta do campo
						NIL , ; 						// [12] C Agrupamento do campo
						NIL      , ; 					// [13] A Lista de valores permitido  do campo combo
						NIL   , ; 						// [14] N Tamanho M�ximo da maior						
						NIL , ; 						// [15] C Inicializador de Browse
						.T. , ; 						// [16] L Indica se o campo � virtual
						NIL ) 					
	
	oView:AddField( 'VIEW_N89', oStruN89, 'MODEL_N89' )
	oView:CreateHorizontalBox( 'FIELDSN89', 100 )
	oView:SetOwnerView( 'VIEW_N89', 'FIELDSN89' )
	
	oStruN89:setProperty("N89_CODCTR", MVC_VIEW_CANCHANGE, .F.)
	oStruN89:setProperty("N89_CODCOR", MVC_VIEW_CANCHANGE, .F.)
	oStruN89:setProperty("N89_LOJCOR", MVC_VIEW_CANCHANGE, .F.)
	oStruN89:setProperty("N89_FILROM",  MVC_VIEW_CANCHANGE, .F.)
	oStruN89:setProperty("N89_CODCOM",  MVC_VIEW_CANCHANGE, .F.)
	oStruN89:setProperty("N89_CMOEDA",  MVC_VIEW_CANCHANGE, .F.)
	oStruN89:setProperty("N89_TPOPER",  MVC_VIEW_CANCHANGE, .F.)
	
	oStruN89:setProperty("N89_CODCTR",  MVC_VIEW_ORDEM, "04")
	oStruN89:setProperty("N89_FILROM",  MVC_VIEW_ORDEM, "05")
	oStruN89:setProperty("N89_CODCOM",  MVC_VIEW_ORDEM, "06")
	
	If lVisCalc
		oStruN89:setProperty("N89_CODCOR",  MVC_VIEW_ORDEM, "07")
		oStruN89:setProperty("N89_DCORR",  	MVC_VIEW_ORDEM, "08")
		oStruN89:setProperty("N89_LOJCOR", 	MVC_VIEW_ORDEM, "09")
		oStruN89:setProperty("N89_RPSFCO",  MVC_VIEW_ORDEM, "10")
		oStruN89:setProperty("N89_RPSFCL",  MVC_VIEW_ORDEM, "11")
		oStruN89:setProperty("N89_VLRDOC",  MVC_VIEW_ORDEM, "12")
		oStruN89:setProperty("N89_CMOEDA", 	MVC_VIEW_ORDEM, "13")
		oStruN89:setProperty("N89_UMCOMS",  MVC_VIEW_ORDEM, "14")
		oStruN89:setProperty("N89_DMOEDA", 	MVC_VIEW_ORDEM, "15")
		oStruN89:setProperty("N89_TPOPER", 	MVC_VIEW_ORDEM, "16")		
		oStruN89:setProperty("N89_VRCALC", 	MVC_VIEW_ORDEM, "18")		
		oStruN89:setProperty("N89_OBSERV", 	MVC_VIEW_ORDEM, "19")
	Else
		oStruN89:setProperty("N89_CODCOR",  MVC_VIEW_ORDEM, "07")
		oStruN89:setProperty("N89_DCORR",  	MVC_VIEW_ORDEM, "08")
		oStruN89:setProperty("N89_LOJCOR", 	MVC_VIEW_ORDEM, "09")
		oStruN89:setProperty("N89_CMOEDA", 	MVC_VIEW_ORDEM, "10")
		oStruN89:setProperty("N89_DMOEDA", 	MVC_VIEW_ORDEM, "11")
		oStruN89:setProperty("N89_TPOPER", 	MVC_VIEW_ORDEM, "12")		
		oStruN89:setProperty("N89_VRCALC", 	MVC_VIEW_ORDEM, "14")		
		oStruN89:setProperty("N89_OBSERV", 	MVC_VIEW_ORDEM, "15")
	EndIf
	
	
	oStruN89:SetProperty("N89_VRCALC",MVC_VIEW_TITULO, STR0047 )
    oStruN89:RemoveField("N89_VRIMP")

Return ( oView )

/*/{Protheus.doc} OGC110INC
//Fun��o para inclus�o de ajuste manual de comiss�o.
@author rafael.voltz
@since 22/01/2018
@version undefined

@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function OGC110INC()
	Local aArea			:= GetArea()
	
	//somente com status 1 e 5 pode alterar, 2,3,4 n�o
	If (_cTabCom)->COM_STATUS $ "2|3|4" 
		Help('',1, "OGC110NOINCLU") //Inslu�o n�o permitida. Somente comiss�o com status Simula��o pode ser alterada.  Aten��o
		Return .F.
	EndIf
	
	FWExecView('', 'VIEWDEF.OGC110', MODEL_OPERATION_INSERT, , {|| .T. })
	
	RestArea(aArea)
	
	oBrwDetal:ExecuteFilter(.t.)
Return .T.

/*/{Protheus.doc} GetNextSeq
Busca proxima sequencia da comiss�o
@type  Static Function
@author filipe.olegini
@since 14/08/2018
@version P12
@return cSeq, char, retorna a proxima sequencia da chave da tabela
/*/
 Static Function GetNextSeq()
	Local cSeq		as char
	Local cQuery	as char
	Local cAliasQry as char

	cSeq		:= "001"
	cAliasQry	:= GetNextAlias()

	If Select(cAliasQry) <> 0
		(cAliasQry)->(dbCloseArea())
	EndIf 
	
	cQuery := " SELECT MAX(N89_ITEM) AS ITEM "
	cQuery +=   " FROM " + RetSqlName('N89')
	cQuery +=  " WHERE D_E_L_E_T_ = '' "
	cQuery +=    " AND N89_FILIAL = '" + N89->N89_FILIAL + "' "
	cQuery +=    " AND N89_CODCTR = '" + N89->N89_CODCTR + "' "
	cQuery +=    " AND N89_CODCOM = '" + N89->N89_CODCOM + "' "
	cQuery +=    " AND N89_CODCOR = '" + N89->N89_CODCOR + "' " 
	cQuery +=    " AND N89_LOJCOR = '" + N89->N89_LOJCOR + "' "
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	
	If (cAliasQry)->(!Eof())
		cSeq := (cAliasQry)->ITEM
	Else
		cSeq := "001"
	EndIf
	
	//incrementa +1
	cSeq := Soma1(cSeq)

Return cSeq

/*/{Protheus.doc} OGC110ALT
//Fun��o para exclus�o de ajuste manual de comiss�o.
@author rafael.voltz
@since 22/01/2018
@version undefined

@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function OGC110ALT()
	Local aArea			:= GetArea()
	
	//somente com status 1 e 5 pode alterar, 2,3,4 n�o
	If (_cTabCom)->COM_STATUS $ "2|3|4" 
		Help('',1,"OGC110NOALTER") //Altera��o n�o permitida. Somente comiss�o com status Simula��o ou Revis�o pode ser alterada.  Aten��o
		Return .F.
	EndIf
	
	If N89->N89_TPOPER == "1"
		MsgInfo(STR0051, STR0050) //Altera��o n�o permitida. Somente lan�amentos manuais podem ser alterados.  Aten��o
		Return .F.
	EndIf
		
	FWExecView('', 'VIEWDEF.OGC110', MODEL_OPERATION_UPDATE, , {|| .T. })
	
	RestArea(aArea)	
	
	oBrwDetal:ExecuteFilter(.t.)	
Return .T.

/*/{Protheus.doc} OGC110EXC
//Fun��o para exclus�o de ajuste manual de comiss�o.
@author rafael.voltz
@since 22/01/2018
@version undefined

@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function OGC110EXC()
	Local aArea			:= GetArea()
	
	//somente com status 1 e 5 pode excluir
	If (_cTabCom)->COM_STATUS $ "2|3|4" 
		Help('',1, "OGC110NOEXCLUI") //Exclus�o n�o permitida. Somente comiss�o com status Simula��o ou Revis�o podem ser exclu�das.  Aten��o
		Return .F.
	EndIf
	
	If N89->N89_TPOPER == "1"
		MsgInfo(STR0049, STR0050) //Exclus�o n�o permitida. Somente lan�amentos manuais podem ser exclu�dos.  Aten��o
		Return .F.
	EndIf
			
	FWExecView('', 'VIEWDEF.OGC110', MODEL_OPERATION_DELETE, , {|| .T. })
	
	RestArea(aArea)	
	
	oBrwDetal:ExecuteFilter(.t.)	
Return .T.

/*/{Protheus.doc} OGC110VIEW
//Fun��o para visualiza��o de ajuste manual e calculado da comiss�o.
@author rafael.voltz
@since 22/01/2018
@version undefined

@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function OGC110VISU()
	Local aArea			:= GetArea()
	
	FWExecView('', 'VIEWDEF.OGC110', MODEL_OPERATION_VIEW, , {|| .T. })
	
	RestArea(aArea)	
Return .T.

/*{Protheus.doc} OGC110ALST
//Fun��o para alterar o status dos registros.
@author filipe.olegini
@since 10/04/2018
@version undefined

@return return, return_description
@example
(examples)
@see (links_or_references)
*/
Static Function OGC110ALST(nRen,cFil, cCodCom, cStatus)
	Local aArea	    := GetArea()
    Local aAreaN89	:= N89->(GetArea())
	
    dbSelectArea("N89")
    dbSetOrder(3)
    If dbSeek(FWxFilial("N89") + PadR(AllTrim(cCodCom),TamSx3('N89_CODCOM')[1] ))

        While N89->(!EOF()) .AND. N89->N89_FILIAL == FWxFilial("N89") .AND. N89->N89_CODCOM == PadR(AllTrim(cCodCom),TamSx3('N89_CODCOM')[1] )
                
            If RecLock("N89",.F.)
               N89->N89_STATUS := cStatus
               N89->(msUnLock())
            EndIf

            N89->(dbSkip())
        EndDo
    EndIf
	
	//realiza o ajuste na temp onde os registros est�o agrupados
	(_cTabCom)->(dbGoTo(nRen)) //posiciona a linha conforme parametro
	If Reclock(_cTabCom, .F.)			
        (_cTabCom)->COM_STATUS  := cStatus
        (_cTabCom)->(MsUnlock())
	EndIf

    RestArea(aAreaN89)
    RestArea(aArea)

Return

/*/{Protheus.doc} GrvModelo
//Fun��o para gravar o model.
@author rafael.voltz
@since 22/01/2018
@version undefined

@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GrvModelo(oModel)
	Local lRet as logical

	lRet := FWFormCommit( oModel, /*Before Linha*/ , /*After linha*/, {|| iif(oModel:GetOperation() == MODEL_OPERATION_INSERT, ConfirmSx8(), .T.)}, /*Midle Transaction*/,/**/ ) //commit dos dados
	
	//altera o status para todos os registros agrupados somente ap�s o commit.
	If lRet
		OGC110ALST((_cTabCom)->(RECNO()), (_cTabCom)->N89_FILIAL, (_cTabCom)->N89_CODCOM , "1")
	EndIf
	
Return lRet

/*/{Protheus.doc} SairModel
//Fun��o para tratativa quando sair do model pela op��o Fechar.
@author rafael.voltz
@since 22/01/2018
@version undefined

@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SairModel(oModel) 
 	
 If oModel:GetOperation() == MODEL_OPERATION_INSERT
 	RollbackSx8()
 EndIf
 
Return .T.

/*{Protheus.doc} OGX110VPED
//Fun��o de valida��o para a Confirma��o de Comiss�o.
@author roney.maia
@since 25/01/2018
@version 1.0
@return ${Array}, ${aRer[1] = .T. - Valido, .F. - Invalido | aRet[2] = Mensagem devido a erro }
@type function
*/
Static Function OGX110VPED()

	Local aArea		:= GetArea()
	Local cAliasQry	:= GetNextAlias()
	Local cQuery	:= ""
	Local nIt		:= 0
	Local aRet 		:= {.T., ""}
	Local aRoms		:= {}
	
	// Obtem o alias com os romaneios pertencentes ao contrato e corretor selecionado, * equivale aos registros presentes no detalhar
	Local cAliasTmp	:= GetSqlAll("SELECT N89_CODROM, N89_FILROM FROM " + RetSqlName("N89") + " N89 WHERE N89_FILIAL = '"+FwxFilial("N89");
						+"' AND N89_CODCTR = '"+(_cTabCom)->N89_CODCTR;
						+"' AND N89_CODCOR = '"+(_cTabCom)->N89_CODCOR;
						+"' AND N89_LOJCOR = '"+(_cTabCom)->N89_LOJCOR;
						+"' AND N89_CTPMER = '"+(_cTabCom)->N89_CTPMER;
						+"' AND N89_CMOEDA = '"+alltrim(str((_cTabCom)->N89_CMOEDA));
						+"' AND N89_DTCALC = '"+dTOs((_cTabCom)->N89_DTCALC)+"'")
						
	(cAliasTmp)->(dbGoTop())
	
	If (cAliasTmp)->( Eof() ) // Se, n�o houver romaneios n�o ir� gerar o pedido de compra
		(cAliasTmp)->(dbCloseArea())
		RestArea(aArea)
		aRet[2] := STR0054 // # N�o existe romaneios calculados para o corretor selecionado.
		Return aRet
	EndIf
	
	While !(cAliasTmp)->( Eof() ) // Adiciona os romaneios em um array para futura query
		If !Empty((cAliasTmp)->N89_CODROM) .AND. aScan(aRoms, {|x| x[1] == (cAliasTmp)->N89_CODROM }) == 0
			aAdd(aRoms, {(cAliasTmp)->N89_CODROM, (cAliasTmp)->N89_FILROM})
		EndIf
		(cAliasTmp)->(dbSkip())
	EndDo
	
	(cAliasTmp)->(dbCloseArea())
	
	// Monta query com os romaneios presentes para o contrato e corretor em quest�o, verificando se algum romaneio n�o possui status de confirmado.
	cQuery += "SELECT DISTINCT NJJ.NJJ_CODROM FROM " + RetSqlName("NJJ") + " NJJ"
	
	cQuery += " INNER JOIN " + RetSqlName("N89") + " N89 ON"
	cQuery += " N89.N89_FILROM = NJJ.NJJ_FILIAL"
	cQuery += " AND N89.D_E_L_E_T_ <> '*'"
	
	cQuery += " WHERE NJJ.D_E_L_E_T_ <> '*' AND NJJ.NJJ_STATUS <> '3' AND ("
	
	For nIt := 1 To Len(aRoms)
		cQuery += "(NJJ.NJJ_CODROM = '" + aRoms[nIt][1] + "' AND N89.N89_FILROM = '" + aRoms[nIt][2] + "') OR "
	Next nIt
	
	cQuery := SubStr(cQuery, 1, Len(cQuery) - 4) + ")"
	
	If Select(cAliasQry) > 0
		(cAliasQry)->(dbCloseArea())
	EndIf
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery)), cAliasQry, .F., .T.)
	
	(cAliasQry)->(dBGoTop())
	
	If !(cAliasQry)->(Eof()) // Se, houver algum romaneio com status diferente de confirmado, n�o gera o pedido de compra.
		aRet[1] := .F.
		aRet[2] := STR0055 // # H� romaneios n�o confirmados.
		While !(cAliasQry)->(Eof())
			aRet[2] += "[" + (cAliasQry)->NJJ_CODROM + "]"
			(cAliasQry)->(dbSkip())
		EndDo
	EndIf
	
	(cAliasQry)->(dbCloseArea())
	RestArea(aArea)

Return aRet

/*{Protheus.doc} OGC110UPDC
//Fun��o responsavel por atualizar a temp table referente ao browse
com o valor de calculo reajustado.
@author roney.maia
@since 30/01/2018
@version 1.0
@type function
*/
Static Function OGC110UPDC()

	Local cQuery 	:= ""
	Local cVlrCalc	:= ""

	cQuery := " SELECT SUM(N89_VRCALC) AS N89_VRCALC "
	cQuery +=   " FROM " + RetSqlName("N89") 
	cQuery +=  " WHERE D_E_L_E_T_ = '' " 
	cQuery +=    " AND N89_FILIAL = '" + FwXFilial("N89") + "'"
	cQuery +=    " AND N89_CODCTR = '" + (_cTabCom)->N89_CODCTR + "'"
	cQuery +=    " AND N89_CODCOR = '" + (_cTabCom)->N89_CODCOR + "'"
	cQuery +=    " AND N89_CODCOM = '" + (_cTabCom)->N89_CODCOM + "'"
	cQuery +=    " AND N89_LOJCOR = '" + (_cTabCom)->N89_LOJCOR + "'"
	cQuery +=    " AND N89_CTPMER = '" + (_cTabCom)->N89_CTPMER	+ "'"
	cQuery +=    " AND N89_DTCALC = '" + DtoS((_cTabCom)->N89_DTCALC) + "'"
	
	cVlrCalc := GetDataSql(cQuery) // Busca o valor de soma mais atual

	IF Reclock(_cTabCom, .F.)	// Atualiza a temp table do browse de Comissoes calculadas, na linha ja posicionada			
		(_cTabCom)->N89_VRCALC := cVlrCalc
		(_cTabCom)->(MsUnlock())
	EndIf

Return

/*{Protheus.doc} OGC110GPDC
//Fun��o chama a partir do menu para gerar pedido de compra da comiss�o
@author filipe.olegini
@since 30/01/2018
@version 1.0
@type function
*/
Function OGC110GPDC()
	Local aArea	:= GetArea()
    Local lRet	:= .T.
	
	//somente com status 1 e 5 pode excluir
	If (_cTabCom)->COM_STATUS <> "3" 
		Help('',1, "OGC110GEPED") //Altera��o n�o permitida. Somente comiss�o Aprovada pode gerar pedido de compra.  Aten��o
		lRet	:= .F.
	Else
        Processa({|| lRet := OGC110GPD((_cTabCom)->N89_FILIAL, (_cTabCom)->N89_CODCOM)}, STR0060 + " " + STR0013) //Gerando pedido de compra... Aguarde...
    EndIf
	
	If lRet
		OGC110ALST((_cTabCom)->(RECNO()), (_cTabCom)->N89_FILIAL, (_cTabCom)->N89_CODCOM , "4")
	EndIf
	
    RestArea(aArea)

Return

/*{Protheus.doc} OGC110GPD
//Fun��o responsavel por gerar o pedido de compras para comiss�o
//Fun��o utilizada no AGRXFUN1
@author filipe.olegini
@since 30/01/2018
@version 1.0
@type function
*/
Function OGC110GPD(cFil, cCodCom)
	Local aArea		:= GetArea()
    Local aAreaN89	:= N89->(GetArea())
	Local cNum		:=	""
	Local aCab 		:= {}
	Local aItens 	:= {}
	Local aLinha 	:= {}
	Local aCabEx	:= {} //variaveis para controlar a exclusao
	Local aItmEx	:= {} //variaveis para controlar a exclusao
	Local nEx		:= 0
	Local cQuery	:= ""
	Local cTMP01    := GetNextAlias()
	Local cFilAntSv := ""
	Local cTes		:= SuperGetMv("MV_AGRO020")
	Local cProduto	:= SuperGetMv("MV_AGRO021")
	Local cCondPg	:= SuperGetMv("MV_AGRO022")
	Local isAlcada	:= ISINCALLSTACK('AGRXCOM8')
	Local lOGC110C7 := ExistBlock("OGC110C7")
	Local cUsrName  := UsrRetName(RetCodUsr())
	
	If Empty(cTes) .OR. Empty(cProduto) .OR. Empty(cCondPg)
		
		//se for via controle de alcadas, envia email para n�o apresentar na tela de aprova��o as consistencias
		If isAlcada
			OGC110MAIL(cCodCom, UsrRetName(RetCodUsr()), STR0066) //Ocorreu problema ao gerar o pedido de compras. Favor gerar os pedidos atrav�s da rotina de comiss�o no m�dulo Agroindustria.	
		Else
			Help('',1, "OGC110NOPAR") //Problema gera��o do pedido de compra ## Realiza o cadastros dos parametros MV_AGRO020 / MV_AGRO021 / MV_AGRO022 
		EndIf
		
		Return .F.
	EndIf
	
	//Faz o for por filial de romaneio
	cQuery := "SELECT N89.N89_FILIAL, "
	cQuery +=       " N89.N89_CODCOM, "
	cQuery +=       " N89.N89_FILROM, "
	cQuery +=       " N89.N89_CODCOR, "
	cQuery +=       " N89.N89_LOJCOR, "
	cQuery +=       " N89.N89_CMOEDA, "
	cQuery +=       " N89.N89_TXMOED, "
	cQuery +=       " SUM(N89.N89_VRCALC) AS N89_VRCALC "
	cQuery +=  " FROM  " + RetSqlname("N89") + " N89 "
	cQuery += " WHERE N89.D_E_L_E_T_ = '' "
	cQuery +=   " AND N89.N89_FILIAL = '" + cFil + "'" 
	cQuery +=   " AND N89.N89_CODCOM = '" + cCodCom + "'"
	cQuery += " GROUP BY N89.N89_FILIAL, N89.N89_CODCOM, N89.N89_FILROM, N89.N89_CODCOR, "
	cQuery += "          N89.N89_LOJCOR, N89.N89_CMOEDA, N89.N89_TXMOED "
	cQuery += " ORDER BY N89.N89_FILROM "
	
	cQuery := ChangeQuery( cQuery )
	
	If Select(cTMP01) <> 0
		(cTMP01)->(dbCloseArea())
	EndIf
				
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cTMP01,.T.,.T.)
	
	While (cTMP01)->(!EOF())
		 
		 //zera arrays
		 aCab 		:= {}
		 aItens 	:= {}
		 aLinha 	:= {}
		
		//troca a filial para a filial do romaneio
		cFilAntSv	:= cFilAnt
		cFilAnt		:= (cTMP01)->N89_FILROM	
		
		//busca o proximo numero de pedido de compra na filial do romaneio
		dbSelectArea("SC7")
		dbSetOrder(1)
		MsSeek(cFilAnt+"ZZZZZZ",.T.)
		dbSkip(-1)
	
		If Empty(SC7->C7_NUM)
			cNum := StrZero(1,TamSX3("C7_NUM")[1])
		Else
			cNum := Soma1(SC7->C7_NUM)
		EndIf			
		
		SC7->(dbCloseArea())
		
		//monta os arrays do pedido de compra
		aCab 	 := {{"C7_NUM"		 , cNum						, Nil},;
					 {"C7_EMISSAO"	 , dDataBase				, Nil},;
					 {"C7_FORNECE"	 , (cTMP01)->N89_CODCOR 	, Nil},;
					 {"C7_LOJA"   	 , (cTMP01)->N89_LOJCOR		, Nil},;
					 {"C7_COND"      , cCondPg   				, Nil},;					       
					 {"C7_TXMOEDA"   , (cTMP01)->N89_TXMOED		, Nil},; 
					 {"C7_CONTATO"   , "OGC110"					, Nil},;
					 {"C7_FILENT"    , cFilAnt					, Nil},;
					 {"C7_MOEDA"     , (cTMP01)->N89_CMOEDA		, Nil},;					 
					 {"ALCADA"	 	 , "S"						, Nil}}  //envia essa linha para nao gerar pedido com alcada
	
		aLinha :=	{{"C7_PRODUTO"	, cProduto					, Nil},;
					 {"C7_QUANT" 	, 1							, Nil},;					 
					 {"C7_PRECO" 	, (cTMP01)->N89_VRCALC		, Nil},;
					 {"C7_TOTAL" 	, (cTMP01)->N89_VRCALC		, Nil},;
					 {"C7_DATPRF"	, dDataBase					, Nil},; 
					 {"C7_TXMOEDA"  , (cTMP01)->N89_TXMOED		, Nil},;               
					 {"C7_MOEDA"    , (cTMP01)->N89_CMOEDA		, Nil},;
					 {"C7_ORIGEM"   , "SIGAAGR"					, Nil},; //envia este campo para bloquear altera��es no pedido de compra
					 {"C7_TES"    	, cTes						, Nil}}
		
		//Ponto de Entrada para envio de informa��es	
		If lOGC110C7
			aRetPeC7 := ExecBlock("OGC110C7",.F.,.F.,{aCab, aLinha})
			If ValType( aRetPeC7 ) == "A" .and. len(aRetPeC7) > 1 .and. ValType( aRetPeC7[1] ) == "A" .and. ValType( aRetPeC7[2] ) == "A"
				aCab   := aClone(aRetPeC7[1])
				aLinha := aClone(aRetPeC7[2])
			EndIf	
		EndIf
						 
		aAdd(aItens,aLinha)                           
		lMsErroAuto := .F.                    
	
		MSExecAuto({|u,v,x,y| MATA120(u,v,x,y)},1,aCab,aItens,3) 
	
		If lMsErroAuto
			
			If !isAlcada
				MostraErro()		
			EndIf
			
			//restaura a filial para exclusao dos pedidos ja gerados
			cFilAnt	:= cFilAntSv
			
			//se algum pedido der errado e ja tiver gerado algum anteriormente
			If Len(aCabEx) > 0
				
				If isAlcada
					OGC110MAIL(cCodCom, cUsrName,STR0066) //Ocorreu problema ao gerar o pedido de commpras. Favor gerar os pedidos atrav�s da rotina de comiss�o no m�dulo Agroindustria.	
				Else
					Help('',1, "OGC110ERRPED") //Problema gera��o do pedido de compra ## Realize a gera��o pela rotina de comiss�o calculada no modulo Agroindustia 
				EndIf
				
				For nEx := 1 To Len(aCabEx)
					lMsErroAuto := .F.                    
					
					cFilAntSv	:= cFilAnt
					cFilAnt		:= aCabEx[nEx][8][2] //utiliza a filial de entrega
					
					MSExecAuto({|u,v,x,y| MATA120(u,v,x,y)},1,aCabEx[nEx],aItmEx[nEx],5)
					If lMsErroAuto
						If !isAlcada
							MostraErro()		
						EndIf				
					EndIf
					
					cFilAnt	:= cFilAntSv
					
				Next nEx
							
			EndIf
			
			RestArea(aArea)
			
			Return .F.
		Else
			//atualiza o status dos registros buscados na soma e vincula o pedido de compra gerado
			dbSelectArea("N89")
            dbSetOrder(3)
            If dbSeek(PadR(AllTrim((cTMP01)->N89_FILIAL),TamSx3('N89_FILIAL')[1] ) + PadR(AllTrim((cTMP01)->N89_CODCOM),TamSx3('N89_CODCOM')[1] ))

                While N89->(!EOF()) .AND. N89->N89_FILIAL == PadR(AllTrim((cTMP01)->N89_FILIAL),TamSx3('N89_FILIAL')[1] );
                                    .AND. N89->N89_CODCOM == PadR(AllTrim((cTMP01)->N89_CODCOM),TamSx3('N89_CODCOM')[1] );
                                    .AND. N89->N89_FILROM == PadR(AllTrim((cTMP01)->N89_FILROM),TamSx3('N89_FILROM')[1] );
                                    .AND. N89->N89_CODCOR == PadR(AllTrim((cTMP01)->N89_CODCOR),TamSx3('N89_CODCOR')[1] );
                                    .AND. N89->N89_LOJCOR == PadR(AllTrim((cTMP01)->N89_LOJCOR),TamSx3('N89_LOJCOR')[1] )

                    If RecLock("N89",.F.)
                        N89->N89_NUMDOC := cNum
                        N89->(msUnLock())
                    EndIf

                    N89->(dbSkip())
                EndDo
            EndIf
			
			//adiciona os arrays numa variavel de controle caso algum pedido de errado para reverter todos.
			aAdd(aCabEx,aCab)
			aAdd(aItmEx,aItens)
			
		EndIf
		
		//restaura a filial
		cFilAnt	:= cFilAntSv
			
		(cTMP01)->(dbSkip())
	EndDo
	
	//Fecha a tabela, caso tenha sido aberta
	If Select(cTMP01) <> 0
		(cTMP01)->(dbCloseArea())
	EndIf
	
	If !isAlcada
		MsgInfo( STR0061 , STR0050 ) //"Pedido(s) de Compra gerado(s) com sucesso!"###"Aten��o"
	EndIf
	
    RestArea(aAreaN89)
	RestArea(aArea)
	
Return .T.


/*{Protheus.doc} OGC110MAIL()
fun��o para enviar e-mail com mensagens referente a comiss�o.
@author filipe.olegini
@since 19/04/2018
@version 12
*/
Static Function OGC110MAIL(cCodCom, cUserSolic, cObs)		
	Local cEmails   	:= ""
	Local nX        	:= 0	
	Local cRemetnt  	:= ""
	Local aMail     	:= {}
	Local aNomeUser 	:= {}
	Local cAssunto  	:= ""
	Local cMesg     	:= ""
	Local cMsgRet   	:= ""
	Local cTMP02    	:= GetNextAlias()	
	Local cQuery		:= ""
	Local cUserAprov	:= ""
	
	//busca o primeiro usu�rio da comiss�o - o correto � ser sempre o mesmo
	cQuery := " SELECT DISTINCT N89_USER "
	cQuery +=   " FROM " + RetSqlname("N89")
	cQuery +=  " WHERE D_E_L_E_T_ = '' "
	cQuery +=    " AND N89_FILIAL = '" + FwXfilial("N89")+ "' "
	cQuery +=    " AND N89_CODCOM = '" + cCodCom + "' "
	
	cQuery := ChangeQuery( cQuery )
	
	If Select(cTMP02) <> 0
		(cTMP02)->(dbCloseArea())
	EndIf
				
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cTMP02,.T.,.T.)
	
	cUserAprov := (cTMP02)->N89_USER
	
	(cTMP02)->(dbCloseArea())
	
	//Busca E-mail Aprovador Busca pelo nome
	PswOrder(2)
	If	PswSeek(cUserAprov)
		aMail := {PswRet(1)[1][14]}
	EndIf
	If !Empty(aMail)
		For nX := 1 To Len(aMail)
			If !Empty(aMail[1])
				cRemetnt += aMail[1] + ";"
			EndIf
		Next
	Endif

	If Empty(cRemetnt)
		MsgAlert(STR0063) //"E-mail n�o foi enviado. Endere�o do remetente n�o foi encontrado." 
		Return 
	EndIf

	//Busca E-mail Solicitante busca pelo nome
	If	PswSeek(cUserSolic)
		aMail 	  := {PswRet(1)[1][14]}
		aNomeUser := {PswRet(1)[1][4]}
	EndIf

	If !Empty(aMail)
		For nX := 1 To Len(aMail)
			If !Empty(aMail[1])
				cEmails += aMail[1] + ";"
			EndIf
		Next
	Endif

	If Empty(cEmails)
		MsgAlert(STR0064) //"E-mail n�o foi enviado. Endere�o do destinat�rio n�o foi encontrado."  
		Return 
	EndIf

	If !Empty(aNomeUser)
		For nX := 1 To Len(aNomeUser)
			cNomUserAp := aNomeUser[1] 
		Next
	Endif

	cMesg := STR0068 + ", <br><br>"
	cMesg += STR0067 + " <br><br>" 
	cMesg += STR0069 + ": " + Alltrim(cCodCom) //Comiss�o
	cMesg += STR0070 + "<br>: " + STR0072 //Situa��o # PROBLEMA
	cMesg += STR0071 + "<br>: "+ Alltrim(cObs) //Obs
	cMesg += "<br><br>" + STR0072 //Atenciosamente
	cMesg += "<br><br> " + 	cNomUserAp
	
	cMsgRet := OGX017MAIL(cAssunto,cEmails,cMesg, cRemetnt, {})		

	If !Empty(cMsgRet)
		MsgAlert(STR0065 + cMsgRet) //"N�o foi poss�vel enviar o e-mail."
		Return 
	EndIf

Return 

