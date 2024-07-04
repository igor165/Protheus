#include "VDFA150.CH" 
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'FWMVCDEF.CH' 

/*/{Protheus.doc} VDFA150
	Controle de Promotores Eleitorais
	@owner Fabricio Amaro
	@author Fabricio Amaro
	@since 08/11/2013
	@version P11 Release 8
/*/
//	project GESTÃO DE PESSOAS E VIDA FUNCIONAL MP-MT (M12RHMP)

Function VDFA150()
	Local oBrowse
	Private cTab := chr(9)
	Private cEnt := chr(13)+chr(10)
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('RIM')
	oBrowse:SetDescription(STR0001)//'Manutenção Promotores Eleitorais'
	oBrowse:DisableDetails()
	oBrowse:Activate()
	
Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0002	ACTION 'VIEWDEF.VDFA150' OPERATION 2 ACCESS 0//'Visualizar'
	ADD OPTION aRotina TITLE STR0003	ACTION 'VIEWDEF.VDFA150' OPERATION 3 ACCESS 0//'Incluir'
	ADD OPTION aRotina TITLE STR0004	ACTION 'VIEWDEF.VDFA150' OPERATION 4 ACCESS 0//'Alterar'
	ADD OPTION aRotina TITLE STR0005	ACTION 'VIEWDEF.VDFA150' OPERATION 5 ACCESS 0//'Excluir'
	ADD OPTION aRotina TITLE STR0006	ACTION 'VIEWDEF.VDFA150' OPERATION 8 ACCESS 0//'Imprimir'
	ADD OPTION aRotina TITLE STR0007	ACTION 'fCargosPro("X")' OPERATION 6 ACCESS 0//'Cargos de Promotores'

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruRIM := FWFormStruct( 1, 'RIM', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oModel
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('VDFA150',/*bPreValidacao*/,{|oModel|VDFA150POS(oModel)},/*{|oModel|VDFA150GRV(oModel)}*/,/*bCancel*/ )
	//oModel := MPFormModel():New('VDFA150',/*bPreValidacao*/,,/*{|oModel|VDFA150GRV(oModel)}*/,/*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'RIMMASTER', /*cOwner*/, oStruRIM, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	
	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( STR0008 )//'Manutenção do Controle de Promotores Eleitorais'
	
	oModel:SetPrimaryKey( { "RIM_FILIAL", "RIM_MAT" } )
	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'RIMMASTER' ):SetDescription( STR0009 )//'Dados do Promotor Eleitoral/'
	
	// Liga a validação da ativacao do Modelo de Dados
	//oModel:SetVldActivate( { |oModel| xValid(oModel) } )
	
Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel( 'VDFA150' )
	// Cria a estrutura a ser usada na View
	Local oStruRIM := FWFormStruct( 2, 'RIM' )
	//Local oStruRIM := FWFormStruct( 2, 'RIM', { |cCampo| VDFA150STRU(cCampo) } )
	Local oView  
	//Local cCampos := {}

	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )
	
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_RIM', oStruRIM, 'RIMMASTER' )
	
	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'TELA' , 100 )
	
	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_RIM', 'TELA' )
	
	//oView:SetViewAction( 'BUTTONOK'    , { |o| Help(,,'HELP',,'Ação de Confirmar ' + o:ClassName(),1,0) } )
	//oView:SetViewAction( 'BUTTONCANCEL', { |o| Help(,,'HELP',,'Ação de Cancelar '  + o:ClassName(),1,0) } )
Return oView


