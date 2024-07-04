#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FWBrowse.ch'
#Include 'OGC090.ch'

#DEFINE CRLF CHR(13)+CHR(10)
Static __oMBrowse 	:= Nil
Static __aCpsBrow	:= {}
Static __oArqTemp   := Nil

/*{Protheus.doc} OGC090
Painel de comissões
@author 	marcelo.wesan
@since 		14/09/2017
@version 	1.0
*/
Function OGC090()
	Local aColumns		:= {}
	Local aWdCol        := {}
	Private aRotina     := MenuDef()
	Private _cQueryRel  := ""
	Private _cTabPen	:= ""

	If !(SuperGetMv('MV_AGRA001', , .F.))
		Help(" ",1,"OGC010AGRA001") //O parâmetro MV_AGRA001(Novo Conceito UBA) está desativado.
		Return(.F.)
	Endif

	//--Cria Browser
	__oMBrowse := FWMBrowse():New()		//--Fornece um objeto do tipo grid que permite a exibição de dados do tipo array, texto, tabela e query.

	aColumns  := OGC090COL()			//--Cria campos para browser
	_cTabPen := OGC090TAB() 			//--Cria a tabela temporaria com os campos informando no array "__aCpsBrow"
    lContinua := OGC090REG(.F.) 		//--Carrega a tabela temporaria caso possua informações gravadas

	//--Se retorno dos registros for
	If lContinua
	    __oMBrowse:SetAlias(_cTabPen) 
	    __oMBrowse:AddLegend( "(_cTabPen)->STATUS == '1'"	, "BR_VERMELHO"	    , STR0007) //Pendente Calculo
		__oMBrowse:AddLegend( "(_cTabPen)->STATUS == '2'"	, "BR_AMARELO"		, STR0008)//Calculado Parcial
		__oMBrowse:AddLegend( "(_cTabPen)->STATUS == '3'"	, "BR_VERDE"		, STR0009)  //Calculado										//--Indica o alias da tabela que será utilizada no Browse
		__oMBrowse:SetColumns(aColumns)										    //--Indica os campos que serão adicionados as colunas do Browse.
	    __oMBrowse:SetDescription(STR0001)			 	                        //--Indica a descrição do Browse
	    __oMBrowse:SetMenuDef("OGC090")									        //--Indica o programa que será utilizado para a carga do menu funcional
		__oMBrowse:SetAmbiente(.F.)												//--Indica se habilita a utilização da funcionalidade Walk-Thru no Browse
		__oMBrowse:SetDataTable(.T.)											//--Indica se a tabela é de formato Alias
		__oMBrowse:SetTemporary(.T.)
		__oMBrowse:SetOnlyFields({'*'})
		__oMBrowse:SetWidthColumns(aWdCol)
		
		__oMBrowse:Activate()
	EndIf

	//remove a temp-table
	AGRDLTPTB(__oArqTemp)
Return

/*{Protheus.doc} OGC090VRO
Guarda o contrato em variável
@author 	marcelo.wesan
@since 		14/09/2017
@version 	1.0
@return 	aRotina - Array - Array com as opções disponiveis de ações relacionadas
*/
Function OGC090VRO()

	OGC100VROM(xFilial("NJR"),(_cTabPen)->CONTRATO, (_cTabPen)->NOMFOR, (_cTabPen)->LJCOR, (_cTabPen)->TPCOM)
	
	OGC090REG()
Return
/*{Protheus.doc} MenuDef
Função de Menu
@author 	marcelo.wesan
@since 		14/09/2017
@version 	1.0
@return 	aRotina - Array - Array com as opções disponiveis de ações relacionadas
*/
Static Function MenuDef()
	Local aRotina 	:= {}

	aAdd( aRotina,{STR0002 ,"OGC090VRO()",0,4,0,.F.})	//"Simular"

Return( aRotina )

