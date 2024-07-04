#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'FWBrowse.ch' 
#Include 'FINA027.CH'
 
//-------------------------------------------------------------------
/*/{Protheus.doc} Fina027A()
Importação de retenções previas de INSS do SIGAPLS

@author Mauricio Pequim Jr.
@since 14/04/2015
@version P12.1.4
/*/
//-------------------------------------------------------------------

Function Fina027A()

Local cFunction		:= "FINA027A"
Local cTitle		:= STR0028//"Importação dados SIGAPLS"
Local bProcess		:= {|oSelf,cAlias| F027AATU(oSelf) }	
Local cDescription	:= STR0029//"Importação de débitos e créditos do prestador de serviço referente a salários para o cadastro de prévias de INSS"
Local cPerg			:= "FINA027A"

SetKey( VK_F12, { |a,b| AcessaPerg(cPerg,.T.) } )

Pergunte(cPerg,.F.)
tNewProcess():New(cFunction,cTitle,bProcess,cDescription,cPerg)

SET KEY VK_F12 TO

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F027AATU()
Processamento da importação de retenções previas de INSS do SIGAPLS

@author Mauricio Pequim Jr.
@since 14/04/2015
@version P12.1.4
/*/
//-------------------------------------------------------------------
Function F027AATU(oSelf)

Local cQuery	:= ""
Local cAliasQry	:= ""
Local cCodSer	:= GetNewPar("MV_PLSCIOE","")
local lPLS		:= FWIsInCallStack("PLSA755")
Local cAnoBaseI	:= Iif(lPLS, BGQ->BGQ_ANO, Substr(Dtos(mv_par01),1,4))
Local cAnoBaseF	:= Iif(lPLS, BGQ->BGQ_ANO, Substr(Dtos(mv_par02),1,4))
Local cMesBaseI	:= Iif(lPLS, BGQ->BGQ_MES, Substr(Dtos(mv_par01),5,2))
Local cMesBaseF	:= Iif(lPLS, BGQ->BGQ_MES, Substr(Dtos(mv_par02),5,2))
Local cCodRda	:= ""
Local cAno		:= ""
Local cMes		:= ""
Local cTipo		:= ""
Local cNroPgt	:= ""
Local cFornOld	:= ""
Local cLojaOld	:= ""
Local nValInss	:= 0
Local nPercIns	:= 0
Local dDataIni	:= Iif(lPLS, FirstDay(CToD("01/"+BGQ->BGQ_MES+"/"+BGQ->BGQ_ANO)), FirstDay(mv_par01))
Local dDataFim	:= Iif(lPLS, Lastday(CToD("01/"+BGQ->BGQ_MES+"/"+BGQ->BGQ_ANO)), Lastday(mv_par02))
Local dFirstDay	:= CTOD("//")
Local dLastDay 	:= CTOD("//")
Local dVldFim 	:= CTOD("31/12/"+Substr(Dtos(dDataBase),1,4))
Local lGravou	:=.F.

//BBC
//Seleciona as retenções de INSS

cAliasQry := GetNextAlias()
cQuery := "SELECT BAU_FILIAL, BAU_CODIGO, BAU_CODSA2, BAU_LOJSA2, BBC_CNPJ, BBC_NOME, BBC_VALOR, BBC_VLDINI, "
cQuery += "BBC_VLDFIM, BBC_CODSER, BBC.R_E_C_N_O_ BBCRECNO "
cQuery += "FROM " + RetSQLTab('BAU')
cQuery += "JOIN " + RetSQLTab('BBC')
cQuery += "ON BBC.BBC_CODIGO = BAU.BAU_CODIGO "
cQuery += "WHERE "
cQuery += "BBC_IMPFIN IN (' ','2') AND "
cQuery += "BBC_PROMED = '1' AND "
cQuery += "BBC_STATUS = '1' AND "
cQuery += "BBC_CODSER =  '" + cCodSer + "' AND "
cQuery += "BBC_DEBCRE = '3' AND "
cQuery += "(BBC_VLDINI >= '" + DTOS(dDataIni) + "' OR BBC_VLDINI  = ' ') AND "
cQuery += "(BBC_VLDFIM <= '" + DTOS(dDataFim) + "' OR BBC_VLDFIM  = ' ') AND "
cQuery += RetSqlCond("BAU,BBC")
cQuery += "ORDER BY BAU_FILIAL, BAU_CODIGO"

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
TcSetField(cAliasQry,"BBC_VALOR","N",TamSX3("BBC_VALOR")[1],TamSX3("BBC_VALOR")[2])

dbSelectArea(cAliasQry)

DbGotop()
While !(cAliasQry)->(Eof())
	If !Empty((cAliasQry)->BAU_CODSA2)
		If oSelf <> nil
			oSelf:IncRegua2(STR0030)//"Atualizando Prévias de INSS (BBC)..."
		EndIf
	
		F027PercINS(@cFornOld,@cLojaOld,@nPercIns,(cAliasQry)->BAU_CODSA2,(cAliasQry)->BAU_LOJSA2)
		
		nValInss	:= (cAliasQry)->BBC_VALOR * (nPercIns/100)
		cTipo		:= Posicione("BBB",1,xFilial("BBB")+(cAliasQry)->BBC_CODSER,"BBB_TIPOCT")
		cTipo		:= IIF(cTipo $ "2|3","2","1")
	
		dDataIni	:= IIF(Empty((cAliasQry)->BBC_VLDINI), dDataIni, STOD((cAliasQry)->BBC_VLDINI) )
		dDataFim	:= IIF(Empty((cAliasQry)->BBC_VLDFIM), dVLDFIM , STOD((cAliasQry)->BBC_VLDFIM) )	
	
		//Chamada da função de gravação
		lGravou := F027AIMP((cAliasQry)->BAU_CODSA2	,;	//Codigo do Fornecedor
							(cAliasQry)->BAU_LOJSA2	,;	//Loja
							dDataIni				,;	//Data inicial da retenção
							dDataFim				,;	//Data final da retenção
							(cAliasQry)->BBC_NOME	,;	//Entidade Tomadora   
							cTipo					,;	//Tipo de Pessoa (1=Fisica,2=Juridica)								
							(cAliasQry)->BBC_CNPJ	,;	//CNPJ da Entidade Tomadora   
							(cAliasQry)->BBC_VALOR	,;	//Valor base INSS
							nValInss 				)   		//Valor INSS  
			
		If lGravou
			BBC->(dbGoto((cAliasQry)->BBCRECNO))
			RecLock("BBC")
			BBC->BBC_IMPFIN = '1'	//Importado para o cadastro de Prévias de INSS 
			BBC->BBC_VLDFIM = Iif(Empty(BBC->BBC_VLDFIM),DTOS(dDataFim),BBC->BBC_VLDFIM)			
			MsUnlock()
		Endif
	EndIf
	(cAliasQry)->(DbSkip())
Enddo
(cAliasQry)->(DbCloseArea())

cFornOld	:= ""
cLojaOld	:= ""
nPercIns	:= 0

//BGQ
//Seleciona as retenções de INSS
cAliasQry := GetNextAlias()
cQuery := "SELECT BAU_FILIAL, BAU_CODIGO, BAU_CODSA2, BAU_LOJSA2, BGQ_TIPOCT, BGQ_NOME, BGQ_VALOR, BGQ_MES, BGQ_ANO, BGQ.R_E_C_N_O_ BGQRECNO "  "
cQuery += "FROM " + RetSQLTab('BAU')
cQuery += "JOIN " + RetSQLTab('BGQ')
cQuery += "ON BGQ.BGQ_CODIGO = BAU.BAU_CODIGO "
cQuery += "WHERE "
cQuery += "BGQ_IMPFIN IN (' ','2') AND "
cQuery += "BGQ_ATIVO <> '0' AND "
cQuery += "BGQ_CODLAN =  '" + cCodSer + "' AND "
cQuery += "BGQ_TIPO = '3' AND "
cQuery += "BGQ_OPELOT = ' ' AND "
cQuery += "BGQ_NUMLOT = ' ' AND "
cQuery += "BGQ_ANO||BGQ_MES BETWEEN '" + cAnoBaseI + cMesBaseI + "' AND '" + cAnoBaseF + cMesBaseF + "' AND "
cQuery += RetSqlCond("BAU,BGQ")
cQuery += "ORDER BY BAU_FILIAL, BAU_CODIGO"

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
TcSetField(cAliasQry,"BGQ_VALOR","N",TamSX3("BGQ_VALOR")[1],TamSX3("BGQ_VALOR")[2])

dbSelectArea(cAliasQry)

DbGotop()
While !(cAliasQry)->(Eof())	
	If !Empty((cAliasQry)->BAU_CODSA2)
		If oSelf <> nil
			oSelf:IncRegua2("Atualizando Prévias de INSS (BGQ)...")
		EndIf
	
		cAno		:= (cAliasQry)->BGQ_ANO
		cMes		:= (cAliasQry)->BGQ_MES
		dFirstDay	:= CTOD("01/"+cMes+"/"+cAno)
		dLastDay 	:= LastDay(dFirstDay)
		cTipo		:= IIF((cAliasQry)->BGQ_TIPOCT $ "2|3","2","1")
		
		//Obtém percentual INSS
		F027PercINS(@cFornOld,@cLojaOld,@nPercIns,(cAliasQry)->BAU_CODSA2,(cAliasQry)->BAU_LOJSA2)
		
		nValInss	:= (cAliasQry)->BGQ_VALOR * (nPercIns/100)
			
		//Chamada da função de gravação	ADMIN
		
		lGravou := F027AIMP((cAliasQry)->BAU_CODSA2	,;	//Codigo do Fornecedor
								(cAliasQry)->BAU_LOJSA2	,;	//Loja
								dFirstDay				,;	//Primeiro dia do mês/ano de E2_MESBASE+E2_ANOBASE
								dLastDay				,;	//Ultimo dia do mês/ano de E2_MESBASE+E2_ANOBASE
								(cAliasQry)->BGQ_NOME	,;	//Entidade Tomadora   
								cTipo					,;	//Tipo de Pessoa (1=Fisica,2=Juridica)  
								""						,;	//CNPJ da Entidade Tomadora   
								(cAliasQry)->BGQ_VALOR	,;	//Valor base INSS
								nValInss 				)   //Valor INSS  
	
		
		If lGravou
			BGQ->(dbGoto((cAliasQry)->BGQRECNO))
			RecLock("BGQ")
			BGQ->BGQ_IMPFIN = '1'
			MsUnlock()
		Endif
	EndIf	
	(cAliasQry)->(DbSkip())
Enddo
(cAliasQry)->(DbCloseArea())

Return .T.



//-------------------------------------------------------------------
/*/{Protheus.doc} F027PercINS()
Retorna percentual de INSS a ser aplicado sobre o valor das tabelas
de retenção do SIGAPLS (BBC_VALOR ou BGQ_VALOR)