//FUNÇÃO DE VERIFICAÇÃO NA CONFIRMAÇÃO DA ROTINA
Static Function VDFA150POS(oModel)
	Local aArea		 := GetArea()
	Local lRet 		 := .T.
	Local cMsg		 := ""
	Local nOperation := oModel:GetOperation()
	Local cEnt  	 := chr(13)+chr(10)
	Local cCargos 	 := Alltrim(StrTran(GetMv("MV_VDFCAPO"),"/","','"))  //PARAMETRO QUE CONTEM OS CARGOS DE PROMOTORES ELEITORAIS. SEPARE COM "/"
	
	Local RIMComarca := Alltrim(oModel:GetValue('RIMMASTER','RIM_COMARC'))
	Local RIMFilial  := cFilAnt
	Local RIMMat  	 := Alltrim(oModel:GetValue('RIMMASTER','RIM_MAT'))
	Local RIMDtIni   := (oModel:GetValue('RIMMASTER','RIM_DTINI'))
	Local RIMDtFim   := (oModel:GetValue('RIMMASTER','RIM_DTFIM'))
	
	Local cCargoFunc := POSICIONE("SRA",1,RIMFilial + RIMMat,"RA_CARGO")
	
	If (!Empty(RIMDtIni) .AND. Empty(RIMDtFim)) .OR. (Empty(RIMDtIni) .AND. !Empty(RIMDtFim)) .OR. RIMDtIni > RIMDtFim
		Help(,,STR0010,,STR0021,1,0)//"Problema"    "Periodo Inválido. Verifique se as datas de Inicio e fim são validas."                                                                                                                                                                                                                                                                                                                                                                                                                                              "                                                                                                                                                                                                                                                                                                                                                                                                                                                
		Return .F. 
	EndIf
	
	If nOperation == 3 .OR. nOperation == 4 //INCLUIR OU ALTERAR
		
		//Verifica se já existe informação para esse promotor nessa mesma data nessa mesma comarca
		cQryTmp := " SELECT * FROM " + RETSQLNAME("RIM") 
		cQryTmp += " WHERE RIM_FILIAL = '"+RIMFilial+"' "
		cQryTmp += " AND RIM_MAT = '"+RIMMat+"' "
		cQryTmp += " AND RIM_COMARC = '"+RIMComarca+"' "
		cQryTmp += " AND RIM_DTINI = '"+DTOS(RIMDtIni)+"' " 
		cQryTmp += " AND D_E_L_E_T_ = ' '"
		If nOperation == 4
			cQryTmp += " AND R_E_C_N_O_ <> "+alltrim(str(RIM->(recno())))
		EndIf
		//EXECUTA A SELEÇÃO DE DADOS 		
		cQryTmp := ChangeQuery(cQryTmp)
		dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQryTmp), 'XTEMP', .F., .T. )
		If !XTEMP->(Eof())
			Help(,,STR0010,,STR0011,1,0)//"Problema"    "Já existe um lançamento para esse membro/servidor, nessa mesma Comarca e Data!"
			XTEMP->(DbCloseArea())
			Return .F.
		EndIf
		XTEMP->(DbCloseArea())

		//VERIFICA SE O SERVIDOR/MEMBRO QUE ESTÁ SENDO INFORMADO POSSUI O CARGO DE PROMOTOR
		If !(cCargoFunc $ cCargos)
			cCargos := fCargosPro("M",1)
			If !(MsgBox(STR0012 + cEnt + cEnt + ; //"Atenção! O servidor/membro informado não possui o cargo que esteja na lista de cargos indicados como Promotores."
						STR0013 + cCargoFunc + " - " + Alltrim(Posicione("SQ3",1,XFILIAL("SQ3")+cCargoFunc,"Q3_DESCSUM")) + cEnt + cEnt + ; //"Cargo atual: "
						STR0014 + cEnt + cEnt + ; //"Cargos de Promotores: "
						left(cCargos,len(cCargos)-3) + cEnt + cEnt + ;
						STR0015;  //  //"Deseja realmente continuar?"
						,STR0016,"YESNO")) //"Cargos x Promotores"
				Help(,,STR0010,,STR0017,1,0)//"Problema"   'Por favor, informe os dados corretamente!'
				Return .F.
			EndIf 
		EndIf

		//AGORA VERIFICA SE O PROXIMO DA LISTA NÃO FOR O QUE ESTÁ SENDO INCLUIDO, AVISA O USUÁRIO
		aProx := fProxEleit(RIMComarca)
		If !(Empty(aProx))
			If !((aProx[1][1] + aProx[1][2]) == (RIMFilial + RIMMat))
				
				If !(MsgBox(STR0018 + cEnt + cEnt + ;  //"Atenção! O promotor informado não é o próximo da lista de espera para essa Comarca. Próximo: "
							aProx[1][1] + "/" + aProx[1][2] + " - " + alltrim(aProx[1][3]) + cEnt + cEnt + ;
							STR0015 ;//"Deseja realmente continuar?";
							,STR0019,"YESNO"))  //"Lista de Espera"
					Help(,,STR0010,,STR0017,1,0)//"Problema"   'Por favor, informe os dados corretamente!'
					Return .F.
				EndIf 
			EndIf
		EndIf
	EndIf
	RestArea( aArea )
