#INCLUDE "PROTHEUS.CH"
#INCLUDE "ECF.CH"
#Include "FWLIBVERSION.CH"

//AMARRACAO

Static cCodRev		:= ""
Static __lDefTop	:= IfDefTopCTB()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EcdProcessa�Autor  �Microsiga          � Data �  02/26/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ECFProcessa(cEmp, aFils,cMatriz, cModEsc, bIncTree,aResWiz2,aResWiz4,aResWiz5,aResWiz6,aResWiz7,aResWiz8,aResWiz9,aAutoWizd,lAutoDIPJ,lAutoJobs,lAutomato,aAutoY540)
Local bProcess		:= {|oSelf|  }
Local oProcess		:= Nil
Local aParamEcf		:=	{} 
Local aParamSave 	:=	{} 

Private lLeiaute2 	:= .F.
Private lLeiaute5	:= .F.
Private lLeiaute6	:= .F.
Private lLeiaute7	:= .F.
Private lLeiaute8	:= .F.

Default cMatriz		:= ""
Default bIncTree   	:= {||.T.}
Default aAutoWizd	:=	{}

Default lAutoDIPJ	:= .F. 
Default lAutoJobs	:= .F.
Default lAutomato	:= .F.
Default aAutoY540   := {}

aParamEcf := Array( ECF_NUMCOLS )

//Wizard1
//Tela de Apresenta��o

//Wizard 02
aParamEcf[ECF_CENTRALIZA]		:= aResWiz2[1] //"Centraliza��o"
aParamEcf[ECF_TIPOESC] 			:= aResWiz2[2] //"Qual o Tipo de Escritura��o?"
aParamEcf[ECF_LAYOUT] 			:= aResWiz2[3] //"Informe o leiaute da ECF?"

//Wizard 04
aParamEcf[ECF_IND_SIT_INI_PER] 	:= aResWiz4[1] //"Indicador Inicio de Periodo"
aParamEcf[ECF_SIT_ESPECIAL] 		:= aResWiz4[2] //"Indicador de Situa��o Especial"
aParamEcf[ECF_PAT_REMAN_CIS]	:= aResWiz4[3] //"Patr. Remanescente de Cis�o(%)"
aParamEcf[ECF_RETIFICADORA] 		:= aResWiz4[4] //"Retificadora"
aParamEcf[ECF_NUM_REC] 			:= aResWiz4[5] //"N�mero do Recibo Anterior"
aParamEcf[ECF_TIP_ECF] 			:= aResWiz4[6] //"Tipo da ECF"
aParamEcf[ECF_COD_SCP] 			:= aResWiz4[7] //"Identifica��o da SCP"
aParamEcf[ECF_DATA_SIT]			:= aResWiz4[8] //"Data Situa��o Especial/Evento"
aParamEcf[ECF_AVAL_ESTOQUE]		:= aResWiz4[9] //"M�todo de Avali��o de Estoques"

//Wizard 5
aParamEcf[ECF_OPT_REFIS] 		:= aResWiz5[1]  		//"Indicador de Optante pelo Refis"
aParamEcf[ECF_OPT_PAES] 			:= aResWiz5[2]  		//"Indicador de Optante pelo Paes"
aParamEcf[ECF_FORMA_TRIB] 		:= aResWiz5[3]  		//"Forma de Tributa��o do Lucro"
aParamEcf[ECF_FORMA_APUR] 		:= aResWiz5[4]  		//"Per�odo de Apura��o do IRPJ e CSLL"
aParamEcf[ECF_COD_QUALIF_PJ] 	:= aResWiz5[5]  		//"Qualifica��o da Pessoa Jur�dica"	
aParamEcf[ECF_FORMA_TRIB_PER]	:= Upper(aResWiz5[6])  	//"Forma de Tributa��o no Per�odo"
aParamEcf[ECF_MES_BAL_RED] 		:= Upper(aResWiz5[7]) 	//"Forma de Apura��o da Estimativa"
aParamEcf[ECF_TIP_ESC_PRE] 		:= aResWiz5[8]  		//"Tipo de Escritura��o"
aParamEcf[ECF_TIP_ENT] 			:= aResWiz5[9]  		//"Tipo de Entidade Imune ou Isenta"	
aParamEcf[ECF_FORMA_APUR_I] 		:= aResWiz5[10] 		//"Exist. Ativ. Tribu. IRPJ e CSLL para Imunes e Isentas"	
aParamEcf[ECF_APUR_CSLL] 		:= aResWiz5[11] 		//"Apura��o da CSLL para Imunes e Isentas"	
aParamEcf[ECF_OPT_EXT_RTT] 		:= aResWiz5[12] 		//"Optante pela Extin��o do RTT em 2014"
aParamEcf[ECF_DIF_CONT_SOC_FCO]	:= aResWiz5[13] 		//"Dif. entre Contabilidade Societaria e FCONT"
aParamEcf[ECF_CRI_REC_REC]		:= aResWiz5[14] 		//"Crit�rio de reconhecimento de receitas"
aParamEcf[ECF_DEC_PAIS_PAIS]	:= aResWiz5[15] 		//"Declara��o Pa�s a Pa�s"
aParamEcf[ECF_COD_IDENT_BLO_W]	:= aResWiz5[16] 		//"Codigo Identif. Bloco W"
aParamEcf[ECF_DEREX]			:= aResWiz5[17] 		//"DEREX"
	
//Wizard 6
aParamEcf[ECF_IND_ALIQ_CSLL] 	:= aResWiz6[1]  //"X280 - PJ Sujeita a Aliquota de 15%"
aParamEcf[ECF_IND_QTE_SCP] 		:= aResWiz6[2]  //"Quantidade de SCP da PJ"
aParamEcf[ECF_IND_ADM_FUN_CLU] 	:= aResWiz6[3]  //"Administradora de Fundos e Clubes de Investimento"		
aParamEcf[ECF_IND_PART_CONS] 	:= aResWiz6[4]  //"Participa��es em Cons�rcios de Empresas"	
aParamEcf[ECF_IND_OP_EXT] 		:= aResWiz6[5]  //"Opera��es com o Exterior"	
aParamEcf[ECF_IND_OP_VINC] 		:= aResWiz6[6]  //"X291 - Opera��es com pessoa Vinculada/Interposta Pessoa/Pais com Tributa��o Favorecida"
aParamEcf[ECF_IND_PJ_ENQUAD] 	:= aResWiz6[7]  //"PJ Enquadrada no Art.58-Ada IN RFB n�1312/2012"	
aParamEcf[ECF_IND_PART_EXT]	 	:= aResWiz6[8]  //"Participa��es no Exterior"
aParamEcf[ECF_IND_ATIV_RURAL] 	:= aResWiz6[9]  //"Atividade Rural"	
aParamEcf[ECF_IND_LUC_EXP] 		:= aResWiz6[10] //"Lucro da Explora��o"
aParamEcf[ECF_IND_RED_ISEN]	 	:= aResWiz6[11] //"Isen��o e Redu��o do Imposto para Lucro Presumido"
aParamEcf[ECF_IND_FIN] 			:= aResWiz6[12] //"FINOR/FINAM/FUNRES"	
aParamEcf[ECF_IND_DOA_ELEIT] 	:= aResWiz6[13] //"Doa��es a Campanhas Eleitorais"
aParamEcf[ECF_IND_PART_COLIG]	:= aResWiz6[14] //"Participa��o Permanente em Coligadas ou Controladas"
aParamEcf[ECF_IND_VEND_EXP]	 	:= aResWiz6[15] //"PJ Efetuou Vendas a Empresa Comercial Exportadora com Fim Expec�fico de Exporta��o"
aParamEcf[ECF_IND_REC_EXT]	 	:= aResWiz6[16] //"Rendimentos do Exterior ou de N�o Residentes"	
aParamEcf[ECF_IND_ATIV_EXT] 		:= aResWiz6[17] //"Ativos no Exterior"
aParamEcf[ECF_IND_COM_EXP] 		:= aResWiz6[18] //"PJ Comercial Exportadora"	
aParamEcf[ECF_IND_PAGTO_EXT] 	:= aResWiz6[19] //"Pagamentos ao Exterior ou n�o Residentes"	
aParamEcf[ECF_IND_ECOM_TI] 		:= aResWiz6[20] //"Com�rcio Eletronico e Tecnologia da Informa��o"
aParamEcf[ECF_IND_ROY_REC] 		:= aResWiz6[21] //"Royalties Recebidos do Brasil e do Exterior"
aParamEcf[ECF_IND_ROY_PAG] 		:= aResWiz6[22] //"Royalties Pagos a benefici�rios do Brasil e do Exterior"
aParamEcf[ECF_IND_REND_SERV] 	:= aResWiz6[23] //"Rendimentos Relativos a Servi�os, Juros e Dividendos Recebidos do Brasil e do Exterior"	
aParamEcf[ECF_IND_PAGTO_REM] 	:= aResWiz6[24] //"Pagamentos ou Remessas a Titulos de Servi�os, Juros e Dividendos a Beneficiarios do Brasil e do Exterior"
aParamEcf[ECF_IND_INOV_TEC] 		:= aResWiz6[25] //"Inova��o Tenol�gica e Desenvolvimento Tecnol�gico"	
aParamEcf[ECF_IND_CAP_INF] 		:= aResWiz6[26] //"Capita��o de Infom�tica e Inclus�o Digital"	
aParamEcf[ECF_IND_PJ_HAB] 		:= aResWiz6[27] //"PJ Habitada"	
aParamEcf[ECF_IND_POLO_AM] 		:= aResWiz6[28] //"P�lo INdustrial de Manaus e Amaz�nia Ocidental"	
aParamEcf[ECF_IND_ZON_EXP] 		:= aResWiz6[29] //"Zonas de Processamento de Exporta��o"	
aParamEcf[ECF_IND_AREA_COM]	 	:= aResWiz6[30] //"�reas de Livre Com�rcio"
aParamEcf[ECF_COD_IDENT_REG21] 	:= aResWiz6[31] //"Codigo Identif. Registro 0021"		
aParamEcf[ECF_COD_ID_BL_V_DEREX]:= aResWiz6[32] //"Codigo Identif. BLOCO V DEREX"		

//Wizard7
aParamEcf[ECF_DATA_INI] 			:= aResWiz7[1]  				//"Data Inicial"
aParamEcf[ECF_DATA_FIM] 			:= aResWiz7[2]  				//"Data Final"
aParamEcf[ECF_DATA_LP] 			:= aResWiz7[3]  				//"Data LP"	
aParamEcf[ECF_CALENDARIO]		:= aResWiz7[4]  				//"Calend�rio"
aParamEcf[ECF_MOEDA] 				:= aResWiz7[5]  				//"Moeda"
aParamEcf[ECF_TIPO_SALDO] 		:= aResWiz7[6]  				//"Tipo de Saldo"
aParamEcf[ECF_CONTA_INI]			:= aResWiz7[7]  				//"K155 - Conta Patrimonio De"
aParamEcf[ECF_CONTA_FIM]			:= aResWiz7[8]  				//"K155 - Conta Patrimonio Ate"
aParamEcf[ECF_CONTA_PATR_INI]	:= aResWiz7[9]  				//"K155 - Conta Patrimonio De"
aParamEcf[ECF_CONTA_PATR_FIM]	:= aResWiz7[10] 				//"K155 - Conta Patrimonio Ate"
aParamEcf[ECF_CONTA_RESU_INI]	:= aResWiz7[11] 				//"K355 - Conta Resultado De"
aParamEcf[ECF_CONTA_RESU_FIM]	:= aResWiz7[12] 				//"K355 - Conta Resultado Ate"
aParamEcf[ECF_CON_VISAO]			:= aResWiz7[13]					//"Considera Vis. p/ Bal. Patrim. e DRE"
aParamEcf[ECF_COD_BALPAT]		:= aResWiz7[14]					//"Cod. Conf. Bal. Patrim"
aParamEcf[ECF_COD_DRE]			:= aResWiz7[15]					//"Cod. Conf. Dem. Resul"
aParamEcf[ECF_PROC_CUSTO] 		:= If(aResWiz7[16] == 1,.T.,.F.)//"Processa C. Custo ?"
aParamEcf[ECF_COD_PLA]			:= aResWiz7[17]					// Plan. Conta Ref.
aParamEcf[ECF_VER_PLA]			:= aResWiz7[18]					// Versao 