@author Mauricio Pequim Jr.
@since 14/04/2015
@version P12.1.4
/*/
//-------------------------------------------------------------------
Static Function F027PercINS(cFornOld,cLojaOld,nPercIns,cFornAtu,cLojaAtu)

DEFAULT cFornOld := ""
DEFAULT cLojaOld := ""
DEFAULT nPercIns := 0
DEFAULT cFornAtu := ""
DEFAULT cLojaAtu := ""


//Obtém percentual de INSS
If cFornOld+cLojaOld != cFornAtu+cLojaAtu
	cFornOld := cFornAtu
	cLojaOld := cLojaAtu
	cNatureza	:= Posicione("SA2",1,xFilial("SA2")+cFornAtu+cLojaAtu,"A2_NATUREZ")
	If !Empty(cNatureza)
		nPercIns	:= Posicione("SED",1,xFilial("SED")+cNatureza,"ED_PERCINS")
	Endif
Endif

If nPercIns == 0
	If FWIsInCallStack("PLSA755")
		Pergunte("FINA027A",.F.)
	EndIf
	nPercIns := mv_par03
Endif 

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} F027AIMP()
Realiza importação/gravação dos dados (Retenção Prévia de INSS)
das tabelas BGQ e BBC do módulo SIGAPLS, para as tabelas FJW e FLX.
Valindando os períodos.

@author Lucas de Oliveira
@since 13/04/2015
@version P12.1.5
/*/
//-------------------------------------------------------------------
Function F027AIMP(cFornec, cLoja, dDataIni, dDataFim, cEntidade, cTipo, cCNPJ, nValBase, nINSS)
Local oModel	:= FWLoadModel('FINA027')//Cadastro de retenções previas de INSS
Local oAuxFJW	:= oModel:GetModel('FJWMASTER')
Local oAuxFLX	:= oModel:GetModel('FLXDETAIL')
Local cNome		:= ""
Local cItem		:= ''
Local nAnoIni	:= 0
Local nAnoFim	:= 0
Local nMesIni	:= 0
Local nMesFim	:= 0
Local nMeses	:= 0
Local nX		:= 0
Local nMes		:= 0
Local lRet		:= .T.
Local aAreaAnt	:= {}
Local nTamEnt	:= TamSx3("FLX_ENTIDA")[1]

