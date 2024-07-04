#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWCOMMAND.CH" 

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA133
@author Erick G. Dias
@since 04/05/2017
@version 12.1.7
@description Replicador de cadastros das tabelas SF4, SFM, SF7, CFC, SM4, CC7 e SBZ
			 Esta rotina ir� buscar os registros da filial de origem (filial logada) e replicar
			 para as tabelas da filial de destino. Caso exista informa��o na tabela da filial de 
			 destino, a c�pia n�o ser� efetuada, caso a tabela na filial de destino esteja vazia,
			 ent�o a c�pia ser� efetuada.

/*/
//----------------------------------------------------------------------------------------------------
Function FISA133()

Local cNomWiz		:= "FISA133"
Local cNomeCfp		:= "FISA133"
Local cNomeAnt		:= Iif(File(cNomWiz+".cfp"),"","FISA133")
Local cAliasOri		:= ''
Local cFilLog		:= cFilAnt
Local cEmpLog		:= cEmpAnt
Local aWizard		:= {}
Local aLisFil		:= {}
Local aEstrut		:= {}
Local aTAbProc		:= {}
Local aAreaSM0  	:= SM0->(GetArea())
Local nCont			:= 0
Local nContTab		:= 0
Local nQtdeTAb		:= 0
Local nQtdReplic	:= 0
Local lProc			:= .F.
Local lEnd			:= .F.

//------------------------------------------------
//Array com tabelas dispon�veis a serem replicadas
//------------------------------------------------
aAdd(aTAbProc,{"SF4",.F.,-1})
aAdd(aTAbProc,{"SFM",.F.,-1})
aAdd(aTAbProc,{"SF7",.F.,-1})
aAdd(aTAbProc,{"CFC",.F.,-1})
aAdd(aTAbProc,{"SM4",.F.,-1})
aAdd(aTAbProc,{"CC7",.F.,-1})
aAdd(aTAbProc,{"SBZ",.F.,-1})

//------------------------------------------------
//Monta Wizard de gera��o do arquivo
//------------------------------------------------
If !CriaWizard (cNomWiz,cNomeAnt)
	Return	
EndIF	

//------------------------------------------------
//Tratamento do arquivo da wizard por filial
//------------------------------------------------
cNomeCFP := Iif(File(cNomeCfp+".cfp"),cNomeCfp,"FISA133")    
If !xMagLeWiz(cNomeCfp,@aWizard,.T.)
	Return	//Se por algum motivo a leitura do CFP falhar aborto a rotina.
EndIf

//-------------------------------------------------------------
//Verifica quais tabelas foram marcadas para serem processadas.
//-------------------------------------------------------------
For nCont	:= 1 to len(aTAbProc)	

	IF awizard[1][nCont] == 'T'
		aTAbProc[nCont][2]	:= .T.
		aTAbProc[nCont][3]	:= CriaTxtLog(aTAbProc[nCont][1])
		lProc				:= .T.		
		nQtdeTAb ++
		dbSelectArea(aTAbProc[nCont][1])
		dbSetOrder(1)
	EndIF
	
Next nCont

IF !lProc
	Alert("Processo n�o ser� realizado pois nenhuma tabela foi selecionada")
Else
	
	//-----------------------------------
	//Abre tela para sele��o das filiais
	//-----------------------------------
	aLisFil  :=	MatFilCalc( .T.,,,,,,.T. )				
	
	Begin Transaction
	
		Processa({|lEnd|FisReplica(aWizard,aLisFil,aTAbProc,nQtdeTAb,@nQtdReplic)},,,.T.)
			
	End Transaction
		
EndIF

RestArea (aAreaSM0)

If nQtdReplic > 0
	MsgInfo('Processamento conclu�do com sucesso! '+ chr(10)+chr(13)+ alltrim(str(nQtdReplic)) +' Registros foram replicados') 
Else
	MsgAlert('Nenhum registro foi replicado pois informa��es j� existem na filial de destino ') 
EndIF

Return

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaWizard
@author Erick G. Dias
@since 04/05/2017
@version 12.1.7
@param cNomWiz, Caracter, Nome da wizard
@param cNomeAnt, Caracter, Nome da wizard
@return	lRet, L�gico, Retorna se conseguiu montar a wizard
@description Fun��o que ir� montar a wizard de processamento 

/*/
//----------------------------------------------------------------------------------------------------