//Wizard8
aParamEcf[ECF_REGL210]			:= aResWiz8[01] 				//"L210 - Informa. Comp.Custos"
aParamEcf[ECF_REGP130]			:= aResWiz8[02] 				//"P130 - Dem. Receitas Incent."
aParamEcf[ECF_REGP200]			:= aResWiz8[03] 				//"P200 - Apur. da Base C�lculo."
aParamEcf[ECF_REGP230]			:= aResWiz8[04] 				//"P230 - Calc. Isen��o e Redu."
aParamEcf[ECF_REGP300]			:= aResWiz8[05] 				//"P300 - C�lculo do IRPJ"
aParamEcf[ECF_REGP400]			:= aResWiz8[06] 				//"P400 - Apur Base de Calc.CSLL"
aParamEcf[ECF_REGP500]			:= aResWiz8[07] 				//"P500 - Calc. do CSLL"	
aParamEcf[ECF_REGT120]			:= aResWiz8[08] 				//"T120 - Apur. da Base C�lculo"
aParamEcf[ECF_REGT150]			:= aResWiz8[09] 				//"T150 - C�lculo do IRPJ"
aParamEcf[ECF_REGT170]			:= aResWiz8[10] 				//"T170 - Apur Base de Calc.CSLL"
aParamEcf[ECF_REGT181]			:= aResWiz8[11] 				//"T181 - Calc. do CSLL"		
aParamEcf[ECF_REGU180]			:= aResWiz8[12] 				//"U180 - C�lculo do IRPJ"
aParamEcf[ECF_REGU182]			:= aResWiz8[13] 				//"U182 - Calc. do CSLL"

//Wizard 09
aParamEcf[ECF_POSANTLP]			:= aResWiz9[1]  //"Posi��o Anterior L/P
//aParamEcf[ECF_REGX291] 			:= aResWiz9[2]  //"X291: OPERA��ES COM O EXTERIOR � PESSOA VINCULADA/INTERPOSTA/PA�S COM TRIBUTA��O FAVORECIDA"
//aParamEcf[ECF_REGX292] 			:= aResWiz9[3]  //"X292: OPERA��ES COM O EXTERIOR � PESSOA N�O VINCULADA/N�O INTERPOSTA/PA�S SEM TRIBUTA��O FAVORECIDA"
//aParamEcf[ECF_REGX300] 			:= aResWiz9[4]  //"X300: OPERA��ES COM O EXTERIOR � EXPORTA��ES (ENTRADAS DE DIVISAS)"
//aParamEcf[ECF_REGX310] 			:= aResWiz9[5]  //"X310: OPERA��ES COM O EXTERIOR � CONTRATANTES DAS EXPORTA��ES"
//aParamEcf[ECF_REGX320] 			:= aResWiz9[6]  //"X320: OPERA��ES COM O EXTERIOR � IMPORTA��ES (SA�DAS DE DIVISAS)"
//aParamEcf[ECF_REGX330] 			:= aResWiz9[7]  //"X330: OPERA��ES COM O EXTERIOR � CONTRATANTES DAS IMPORTA��ES"
//aParamEcf[ECF_REGX340] 			:= aResWiz9[8]  //"X340: PARTICIPA��ES NO EXTERIOR"
//aParamEcf[ECF_REGX350] 			:= aResWiz9[02]	//"X350: PARTICIPA��ES NO EXTERIOR � RESULTADO DO PER�ODO DE APURA��O"
aParamEcf[ECF_REGX390] 			:= aResWiz9[02]	//"X390: ORIGENS E APLICA��ES DE RECURSOS � IMUNES E ISENTAS"
aParamEcf[ECF_REGX400] 			:= aResWiz9[03]	//"X400: Com�rcio Eletr�nico e Tecnologia da Informa��o"
aParamEcf[ECF_REGX460] 			:= aResWiz9[04]	//"X460: Inova��o Tecnol�gica e Desenvolvimento Tecnol�gico"
aParamEcf[ECF_REGX470] 			:= aResWiz9[05]	//"X470: Capacita��o de Inform�tica e Inclus�o Digital"
aParamEcf[ECF_REGX480] 			:= aResWiz9[06]	//"X480: Repes, Recap, Padis, PATVD, Reidi, Repenec, Reicomp, Retaero, Recine, Res�duos S�lidos, Recopa, Copa do Mundo, Retid, REPNBL-Redes, Reif e Olimp�adas"
aParamEcf[ECF_REGX490] 			:= aResWiz9[07]	//"X490: P�lo Industrial de Manaus e Amaz�nia Ocidental"
aParamEcf[ECF_REGX500] 			:= aResWiz9[08]	//"X500: ZONAS DE PROCESSAMENTO DE EXPORTA��O (ZPE)"
aParamEcf[ECF_REGX510] 			:= aResWiz9[09]	//"X500: ZONAS DE PROCESSAMENTO DE EXPORTA��O (ZPE)"
aParamEcf[ECF_REGY671]			:= aResWiz9[10]	//"Y671: Outras Informa��es "
aParamEcf[ECF_REGY672] 			:= aResWiz9[11]	//"Y672: Outras Informa��es (Lucro Presumido ou Lucro Arbitrado) "
aParamEcf[ECF_REGY681] 			:= aResWiz9[12]	//"Y672: Outras Informa��es (Lucro Presumido ou Lucro Arbitrado) "
aParamEcf[ECF_REGY800]			:= aResWiz9[13]	//"Y671: Outras Informa��es "

If aParamEcf[ECF_LAYOUT] == 1
	lLeiaute2 	:= .F.
Elseif aParamEcf[ECF_LAYOUT] == 2
	lLeiaute2 	:= .T.
ElseIf aParamEcf[ECF_LAYOUT] == 5
	lLeiaute5 := .T.
ElseIf aParamEcf[ECF_LAYOUT] == 6
	lLeiaute6 := .T.
ElseIf aParamEcf[ECF_LAYOUT] == 7
	lLeiaute7 := .T.
ElseIf aParamEcf[ECF_LAYOUT] == 8
	lLeiaute8 := .T.	
EndIf

aParamSave := aClone(aParamEcf)

// tratamento de retorno l�gico 
aParamSave[ECF_PROC_CUSTO] := aResWiz7[16]

//grava as respostas em arquivo na pasta Profile
ECDSave('RespEcf',aParamSave,"","ECF")

If !lAutomato
	oProcess:= MsNewProcess():New( {|lEnd| ECFExport(cEmp,aFils,cMatriz,cModEsc,aParamEcf,oProcess, bIncTree),EcdGetMsg()} )
	oProcess:Activate()
Else
	ECFExport(cEmp,aFils,cMatriz,cModEsc,aParamEcf,oProcess,bIncTree,aAutoWizd,lAutoDIPJ,lAutoJobs,lAutomato,aAutoY540)
EndIf


Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ECFExport �Autor  �Felipe Cunha        � Data �  01/01/15   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function EcfExport (cEmp,aFils,cMatriz,cModEsc,aParamEcf,oProcess,bIncTree,aAutoWizd,lAutoDIPJ,lAutoJobs,lAutomato,aAutoY540)
Local aArea    		:= GetArea()
Local aForTrib		:= {}
Local aDatApur		:= {}
Local lRet			:= .T.
Local cEntRef		:= ''
Local cForApur  	:= If(aParamECF[ ECF_FORMA_APUR  ]== 1, "T", If(aParamECF[ ECF_FORMA_APUR   ]==2,"A", " "))
Local cForApurC  	:= If(aParamECF[ ECF_APUR_CSLL   ]== 1, "A", If(aParamECF[ ECF_APUR_CSLL    ]==2,"T", If(aParamECF[ ECF_APUR_CSLL    ]==3,"D","")))
Local cForApurI		:= If(aParamECF[ ECF_FORMA_APUR_I]== 1, "A", If(aParamECF[ ECF_FORMA_APUR_I ]==2,"T", If(aParamECF[ ECF_FORMA_APUR_I ]==3,"D","")))
Local lProcCusto	:= aParamEcf[ECF_PROC_CUSTO] 




Local cForTribP		:= ""
Local cMesBal		:= ""
Local nX			:= ''
Local lPosAntLP		:= aParamEcf[ECF_POSANTLP] == 1

Private nRecCS0	:= 0
Private lConsVis		:= If (aParamEcf[ECF_CON_VISAO] == 1, .T. , .F.)
Private cCodDRE		:= aParamEcf[ECF_COD_DRE]
Private cCodBP		:= aParamEcf[ECF_COD_BALPAT]
Private cCodPla		:= aParamEcf[ECF_COD_PLA]
Private cVerPla		:= aParamEcf[ECF_VER_PLA]

Default cMatriz 	:= ""
Default cModEsc 	:= "ECF"
Default oProcess	:= Nil
Default bIncTree   := {||.T.}
Default aAutoWizd	:=	{}
Default lAutoDIPJ	:= .F.
Default lAutoJobs	:= .F.
Default lAutomato	:= .F.
Default aAutoY540   := { }

If oProcess <> Nil
	oProcess:SetRegua1(49)
Endif

// Preenche a entidade referencial conforme cadastro selecionado no passo 7
dbSelectArea('CVN')
CVN->(DBSetOrder(4))//CVN_FILIAL+CVN_CODPLA+CVN_VERSAO+CVN_CTAREF
If !Empty(cCodPla)
	if dbSeek(xFilial('CVN') + cCodPla + cVerPla)
		cEntRef := CVN->CVN_ENTREF
	EndIf		
EndIf
//----------------------------------------------------------------
// Verifica a forma de apura��o P/ cada Tributa��o
//----------------------------------------------------------------
aAdd( aForTrib, AllTrim(UPPER(aParamECF[ ECF_FORMA_TRIB_PER])) )
aAdd( aForTrib, AllTrim(UPPER(aParamECF[ ECF_MES_BAL_RED]   )) )	
aAdd( aForTrib, {"T01","T02","T03","T04" } )
aAdd( aForTrib, {"A01","A02","A03","A04","A05","A06","A07","A08","A09","A10","A11","A12" } )

//----------------------------------------------------------------
// Inicio o controle de mensagens de erro
//----------------------------------------------------------------
EcdNewMsg() 

//--------------------------------------------------------------
// Grava Dados da Empresa - CS0 - Registro 0000/0010/0020
//--------------------------------------------------------------
lRet := lRet .AND. ECF_Revisao(cEmp,aFils,cMatriz,cModEsc,aParamEcf,oProcess, bIncTree)
ECF_CodRev( cCodRev)

//--------------------------------------------------------------
// Grava Dados da Empresa - CSZ - Parametros ECF 
//--------------------------------------------------------------
lRet := lRet .AND. ECF_Param( aFils,oProcess, aParamEcf, cMatriz, cModEsc)

//--------------------------------------------------------------
// Grava Dados da Empresa - CS2 - 
//--------------------------------------------------------------
lRet := lRet .AND. ECF_Empresas( aFils,oProcess, aParamEcf, cMatriz, cModEsc)

//--------------------------------------------------------------
// Exporta dados de Identifica��o das SCP - Registro 0035
//--------------------------------------------------------------
If AllTrim(Str(aParamEcf[ECF_TIP_ECF] -1 )) == '1'
	lRet := lRet .AND. ExportaSCP( oProcess )
EndIf

//--------------------------------------------------------------
// Exporta dados de Signatarios - Registro 0930
//--------------------------------------------------------------
lRet := lRet .AND. ExportaSignatario( oProcess, aParamEcf[ECF_DATA_FIM], .T., cModEsc)

//--------------------------------------------------------------
// Exporta dados de Plano de Contas - Registro J050
//--------------------------------------------------------------
If aParamEcf[ECF_CONTA_FIM] != ' ' .AND. ( (AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '1234') .OR. (AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '5789' .AND. aParamEcf[ECF_TIP_ESC_PRE] == 2))
	lRet := lRet .And. ExportaConta( oProcess, aParamEcf[ECF_CONTA_INI] , aParamEcf[ECF_CONTA_FIM], aParamEcf[ECF_DATA_FIM] , aParamEcf[ECF_DATA_INI] , aParamEcf[ECF_MOEDA], aParamEcf[ECF_TIPO_SALDO], 'ECF', aFils )
EndIf

//--------------------------------------------------------------
// Exporta dados de Plano de Contas Ref. - Registro J051
//--------------------------------------------------------------
If aParamEcf[ECF_CONTA_FIM] != ' '  .AND. ( (AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '1234') .OR. (AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '5789' .AND. aParamEcf[ECF_TIP_ESC_PRE] == 2))
	lRet := lRet .And. ExportaCtRef( oProcess, aParamEcf[ECF_CONTA_INI] , aParamEcf[ECF_CONTA_FIM], aParamEcf[ECF_DATA_FIM], aParamEcf[ECF_PROC_CUSTO], cCodPla, cModEsc,aParamEcf[ECF_VER_PLA],lAutomato)
EndIf

//--------------------------------------------------------------
// Exporta dados de SubConta Correlatas - Registro J053
//--------------------------------------------------------------
If aParamEcf[ECF_CONTA_FIM] != ' '
	lRet := lRet .And. ExportaSubConta( oProcess )
EndIf

//--------------------------------------------------------------
// Exporta dados de Centro de Custo - Registro J100
//--------------------------------------------------------------
If lProcCusto .AND. ( (AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '1234') .OR. (AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '5789' .AND. aParamEcf[ECF_TIP_ESC_PRE] == 2)) 
	lRet := lRet .And. ExportaCusto( oProcess, aParamEcf[ECF_DATA_FIM] ,lProcCusto)