DEFAULT cFornec 	:= ""
DEFAULT cLoja		:= ""
DEFAULT dDataIni	:= CTOD("//")
DEFAULT dDataFim	:= CTOD("//")
DEFAULT cEntidade	:= ""
DEFAULT cTipo		:= ""
DEFAULT cCNPJ		:= ""
DEFAULT nValBase	:= 0
DEFAULT nINSS		:= 0

If !Empty(cFornec) .and. !Empty(cLoja) .and. !Empty(dDataIni) .and. !Empty(dDataFim) .and. nINSS > 0

	aAreaAnt	:= GetArea()
	cNome		:= Posicione("SA2", 1, xFilial("SA2") + cFornec + cLoja, "A2_NOME")
	nAnoIni		:= Year(dDataIni)
	nAnoFim		:= Year(dDataFim)
	nMesIni		:= Month(dDataIni)
	nMesFim		:= Month(dDataFim)
	cEntidade	:= Substr(cEntidade,1,nTamEnt)
	nMes		:= nMesIni

	//verifica se ja existe registro na FJW
	dbselectarea("FJW")
	dbsetorder(1)

	If !(MsSeek( xFilial('FJW') + cFornec + cLoja )) //se não existir, seta operação para "INCLUSÃO" 
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		oModel:Activate()		
		oModel:setValue('FJWMASTER' , 'FJW_FORNEC', cFornec)
		oModel:setValue('FJWMASTER' , 'FJW_LOJA'	, cLoja)
		oModel:setValue('FJWMASTER' , 'FJW_NOME'	, cNome)
		
		cItem := '000000'
	Else //se existir seta operação para "ALTERAÇÃO"	
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		oModel:Activate()		
		oAuxFLX:GoLine(oAuxFLX:Length())
		cItem := oAuxFLX:GetValue('FLX_ITEM')
	EndIf	
	
	//Qunatidade de meses
	If nAnoIni == nAnoFim
		nMeses := (nMesFim - nMesIni) +1
	Else
		nMeses := ((12 - nMesIni) + nMesFim) +1
	EndIf

	//Inclui na FLX os registros, 1 por mes 
	For nX := 1 To nMeses
		cItem := Soma1(cItem)

		If !oAuxFLX:IsEmpty()
			oAuxFLX:AddLine()
		EndIf
		
		oAuxFLX:SetValue( 'FLX_ITEM'	, cItem)
		oAuxFLX:SetValue( 'FLX_DTINI'	, FirstDay(ctod("01/"+ strzero(nMesIni,2) +"/"+ cvaltochar(nAnoIni))))
		oAuxFLX:SetValue( 'FLX_DTFIM'	, LastDay( ctod("01/"+ strzero(nMesIni,2) +"/"+ cvaltochar(nAnoIni))))
		oAuxFLX:SetValue( 'FLX_ENTIDA'	, cEntidade)
		oAuxFLX:SetValue( 'FLX_TIPO'	, cTipo)
		oAuxFLX:SetValue( 'FLX_CNPJ'	, cCNPJ)
		oAuxFLX:SetValue( 'FLX_BASE'	, nValBase)
		oAuxFLX:SetValue( 'FLX_INSS'	, nINSS)

		// Controle para não passar do mês 12, e atualizar o Ano.
		If nMesIni == 12 .and. oAuxFLX:GetValue( 'FLX_DTFIM') != dDataFim
			nMesIni := 0
			nAnoIni := nAnoIni + 1
		EndIf

		nMesIni := nMesIni + 1
		
	Next nX
	
	If oModel:VldData()
		oModel:CommitData()
	Else   
		cLog := oModel:GetErrorMessage()[4] + ' - '
		cLog += oModel:GetErrorMessage()[5] + ' - '
		cLog += oModel:GetErrorMessage()[6]             
	
		Help( ,,"F027AIMP",,cLog, 1, 0 )
		lRet := .F.
	EndIf
	
	oModel:DeActivate()
	oModel:Destroy()
	oModel := Nil 
	Restarea(aAreaAnt)