/*{Protheus.doc} OGC090COL
Função Tela Temporaria
@author 	marcelo.wesan
@since 		14/09/2017
@version 	1.0
@return 	aColumns - Array - Array com os campos da tela
*/
Static Function OGC090COL(  )
	Local aColumns		:= {}	
	Local nX			:= {}

    //-------------    [1]         [2]                        [3]                         [4]                         [5] 			            [6]
	__aCpsBrow := { {" " , "STATUS"	, "C"	, 1	, 0, '@!'},;
	                {STR0003 ,                 "CONTRATO", TamSX3( "NJR_CODCTR" )[3], TamSX3( "NJR_CODCTR" )[1]	, TamSX3( "NJR_CODCTR" )[2]	, PesqPict("NJR","NJR_CODCTR") 	},;	
                    {AgrTitulo("NJR_TIPMER") , "TIPMER"	, TamSX3( "NJR_TIPMER" )[3]	, 07						, TamSX3( "NJR_TIPMER" )[2]	, PesqPict("NJR","NJR_TIPMER") 	},;
                    {AgrTitulo("NJR_CODENT") , "CODENT"	, TamSX3( "NJR_CODENT" )[3]	, TamSX3( "NJR_CODENT" )[1]	, TamSX3( "NJR_CODENT" )[2]	, PesqPict("NJR","NJR_CODENT") 	},;
		            {AgrTitulo("NJR_LOJENT") , "LOJENT"	, TamSX3( "NJR_LOJENT" )[3]	, TamSX3( "NJR_LOJENT" )[1]	, TamSX3( "NJR_LOJENT" )[2]	, PesqPict("NJR","NJR_LOJENT") 	},;
		            {AgrTitulo("NJR_NOMENT") , "NOMENT"	, TamSX3( "NJR_NOMENT" )[3]	, TamSX3( "NJR_NOMENT" )[1]	, TamSX3( "NJR_NOMENT" )[2]	, PesqPict("NJR","NJR_NOMENT") 	},;
		            {AgrTitulo("NNF_CODENT") , "NOMFOR"	, TamSX3( "NNF_CODENT" )[3]	, TamSX3( "NNF_CODENT" )[1]	, TamSX3( "NNF_CODENT" )[2]	, PesqPict("NNF","NNF_CODENT") 	},;
                    {AgrTitulo("NNF_LOJENT") , "LJCOR"	, TamSX3( "NNF_LOJENT" )[3]	, TamSX3( "NNF_LOJENT" )[1]	, TamSX3( "NNF_LOJENT" )[2]	, PesqPict("NNF","NNF_LOJENT") 	},;
                    {AgrTitulo("NNF_NOMENT") , "NOMCOR"	, TamSX3( "NNF_NOMENT" )[3]	, TamSX3( "NNF_NOMENT" )[1]	, TamSX3( "NNF_NOMENT" )[2]	, PesqPict("NNF","NNF_NOMENT") 	},;
                    {AgrTitulo("NNF_CDCORR") , "CDCORR"	, TamSX3( "NNF_CDCORR" )[3]	, TamSX3( "NNF_CDCORR" )[1]	, TamSX3( "NNF_CDCORR" )[2]	, PesqPict("NNF","NNF_CDCORR") 	},;
                    {AgrTitulo("NNF_NMCORR") , "NMCORR"	, TamSX3( "NNF_NMCORR" )[3]	, TamSX3( "NNF_NMCORR" )[1]	, TamSX3( "NNF_NMCORR" )[2]	, PesqPict("NNF","NNF_NMCORR") 	},; 
                    {AgrTitulo("NNF_MODCOM") , "TPCOM"	, TamSX3( "NNF_MODCOM" )[3]	, 35						, TamSX3( "NNF_MODCOM" )[2]	, PesqPict("NNF","NNF_MODCOM") 	},;
                    {AgrTitulo("NJR_CODSAF") , "SAFRA"	, TamSX3( "NJR_CODSAF" )[3]	, TamSX3( "NJR_CODSAF" )[1]	, TamSX3( "NJR_CODSAF" )[2]	, PesqPict("NJR","NJR_CODSAF") 	},;
                    {AgrTitulo("NJR_CODPRO") , "PRODUTO", TamSX3( "NJR_CODPRO" )[3]	, TamSX3( "NJR_CODPRO" )[1]	, TamSX3( "NJR_CODPRO" )[2]	, PesqPict("NJR","NJR_CODPRO") 	},;
                    {AgrTitulo("NJR_DESPRO") , "DESCPRO", TamSX3( "NJR_DESPRO" )[3]	, TamSX3( "NJR_DESPRO" )[1]	, TamSX3( "NJR_DESPRO" )[2]	, PesqPict("NJR","NJR_DESPRO") 	}}
		           
	// Montando a coluna para tela
	For nX	:= 2 To Len(__aCpsBrow)

		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+__aCpsBrow[nX][2]+"}"))			//--Coluna da Temporaria
		aColumns[Len(aColumns)]:SetTitle(__aCpsBrow[nX][1]) 	//--Titulo da Coluna
		aColumns[Len(aColumns)]:SetSize(__aCpsBrow[nX][4])		//--Tamanho do Campo
		aColumns[Len(aColumns)]:SetDecimal(__aCpsBrow[nX][5])	//--Tamanho do Decimal
		aColumns[Len(aColumns)]:SetPicture(__aCpsBrow[nX][6])	//--Picture
		aColumns[Len(aColumns)]:SetAlign(CONTROL_ALIGN_LEFT)	//--Define alinhamento
	Next