EndIf

//----------------------------------------------------------------
// Exporta dados de Saldos Contabeis - Registro K030 e K155 e K156
//----------------------------------------------------------------
If aParamEcf[ECF_CONTA_PATR_FIM] != ' ' .AND. ( (AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '1234') .OR. (  (AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '5789') .AND. (aParamEcf[ECF_TIP_ESC_PRE] == 2) ) ) 
	//Processa registro A00 somente quando Anual
	If (cForApur == 'A' .AND. cForApurC == '') .OR. (cForApurC == 'A' .OR. cForApurC == 'D' .OR. cForApurI == 'D')
		lRet := ECDGRVBal( aParamEcf[ECF_DATA_INI]		, aParamEcf[ECF_DATA_FIM]		, aParamEcf[ECF_MOEDA]		, aParamEcf[ECF_TIPO_SALDO]	,; 
						   aParamEcf[ECF_CONTA_PATR_INI], aParamEcf[ECF_CONTA_PATR_FIM]	, aParamEcf[ECF_PROC_CUSTO]	, /*aParamEcf[ECF_DATA_LP]*/,;
						   oProcess						, aFils							, cModEsc					,.F.						,;
						   cEntRef						, "A00"							, "K155" 					, cCodPla, cVerPla)
	EndIf
	
	lRet := ExportaBalanc(	oProcess						, aFils							, aParamEcf[ECF_DATA_INI]		,;
							aParamEcf[ECF_DATA_FIM]			, aParamEcf[ECF_DATA_FIM]		, aParamEcf[ECF_MOEDA]			,;
							aParamEcf[ECF_TIPO_SALDO]		, aParamEcf[ECF_CONTA_PATR_INI]	, aParamEcf[ECF_CONTA_PATR_FIM]	,;
							aParamEcf[ECF_DATA_LP]			, aParamEcf[ECF_PROC_CUSTO]		, aParamEcf[ECF_CALENDARIO]		,;
							aParamEcf[ECF_SIT_ESPECIAL]		, cModEsc						, .F.							,; 
							cEntRef							, cForApur						, aForTrib						,;
							"K155" 							, cForApurC						, cCodPla						,;
							cVerPla, cForApurI )			

EndIf

//--------------------------------------------------------------
// Exporta dados de Saldos Contabeis - Registro K355 e K356
//--------------------------------------------------------------			
If aParamEcf[ECF_CONTA_PATR_FIM] != ' ' .AND. ( (AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '1234') .OR. (  (AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '5789') .AND. (aParamEcf[ECF_TIP_ESC_PRE] == 2) ) ) 
	//Processa registro A00 somente quando Anual
	If (cForApur == 'A' .AND. cForApurC == '') .OR. (cForApurC == 'A' .OR. cForApurC == 'D' .OR. cForApurI == 'D') 
		lRet := ECDGRVBal( aParamEcf[ECF_DATA_INI]		, aParamEcf[ECF_DATA_FIM]		, aParamEcf[ECF_MOEDA]		, aParamEcf[ECF_TIPO_SALDO]	,; 
						   aParamEcf[ECF_CONTA_RESU_INI], aParamEcf[ECF_CONTA_RESU_FIM]	, aParamEcf[ECF_PROC_CUSTO]	, aParamEcf[ECF_DATA_LP]	,;
						   oProcess						, aFils							, cModEsc					,.T.						,;
						   cEntRef						, "A00"							, "K355" 					, cCodPla, cVerPla)
	EndIf
	
	lRet := ExportaBalanc(	oProcess						, aFils							, aParamEcf[ECF_DATA_INI]		,;
							aParamEcf[ECF_DATA_FIM]			, aParamEcf[ECF_DATA_FIM]		, aParamEcf[ECF_MOEDA]			,;
							aParamEcf[ECF_TIPO_SALDO]		, aParamEcf[ECF_CONTA_RESU_INI]	, aParamEcf[ECF_CONTA_RESU_FIM]	,;
							aParamEcf[ECF_DATA_LP]			, aParamEcf[ECF_PROC_CUSTO]		, aParamEcf[ECF_CALENDARIO]		,;
							aParamEcf[ECF_SIT_ESPECIAL]		, cModEsc						, .T.							,;
							cEntRef							, cForApur						, aForTrib						,;
							"K355" 							, cForApurC						, cCodPla						,;
							cVerPla, cForApurI )	
EndIf

//----------------------------------------------------------------
// Exporta Reg. L030 / L100 
//----------------------------------------------------------------
If ( !lConsVis ) .AND. ( aParamEcf[ECF_CONTA_PATR_FIM] != ' ' ) .AND. ( AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '1234' )  
	//Processa registro A00 somente quando Anual
	If cForApur == 'A'	 
		lRet := ECDGRVBal( aParamEcf[ECF_DATA_INI]		, aParamEcf[ECF_DATA_FIM]		, aParamEcf[ECF_MOEDA]		, aParamEcf[ECF_TIPO_SALDO]	,; 
						   aParamEcf[ECF_CONTA_PATR_INI], aParamEcf[ECF_CONTA_PATR_FIM]	, aParamEcf[ECF_PROC_CUSTO]	, /*aParamEcf[ECF_DATA_LP]*/,;
						   oProcess						, aFils							, cModEsc					,.F.						,;
						   cEntRef						, "A00"							, "L100" 					, cCodPla, cVerPla)
	EndIf
	
	lRet := ExportaBalanc(	oProcess						, aFils							, aParamEcf[ECF_DATA_INI]		,;
							aParamEcf[ECF_DATA_FIM]			, aParamEcf[ECF_DATA_FIM]		, aParamEcf[ECF_MOEDA]			,;
							aParamEcf[ECF_TIPO_SALDO]		, aParamEcf[ECF_CONTA_PATR_INI]	, aParamEcf[ECF_CONTA_PATR_FIM]	,;
							aParamEcf[ECF_DATA_LP]			, aParamEcf[ECF_PROC_CUSTO]		, aParamEcf[ECF_CALENDARIO]		,;
							aParamEcf[ECF_SIT_ESPECIAL]		, cModEsc						, .F.							,;
							cEntRef							, cForApur						, aForTrib						,;
							"L100" 							, cForApurC						, cCodPla						,;
							cVerPla)			
ElseIf ( lConsVis ) .AND. ( AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '1234' )
	lRet := lRet .AND. ECF_Demonst( aFils, oProcess, aParamEcf, cMatriz, cModEsc, 'L100', aForTrib, cCodBP, .F. )
EndIf

//--------------------------------------------------------------
//Registro L210: Cod.Conf.Comp.Custos"
//--------------------------------------------------------------
If aParamEcf[ECF_REGL210] != ' '
	lRet := lRet .AND. ECF_Demonst( aFils, oProcess, aParamEcf, cMatriz, cModEsc, 'L210', aForTrib, aParamEcf[ECF_REGL210], .T. )
EndIf

//----------------------------------------------------------------
// Exporta Reg. L030 / L300 
//----------------------------------------------------------------
If ( !lConsVis ) .AND. aParamEcf[ECF_CONTA_PATR_FIM] != ' ' .AND. (AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '1234') 
	//Processa registro A00 somente quando Anual
	If cForApur == 'A'	 
		lRet := ECDGRVBal( aParamEcf[ECF_DATA_INI]		, aParamEcf[ECF_DATA_FIM]		, aParamEcf[ECF_MOEDA]		, aParamEcf[ECF_TIPO_SALDO]	,; 
						   aParamEcf[ECF_CONTA_RESU_INI], aParamEcf[ECF_CONTA_RESU_FIM]	, aParamEcf[ECF_PROC_CUSTO]	, aParamEcf[ECF_DATA_LP],;
						   oProcess						, aFils							, cModEsc					,.T.						,;
						   cEntRef						, "A00"							, "L300" 					, cCodPla, cVerPla)
	EndIf
	
	lRet := ExportaBalanc(	oProcess						, aFils							, aParamEcf[ECF_DATA_INI]		,;
							aParamEcf[ECF_DATA_FIM]			, aParamEcf[ECF_DATA_FIM]		, aParamEcf[ECF_MOEDA]			,;
							aParamEcf[ECF_TIPO_SALDO]		, aParamEcf[ECF_CONTA_RESU_INI]	, aParamEcf[ECF_CONTA_RESU_FIM]	,;
							aParamEcf[ECF_DATA_LP]			, aParamEcf[ECF_PROC_CUSTO]		, aParamEcf[ECF_CALENDARIO]		,;
							aParamEcf[ECF_SIT_ESPECIAL]		, cModEsc						, .T.							,;
							cEntRef							, cForApur						, aForTrib						,;
							"L300" 							, cForApurC						, cCodPla						,;
							cVerPla)		
ElseIf ( lConsVis ) .AND. (AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '1234')
	lRet := lRet .AND. ECF_Demonst( aFils, oProcess, aParamEcf, cMatriz, cModEsc, 'L300', aForTrib, cCodDRE, .T. )
EndIf


//----------------------------------------------------------------
// Exporta Reg. P030 / P100 
//----------------------------------------------------------------
If cForApur == 'T'
	If ( !lConsVis ) .AND. (aParamEcf[ECF_CONTA_PATR_FIM] != ' ') .AND. (AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '3457') .AND. (aParamEcf[ECF_TIP_ESC_PRE] == 2)  
		lRet := ExportaBalanc(	oProcess						, aFils							, aParamEcf[ECF_DATA_INI]		,;
								aParamEcf[ECF_DATA_FIM]			, aParamEcf[ECF_DATA_FIM]		, aParamEcf[ECF_MOEDA]			,;
								aParamEcf[ECF_TIPO_SALDO]		, aParamEcf[ECF_CONTA_PATR_INI]	, aParamEcf[ECF_CONTA_PATR_FIM]	,;
								aParamEcf[ECF_DATA_LP]			, aParamEcf[ECF_PROC_CUSTO]		, aParamEcf[ECF_CALENDARIO]		,;
								aParamEcf[ECF_SIT_ESPECIAL]		, cModEsc						, .F.							,;
								cEntRef							, cForApur						, aForTrib						,;
								"P100" 							, cForApurC						, cCodPla						,;
								cVerPla)			
	ElseIf ( lConsVis ) .AND. ( AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '3457' ) .AND. ( aParamEcf[ECF_TIP_ESC_PRE] == 2 )
		lRet := lRet .AND. ECF_Demonst( aFils, oProcess, aParamEcf, cMatriz, cModEsc, 'P100', aForTrib, cCodBP, .F. )	 
	EndIf
EndIf

//----------------------------------------------------------------
// Exporta Reg. P030 / P150 
//----------------------------------------------------------------
If cForApur == 'T'
	If ( !lConsVis ) .AND. (aParamEcf[ECF_CONTA_PATR_FIM] != ' ') .AND. (AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '3457') .AND. (aParamEcf[ECF_TIP_ESC_PRE] == 2)  
		lRet := ExportaBalanc(	oProcess						, aFils							, aParamEcf[ECF_DATA_INI]		,;
								aParamEcf[ECF_DATA_FIM]			, aParamEcf[ECF_DATA_FIM]		, aParamEcf[ECF_MOEDA]			,;
								aParamEcf[ECF_TIPO_SALDO]		, aParamEcf[ECF_CONTA_RESU_INI]	, aParamEcf[ECF_CONTA_RESU_FIM]	,;
								aParamEcf[ECF_DATA_LP]			, aParamEcf[ECF_PROC_CUSTO]		, aParamEcf[ECF_CALENDARIO]		,;
								aParamEcf[ECF_SIT_ESPECIAL]		, cModEsc						, .T.							,;
								cEntRef							, cForApur						, aForTrib						,;
								"P150" 							, cForApurC						, cCodPla						,;
								cVerPla)			
	ElseIf ( lConsVis ) .AND. ( AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '3457' ) .AND. ( aParamEcf[ECF_TIP_ESC_PRE] == 2 )
		lRet := lRet .AND. ECF_Demonst( aFils, oProcess, aParamEcf, cMatriz, cModEsc, 'P150', aForTrib, cCodDRE, .T. )
	EndIf
EndIf

//--------------------------------------------------------------
//Registro P130: Demonstra��o das Receitas Incentivadas do Lucro Presumido
//--------------------------------------------------------------
If aParamEcf[ECF_REGP130] != ' ' .AND. aParamEcf[ECF_IND_RED_ISEN] == 1  .AND. aParamEcf[ECF_OPT_REFIS] == 1
	lRet := lRet .AND. ECF_Demonst( aFils,oProcess, aParamEcf, cMatriz, cModEsc,'P130', aForTrib, aParamEcf[ECF_REGP130], .T.)
EndIf