Static Function CriaWizard (cNomWiz,cNomeAnt)	

Local 	lRet		:= .F.
Local	aTxtApre	:=	{}
Local	aPaineis	:=	{}
Local	cTitObj1	:=	""

aAdd (aTxtApre, "Bem Vindo ao facilitador de c�pia de cadastros")
aAdd (aTxtApre, "")	
aAdd (aTxtApre, "Bem Vindo ao facilitador de c�pia de cadastros")
aAdd (aTxtApre, "Bem Vindo ao facilitador de c�pia de cadastros")

aAdd (aPaineis, {})
nPos	:=	Len (aPaineis)
aAdd (aPaineis[nPos], "Selecione abaixo as tabelas que deseja copiar para a filial de destino...")
aAdd (aPaineis[nPos], "Selecione abaixo as tabelas que deseja copiar para a filial de destino...")
aAdd (aPaineis[nPos], {})

cTitObj1	:=	"TES (SF4)" 								   			 
aAdd (aPaineis[nPos][3], {4, cTitObj1,,,,,.T.,})
aAdd (aPaineis[nPos][3], {0,"",,,,,,})

cTitObj1	:=	"TES Inteligente (SFM)" 								   			 
aAdd (aPaineis[nPos][3], {4, cTitObj1,,,,,.T.,})
aAdd (aPaineis[nPos][3], {0,"",,,,,,})

cTitObj1	:=	"Exce��o Fiscal (SF7)" 								   			 
aAdd (aPaineis[nPos][3], {4, cTitObj1,,,,,.T.,})
aAdd (aPaineis[nPos][3], {0,"",,,,,,})

cTitObj1	:=	"UFxUF (CFC)" 								   			 
aAdd (aPaineis[nPos][3], {4, cTitObj1,,,,,.T.,})
aAdd (aPaineis[nPos][3], {0,"",,,,,,})

cTitObj1	:=	"F�rmulas (SM4)" 								   			 
aAdd (aPaineis[nPos][3], {4, cTitObj1,,,,,.T.,})
aAdd (aPaineis[nPos][3], {0,"",,,,,,})

cTitObj1	:=	"Amarra��o TES x Lancto Apura��o (CC7)" 								   			 
aAdd (aPaineis[nPos][3], {4, cTitObj1,,,,,.T.,})
aAdd (aPaineis[nPos][3], {0,"",,,,,,})

cTitObj1	:=	"Indicador de Produtos (SBZ)" 								   			 
aAdd (aPaineis[nPos][3], {4, cTitObj1,,,,,.T.,})
aAdd (aPaineis[nPos][3], {0,"",,,,,,})

lRet	:=	xMagWizard (aTxtApre, aPaineis, cNomWiz, cNomeAnt)

Return lRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Qry
@author Erick G. Dias
@since 04/05/2017
@version 12.1.7
@param cTab, Caracter, Nome da tabela
@param cAliasRet, Caracter, Alias que esta fun��o ir� retornar o resultado da query, � um par�metro por refer�ncia
@return	lRet, L�gico, Retorna se existe ao menos uma informa��o na tabela
@description Fun��o que faz sele��o das informa��es que dever�o ser replicadas 

/*/
//----------------------------------------------------------------------------------------------------
Static Function Qry(cTab,cAliasRet)

Local	cSelect		:= ''
Local 	cFrom		:= ''
Local   cWhere		:= ''
Local   cPrefixo	:= Iif( Substring(cTab,1,1) == 'S' ,Substring(cTab,2,2) ,cTab  ) + "_"
Local 	cAliasTab	:= GetNextAlias()
Local 	lRet		:= .F.	

cSelect	:=	cTab + ".*"
cFrom	:=	RetSqlName(cTab)+" "+ cTab + " "
cWhere	:=	cTab + "." + cPrefixo + "FILIAL ='"+xFilial(cTab)+"' AND "
cWhere	+=  cTab + ".D_E_L_E_T_=' '"

cSelect:= '%'+cSelect+'%'
cFrom:= '%'+cFrom+'%'
cWhere:= '%'+cWhere+'%'

cAliasTab	:=	GetNextAlias()
BeginSql Alias cAliasTab
	
	SELECT
	%Exp:cSelect%

	FROM
	%Exp:cFrom%	

	WHERE
	%Exp:cWhere%
	
EndSql

(cAliasTab)->(DbGoTop ())
Do While !(cAliasTab)->(Eof ())
	//Se houver ao menos uma informa��o na tabela retorno .T.
	lRet	:= .T.
	Exit	
			
	(cAliasTab)->(dbSkip())
	Loop
EndDo

IF lRet
	cAliasRet	:= cAliasTab
Else
	(cAliasTab)->(DbCloseArea ())
EndIF

Return lRet


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GrvTab
 
@author Erick G. Dias
@since 04/05/2017
@version 12.1.7
@param aEstrut, Array, Estrutura da tabela que ser� copiada
@param cAliasQry, Caracter, Alias da Query executada da tabela que ser� copiada
@param cTabela, Caracter, Nome da tabela que ser� copiada
@description Fun��o que ir� realizar a c�pia da tabela para demais filiais 

/*/
//----------------------------------------------------------------------------------------------------
Static Function GrvTab(aEstrut, cAliasQry, cTabela, nHandle )