Return(aColumns)


/*{Protheus.doc} OGC090TAB
Função para realizar a criação da tabela temporária
@author 	marcelo.wesan
@since 		14/09/2017
@version 	1.0
@return 	cTabela 	- Caracter	- Retorna a tabela criada
*/
Function OGC090TAB()
    Local nCont 	:= 0
    Local cTabela	:= ''
	Local aStrTab 	:= {}	//Estrutura da tabela

    //-- Busca no __aCpsBrow as propriedades para criar as colunas
    For nCont := 1 to Len(__aCpsBrow)
        aADD(aStrTab,{__aCpsBrow[nCont][2], __aCpsBrow[nCont][3], __aCpsBrow[nCont][4], __aCpsBrow[nCont][5] })
    Next nCont
   	//-- Tabela temporaria de pendencias
   	cTabela  := GetNextAlias()
   	//-- A função AGRCRTPTB está no fonte AGRUTIL01 - Funções Genericas
    __oArqTemp := AGRCRTPTB(cTabela, {aStrTab, {{"","CONTRATO,NOMFOR,TPCOM"}}})

Return cTabela

/*{Protheus.doc} OGC090REG
Função para realizar a busca dos registros para consulta
@author 	marcelo.wesan
@since 		14/09/2017
@version 	1.0
@param
*/
Function OGC090REG()

    Local aArea     := GetArea()
	Local cTemp 	:= GetNextAlias()
	Local cQuery    := ""
	Local aQuery    := {}
	Local cTipoCom  := ""
	Local cStatus   := " "
	Local lExibe    := .T.

	//--Deleta tudo da temporaria para realizar nova busca
	DbSelectArea((_cTabPen))
	DbGoTop()
	If DbSeek((_cTabPen)->CONTRATO)
		While .Not. (_cTabPen)->(Eof())
			If RecLock((_cTabPen),.f.)
				(_cTabPen)->(DbDelete())
				(_cTabPen)->(MsUnlock())
			EndIf
			(_cTabPen)->( dbSkip() )
		EndDo
	EndIF

	//--Query dados para consulta
	cQuery := " SELECT DISTINCT NNF.NNF_FILIAL, NNF.NNF_STATUS, NNF.NNF_CODCTR, NJR.NJR_TIPMER, "
	cQuery +=        " NNF.NNF_MODCOM, NNF.NNF_CDCORR, NNF.NNF_CODENT, "
	cQuery +=        " NJR.NJR_CODSAF, NJR.NJR_CODPRO, NJR.NJR_CODENT, "
	cQuery +=        " NJR.NJR_LOJENT, NJR.NJR_STATUS, NJR.NJR_CODCTR, N9A.N9A_OPEFUT,"
	aAdd(aQuery, cQuery)	
	cQuery := "(SELECT COUNT(*) TOTAL"
	cQuery += " FROM " + RetSqlName("NJJ") + " NJJ" //ROMANEIOS
	cQuery += " WHERE NJJ.D_E_L_E_T_ 	= '' "
	cQuery +=                                      " AND NJJ.NJJ_FILIAL = '"+xFilial("NJJ")+"'"
	cQuery +=  									   " AND NJJ.NJJ_CODCTR =  NNF.NNF_CODCTR )TOTAL,
    aAdd(aQuery, cQuery)
    cQuery := aQuery[1] + aQuery[2]
    _cQueryRel := aQuery[1] + aQuery[2]
    cQuery += " (SELECT COUNT(DISTINCT NJJ_CODROM) CORRETOR"
    cQuery += " FROM " + RetSqlName("NJJ") + " NJJ"
	cQuery += " INNER JOIN " + RetSqlName("N89") + " N89 ON N89.D_E_L_E_T_ = '' "
	cQuery +=  									   " AND N89.N89_FILIAL = '"+xFilial("N89")+"'"
	cQuery +=  									   " AND N89.N89_CODROM = NJJ.NJJ_CODROM "
	cQuery += " WHERE NJJ.D_E_L_E_T_ 	= '' "
	cQuery +=                                      " AND NJJ.NJJ_FILIAL = '"+xFilial("NJJ")+"'"
	cQuery +=                                      " AND NJJ.NJJ_CODCTR = NJR.NJR_CODCTR "
	cQuery +=                                      " AND (N89.N89_CODCOR =  NNF.NNF_CODENT) "                              
	cQuery +=  									   " AND (N89_CODROM IS NOT NULL OR N89_CODROM <> ''))CORRETOR "
        
	cQuery += " FROM " + RetSqlName("NNF") + " NNF" //CORRETOR CONTRATO
	
	cQuery += " INNER  JOIN " + RetSqlName("NJR") + " NJR ON NJR.D_E_L_E_T_ = '' "
	cQuery +=  									   " AND NJR.NJR_FILIAL = '"+xFilial("NJR")+"'"
	cQuery +=  									   " AND NNF.NNF_CODCTR = NJR.NJR_CODCTR "	
	
	cQuery += " INNER  JOIN " + RetSqlName("NNY") + " NNY ON NNY.D_E_L_E_T_ = '' "
	cQuery +=  									   " AND NNY.NNY_FILIAL = '"+xFilial("NNY")+"'"
	cQuery +=  									   " AND NNY.NNY_CODCTR = NNF.NNF_CODCTR "	
	
	cQuery += " INNER  JOIN " + RetSqlName("N9A") + " N9A ON N9A.D_E_L_E_T_ = '' "
	cQuery +=  									   " AND N9A.N9A_FILIAL = '"+xFilial("N9A")+"'"
	cQuery +=  									   " AND N9A.N9A_CODCTR = NNY.NNY_CODCTR "
	cQuery +=  									   " AND N9A.N9A_ITEM   = NNY.NNY_ITEM "	  
	
	cQuery += " INNER  JOIN " + RetSqlName("NJM") + " NJM ON NJM.D_E_L_E_T_ = '' "
	cQuery +=  									   " AND NJM.NJM_FILIAL = '"+xFilial("NJM")+"'"
	cQuery +=  									   " AND NJM.NJM_CODCTR = N9A.N9A_CODCTR "
	cQuery +=  									   " AND NJM.NJM_ITEM =   N9A.N9A_ITEM "		
	cQuery +=  									   " AND NJM.NJM_SEQPRI = N9A.N9A_SEQPRI"		
	
	cQuery += " WHERE NNF.D_E_L_E_T_ 	= '' "
	cQuery +=                                      " AND (NJR.NJR_STATUS = 'A' OR  NJR.NJR_STATUS = 'I')"
	cQuery +=  									   " AND NNF.NNF_FILIAL =  '"+xFilial("NNF")+"'"
	cQuery +=  									   " AND NNF.NNF_TIPCOM IN ('0','1') "	
	cQuery += "GROUP BY NNF.NNF_FILIAL,NNF.NNF_STATUS,NNF.NNF_CODCTR,NJR.NJR_TIPMER,NNF.NNF_MODCOM,NNF.NNF_CDCORR,NNF.NNF_CODENT,NJR.NJR_CODSAF,NJR.NJR_CODPRO,NJR.NJR_CODENT,NJR.NJR_LOJENT,NJR.NJR_STATUS,NJR.NJR_CODCTR,N9A.N9A_OPEFUT"
	
	cQuery := ChangeQuery( cQuery )
	If select(cTemp) <> 0
		(cTemp)->(dbCloseArea())
	EndIf
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cTemp,.T.,.T.)
    
	//--Alimenta a tabela temporária.
	While .Not. (cTemp)->(Eof()) .AND. (cTemp)->NNF_FILIAL == xFilial("NNF")

		If((cTemp)->N9A_OPEFUT == "1")
    		lExibe := OGC090SLDR((cTemp)->NNF_CODCTR)
    	Endif    	 	  

    	If lExibe          
	    
	        cTipoCom := ""
			If (cTemp)->NNF_MODCOM  == '1'
				cTipoCom := STR0004	//"% Valor Contrato"
			ElseIf (cTemp)->NNF_MODCOM   == '2'
				cTipoCom := STR0005	//"Valor"
			ElseIf (cTemp)->NNF_MODCOM   == '3'
				cTipoCom := STR0006	//"Pontos"
			EndIf
            
           (_cTabPen)->(Dbgotop())
           If (_cTabPen)-> (DbSeek((cTemp)->NJR_CODCTR +(cTemp)->NNF_CODENT ))
           		RecLock((_cTabPen),.F.)
			    (_cTabPen)->TPCOM	:= Alltrim( (_cTabPen)->TPCOM ) + '/' + Alltrim(cTipoCom)
				MsUnlock()
			 Else 
			
				If  (cTemp)->TOTAL == 0 .AND. (cTemp)->CORRETOR == 0 
		           cStatus := "1" //Pendente Calculo
		        ElseIf (cTemp)->TOTAL > (cTemp)->CORRETOR .and. (cTemp)->CORRETOR == 0 
		           cStatus := "1" // Pendente Calculo
		        ElseIf (cTemp)->TOTAL > (cTemp)->CORRETOR
		           cStatus := "2"// Calculado Parcial
		        ElseIf (cTemp)->TOTAL == (cTemp)->CORRETOR 
		           cStatus := "3" //Calculado
		        EndIf	
				
				RecLock((_cTabPen),.T.)
				    (_cTabPen)->STATUS	    :=  cStatus 
					(_cTabPen)->CONTRATO	:= (cTemp)->NJR_CODCTR
					(_cTabPen)->TIPMER		:= IIF((cTemp)->NJR_TIPMER == "1",STR0010,STR0011)
					(_cTabPen)->CODENT	    := (cTemp)->NJR_CODENT
					(_cTabPen)->LOJENT	    := (cTemp)->NJR_LOJENT
					(_cTabPen)->NOMENT	    := POSICIONE('NJ0',1,XFILIAL('NJ0')+(cTemp)->NJR_CODENT+(cTemp)->NJR_LOJENT,'NJ0_NOME')
					(_cTabPen)->NOMFOR	    := (cTemp)->NNF_CODENT
					(_cTabPen)->LJCOR	    := POSICIONE('SA2',1,XFILIAL('SA2')+(cTemp)->NNF_CODENT,'A2_LOJA') 
					(_cTabPen)->NOMCOR	    := Posicione('SA2',1,xFilial('SA2')+(cTemp)->NNF_CODENT+(_cTabPen)->LJCOR,'A2_NOME')     
					(_cTabPen)->CDCORR	    := (cTemp)->NNF_CDCORR
					(_cTabPen)->NMCORR	    := Posicione('SU5',1,XFILIAL('SU5')+(cTemp)->NNF_CDCORR,'U5_CONTAT') 
					(_cTabPen)->TPCOM	    := Alltrim(cTipoCom)
					(_cTabPen)->SAFRA	    := (cTemp)->NJR_CODSAF
					(_cTabPen)->PRODUTO		:= (cTemp)->NJR_CODPRO
					(_cTabPen)->DESCPRO		:= Posicione('SB1',1,xFilial('SB1')+(cTemp)->NJR_CODPRO,'B1_DESC')
				MsUnlock()
			EndIf
			
		Endif
		
		lExibe := .T.

		(cTemp)->( dbSkip() )
	EndDo
	(cTemp)->(dbCloseArea())

	(_cTabPen)->(dbGoTop())
	__oMBrowse:UpdateBrowse()
	
	RestArea(aArea)