//--------------------------------------------------------------
//Registro P200: Apura��o da Base de C�lculo do Lucro Presumido
//--------------------------------------------------------------
If aParamEcf[ECF_REGP200] != ' '
	lRet := lRet .AND. ECF_Demonst( aFils,oProcess, aParamEcf, cMatriz, cModEsc,'P200', aForTrib, aParamEcf[ECF_REGP200], .T. )
EndIf

//--------------------------------------------------------------
//Registro P230: C�lculo da Isen��o e Redu��o do Lucro Presumido
//--------------------------------------------------------------
If aParamEcf[ECF_REGP230] != ' ' .AND. aParamEcf[ECF_IND_RED_ISEN] == 1 .AND. aParamEcf[ECF_OPT_REFIS] == 1
	lRet := lRet .AND. ECF_Demonst( aFils,oProcess, aParamEcf, cMatriz, cModEsc,'P230', aForTrib, aParamEcf[ECF_REGP230], .T. )
EndIf

//--------------------------------------------------------------
//Registro P300: C�lculo do IRPJ com Base no Lucro Presumido

//--------------------------------------------------------------
If aParamEcf[ECF_REGP300] != ' '
	lRet := lRet .AND. ECF_Demonst( aFils,oProcess, aParamEcf, cMatriz, cModEsc,'P300', aForTrib, aParamEcf[ECF_REGP300],.T. )
EndIf

//--------------------------------------------------------------
//Registro P400: Apura��o da Base de C�lculo da CSLL com Base no Lucro Presumido
//--------------------------------------------------------------
If aParamEcf[ECF_REGP400] != ' '
	lRet := lRet .AND. ECF_Demonst( aFils,oProcess, aParamEcf, cMatriz, cModEsc,'P400', aForTrib, aParamEcf[ECF_REGP400], .T. )
EndIf

//--------------------------------------------------------------
//Registro P500: C�lculo da CSLL com Base no Lucro Presumido
//--------------------------------------------------------------
If aParamEcf[ECF_REGP500] != ' '
	lRet := lRet .AND. ECF_Demonst( aFils,oProcess, aParamEcf, cMatriz, cModEsc,'P500', aForTrib, aParamEcf[ECF_REGP500], .T. )
EndIf

//--------------------------------------------------------------
//Registro 	T120: Apura��o da Base de C�lculo do IRPJ com Base no Lucro Arbitrado
//--------------------------------------------------------------
If (aParamEcf[ECF_REGT120] != ' ') .AND. (AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '2467')
	lRet := lRet .AND. ECF_Demonst( aFils,oProcess, aParamEcf, cMatriz, cModEsc,'T120', aForTrib, aParamEcf[ECF_REGT120], .T. )
EndIf

//--------------------------------------------------------------
//Registro T150: C�lculo do Imposto de Renda com Base no Lucro Arbitrado
//--------------------------------------------------------------
If aParamEcf[ECF_REGT150] != ' ' .AND. (AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '2467')
	lRet := lRet .AND. ECF_Demonst( aFils,oProcess, aParamEcf, cMatriz, cModEsc,'T150', aForTrib, aParamEcf[ECF_REGT150],.T. )
EndIf

//--------------------------------------------------------------
//Registro T170: Apura��o da Base de C�lculo da CSLL com Base no Lucro Arbitrado
//--------------------------------------------------------------
If aParamEcf[ECF_REGT170] != ' ' .AND. (AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '2467')
	lRet := lRet .AND. ECF_Demonst( aFils,oProcess, aParamEcf, cMatriz, cModEsc,'T170', aForTrib, aParamEcf[ECF_REGT170],.T. )
EndIf

//--------------------------------------------------------------
//Registro T181: C�lculo da CSLL com Base no Lucro Arbitrado 
//--------------------------------------------------------------
If aParamEcf[ECF_REGT181] != ' ' .AND. (AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '2467')
	lRet := lRet .AND. ECF_Demonst( aFils,oProcess, aParamEcf, cMatriz, cModEsc,'T181', aForTrib, aParamEcf[ECF_REGT181],.T.)
EndIf

//----------------------------------------------------------------
// Exporta Reg. U030 / U100 
//----------------------------------------------------------------
If  ( !lConsVis ) .AND. aParamEcf[ECF_CONTA_PATR_FIM] != ' ' .AND. (AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '89')
	//Processa registro A00 somente quando Anual
	If ( cForApurC == 'A' .OR. cForApurC == 'D' ) .OR. ( cForApurI == 'A' .OR. cForApurI == 'D' )	 
		lRet := ECDGRVBal( aParamEcf[ECF_DATA_INI]		, aParamEcf[ECF_DATA_FIM]		, aParamEcf[ECF_MOEDA]		, aParamEcf[ECF_TIPO_SALDO]	,; 
						   aParamEcf[ECF_CONTA_PATR_INI], aParamEcf[ECF_CONTA_PATR_FIM]	, aParamEcf[ECF_PROC_CUSTO]	, /*aParamEcf[ECF_DATA_LP]*/,;
						   oProcess						, aFils							, cModEsc					,.F.						,;
						   cEntRef						, "A00"							, "U100" 					, cCodPla, cVerPla)
	EndIf
	
	lRet := ExportaBalanc(	oProcess						, aFils							, aParamEcf[ECF_DATA_INI]		,;
							aParamEcf[ECF_DATA_FIM]			, aParamEcf[ECF_DATA_FIM]		, aParamEcf[ECF_MOEDA]			,;
							aParamEcf[ECF_TIPO_SALDO]		, aParamEcf[ECF_CONTA_PATR_INI]	, aParamEcf[ECF_CONTA_PATR_FIM]	,;
							aParamEcf[ECF_DATA_LP]			, aParamEcf[ECF_PROC_CUSTO]		, aParamEcf[ECF_CALENDARIO]		,;
							aParamEcf[ECF_SIT_ESPECIAL]		, cModEsc						, .F.							,;
							cEntRef							, cForApur						, aForTrib						,;
							"U100" 							, cForApurC						, cCodPla, cVerPla )			
ElseIf  ( lConsVis ) .AND. ( AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '89' ) 
	lRet := lRet .AND. ECF_Demonst( aFils, oProcess, aParamEcf, cMatriz, cModEsc, 'U100', aForTrib, cCodBP, .F. )
EndIf

//----------------------------------------------------------------
// Exporta Reg. U030 / U150 
//----------------------------------------------------------------
If  ( !lConsVis ) .AND. aParamEcf[ECF_CONTA_PATR_FIM] != ' ' .AND. (AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '89')  
	//Processa registro A00 somente quando Anual
	If ( cForApurC == 'A' .OR. cForApurC == 'D' ) .OR. ( cForApurI == 'A' .OR. cForApurI == 'D' )		 
		lRet := ECDGRVBal( aParamEcf[ECF_DATA_INI]		, aParamEcf[ECF_DATA_FIM]		, aParamEcf[ECF_MOEDA]		, aParamEcf[ECF_TIPO_SALDO]	,; 
						   aParamEcf[ECF_CONTA_RESU_INI], aParamEcf[ECF_CONTA_RESU_FIM]	, aParamEcf[ECF_PROC_CUSTO]	, aParamEcf[ECF_DATA_LP],;
						   oProcess						, aFils							, cModEsc					,.T.						,;
						   cEntRef						, "A00"							, "U150" 					, cCodPla, cVerPla)
	EndIf
	
	lRet := ExportaBalanc(	oProcess						, aFils							,aParamEcf[ECF_DATA_INI]		,;
							aParamEcf[ECF_DATA_FIM]			, aParamEcf[ECF_DATA_FIM]		, aParamEcf[ECF_MOEDA]			,;
							aParamEcf[ECF_TIPO_SALDO]		, aParamEcf[ECF_CONTA_RESU_INI]	, aParamEcf[ECF_CONTA_RESU_FIM]	,;
							aParamEcf[ECF_DATA_LP]			, aParamEcf[ECF_PROC_CUSTO]		, aParamEcf[ECF_CALENDARIO]		,;
							aParamEcf[ECF_SIT_ESPECIAL]		, cModEsc						, .T.							,;
							cEntRef							, cForApur						, aForTrib						,;
							"U150"							, cForApurC						, cCodPla, cVerPla )			
ElseIf  ( lConsVis ) .AND. ( AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '89' )
	lRet := lRet .AND. ECF_Demonst( aFils, oProcess, aParamEcf, cMatriz, cModEsc, 'U150', aForTrib, cCodDRE, .T. )
EndIf


//--------------------------------------------------------------
//Registro U180: 
//--------------------------------------------------------------
If aParamEcf[ECF_REGU180] != ' ' .AND. (AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '89') .AND. (AllTrim(Str(aParamEcf[ECF_FORMA_APUR_I])) $ '1|2')
	lRet := lRet .AND. ECF_Demonst( aFils,oProcess, aParamEcf, cMatriz, cModEsc,'U180', aForTrib, aParamEcf[ECF_REGU180], .T.)
EndIf

//--------------------------------------------------------------
//Registro U182: 
//--------------------------------------------------------------
If aParamEcf[ECF_REGU182] != ' ' .AND. (AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '89') .AND. ( (AllTrim(Str(aParamEcf[ECF_FORMA_APUR_I])) $ '1|2') .OR. (AllTrim(Str(aParamEcf[ECF_APUR_CSLL])) $ "1|2") )
	lRet := lRet .AND. ECF_Demonst( aFils,oProcess, aParamEcf, cMatriz, cModEsc,'U182', aForTrib, aParamEcf[ECF_REGU182],.T. )
EndIf


//--------------------------------------------------------------
// Verifica Bloco V - Derex 
//--------------------------------------------------------------
If aParamEcf[ECF_DEREX] == 1 
	nCabDem := 1
	ExportaDerex( aParamEcf[ ECF_COD_ID_BL_V_DEREX ], cModEsc, oProcess, aFils, aParamEcf, nCabDem, lPosAntLP )
EndIf

//--------------------------------------------------------------
// Verifica data da apura��o nos blocos X/Y
//--------------------------------------------------------------
If aParamEcf[ECF_POSANTLP] == 1 
	nCabDem := 2
Else
	nCabDem := 1
EndIf

//--------------------------------------------------------------
//Registro X280: Atividades Incentivadas � PJ em Geral
//--------------------------------------------------------------
//Cadastro dever� ser feito pelo TAF

//--------------------------------------------------------------
//Registro X291: Opera��es com o Exterior � Pessoa Vinculada/Interposta/Pa�s com Tributa��o Favorecida
//--------------------------------------------------------------
//A975R29a33 - Hoje pega os dados da tabela SAI, em contato com equipe fiscal para entender

//--------------------------------------------------------------
//Registro X292: Opera��es com o Exterior � Pessoa N�o Vinculada/N�o Interposta/Pa�s sem Tributa��o Favorecida
//--------------------------------------------------------------
//A975R29a33 - Hoje pega os dados da tabela SAI, em contato com equipe fiscal para entender

//--------------------------------------------------------------
//Registro X300: Opera��es com o Exterior � Exporta��es (Entradas de Divisas)
//--------------------------------------------------------------
//A975R29a33 - Hoje pega os dados da tabela SAI, em contato com equipe fiscal para entender

//--------------------------------------------------------------
//Registro X310: Opera��es com o Exterior � Contratantes das Exporta��es
//--------------------------------------------------------------
//A975R29a33 - Hoje pega os dados da tabela SAI, em contato com equipe fiscal para entender

//--------------------------------------------------------------
//Registro X320: Opera��es com o Exterior � Importa��es (Sa�da de Divisas)
//--------------------------------------------------------------
//A975R29a33 - Hoje pega os dados da tabela SAI, em contato com equipe fiscal para entender

//--------------------------------------------------------------
//Registro X330: Opera��es com o Exterior � Contratantes das Importa��es
//--------------------------------------------------------------
//A975R29a33 - Hoje pega os dados da tabela SAI, em contato com equipe fiscal para entender

//--------------------------------------------------------------
//Registro X340: Identifica��o da Participa��o no Exterior
//--------------------------------------------------------------
//Em analise com equipe fiscal/Materiais

//--------------------------------------------------------------
//Registro X350: Participa��es no Exterior � Resultado do Per�odo de Apura��o
//--------------------------------------------------------------
/*If aParamEcf[ECF_REGX350] != ' '
	lRet := lRet .And. ExportaDemonst( oProcess, aFils, aParamEcf[ECF_REGX350] , aParamEcf[ECF_MOEDA], aParamEcf[ECF_TIPO_SALDO],;
									aParamEcf[ECF_DATA_INI], aParamEcf[ECF_DATA_FIM] , aParamEcf[ECF_DATA_INI],;
									aParamEcf[ECF_DATA_FIM], aParamEcf[ECF_DATA_LP], nCabDem , aParamEcf[ECF_CALENDARIO], .T.,cModEsc,,'X350')
EndIf*/

//--------------------------------------------------------------
//Registro X351: Demonstrativo de Resultados e de Imposto Pago no Exterior
//--------------------------------------------------------------
//Cadastro dever� ser feito pelo TAF - Atualmente estes registros 
//  necessitam de valores em outras moedas, n�o iremos aplicar no sistema neste momento