Return lRet


/*/{Protheus.doc} fProxEleit()
	Verifica o proximo promotor da lista de espera
	@owner Fabricio Amaro
	@author Fabricio Amaro
	@since 11/11/2013
	@version P11 Release 8
/*/
//	project GESTÃO DE PESSOAS E VIDA FUNCIONAL MP-MT (M12RHMP)
//Indique apenas a Comarca, e a função irá retornar um Array contendo o próximo promotor da lista de espera
// com base nas regras específicas do MP-MT
Function fProxEleit(cComarca)
	Local aArea	  := GetArea()
	Local aRet 	  := {}
	Local cOrdena := cOrdena2 := cAsOrdem := cAsOrdem2 := cDB2 := cSelect := " "
	Local lOracle := .F.
	Default cComarca := ""
	
	cCargos := Alltrim(StrTran(GetMv("MV_VDFCAPO"),"/","','"))  //PARAMETRO QUE CONTEM OS CARGOS DE PROMOTORES ELEITORAIS. SEPARE COM "/"
	
	If "MSSQL" $ AllTrim(Upper(TcGetDb())) .Or. AllTrim(Upper(TcGetDb())) == 'SYBASE' 
		cSelect	 := " SELECT TOP 1 "
		cOrdena	 := " ORDENACAO_DATA = "
		cOrdena2 := " ORDENA_R3DATA = "
	ElseIf "ORACLE" $ AllTrim(Upper(TcGetDb()))
		lOracle   := .T.
		cSelect	  := " SELECT "
		cAsOrdem  := " AS ORDENACAO_DATA "
		cAsOrdem2 := " AS ORDENA_R3DATA "
	ElseIf "DB2" $ AllTrim(Upper(TcGetDb()))
		cSelect	  := " SELECT "
		cDB2 	  := " FETCH FIRST 1 ROWS ONLY "
		cAsOrdem  := " AS ORDENACAO_DATA "
		cAsOrdem2 := " AS ORDENA_R3DATA "
	ElseIf  AllTrim(Upper(TcGetDb())) $ "MYSQL/POSTGRES"
		cSelect	  := " SELECT "
		cDB2 	  := " LIMIT 1 "
		cAsOrdem  := " AS ORDENACAO_DATA "
		cAsOrdem2 := " AS ORDENA_R3DATA "
	EndIf

	cQryTmp := " SELECT RA_FILIAL, RA_MAT , RA_NOME , RA_DEPTO , QB_COMARC, " 
	cQryTmp += " ( "+cSelect + If(lOracle," MAX(RE_DATA) "," RE_DATA ") + " FROM "+ RETSQLNAME("SRE") +" SRE WHERE RE_FILIALP = RA_FILIAL AND RE_MATP = RA_MAT AND RE_DEPTOP  = RA_DEPTO AND RE_DEPTOD <> RE_DEPTOP AND SRE.D_E_L_E_T_ = ' ' " + If(lOracle," "," ORDER BY RE_DATA DESC "+cDB2) + ") AS RE_DATA , "
	cQryTmp += cOrdena 
	cQryTmp += " CASE "
	cQryTmp += " 	WHEN ( "+cSelect + If(lOracle," MAX(RE_DATA) "," RE_DATA ") + " FROM "+ RETSQLNAME("SRE") +" SRE WHERE RE_FILIALP = RA_FILIAL AND RE_MATP = RA_MAT AND RE_DEPTOP  = RA_DEPTO AND RE_DEPTOD <> RE_DEPTOP AND SRE.D_E_L_E_T_ = ' ' "+ If(lOracle," " ," ORDER BY RE_DATA DESC "+cDB2) + " ) IS NULL THEN RA_ADMISSA "
	cQryTmp += " 	ELSE ( "+cSelect + If(lOracle," MAX(RE_DATA) "," RE_DATA ") + " FROM "+ RETSQLNAME("SRE") +" SRE WHERE RE_FILIALP = RA_FILIAL AND RE_MATP = RA_MAT AND RE_DEPTOP  = RA_DEPTO AND RE_DEPTOD <> RE_DEPTOP AND SRE.D_E_L_E_T_ = ' ' "+ If(lOracle," " ," ORDER BY RE_DATA DESC "+cDB2) + " ) 
	cQryTmp += " END "
	cQryTmp += cAsOrdem + " , "
	cQryTmp += " ( "+cSelect+ If(lOracle," MAX(RIM_COMARC || SUBSTR(MAX(RIM_DTFIM),1,0)) "," RIM_COMARC ")+ " FROM "+ RETSQLNAME("RIM") +" RIM WHERE RIM_FILIAL = RA_FILIAL AND RIM_MAT = RA_MAT AND RIM.D_E_L_E_T_ = ' ' "+ If(lOracle," GROUP BY RIM_COMARC "," ORDER BY RIM_DTFIM DESC " + cDB2) + " ) AS RIM_COMARC , "
	cQryTmp += " ( "+cSelect+ If(lOracle," MAX(RIM_DTINI  || SUBSTR(MAX(RIM_DTFIM),1,0)) "," RIM_DTINI ") + " FROM "+ RETSQLNAME("RIM") +" RIM WHERE RIM_FILIAL = RA_FILIAL AND RIM_MAT = RA_MAT AND RIM.D_E_L_E_T_ = ' ' "+ If(lOracle," GROUP BY RIM_DTINI  "," ORDER BY RIM_DTFIM DESC " + cDB2) + " ) AS RIM_DTINI  , "
	cQryTmp += " ( CASE "
	cQryTmp += "    WHEN ( "+cSelect+ If(lOracle," MAX(RIM_DTFIM) "," RIM_DTFIM ")+ " FROM "+ RETSQLNAME("RIM") +" RIM WHERE RIM_FILIAL = RA_FILIAL AND RIM_MAT = RA_MAT AND RIM.D_E_L_E_T_ = ' ' "+ If(lOracle," "," ORDER BY RIM_DTFIM DESC " + cDB2) + " ) IS NULL THEN ' ' "
	cQryTmp += "    ELSE ( "+cSelect+ If(lOracle," MAX(RIM_DTFIM) "," RIM_DTFIM ")+ " FROM "+ RETSQLNAME("RIM") +" RIM WHERE RIM_FILIAL = RA_FILIAL AND RIM_MAT = RA_MAT AND RIM.D_E_L_E_T_ = ' ' "+ If(lOracle," "," ORDER BY RIM_DTFIM DESC " + cDB2) + " )  "
	cQryTmp += "   END ) AS RIM_DTFIM  , "
	cQryTmp += " RA_TABELA , RA_TABNIVE , RA_TABFAIX , "
	cQryTmp += " ( "+cSelect + If(lOracle," MIN(R3_DATA) "," R3_DATA ") + " FROM "+ RETSQLNAME("SR3") +" SR3 WHERE R3_FILIAL = RA_FILIAL AND R3_MAT = RA_MAT AND R3_TABELA = RA_TABELA AND R3_TABNIVE = RA_TABNIVE AND R3_TABFAIX = RA_TABFAIX AND SR3.D_E_L_E_T_ = ' ' "+ If(lOracle," "," ORDER BY R3_DATA "+cDB2) + " ) AS R3_DATA , "
	cQryTmp += cOrdena2
	cQryTmp += " CASE "
	cQryTmp += " 	WHEN ( "+cSelect + If(lOracle," MIN(R3_DATA) "," R3_DATA ") + " FROM "+ RETSQLNAME("SR3") +" SR3 WHERE R3_FILIAL = RA_FILIAL AND R3_MAT = RA_MAT AND R3_TABELA = RA_TABELA AND R3_TABNIVE = RA_TABNIVE AND R3_TABFAIX = RA_TABFAIX AND SR3.D_E_L_E_T_ = ' ' "+ If(lOracle," "," ORDER BY R3_DATA "+cDB2)+ " ) IS NULL THEN RA_ADMISSA "
	cQryTmp += " 	ELSE ( "+cSelect + If(lOracle," MIN(R3_DATA) "," R3_DATA ") + " FROM "+ RETSQLNAME("SR3") +" SR3 WHERE R3_FILIAL = RA_FILIAL AND R3_MAT = RA_MAT AND R3_TABELA = RA_TABELA AND R3_TABNIVE = RA_TABNIVE AND R3_TABFAIX = RA_TABFAIX AND SR3.D_E_L_E_T_ = ' ' "+ If(lOracle," "," ORDER BY R3_DATA "+cDB2)+ " ) "
	cQryTmp += " END "
	cQryTmp += cAsOrdem2 + " , "
	cQryTmp += " RA_ADMISSA , RA_NASC "
	cQryTmp += " FROM "+ RETSQLNAME("SRA") +" SRA "
	cQryTmp += " INNER JOIN "+ RETSQLNAME("SQB") +" SQB ON RA_DEPTO   = QB_DEPTO  AND SQB.D_E_L_E_T_ = ' ' "
	cQryTmp += " WHERE SRA.D_E_L_E_T_ = ' ' "
	cQryTmp += " AND SRA.RA_SITFOLH <> 'D' "
	cQryTmp += " AND SRA.RA_CARGO IN ('"+cCargos+"') "
	cQryTmp += " AND QB_COMARC = '"+cComarca+"' "
	cQryTmp += " ORDER BY RIM_DTFIM , ORDENA_R3DATA,ORDENACAO_DATA , RA_TABELA DESC ,RA_TABNIVE DESC , RA_TABFAIX DESC,  RA_NASC "

	//EXECUTA A SELEÇÃO DE DADOS 		
	cQryTmp := ChangeQuery(cQryTmp)
	dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQryTmp), 'XTEMP', .F., .T. )
	If !XTEMP->(Eof())
		While !Eof()
			AADD(aRet,{	XTEMP->RA_FILIAL,;
						XTEMP->RA_MAT,;
						XTEMP->RA_NOME,;
						XTEMP->RA_DEPTO,;
						XTEMP->QB_COMARC,;
						XTEMP->RE_DATA,;
						XTEMP->ORDENACAO_DATA,;
						XTEMP->RIM_COMARC,;
						XTEMP->RIM_DTINI,;
						XTEMP->RIM_DTFIM,;
						XTEMP->RA_TABELA,;
						XTEMP->RA_TABNIVE,;
						XTEMP->RA_TABFAIX,;
						XTEMP->R3_DATA,;
						XTEMP->ORDENA_R3DATA,;
						XTEMP->RA_ADMISSA,;
						XTEMP->RA_NASC;
						})
			dbSkip()
		EndDO
	EndIf
	XTEMP->(DbCloseArea())
	RestArea( aArea )