Local nCont		:= 0
Local cLinha	:= ''

//Inclui nova linha na tabela
RecLock(cTabela,.T.)

//Grava��o do campo _FILIAL ser� sempre com retorno do xFilial()
&(cTabela + "->" + Iif(Substr(cTabela,1,1) == 'S', Substr(cTabela,2,2) ,cTabela )   + "_FILIAL" ) := xFilial(cTabela)

//La�o nos campos da tabela estrutura do SX3
For nCont := 1 to Len(aEstrut)
	
	If aEstrut[nCont][2] <> 'M'
	
		//Para campo tipo Date preciso utilizar a fun��o TcSetField para que n�o ocorra erro de Type Mismatch
		If aEstrut[nCont][2] == 'D'		
			TcSetField(cAliasQry,aEstrut[nCont][1],"D",8,0)
		EndiF
		
		//Campo Filial n�o ser� copiado, j� foi gravado anteriormente com conte�do do xFilial
		If ! "FILIAL"  $ aEstrut[nCont][1]
			&(cTabela + "->" +aEstrut[nCont][1] )	:= 	(cAliasQry)->&(aEstrut[nCont][1])	
		EndIF
		
	EndIf
	
Next nCont

MsUnLock()

Do Case 

	Case cTabela == 'SFM'
		cLinha	:= LogSFM(cAliasQry) 
		
	Case cTabela == 'SF4'
		cLinha	:= LogSF4(cAliasQry)
		
	Case cTabela == 'SF7'
		cLinha	:= LogSF7(cAliasQry)	
		
	Case cTabela == 'CFC'
		cLinha	:= LogCFC(cAliasQry)
			
	Case cTabela == 'SM4'
		cLinha	:= LogSM4(cAliasQry)
			
	Case cTabela == 'CC7'
		cLinha	:= LogCC7(cAliasQry)
			
	Case cTabela == 'SBZ'
		cLinha	:= LogSBZ(cAliasQry)

EndCase

If nHandle > 0 .AND. Len(Alltrim(cLinha)) > 0
	FWrite (nHandle, cLinha, Len (cLinha))
EndIF

Return

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FisReplica
 
@author Erick G. Dias
@since 04/05/2017
@version 12.1.7

@param aWizard, Array, Informa��es da Wizard
@param aLisFil, Caracter, Array com as filiais que dever�o ser processadas
@param aTAbProc, Caracter, Array com tabelas que dever�o ser replicadas
@param nQtdeTAb, Caracter, Quantidade de tabelas selecionadas pelo cliente
@param nQtdReplic, Caracter, Quantidade de registros replicados por esta fun��o (par�metro por refer�ncia)
@description Fun��o que far� la�o nas filiais e tabelas selecionadas pelo cliente, para seguir
             o fluxo de replicar os cadastros 