//--------------------------------------------------------------
//Registro X352: Demonstrativo de Resultados no Exterior de Coligadas em Regime de Caixa
//--------------------------------------------------------------
//Cadastro dever� ser feito pelo TAF - Atualmente estes registros 
//  necessitam de valores em outras moedas, n�o iremos aplicar no sistema neste momento

//--------------------------------------------------------------
//Registro X353: Demonstrativo de Consolida��o
//--------------------------------------------------------------
//Cadastro dever� ser feito pelo TAF - Atualmente estes registros 
//  necessitam de valores em outras moedas, n�o iremos aplicar no sistema neste momento

//--------------------------------------------------------------
//Registro X354: Demonstrativo de Preju�zos Acumulados
//--------------------------------------------------------------
//Cadastro dever� ser feito pelo TAF - Atualmente estes registros 
//  necessitam de valores em outras moedas, n�o iremos aplicar no sistema neste momento

//--------------------------------------------------------------
//Registro X355: Demonstrativo de Rendas Ativas e Passivas
//--------------------------------------------------------------
//Cadastro dever� ser feito pelo TAF - Atualmente estes registros 
//  necessitam de valores em outras moedas, n�o iremos aplicar no sistema neste momento

//--------------------------------------------------------------
//Registro X356: Demonstrativo de Estrutura Societ�ria
//--------------------------------------------------------------
//Cadastro dever� ser feito pelo TAF - Atualmente estes registros 
//  necessitam de valores em outras moedas, n�o iremos aplicar no sistema neste momento

//--------------------------------------------------------------
//Registro X390: Origem e Aplica��o de Recursos � Imunes e Isentas
//--------------------------------------------------------------
If aParamEcf[ECF_REGX390] != ' ' .AND. AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '89'
	lRet := lRet .And. ExportaDemonst( oProcess, aFils, aParamEcf[ECF_REGX390] , aParamEcf[ECF_MOEDA], aParamEcf[ECF_TIPO_SALDO],;
									aParamEcf[ECF_DATA_INI], aParamEcf[ECF_DATA_FIM] , aParamEcf[ECF_DATA_INI],;
									aParamEcf[ECF_DATA_FIM], aParamEcf[ECF_DATA_LP], nCabDem , aParamEcf[ECF_CALENDARIO], .T.,cModEsc,,'X390' ,, lPosAntLP )
EndIf
												
//--------------------------------------------------------------
//Registro X400: Com�rcio Eletr�nico e Tecnologia da Informa��o
//--------------------------------------------------------------
If aParamEcf[ECF_REGX400] != ' ' .AND. aParamEcf[ECF_IND_ECOM_TI] == 1 
	lRet := lRet .And. ExportaDemonst( oProcess, aFils, aParamEcf[ECF_REGX400] , aParamEcf[ECF_MOEDA], aParamEcf[ECF_TIPO_SALDO],;
									aParamEcf[ECF_DATA_INI], aParamEcf[ECF_DATA_FIM] , aParamEcf[ECF_DATA_INI],;
									aParamEcf[ECF_DATA_FIM], aParamEcf[ECF_DATA_LP], nCabDem , aParamEcf[ECF_CALENDARIO], .T.,cModEsc,, 'X400' ,, lPosAntLP )
EndIf

//--------------------------------------------------------------
//Registro X410: Com�rcio Eletr�nico
//--------------------------------------------------------------
//Cadastro dever� ser feito pelo TAF

//--------------------------------------------------------------
//Registro X420: Royalties Recebidos ou Pagos a Benefici�rios do Brasil e do Exterior
//--------------------------------------------------------------
//Cadastro dever� ser feito pelo TAF

//--------------------------------------------------------------
//Registro X430: Rendimentos Relativos a Servi�os, Juros e Dividendos Recebidos do Brasil e do Exterior
//--------------------------------------------------------------
//Cadastro dever� ser feito pelo TAF

//--------------------------------------------------------------
//Registro X450: Pagamentos/Remessas Relativos a Servi�os, Juros e Dividendos Recebidos do Brasil e do Exterior
//--------------------------------------------------------------
//Cadastro dever� ser feito pelo TAF

//--------------------------------------------------------------
//Registro X460: Inova��o Tecnol�gica e Desenvolvimento Tecnol�gico
//--------------------------------------------------------------
If aParamEcf[ECF_REGX460] != ' ' .AND. aParamEcf[ECF_IND_INOV_TEC] == 1
	lRet := lRet .And. ExportaDemonst( oProcess, aFils, aParamEcf[ECF_REGX460] , aParamEcf[ECF_MOEDA], aParamEcf[ECF_TIPO_SALDO],;
									aParamEcf[ECF_DATA_INI], aParamEcf[ECF_DATA_FIM] , aParamEcf[ECF_DATA_INI],;
									aParamEcf[ECF_DATA_FIM], aParamEcf[ECF_DATA_LP], nCabDem , aParamEcf[ECF_CALENDARIO], .T.,cModEsc,, 'X460' ,, lPosAntLP )
EndIf

//--------------------------------------------------------------
//Registro X470: Capacita��o de Inform�tica e Inclus�o Digital
//--------------------------------------------------------------
If aParamEcf[ECF_REGX470] != ' ' .AND. aParamEcf[ECF_IND_CAP_INF] == 1
	lRet := lRet .And. ExportaDemonst( oProcess, aFils, aParamEcf[ECF_REGX470] , aParamEcf[ECF_MOEDA], aParamEcf[ECF_TIPO_SALDO],;
									aParamEcf[ECF_DATA_INI], aParamEcf[ECF_DATA_FIM] , aParamEcf[ECF_DATA_INI],;
									aParamEcf[ECF_DATA_FIM], aParamEcf[ECF_DATA_LP], nCabDem , aParamEcf[ECF_CALENDARIO], .T.,cModEsc,, 'X470' ,, lPosAntLP )
EndIf

//--------------------------------------------------------------
//Registro X480: Repes, Recap, Padis, PATVD, Reidi, Repenec, Reicomp, Retaero, Recine, Res�duos S�lidos, Recopa, Copa do Mundo, Retid, REPNBL-Redes, Reif e Olimp�adas
//--------------------------------------------------------------
If aParamEcf[ECF_REGX480] != ' '
	lRet := lRet .And. ExportaDemonst( oProcess, aFils, aParamEcf[ECF_REGX480] , aParamEcf[ECF_MOEDA], aParamEcf[ECF_TIPO_SALDO],;
									aParamEcf[ECF_DATA_INI], aParamEcf[ECF_DATA_FIM] , aParamEcf[ECF_DATA_INI],;
									aParamEcf[ECF_DATA_FIM], aParamEcf[ECF_DATA_LP], nCabDem , aParamEcf[ECF_CALENDARIO], .T.,cModEsc,, 'X480' ,, lPosAntLP )
EndIf

//--------------------------------------------------------------
//Registro X490: P�lo Industrial de Manaus e Amaz�nia Ocidental
//--------------------------------------------------------------
If aParamEcf[ECF_REGX490] != ' ' .AND. aParamEcf[ECF_IND_POLO_AM] == 1
	lRet := lRet .And. ExportaDemonst( oProcess, aFils, aParamEcf[ECF_REGX490] , aParamEcf[ECF_MOEDA], aParamEcf[ECF_TIPO_SALDO],;
									aParamEcf[ECF_DATA_INI], aParamEcf[ECF_DATA_FIM] , aParamEcf[ECF_DATA_INI],;
									aParamEcf[ECF_DATA_FIM], aParamEcf[ECF_DATA_LP], nCabDem , aParamEcf[ECF_CALENDARIO], .T.,cModEsc,, 'X490' ,, lPosAntLP )
EndIf

//--------------------------------------------------------------
//Registro X500: Zonas de Processamento de Exporta��o (ZPE)
//--------------------------------------------------------------
If aParamEcf[ECF_REGX500] != ' ' .AND. aParamEcf[ECF_IND_ZON_EXP] == 1
	lRet := lRet .And. ExportaDemonst( oProcess, aFils, aParamEcf[ECF_REGX500] , aParamEcf[ECF_MOEDA], aParamEcf[ECF_TIPO_SALDO],;
									aParamEcf[ECF_DATA_INI], aParamEcf[ECF_DATA_FIM] , aParamEcf[ECF_DATA_INI],;
									aParamEcf[ECF_DATA_FIM], aParamEcf[ECF_DATA_LP], nCabDem , aParamEcf[ECF_CALENDARIO], .T.,cModEsc,, 'X500' ,, lPosAntLP )
EndIf

//--------------------------------------------------------------
//Registro X510: �reas de Livre Com�rcio (ALC) 
//--------------------------------------------------------------
If aParamEcf[ECF_REGX510] != ' ' .AND. aParamEcf[ECF_IND_AREA_COM] == 1
	lRet := lRet .And. ExportaDemonst( oProcess, aFils, aParamEcf[ECF_REGX510] , aParamEcf[ECF_MOEDA], aParamEcf[ECF_TIPO_SALDO],;
									aParamEcf[ECF_DATA_INI], aParamEcf[ECF_DATA_FIM] , aParamEcf[ECF_DATA_INI],;
									aParamEcf[ECF_DATA_FIM], aParamEcf[ECF_DATA_LP], nCabDem , aParamEcf[ECF_CALENDARIO], .T.,cModEsc,, 'X510' ,, lPosAntLP )
EndIf

//--------------------------------------------------------------
//Registro Y520: Pagamentos/Recebimentos do Exterior ou de N�o Residentes
//--------------------------------------------------------------


//--------------------------------------------------------------
//Registro Y540: Discrimina��o da Receita de Vendas dos Estabeleciamentos por Atividade Econ�miva
//--------------------------------------------------------------


//--------------------------------------------------------------
//Registro Y550: Vendas a Comercial Exportadora com Fim Espec�fico de Exporta��o
//--------------------------------------------------------------


//--------------------------------------------------------------
//Registro Y560: Detalhamento das Exporta��es da Comercial Exportadora
//--------------------------------------------------------------


//--------------------------------------------------------------
//Registro Y570: Demonstrativo do Imposto de Renda e CSLL Retidos na Fonte
//--------------------------------------------------------------


//--------------------------------------------------------------
//Registro Y580: Doa��es a Campanhas Eleitorais
//--------------------------------------------------------------
//Cadastro dever� ser feito pelo TAF

//--------------------------------------------------------------
//Registro Y590: Ativos no Exterior
//--------------------------------------------------------------
//Cadastro dever� ser feito pelo TAF

//--------------------------------------------------------------
//Registro Y600: Identifica��o de S�cios ou Titular
//--------------------------------------------------------------
//Cadastro dever� ser feito pelo TAF

//--------------------------------------------------------------
//Registro Y611: Rendimentos de Dirigentes, Conselheiros, S�cios ou Titular
//--------------------------------------------------------------
//Cadastro dever� ser feito pelo TAF

//--------------------------------------------------------------
//Registro Y612: Rendimentos de Dirigentes e Conselheiros � Imunes ou Isentas
//--------------------------------------------------------------
//Cadastro dever� ser feito pelo TAF

//--------------------------------------------------------------
//Registro Y620: Particia��o Permanente em Coligadas ou Controladas
//--------------------------------------------------------------
//Cadastro dever� ser feito pelo TAF

//--------------------------------------------------------------
//egistro Y630: Fundos/Clubes de Investimento
//--------------------------------------------------------------
//Cadastro dever� ser feito pelo TAF

//--------------------------------------------------------------
//Registro Y640: Participa��es em Cons�rcios de Empresas
//--------------------------------------------------------------
//Cadastro dever� ser feito pelo TAF

//--------------------------------------------------------------
//Registro Y650: Participantes do Cons�rcio
//--------------------------------------------------------------
//Cadastro dever� ser feito pelo TAF

//--------------------------------------------------------------
//Registro Y660: Dados de Sucessoras
//--------------------------------------------------------------
//Cadastro dever� ser feito pelo TAF

//--------------------------------------------------------------
//Registro Y665: Demonstrativo das Diferen�as na Ado��o Inicial
//--------------------------------------------------------------


//--------------------------------------------------------------
//Registro Y671: Outras Informa��es
//--------------------------------------------------------------
If aParamEcf[ECF_REGY671] != ' ' .AND. AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '1234'
	lRet := lRet .And. ExportaDemonst( oProcess, aFils, aParamEcf[ECF_REGY671] , aParamEcf[ECF_MOEDA], aParamEcf[ECF_TIPO_SALDO],;
									aParamEcf[ECF_DATA_INI], aParamEcf[ECF_DATA_FIM] , aParamEcf[ECF_DATA_INI],;
									aParamEcf[ECF_DATA_FIM], aParamEcf[ECF_DATA_LP], nCabDem , aParamEcf[ECF_CALENDARIO], .T.,cModEsc,, 'Y671',.T. , lPosAntLP )
EndIf