Else
	Help( ,,"F027ANAOIMP",,STR0031, 1, 0 )//"Não foi possivel efetuar a importação. Verifique dados do Fornecedor, Loja, Data inicio e Data final de vigência da prévia de INSS"
	lRet		:= .F.
Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F027ADEL()
Deleta os registros das tabelas FJW e FLX,
quando deletado os itens das tabelas BBC ou BGQ
no processo de integração com módulo SIGAPLS.

@author Lucas de Oliveira
@since 13/04/2015
@version P12.1.5
/*/
//-------------------------------------------------------------------
Function F027ADEL(cFornec, cLoja, dDtIni, dDtFim, cCNPJ)
Local aArea 	:= GetArea()

DEFAULT cFornec	:= ""
DEFAULT cLoja	:= ""
DEFAULT dDtIni	:= CTOD("//")
DEFAULT dDtFim	:= CTOD("//")
DEFAULT cCNPJ	:= ""

dbselectarea("FJW")
dbsetorder(1)

If FJW->(MsSeek( xFilial( 'FJW' ) + cFornec + cLoja ))
	
	dbselectarea("FLX")
	dbsetorder(1)
	If FLX->(MsSeek( xFilial('FLX') + cFornec + cLoja ))
		While !FLX->(EOF())
			If FLX->FLX_DTINI >= dDtIni .AND. FLX->FLX_DTFIM <= dDtFim .AND. Iif(FWIsInCallStack("PLSA360") ,FLX->FLX_CNPJ == cCNPJ, .T.) .AND. !F027VerFLX()
				RecLock("FLX",.F.)
				FLX->(DbDelete())
		 		FLX->(MsUnlock())
			EndIf
			FLX->(dbSkip())
		EndDo
	EndIf
	
	If !FLX->(MsSeek( xFilial('FLX') + cFornec + cLoja ))
		RecLock("FJW",.F.)
		FJW->(DbDelete())
		FJW->(MsUnlock())
	EndIf
	
EndIf

RESTAREA(aArea)

Return