/*/
//----------------------------------------------------------------------------------------------------
Static Function FisReplica(aWizard,aLisFil,aTAbProc,nQtdeTAb,nQtdReplic)

Local cAliasOri		:= ''
Local cFilLog		:= cFilAnt
Local cEmpLog		:= cEmpAnt
Local aEstrut		:= {}
Local aAreaSM0  := SM0->(GetArea())
Local nCont			:= 0
Local nContTab		:= 0
Local lProc			:= .F.

ProcRegua(nQtdeTAb+Len(aLisFil))

//La�o nas tabelas a serem replicadas
For nContTab	:= 1 to len(aTAbProc)	
	//Verifica se tabela foi selecionada para ser replicada e se existe informa��o a ser replicada
	IF aTAbProc[nContTab][2] .AND. Qry(aTAbProc[nContTab][1],@cAliasOri)			
			
		//Processa as filiais marcadas pelo usu�rio
		For nCont	:= 1 to Len(aLisFil)
			IF aLisFil[nCont][1] 				
				
				SM0->(DbGoTop ())
				SM0->(MsSeek (cEmpLog+aLisFil[nCont][2], .T.))	//Pego a filial mais proxima
				cFilAnt := FWGETCODFILIAL				
				
				//A Filial logada n�o ter� nada replicado, por este motivo estou descartando ela
				IF cFilLog <> cFilAnt
					IncProc("Replicando tabela " + aTAbProc[nContTab][1] + " da filial " + cFilAnt ) //"Processando filial: "
					//Verifica se existe alguma informa��o na tabela de destino						
					IF !(aTAbProc[nContTab][1])->(dbSeek(xFilial(aTAbProc[nContTab][1])))
											
						//Monta estrutura da tabela com base no SX3
						aEstrut	:= (aTAbProc[nContTab][1])->(dbStruct()) 
						
						//La�o nas informa��es da filial de origem replicando para a filial de destino
						(cAliasOri)->(DbGoTop ())
						Do While !(cAliasOri)->(Eof ())
							
							//Chama fun��o que ir� fazer a c�pia
							GrvTab(aEstrut, cAliasOri, aTAbProc[nContTab][1],aTAbProc[nContTab][3] )	
							nQtdReplic++					
							(cAliasOri)->(dbSkip())
							Loop
						EndDo							
					EndIF
				EndIF				
			EndIF
			//Pr�xima filial			
		Next nCont					
		(cAliasOri)->(DbCloseArea ())
	EndIF
	
	//Restauro a filial para que possa fazer a query na pr�xima tabela na filial logada.
	SM0->(DbGoTop ())
	SM0->(MsSeek (cEmpLog+cFilLog, .T.))
	cFilAnt := FWGETCODFILIAL	
	//pr�xima tabela
Next nContTab	

For nCont:= 1 to len(aTAbProc)

	If (aTAbProc[nCont][3]>=0)
		FClose (aTAbProc[nCont][3])
	Endif
	
Next nCont

Return

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaTxtLog
@author Erick G. Dias
@since 04/05/2017
@version 12.1.7
@description Fun��o respons�vel por criar diret�rio e arquivo de log.	  

/*/
//----------------------------------------------------------------------------------------------------
Static Function CriaTxtLog(cTabela)

Local cDiretorio	:=  GetSrvProfString("Startpath","") + 'FISCOPY'

IF ! ExistDir( cDiretorio ) 
	MakeDir( cDiretorio )
EndIf

Return FCREATE(cDiretorio + '\FISCOPY_REPLICADOR_'+cTabela+'_' + StrTran(DtoC(dDataBase), "/","")+'_'+ StrTran(Time(), ":","" )+'.TXT', 0)


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LogSF4
@author Erick G. Dias
@since 04/05/2017
@version 12.1.7
@description Fun��o que monta o log da tabela SF4

/*/
//----------------------------------------------------------------------------------------------------
Static Function LogSF4(cAliasTab)
Local cLinha	:= ''  

cLinha	:= 'TES replicada para Grupo de Empresa: ' + FWGrpCompany()
cLinha += Iif(FWModeAccess("SF4",1) == 'C' .OR. Empty(Alltrim(FWCompany())) ,''    , ', Empresa: ' + FWCompany()  )
cLinha += Iif(FWModeAccess("SF4",2) == 'C' .OR. Empty(Alltrim(FWUnitBusiness())) ,''  , ', Unidade de Neg�cio: ' + FWUnitBusiness()  )
cLinha += Iif(FWModeAccess("SF4",3) == 'C' .OR. Empty(Alltrim(FWFilial())),''  , ' e Filial ' + FWFilial()  )
cLinha	+=' : C�digo do TES = '			+ (cAliasTab)->F4_CODIGO 
cLinha	+=', Descri��o = ' 				+ (cAliasTab)->F4_TEXTO + ' '
cLinha	+= Chr (13)+Chr (10)

Return cLinha

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LogSFM
@author Erick G. Dias
@since 04/05/2017
@version 12.1.7
@description Fun��o que monta o log da tabela SFM

/*/
//----------------------------------------------------------------------------------------------------
Static Function LogSFM(cAliasTab)
Local cLinha	:= ''   