Return(.T.)

/*{Protheus.doc} OGCSLDR
Função para verificar se não possui mais saldo naRegra Fiscal
@author gustavo.pereira	
@since 15/06/2018
@version 1.0
@return ${return}, ${return_description}
@param cFilCtr, characters, descricao
@param cContrato, characters, descricao
@param cCodCad, characters, descricao
@param cCodRegFis, characters, descricao
@param cQtd, characters, descricao
@type function
*/
function OGC090SLDR(cContrato)
	
	Local cTempN9A 	:= GetNextAlias()
	Local cQuery     	:= ""
	Local lRetorno   	:= .F.
	Local nTotal     	:= 0
	
	//--Query dados para consulta da regra fiscal
	cQuery := " SELECT DISTINCT N9A.N9A_SDONF SLDNF"
	cQuery += " FROM " + RetSqlName("NJM") + " NJM"
	cQuery += " INNER JOIN " + RetSqlName("N9A") + " N9A ON N9A.D_E_L_E_T_ = '' "
	cQuery +=  									   " AND N9A.N9A_FILIAL = '" + xFilial("N9A")+"'"
	cQuery +=  									   " AND N9A.N9A_CODCTR = '" + cContrato +"' "
	cQuery +=  									   " AND NJM.NJM_ITEM   = N9A.N9A_ITEM"
	cQuery +=  									   " AND NJM.NJM_SEQPRI = N9A.N9A_SEQPRI"
	cQuery += " WHERE NJM.D_E_L_E_T_ 	= '' "	
	cQuery +=  									   " AND NJM.NJM_FILIAL = '" + xFilial("NJM")+"'"
	cQuery +=  									   " AND NJM.NJM_CODCTR = '" + cContrato +"' "
	
	cQuery := ChangeQuery( cQuery )
	
	If select(cTempN9A) <> 0
		(cTempN9A)->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cTempN9A,.T.,.T.)	
		
	While .Not. (cTempN9A)->(Eof()) 
		
		nTotal := nTotal + (cTempN9A)->SLDNF	
		
		(cTempN9A)->( dbSkip() )
		
	EndDo		
	
	lRetorno := Iif(nTotal <= 0, .T., .F.)
	
Return lRetorno