//--------------------------------------------------------------
//Registro Y672: Outras Informa��es (Lucro Presumido ou Lucro Arbitrado)
//--------------------------------------------------------------
If aParamEcf[ECF_REGY672] != ' ' .AND. AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '567'
	lRet := lRet .And. ExportaDemonst( oProcess, aFils, aParamEcf[ECF_REGY672] , aParamEcf[ECF_MOEDA], aParamEcf[ECF_TIPO_SALDO],;
									aParamEcf[ECF_DATA_INI], aParamEcf[ECF_DATA_FIM] , aParamEcf[ECF_DATA_INI],;
									aParamEcf[ECF_DATA_FIM], aParamEcf[ECF_DATA_LP], nCabDem , aParamEcf[ECF_CALENDARIO], .T.,cModEsc,, 'Y672',.T. , lPosAntLP )
EndIf

//--------------------------------------------------------------
//Registro Y680: M�s das Informa��es de Optantes pelo Refis (Lucros Real, Presumido e Arbitrado)
//--------------------------------------------------------------
//Cadastro dever� ser feito pelo TAF

//--------------------------------------------------------------
//Registro Y681: Informa��es de Optantes pelo Refis (Lucros Real, Presumido e Arbitrado)
//--------------------------------------------------------------
If aParamEcf[ECF_REGY681] != ' ' .AND. !(AllTrim(Str(aParamEcf[ECF_FORMA_TRIB])) $ '89') .AND. aParamEcf[ECF_OPT_REFIS] == 1
	lRet := lRet .AND. ECF_Demonst( aFils, oProcess, aParamEcf, cMatriz, cModEsc, 'Y681', aForTrib, aParamEcf[ECF_REGY681], .T. )															
EndIf


//--------------------------------------------------------------
//Registro Y682: Informa��es de Optantes pelo Refis � Imunes ou Isentas
//--------------------------------------------------------------


//--------------------------------------------------------------
//Registro Y690: Informa��es de Optantes pelo PAES
//--------------------------------------------------------------


//--------------------------------------------------------------
//Registro Y800: Outras Informa��es 
//--------------------------------------------------------------
If aParamEcf[ECF_REGY800] != ' ' 
	lRet := lRet .And. ExportaOutDem( oProcess,aParamEcf[ECF_DATA_INI], aParamEcf[ECF_DATA_FIM], aParamEcf[ECF_DATA_INI],	;
 									  aParamEcf[ECF_DATA_FIM], aParamEcf[ECF_REGY800] )
EndIf
 	
//------------------------------------------
//Inicia a integra��o com a tabela TAFST1
//------------------------------------------
If nRecCS0 > 0
	DbGoto(nRecCS0)
	CTBS103(GetCodRev(),aAutoWizd,lAutoDIPJ,lAutoJobs,lAutomato,aParamEcf[ECF_CENTRALIZA],aAutoY540)
EndIf
 										
RestArea(aArea)

Return



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ECF_Revisao�Autor  �Renato F. Campos   � Data �  03/01/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ECF_Revisao(cEmp,aFils,cMatriz,cModEsc,aParamEcf,oProcess, bIncTree)
Local cFilEsc	:= ''
Local cLayout	:= ''
Local nIX		:= 0
Local lRet		:= .T.

Default bIncTree   := {||.T.}

If aParamEcf[ECF_LAYOUT] == 1
	cLayout 	:= '1.00'
ElseIf aParamEcf[ECF_LAYOUT] == 2
	cLayout 	:= '2.00'
ElseIf aParamEcf[ECF_LAYOUT] ==	3
	cLayout 	:= '3.00'
ElseIf aParamEcf[ECF_LAYOUT] ==	4
	cLayout 	:= '4.00'
ElseIf aParamEcf[ECF_LAYOUT] ==	5
	cLayout 	:= '5.00'	
ElseIf aParamEcf[ECF_LAYOUT] ==	6
	cLayout 	:= '6.00'
ElseIf aParamEcf[ECF_LAYOUT] ==	7
	cLayout 	:= '7.00'
ElseIf aParamEcf[ECF_LAYOUT] ==	8
	cLayout 	:= '8.00'	
Else
	cLayout 	:= StrZero(aParamEcf[ECF_LAYOUT],4)
EndIf

//---------------------------------------------
//Proximo codigo de revis�o.
//---------------------------------------------
cCodRev := GerNextRev( cEmp )

//---------------------------------------------
//Informativo de Progresso
//---------------------------------------------
If oProcess <> Nil
	oProcess:IncRegua1( 'Exportando Revis�o: ' + cCodRev )
	oProcess:SetRegua2(0)
	oProcess:IncRegua2('')
Endif

//---------------------------------------------
//Carrega a Filial Posicionada
//---------------------------------------------
If !Empty( cMatriz ) .And. aParamEcf[ECF_CENTRALIZA] == 2
	cFilEsc := cMatriz
Else
	For nIx := 1 TO Len( aFils )
		IF ValType( aFils[nIx][1] ) == 'L' .And. aFils[nIx][1]
			cFilEsc := aFils[nIx][3]
			EXIT
		Endif
	Next
EndIf

//---------------------------------------------
//Posiciona na Filial correta
//---------------------------------------------
DbSelectArea( "SM0" )
DbSetOrder(1)
MsSeek( cEmp + cFilEsc )

//---------------------------------------------
//verifica codigo de revis�o
//---------------------------------------------
IF ( cCodRev == '000000' )
	EcdAddMsg( "GeraRevisao-> Erro na gera��o do codigo de revis�o!" , "2" )
	Return .F.
EndIf

//---------------------------------------------
//Grava Dados Tabela CS0
//---------------------------------------------
RecLock( "CS0" , .T. )
CS0->CS0_FILIAL 	:= xFilial("CS0")
CS0->CS0_CODREV 	:= cCodRev
CS0->CS0_CODEMP 	:= cEmp
CS0->CS0_CODFIL 	:= cFilEsc
//CS0->CS0_NUMLIV 	:= ''
//CS0->CS0_REVSUP 	:= ''
//CS0->CS0_REVCAD 	:= ''
//CS0->CS0_TPESC 	:= ''
//CS0->CS0_CONSLD 	:=  ''
CS0->CS0_USER 		:= Substring(cUsuario,1,20) 
CS0->CS0_UPDATE 	:= dDataBase
CS0->CS0_DTINI 		:= aParamEcf[ECF_DATA_INI]
CS0->CS0_DTFIM 		:= aParamEcf[ECF_DATA_FIM]
//CS0->CS0_NATLIV 	:=  ''
CS0->CS0_TIPLIV 	:=  'E'
CS0->CS0_ECDREV 	:= cModEsc
//CS0->CS0_SITPER 	:= ''
CS0->CS0_LEIAUT 	:= cLayout
//CS0->CS0_INNIRE 	:= ''
//CS0->CS0_FINESC 	:= ''
//CS0->CS0_HASHSB 	:= ''
//CS0->CS0_NIRESB 	:= ''
CS0->CS0_DATALP 	:= aParamEcf[ECF_DATA_LP]
CS0->CS0_CODPLA		:= aParamEcf[ECF_COD_PLA]
CS0->CS0_VERPLA		:= aParamEcf[ECF_VER_PLA] 	 				// Vers�o Plano Referencial
nRecCS0 := CS0->( Recno() )
MsUnLock()

Eval(bIncTree)

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ExportaEmpresas�Autor  �Equipe CTB     � Data �  26/02/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Exporta��o dos dados para ECD                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ECF_Empresas( aFils,oProcess, aParamEcf, cMatriz, cModEsc)
Local aArea 	:= GetArea()
Local lRet		:= .T.
Local nIx		:= 0

Default cMatriz 	:= ''
Default cModEsc 	:= 'ECF'

//---------------------------------------------
//Informativo de Progresso
//---------------------------------------------
If oProcess <> Nil
	oProcess:IncRegua1( 'Exportando Filiais')
	oProcess:SetRegua2(0)
	oProcess:IncRegua2('')
Endif

For nIx := 1 TO Len( aFils )

	If oProcess <> Nil
		oProcess:IncRegua2( "Gravando Filial: " + aFils[nIx][3] )
	Endif

	DbSelectArea( "SM0" )
	DbSetOrder(1)
	If (aFils[nIx][1]) .And. MsSeek( aFils[nIx][2] + aFils[nIx][3] ) 
		RecLock( "CS2" , .T. )
		CS2->CS2_FILIAL	:= xFilial("CS2")
		CS2->CS2_CODREV	:=  cCodRev										//Cod. Revisao
		CS2->CS2_CODEMP	:=  SM0->M0_CODIGO								//Cod. Empresa
		CS2->CS2_CODFIL	:=  SM0->M0_CODFIL								//Cod. Filial
		CS2->CS2_NOMEEM	:=  IIF(FwLibVersion() >= "20211004", SubStr( FWSM0Util():getSM0FullName(SM0->M0_CODIGO,SM0->M0_CODFIL), 1, 170 ), SM0->M0_NOMECOM )//Nome Empresa
		CS2->CS2_CNPJ	:=  SM0->M0_CGC									//CNPJ
		CS2->CS2_UF		:=  SM0->M0_ESTENT								//UF
		CS2->CS2_IE		:=  SM0->M0_INSC								//Insc. Estadu
		CS2->CS2_IM		:=  SM0->M0_INSCM								//Insc. Munici
		CS2->CS2_CODMUN	:=  SM0->M0_CODMUN								//Codigo Munic
		CS2->CS2_NOMFIL	:=  SM0->M0_FILIAL								//Nome Filial
		CS2->CS2_DESCMU :=  SM0->M0_CIDENT								//Municipio
		CS2->CS2_INSCR	:=  SM0->M0_INSCANT								//Inscri��o
		CS2->CS2_NIRE	:=  SM0->M0_NIRE								//NIRE
		CS2->CS2_DTNIRE	:= 	SM0->M0_DTRE								//Data do Nire
		CS2->CS2_SITESP	:=  AllTrim(Str(aParamEcf[ECF_SIT_ESPECIAL]))	//Ind Sit Esp
		MsUnLock()
	Endif
Next

RestArea( aArea )

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ExportaEmpresas�Autor  �Equipe CTB     � Data �  26/02/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Exporta��o dos dados para ECF                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ECF_Param( aFils,oProcess, aParamEcf, cMatriz, cModEsc)
Local aArea 	:= GetArea()
Local lRet		:= .T.
Local cVersao	:= ''

Default cMatriz 	:= ''
Default cModEsc 	:= 'ECF'

If aParamEcf[ECF_LAYOUT] == 1
	cVersao 	:= '0001'
ElseIf aParamEcf[ECF_LAYOUT] == 2
	cVersao 	:= '0002'
EndIf

//---------------------------------------------
//Informativo de Progresso
//---------------------------------------------
If oProcess <> Nil
	oProcess:IncRegua1('Exportando Parametros da Rotina')
	oProcess:SetRegua2(0)
	oProcess:IncRegua2('')
Endif

//---------------------------------------------
//Grava Dados Tabela CSZ
//---------------------------------------------
RecLock( "CSZ" , .T. )
CSZ->CSZ_FILIAL 	:= xFilial("CSZ")
CSZ->CSZ_CODREV 	:= cCodRev

//Bloco0000
CSZ->CSZ_VERSAO 	:= cVersao
CSZ->CSZ_CNPJ 		:= SM0->M0_CGC											//"CNPJ"	
CSZ->CSZ_NOME 		:= IIF(FwLibVersion() >= "20211004", SubStr( FWSM0Util():getSM0FullName(SM0->M0_CODIGO,SM0->M0_CODFIL), 1, 170 ), SM0->M0_NOMECOM )	//"Nome Empresarial"
CSZ->CSZ_SITPER 	:= AllTrim(Str(aParamEcf[ECF_IND_SIT_INI_PER] -1 ))		//"Indicador Inicio de Periodo"
CSZ->CSZ_SITESP 	:= AllTrim(Str(aParamEcf[ECF_SIT_ESPECIAL] -1 )) 		//"Indicador de Situa��o Especial"
CSZ->CSZ_PATREM 	:= aParamEcf[ECF_PAT_REMAN_CIS]							//"Patr. Remanescente de Cis�o(%)"
CSZ->CSZ_DTSITE 	:= aParamEcf[ECF_DATA_SIT]								//"Data Situa��o Especial/Evento"
CSZ->CSZ_DTINI 		:= aParamEcf[ECF_DATA_INI]								//"Data Inicial"
CSZ->CSZ_DTFIM 		:= aParamEcf[ECF_DATA_FIM]								//"Data Final"
CSZ->CSZ_RETIFI 	:= AllTrim(Str(aParamEcf[ECF_RETIFICADORA]))			//"Retificadora" (1=S /2=N) 
CSZ->CSZ_NUMREC 	:= aParamEcf[ECF_NUM_REC]	 	 						//"N�mero do Recibo Anterior"
CSZ->CSZ_TIPECF 	:= AllTrim(Str(aParamEcf[ECF_TIP_ECF] -1 ))				//"Tipo da ECF"
CSZ->CSZ_CODSCP 	:= aParamEcf[ECF_COD_SCP]								//"Identifica��o da SCP"