cLinha	:= 'TES Inteligente replicada para Grupo de Empresa: ' + FWGrpCompany()
cLinha += Iif(FWModeAccess("SFM",1) == 'C' .OR. Empty(Alltrim(FWCompany())),''    , ', Empresa: ' + FWCompany()  )
cLinha += Iif(FWModeAccess("SFM",2) == 'C' .OR. Empty(Alltrim(FWUnitBusiness())),''  , ', Unidade de Neg�cio: ' + FWUnitBusiness()  )
cLinha += Iif(FWModeAccess("SFM",3) == 'C' .OR. Empty(Alltrim(FWFilial())),''  , ' e Filial ' + FWFilial()  )
cLinha	+=' : Tipo de Opera��o = '					+ (cAliasTab)->FM_TIPO   
cLinha	+=', Produto = ' 							+ (cAliasTab)->FM_PRODUTO  
cLinha	+=', Cliente/Loja = ' 						+ (cAliasTab)->FM_CLIENTE+'/'+(cAliasTab)->FM_LOJACLI
cLinha	+=', Fornecedor/Loja = ' 					+ (cAliasTab)->FM_FORNECE+'/'+(cAliasTab)->FM_LOJAFOR
cLinha	+=', Estado = ' 							+ (cAliasTab)->FM_EST 
cLinha	+=', Grupo de Tributa��o = ' 				+ (cAliasTab)->FM_GRTRIB
cLinha	+=', Grupo de Produto = ' 					+ (cAliasTab)->FM_GRPROD 
cLinha	+=', NCM = ' 								+ (cAliasTab)->FM_POSIPI 
cLinha	+=', TES de Entrada = ' 					+ (cAliasTab)->FM_TE
cLinha	+=', TES de Sa�da = ' 						+ (cAliasTab)->FM_TS
cLinha	+=', Grupo de TES Inteligente = '			+ (cAliasTab)->FM_GRPTI
cLinha	+=', Tipo de Cliente = ' 					+ (cAliasTab)->FM_TIPOCLI + ' ' 
cLinha	+= Chr (13)+Chr (10)

Return cLinha

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LogSF7
@author Erick G. Dias
@since 04/05/2017
@version 12.1.7
@description Fun��o que monta o log da tabela SF7

/*/
//----------------------------------------------------------------------------------------------------
Static Function LogSF7(cAliasTab)
Local cLinha	:= ''

cLinha	:= 'Exce��o Fiscal replicada para Grupo de Empresa: ' + FWGrpCompany()
cLinha += Iif(FWModeAccess("SF7",1) == 'C' .OR. Empty(Alltrim(FWCompany())),''    , ', Empresa: ' + FWCompany()  )
cLinha += Iif(FWModeAccess("SF7",2) == 'C' .OR. Empty(Alltrim(FWUnitBusiness())),''  , ', Unidade de Neg�cio: ' + FWUnitBusiness()  )
cLinha += Iif(FWModeAccess("SF7",3) == 'C' .OR. Empty(Alltrim(FWFilial())),''  , ' e Filial ' + FWFilial()  )
cLinha	+=' : Grupo de Tributa��o = '				+ (cAliasTab)->F7_GRTRIB 
cLinha	+=', Sequ�ncia = ' 							+ (cAliasTab)->F7_SEQUEN + ' '
cLinha	+= Chr (13)+Chr (10)


Return cLinha

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LogCFC
@author Erick G. Dias
@since 04/05/2017
@version 12.1.7
@description Fun��o que monta o log da tabela CFC

/*/
//----------------------------------------------------------------------------------------------------
Static Function LogCFC(cAliasTab)
Local cLinha	:= ''
   