Return aRet


/*/{Protheus.doc} fCargosPro()
	Apresenta os cargos de promotores, com base no parametro MV_VDFCAPO
	@owner Fabricio Amaro
	@author Fabricio Amaro
	@since 11/11/2013
	@version P11 Release 8
/*/
//	project GESTÃO DE PESSOAS E VIDA FUNCIONAL MP-MT (M12RHMP)
// cRet = A = Retornar o Array  |  M = Retornar um texto com os cargos   |  X = Consulta ao parametro MV_VDFCAPO

Function fCargosPro(cRet)
	Local aArea	:= GetArea()
	Local aRet 	:= {}
	Local cEnt  := chr(13) + chr(10)
	Local cCargos := Alltrim(StrTran(GetMv("MV_VDFCAPO"),"/","','"))  //PARAMETRO QUE CONTEM OS CARGOS DE PROMOTORES ELEITORAIS. SEPARE COM "/"
	Local cMsgCargos := ""
	
	cQryTmp := " SELECT * FROM " + RETSQLNAME("SQ3") 
	cQryTmp += " WHERE Q3_CARGO IN ('"+cCargos+"') "
	cQryTmp += " AND D_E_L_E_T_ = ' ' ORDER BY Q3_CARGO "

	//EXECUTA A SELEÇÃO DE DADOS 		
	cQryTmp := ChangeQuery(cQryTmp)
	dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQryTmp), 'XTEMP', .F., .T. )
	If !XTEMP->(Eof())
		While !Eof()
			AADD(aRet,{	XTEMP->Q3_CARGO,;
						XTEMP->Q3_DESCSUM;
						})
			cMsgCargos += 	XTEMP->Q3_CARGO + " - " + 	XTEMP->Q3_DESCSUM + cEnt
			dbSkip()
		EndDO
	EndIf
	XTEMP->(DbCloseArea())

	If cRet == "X"
		MsgInfo(cMsgCargos,STR0020)  ///"Cargos - MV_VDFCAPO"
	EndIf
	
	RestArea( aArea )
	
	If cRet == "A"
		Return aRet
	ElseIf cRet == "M"
		Return cMsgCargos
	EndIf
Return