//Bloco0010
CSZ->CSZ_FMTPER 	:= UPPER(aParamEcf[ECF_FORMA_TRIB_PER])					//"Forma de Tributa��o no Per�odo
CSZ->CSZ_MESBRE 	:= UPPER(aParamEcf[ECF_MES_BAL_RED])					//"Forma de Apura��o da Estimativa
//CSZ->CSZ_RECANT 	:= ''													//N�o Gravar
CSZ->CSZ_APTREF 	:= AllTrim(Str(aParamEcf[ECF_OPT_REFIS]))				//"Indicador de Optante pelo Refis" (1=S /2=N)
CSZ->CSZ_APTPAE 	:= AllTrim(Str(aParamEcf[ECF_OPT_PAES]))				//"Indicador de Optante pelo Paes" (1=S /2=N)
CSZ->CSZ_FMTRIB 	:= AllTrim(Str(aParamEcf[ECF_FORMA_TRIB]))				//"Forma de Tributa��o do Lucro"
CSZ->CSZ_FMAPUR 	:= AllTrim(Str(aParamEcf[ECF_FORMA_APUR]))				//"Per�odo de Apura��o do IRPJ e CSLL" 1=T(Trimestral) / 2=A(Anual)
CSZ->CSZ_QUALPJ  	:= StrZero(aParamEcf[ECF_COD_QUALIF_PJ],2,0)			//"Qualifica��o da Pessoa Jur�dica"	

If aParamEcf[ECF_TIP_ESC_PRE] > 0
	CSZ->CSZ_TPESCR 	:= AllTrim(Str(aParamEcf[ECF_TIP_ESC_PRE]))			//"Tipo de Escritura��o"  1 = L(Livro Caixa) / 2 = C(Contabil)
EndIf	

If aParamEcf[ECF_FORMA_APUR_I] > 0
	CSZ->CSZ_FMAPUI 	:= AllTrim(Str(aParamEcf[ECF_FORMA_APUR_I]))		//"Exist. Ativ. Tribu. IRPJ e CSLL para Imunes e Isentas" 1=A(Anual) / 2=T(Trimestral) / 3=D(Desobrigada)
EndIf

If aParamEcf[ECF_APUR_CSLL] > 0
	CSZ->CSZ_APUCSL 	:= AllTrim(Str(aParamEcf[ECF_APUR_CSLL]))			//"Apura��o da CSLL para Imunes e Isentas" 1=A(Anual) / 2=T(Trimestral) / 3=D(Desobrigada)
EndIf  

//----------------------------------------------------------------------
//Grava 2-N�O caso esteja em branco
//----------------------------------------------------------------------
If AllTrim(Str(aParamEcf[ECF_OPT_EXT_RTT])) > '0'
		CSZ->CSZ_EXTRTT 	:= AllTrim(Str(aParamEcf[ECF_OPT_EXT_RTT])) 			//"Optante pela Extin��o do RTT em 2014" 1=S(Sim) / 2=N(Nao) 
EndIf

//----------------------------------------------------------------------
//No caso de empresas diferentes de imune e isentas
//  grava em branco caso n�o preenchido.
//Tratativa necessaria para atender divergencia entre manual ECF
//  de 31/05/2015 e PVA.
//----------------------------------------------------------------------  		
If AllTrim(Str(aParamEcf[ECF_DIF_CONT_SOC_FCO])) > '0'
	CSZ->CSZ_DIFFCO		:= AllTrim(Str(aParamEcf[ECF_DIF_CONT_SOC_FCO]))		//"Dif. entre Contabilidade Societaria e FCONT"
EndIf

If aParamEcf[ECF_TIP_ENT] > 0 .AND. aParamEcf[ECF_TIP_ENT] < 16			//"Tipo de Entidade Imune ou Isenta"
	CSZ->CSZ_TPENTI 	:= StrZero(aParamEcf[ECF_TIP_ENT],2,0)		
ElseIf aParamEcf[ECF_TIP_ENT] == 16
	CSZ->CSZ_TPENTI 	:= '99'
EndIf

//Bloco0020
//Legenda  (1=S /2=N)
CSZ->CSZ_ALICSL 	:= AllTrim(Str(aParamEcf[ECF_IND_ALIQ_CSLL]))	//"PJ Sujeita a Aliquota de 15%"
CSZ->CSZ_QTDSCP 	:= aParamEcf[ECF_IND_QTE_SCP]					//"Quantidade de SCP da PJ"
CSZ->CSZ_ADMCLU 	:= AllTrim(Str(aParamEcf[ECF_IND_ADM_FUN_CLU]))	//"Administradora de Fundos e Clubes de Investimento"		
CSZ->CSZ_PARTCO 	:= AllTrim(Str(aParamEcf[ECF_IND_PART_CONS]))	//"Participa��es em Cons�rcios de Empresas"	
CSZ->CSZ_OPEXT 		:= AllTrim(Str(aParamEcf[ECF_IND_OP_EXT]))		//"Opera��es com o Exterior"
CSZ->CSZ_OPVINC 	:= AllTrim(Str(aParamEcf[ECF_IND_OP_VINC])) 	//"Opera��es com pessoa Vinculada/Interposta Pessoa/Pais com Tributa��o Favorecida"
CSZ->CSZ_PJENQU 	:= AllTrim(Str(aParamEcf[ECF_IND_PJ_ENQUAD])) 	//"PJ Enquadrada no Art.58-Ada IN RFB n�1312/2012"	
CSZ->CSZ_PARTEX 	:= AllTrim(Str(aParamEcf[ECF_IND_PART_EXT]))	//"Participa��es no Exterior"
CSZ->CSZ_ATIVRU 	:= AllTrim(Str(aParamEcf[ECF_IND_ATIV_RURAL])) 	//"Atividade Rural"	
CSZ->CSZ_LUCEXP 	:= AllTrim(Str(aParamEcf[ECF_IND_LUC_EXP]))		//"Lucro da Explora��o"
CSZ->CSZ_REDISE 	:= AllTrim(Str(aParamEcf[ECF_IND_RED_ISEN])) 	//"Isen��o e Redu��o do Imposto para Lucro Presumido"
CSZ->CSZ_FIN 		:= AllTrim(Str(aParamEcf[ECF_IND_FIN])) 		//"FINOR/FINAM/FUNRES"
CSZ->CSZ_DOAELE 	:= AllTrim(Str(aParamEcf[ECF_IND_DOA_ELEIT]))	//"Doa��es a Campanhas Eleitorais"
CSZ->CSZ_PCOLIG 	:= AllTrim(Str(aParamEcf[ECF_IND_PART_COLIG]))	//"Participa��o Permanente em Coligadas ou Controladas"
CSZ->CSZ_VENEXP 	:= AllTrim(Str(aParamEcf[ECF_IND_VEND_EXP]))	//"PJ Efetuou Vendas a Empresa Comercial Exportadora com Fim Expec�fico de Exporta��o"
CSZ->CSZ_RECEXT 	:= AllTrim(Str(aParamEcf[ECF_IND_REC_EXT]))  	//"Rendimentos do Exterior ou de N�o Residentes"	
CSZ->CSZ_ATIVEX 	:= AllTrim(Str(aParamEcf[ECF_IND_ATIV_EXT]))  	//"Ativos no Exterior"
CSZ->CSZ_COMEXP 	:= AllTrim(Str(aParamEcf[ECF_IND_COM_EXP]))  	//"PJ Comercial Exportadora"	
CSZ->CSZ_PGTOEX 	:= AllTrim(Str(aParamEcf[ECF_IND_PAGTO_EXT])) 	//"Pagamentos ao Exterior ou n�o Residentes"
CSZ->CSZ_ECOMTI 	:= AllTrim(Str(aParamEcf[ECF_IND_ECOM_TI])) 	//"Com�rcio Eletronico e Tecnologia da Informa��o"
CSZ->CSZ_ROYREC 	:= AllTrim(Str(aParamEcf[ECF_IND_ROY_REC]))  	//"Royalties Recebidos do Brasil e do Exterior"
CSZ->CSZ_ROYPAG 	:= AllTrim(Str(aParamEcf[ECF_IND_ROY_PAG])) 	//"Royalties Pagos a benefici�rios do Brasil e do Exterior"
CSZ->CSZ_RENDSE 	:= AllTrim(Str(aParamEcf[ECF_IND_REND_SERV]))	//"Rendimentos Relativos a Servi�os, Juros e Dividendos Recebidos do Brasil e do Exterior"
CSZ->CSZ_PGTORE 	:= AllTrim(Str(aParamEcf[ECF_IND_PAGTO_REM])) 	//"Pagamentos ou Remessas a Titulos de Servi�os, Juros e Dividendos a Beneficiarios do Brasil e do Exterior"
CSZ->CSZ_INOVTE 	:= AllTrim(Str(aParamEcf[ECF_IND_INOV_TEC]))  	//"Inova��o Tenol�gica e Desenvolvimento Tecnol�gico"	
CSZ->CSZ_CAPINF 	:= AllTrim(Str(aParamEcf[ECF_IND_CAP_INF]))  	//"Capita��o de Infom�tica e Inclus�o Digital"	
CSZ->CSZ_PJHAB 	:= AllTrim(Str(aParamEcf[ECF_IND_PJ_HAB])) 		//"PJ Habitada"		 
CSZ->CSZ_POLOAM 	:= AllTrim(Str(aParamEcf[ECF_IND_POLO_AM]))		//"P�lo INdustrial de Manaus e Amaz�nia Ocidental"	
CSZ->CSZ_ZONEXP 	:= AllTrim(Str(aParamEcf[ECF_IND_ZON_EXP]))		//"Zonas de Processamento de Exporta��o"	
CSZ->CSZ_AREACO 	:= AllTrim(Str(aParamEcf[ECF_IND_AREA_COM]))	//"�reas de Livre Com�rcio"	

//Bloco L200
CSZ_ESTOQU			:= AllTrim(Str(aParamEcf[ECF_AVAL_ESTOQUE]))
//Bloco 0020
If aParamEcf[ECF_LAYOUT] >= 3
	CSZ->CSZ_REGIME			:= AllTrim(Str(aParamEcf[ECF_CRI_REC_REC])) //"Crit�rio de reconhecimento de receitas"
	CSZ->CSZ_DEPAIS			:= AllTrim(Str(aParamEcf[ECF_DEC_PAIS_PAIS])) //"Declara��o Pa�s a Pa�s"
	CSZ->CSZ_IDBLW			:= AllTrim(aParamEcf[ECF_COD_IDENT_BLO_W]) //"Codigo Identif. Bloco W"
	CSZ->CSZ_IDRG21			:= AllTrim(aParamEcf[ECF_COD_IDENT_REG21]) //"Codigo Identif. Registro 0021"
Endif 	

If aParamEcf[ECF_LAYOUT] >= 4
	CSZ->CSZ_DEREX			:= AllTrim(Str(aParamEcf[ECF_DEREX])) //"DEREX 1=Sim 2=Nao
	CSZ->CSZ_IDBLV			:= AllTrim(aParamEcf[ECF_COD_ID_BL_V_DEREX]) //"Identif Bloco V DEREX ECF
Endif

MsUnLock()

RestArea( aArea )

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ExportaEmpresas�Autor  �Equipe CTB     � Data �  26/02/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Exporta��o dos dados para ECD                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ECF_Demonst( aFils,oProcess, aParamEcf, cMatriz, cModEsc, cRegist, aForTrib, cCodVis, lImpAntLP )
Local aArea 		:= GetArea()
Local aStruct		:= {}
Local lRet			:= .T.
Local nx			:= 0
Local nCount		:= 0
Local cQuery		:= ""
Local nCabDem		:= 0
Local cAliasCTG		:= "CTG"
Local cFilCTG		:= xFilial( "CTG" )
Local cCalend		:= aParamEcf[ECF_CALENDARIO]
Local cForApur  	:= If(aParamECF[ ECF_FORMA_APUR  ] == 1, "T", If(aParamECF[ ECF_FORMA_APUR   ]==2,"A", " "))
Local cForApurC  	:= If(aParamECF[ ECF_APUR_CSLL   ]== 1, "A", If(aParamECF[ ECF_APUR_CSLL    ]==2,"T", If(aParamECF[ ECF_APUR_CSLL    ]==3,"D","")))
Local cForApurI		:= If(aParamECF[ ECF_FORMA_APUR_I]== 1, "A", If(aParamECF[ ECF_FORMA_APUR_I ]==2,"T", If(aParamECF[ ECF_FORMA_APUR_I ]==3,"D","")))
Local dDtProcIni	:= Stod( '' )
Local dDtProcFim	:= Stod( '' )
Local dDataIni		:= aParamEcf[ECF_DATA_INI]
Local dDataFim		:= aParamEcf[ECF_DATA_FIM]