cLinha	:= 'UF x UF replicada para Grupo de Empresa: ' + FWGrpCompany()
cLinha += Iif(FWModeAccess("CFC",1) == 'C' .OR. Empty(Alltrim(FWCompany())),''    , ', Empresa: ' + FWCompany()  )
cLinha += Iif(FWModeAccess("CFC",2) == 'C' .OR. Empty(Alltrim(FWUnitBusiness())),''  , ', Unidade de Neg�cio: ' + FWUnitBusiness()  )
cLinha += Iif(FWModeAccess("CFC",3) == 'C' .OR. Empty(Alltrim(FWFilial())),''  , ' e Filial ' + FWFilial()  )
cLinha	+=' : UF Origem = '					+ (cAliasTab)->CFC_UFORIG 
cLinha	+=' : UF Destino = '				+ (cAliasTab)->CFC_UFDEST
cLinha	+=' : Produto = '					+ (cAliasTab)->CFC_CODPRD + ' '
cLinha	+= Chr (13)+Chr (10)

Return cLinha

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LogSM4
@author Erick G. Dias
@since 04/05/2017
@version 12.1.7
@description Fun��o que monta o log da tabela SM4

/*/
//----------------------------------------------------------------------------------------------------
Static Function LogSM4(cAliasTab)
Local cLinha	:= ''
   
cLinha	:= 'F�rmula replicada para Grupo de Empresa: ' + FWGrpCompany()
cLinha += Iif(FWModeAccess("SM4",1) == 'C' .OR. Empty(Alltrim(FWCompany())),''    , ', Empresa: ' + FWCompany()  )
cLinha += Iif(FWModeAccess("SM4",2) == 'C' .OR. Empty(Alltrim(FWUnitBusiness())),''  , ', Unidade de Neg�cio: ' + FWUnitBusiness()  )
cLinha += Iif(FWModeAccess("SM4",3) == 'C' .OR. Empty(Alltrim(FWFilial())),''  , ' e Filial ' + FWFilial()  )
cLinha	+=' : C�digo = '					+ (cAliasTab)->M4_CODIGO   + ' '
cLinha	+= Chr (13)+Chr (10)

Return cLinha

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LogCC7
@author Erick G. Dias
@since 04/05/2017
@version 12.1.7
@description Fun��o que monta o log da tabela CC7 

/*/
//----------------------------------------------------------------------------------------------------
Static Function LogCC7(cAliasTab)
Local cLinha	:= ''

cLinha	:= 'Amarra��o TES x Lanc. Apur. replicado para Grupo de Empresa: ' + FWGrpCompany()
cLinha += Iif(FWModeAccess("CC7",1) == 'C' .OR. Empty(Alltrim(FWCompany())) ,''    , ', Empresa: ' + FWCompany()  )
cLinha += Iif(FWModeAccess("CC7",2) == 'C' .OR. Empty(Alltrim(FWUnitBusiness())),''  , ', Unidade de Neg�cio: ' + FWUnitBusiness()  )
cLinha += Iif(FWModeAccess("CC7",3) == 'C' .OR. Empty(Alltrim(FWFilial())),''  , ' e Filial ' + FWFilial()  )   
cLinha	+=' : TES = '											+ (cAliasTab)->CC7_TES 
cLinha	+=' : Sequ�ncia = '										+ (cAliasTab)->CC7_SEQ
cLinha	+=' : C�digo de Lan�amento = '							+ (cAliasTab)->CC7_CODLAN + ' '
cLinha	+= Chr (13)+Chr (10)

Return cLinha

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LogSBZ
@author Erick G. Dias
@since 04/05/2017
@version 12.1.7
@description Fun��o que monta o log da tabela SBZ 

/*/
//----------------------------------------------------------------------------------------------------
Static Function LogSBZ(cAliasTab)
Local cLinha	:= ''
   
cLinha	:= 'Indicador de Produtos replicado para Grupo de Empresa: ' + FWGrpCompany()
cLinha += Iif(FWModeAccess("SBZ",1) == 'C' .OR. Empty(Alltrim(FWCompany())) ,''    , ', Empresa: ' + FWCompany()  )
cLinha += Iif(FWModeAccess("SBZ",2) == 'C' .OR. Empty(Alltrim(FWUnitBusiness())),''  , ', Unidade de Neg�cio: ' + FWUnitBusiness()  )
cLinha += Iif(FWModeAccess("SBZ",3) == 'C' .OR. Empty(Alltrim(FWFilial())),''  , ' e Filial ' + FWFilial()  )
cLinha	+=' : C�digo = '									+ (cAliasTab)->BZ_COD + ' '
cLinha	+= Chr (13)+Chr (10)                                                                                                                                                                                                                                         

Return cLinha