Default aForTrib	:= {}
Default cRegist		:= ''
Default cCodVis		:= ''
Default lImpAntLP	:= .T.

If oProcess <> Nil
	oProcess:IncRegua1("Exportando Demonstrativo - " + cRegist) //"Exportando Demonstrativo"
	oProcess:SetRegua2(0)
	oProcess:IncRegua2( '' )
Endif

//Se for anual gera demonstrativo para o periodo A00
// Valido somente para Lucro real e Imunes e Isentas
If (cForApur == 'A') .OR. (cForApurC == 'A' .OR. cForApurC == 'D') .OR. (cForApurI == 'A' .OR. cForApurI == 'D')
	ExportaDemonst( oProcess, aFils    , cCodVis , aParamEcf[ECF_MOEDA], aParamEcf[ECF_TIPO_SALDO],;
					dDataIni, dDataFim , dDataIni, dDataFim            , aParamEcf[ECF_DATA_LP]   ,;
					nCabDem , cCalend  , .F.     , cModEsc             ,'A00'                     , ;
					cRegist , .F.	   , lImpAntLP)
Endif

dbSelectArea("CTG")
dbSetOrder(1)	
MsSeek( cFilCTG + cCalend + DTOS( dDataIni ) , .T. )

If __lDefTop
	cQuery := "SELECT CTG.*";
				+ " FROM " + RetSqlName("CTG") + " CTG ";
				+ " WHERE CTG_FILIAL =  '" + cFilCTG 		+ "'" ;
			  	+ " AND CTG_CALEND 	 =  '" + cCalend 		+ "'" ;
			  	+ " AND CTG_DTINI 	 >= '" + DTOS(dDataIni) + "'" ;
			  	+ " AND CTG_DTFIM	 <= '" + DTOS(dDataFim)	+ "'" ;
			  	+ " AND CTG.D_E_L_E_T_=	' ' "	
	
	cQuery 		:= ChangeQuery(cQuery)
	cAliasCTG 	:= GetNextAlias()
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCTG )

	aStruct   := CTG->(dbStruct())

	For nX := 1 To Len(aStruct)
		If aStruct[nX][2] <> "C" .And. FieldPos(aStruct[nX][1])<>0
			TcSetField(cAliasCTG,aStruct[nX][1],aStruct[nX][2],aStruct[nX][3],aStruct[nX][4])
		EndIf
	Next nX
EndIf

While lRet .And. cFilCTG == (cAliasCTG)->CTG_FILIAL .And. ;
	(cAliasCTG)->CTG_CALEND == cCalend .And. ;
	(cAliasCTG)->CTG_DTINI  >= dDataIni .And. ;
	(cAliasCTG)->CTG_DTFIM  <= dDataFim .And. ;
	(cAliasCTG)->( !Eof() )
  
	//-----------------------------
    //Verifica o periodo
    //-----------------------------
    If ( cForApur = "A") .OR. ( cForApurC = "A" ) .OR. ( cForApurI = "A" ) 
    	nCount := Month ((cAliasCTG)->CTG_DTINI)
    ElseIf ( cForApur = "T") .OR. ( cForApurC = "T" ) .OR. ( cForApurI = "T" ) 
    	nCount := ECFRetPeri((cAliasCTG)->CTG_DTINI)
    EndIf
    
	dDtProcIni	:= (cAliasCTG)->CTG_DTINI
	dDtProcFim	:= (cAliasCTG)->CTG_DTFIM
		
	If cForApur = "T" .AND. nCount > 4
		Alert ("Per�odo de Apura��o n�o compativel com Calend�rio Cont�bil")
	    lRet := .F.
	    Exit
	EndIf
	
	If cForApur == 'A'
		cPeriodo := SubStr(aForTrib[2],nCount,1)
	ElseIf cForApur == 'T'
		cPeriodo := SubStr(aForTrib[1],nCount,1)
	EndIf
	
		//Para Lucro Real
	If cForApur == 'A' .AND. cPeriodo == 'B' .AND. cRegist $ 'L100|L210|L300'
		ExportaDemonst( oProcess  , aFils      , cCodVis   , aParamEcf[ECF_MOEDA], aParamEcf[ECF_TIPO_SALDO],;
						dDataIni  , dDtProcFim , dDataIni  , dDtProcFim          , aParamEcf[ECF_DATA_LP]   ,;
						nCabDem   , cCalend    , .F.       , cModEsc             , aForTrib[4][nCount]      ,;
						cRegist	  ,.F.         , lImpAntLP)
	
	ElseIf cForApur == 'T'  .AND. cPeriodo == 'R' .AND. cRegist  $ 'L100|L210|L300'
		ExportaDemonst( oProcess  , aFils      , cCodVis   , aParamEcf[ECF_MOEDA], aParamEcf[ECF_TIPO_SALDO],;
						dDtProcIni, dDtProcFim , dDtProcIni, dDtProcFim          , dDtProcFim			    ,;
						nCabDem   , cCalend    , .F.       , cModEsc             , aForTrib[3][nCount]      ,;
						cRegist	  ,.F.         , lImpAntLP)
	//Para Lucro Presumido e Arbitrado (Trimestral)
	ElseIf cForApur == 'T'  .AND. cPeriodo $ 'P' .AND. cRegist != 'L210'
		ExportaDemonst( oProcess  , aFils      , cCodVis   , aParamEcf[ECF_MOEDA], aParamEcf[ECF_TIPO_SALDO],;
						dDtProcIni, dDtProcFim , dDtProcIni, dDtProcFim          , dDtProcFim				,;
						nCabDem   , cCalend    , .F.       , cModEsc             , aForTrib[3][nCount]      ,;
						cRegist	  ,.F.         , lImpAntLP)
	//Para Imunes e Isentas (Anual)
	ElseIf ( (cForApurC == 'A') .OR. (cForApurI == 'A') ) .AND. cRegist  $ 'U100|U150|U180|182'
		ExportaDemonst( oProcess  , aFils      , cCodVis   , aParamEcf[ECF_MOEDA], aParamEcf[ECF_TIPO_SALDO],;
						dDataIni  , dDtProcFim , dDataIni  , dDtProcFim          , aParamEcf[ECF_DATA_LP]   ,;
						nCabDem   , cCalend    , .F.       , cModEsc             , aForTrib[4][nCount]      ,;
						cRegist	  ,.F.         , lImpAntLP)
	//Para Imunes e Isentas (Trimestral)
	ElseIf cForApurC == 'T' .AND. cRegist  $ 'U100|U150|U180|182'
		ExportaDemonst( oProcess  , aFils      , cCodVis   , aParamEcf[ECF_MOEDA], aParamEcf[ECF_TIPO_SALDO],;
					dDtProcIni, dDtProcFim , dDtProcIni, dDtProcFim          , dDtProcFim   				,;
					nCabDem   , cCalend    , .F.       , cModEsc             , aForTrib[3][nCount]      	,;
					cRegist	  ,.F.         , lImpAntLP)
	//Outros Registros
	ElseIf (cForApur == 'A' .OR. cForApurC == 'A') .AND. !( cRegist $ 'L100|L210|L300|P100|P150|U100|U150' )
		ExportaDemonst( oProcess  , aFils      , cCodVis   , aParamEcf[ECF_MOEDA], aParamEcf[ECF_TIPO_SALDO],;
						dDtProcIni, dDtProcFim , dDtProcIni, dDtProcFim          , aParamEcf[ECF_DATA_LP]   ,;
						nCabDem   , cCalend    , .F.       , cModEsc             , aForTrib[4][nCount]      ,;
						cRegist	  ,.F.         , lImpAntLP)
	
	ElseIf (cForApur == 'T' .OR.  cForApurC == 'T') .AND. !( cRegist $ 'L100|L210|L300|P100|P150|U100|U150' )
		ExportaDemonst( oProcess  , aFils      , cCodVis   , aParamEcf[ECF_MOEDA], aParamEcf[ECF_TIPO_SALDO],;
						dDtProcIni, dDtProcFim , dDtProcIni, dDtProcFim          , dDtProcFim			    ,;
						nCabDem   , cCalend    , .F.       , cModEsc             , aForTrib[3][nCount]      ,;
						cRegist	  ,.F.         , lImpAntLP)
	
	EndIf 
	
	lRet := .T.
		
	( cAliasCTG )->(dbSkip())		
EndDo

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ExportaDerex
Exporta Cadastro do Bloco V=ECF=DEREX

@author TOTVS
@since 03/05/2017
@version P11.8
/*/
//-------------------------------------------------------------------

Static Function ExportaDerex(cIdBloco_V, cModEsc, oProcess, aFils, aParamEcf, nCabDem, lPosAntLP )
Local cCfgLivro := ""
Local cMoeda := ""
Local cTpSaldo := ""
Local dDataIni := Ctod(Space(8))
Local dDataFim := Ctod(Space(8))
Local cCodInstFi := ""
Local cAliasCVW := ""
Local cQuery := "" 
Local nX := 0
Local aArea := GetArea()
Local lRet := .T.

Default cIdBloco_V := ""
Default cModEsc := "ECF"
Default nCabDem := 1
Default lPosAntLP := .F.

If !Empty(cIdBloco_V)
	cQuery := " SELECT CSU_FILIAL, CSU_IDBLV, CSU_ANOCAL, CSU_DESCRI, "
	cQuery += "        CVU_FILIAL, CVU_IDBLV, CVU_CODIGO, CVU_NOME, CVU_MOEDA, CVU_PAIS, "
	cQuery += "        CVW_FILIAL, CVW_IDBLV, CVW_CODIGO, CVW_MES, CVW_TPSALD, CVW_DATINI, CVW_DATFIM, CVW_CFGLIV, CVW_MOEDA "
	cQuery += " FROM " + RetSqlName("CSU") + " CSU, " + RetSqlName("CVU") + " CVU, " + RetSqlName("CVW") + " CVW "
	cQuery += " WHERE CSU_FILIAL = '" + xFilial("CSU") + "' "
	cQuery += "  AND CVU_FILIAL = CSU_FILIAL "
	cQuery += "  AND CVW_FILIAL = CVU_FILIAL "
	cQuery += "  AND CSU_IDBLV = '" + cIdBloco_V + "' "
	cQuery += "  AND CSU_IDBLV = CVU_IDBLV "
	cQuery += "  AND CVW_IDBLV = CVU_IDBLV "
	cQuery += "  AND CVU_CODIGO = CVW_CODIGO "
	cQuery += "  AND CSU.D_E_L_E_T_ = ' ' "
	cQuery += "  AND CVU.D_E_L_E_T_ = ' ' "
	cQuery += "  AND CVW.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY CVW_FILIAL, CVW_IDBLV, CVW_CODIGO, CVW_MES "
	
	cQuery 	:= ChangeQuery(cQuery)
	cAliasCVW 	:= GetNextAlias()
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCVW )

	aStruct   := CVW->(dbStruct())

	For nX := 1 To Len(aStruct)
		If aStruct[nX][2] <> "C" .And. FieldPos(aStruct[nX][1])<>0
			TcSetField(cAliasCVW,aStruct[nX][1],aStruct[nX][2],aStruct[nX][3],aStruct[nX][4])
		EndIf
	Next nX
	
	While (cAliasCVW)->( ! Eof() )
	
		cCodInstFi := (cAliasCVW)->CVW_CODIGO
	
		While (cAliasCVW)->( ! Eof() ) .And. (cAliasCVW)->CVW_CODIGO ==  cCodInstFi
		
			cCfgLivro 	:= (cAliasCVW)->CVW_CFGLIV
			cMoeda 	:= (cAliasCVW)->CVW_MOEDA
			cTpSaldo 	:= (cAliasCVW)->CVW_TPSALD
			dDataIni 	:= (cAliasCVW)->CVW_DATINI
			dDataFim 	:= (cAliasCVW)->CVW_DATFIM
		
			//-----------------------------------------------------------------------------------------------------------------
			//Registro V100: Demonstrativo dos recursos em moeda estrangeira decorrentes do recebimento de exporta��es
			//-----------------------------------------------------------------------------------------------------------------
			lRet := ExportaDemonst( oProcess, aFils, cCfgLivro, cMoeda, cTpSaldo,;
										dDataIni, dDataFim , dDataIni,;
										dDataFim, aParamEcf[ECF_DATA_LP], nCabDem , aParamEcf[ECF_CALENDARIO], .T.,cModEsc, StrZero(Month(dDataFim),2,0), 'V100' ,, lPosAntLP, cIdBloco_V, cCodInstFi )

			If !lRet 
				Exit
			EndIf
			
			(cAliasCVW)->( dbSkip() )
		
		EndDo

		If !lRet 
			Exit
		EndIf

	EndDo

	(cAliasCVW)->( dbCloseArea() )
	
EndIf

RestArea(aArea)

Return(lRet)
