#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH"    
#INCLUDE "CRM980EVENTDEFCRM.CH"  

Static lCRMAZS 	  := Nil
Static lMVCRMTERR := Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CRM980EventDEFCRM 
Classe responsável pelo evento das regras de negócio da 
localização Padrão CRM.

@type 		Classe
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Class CRM980EventDEFCRM From FwModelEvent 
	
	Data aAOVMark 	As Array
	Data cVendAnt 	As Character

	Method New() CONSTRUCTOR
	
	//---------------------
	// PosValid do Model.
	//---------------------
	Method ModelPosVld()
	
	//---------------------------------------------------------------------
	// Bloco com regras de negócio dentro da transação do modelo de dados.
	//---------------------------------------------------------------------
	Method InTTS()
	
	//-------------------------------------------------------------------
	// Metodo responsável por destruir a classe.
	//-------------------------------------------------------------------
	Method Destroy()
		
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo responsável pela construção da classe.

@type 		Método
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Method New() Class CRM980EventDEFCRM
	Self:aAOVMark := CRMA980GMSeg()							//Propriedade utilizada no cadastro de segmentos de negocio.
	Self:cVendAnt := ""
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Método responsável por executar as validações das regras de negócio
do CRM antes da gravação do formulario.
Se retornar falso, não permite gravar.

@type 		Método

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel,cID) Class CRM980EventDEFCRM
	Local lValid 		:= .T.
	Local nOperation	:= oModel:GetOperation()
	Local oMdlSA1		:= oModel:GetModel("SA1MASTER")
	Local aTerritory	:= {}
	
	If ( nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE  )
	
		//---------------------------------------------------------------------
		// Propriedade utilizada para armazenar o vendedor antes da gravação.
		//---------------------------------------------------------------------
		Self:cVendAnt := SA1->A1_VEND 	
		
		//-----------------------------------------------------------------------------
		// Validacao do campo A1_ENTORI.   
		// Verificar se o campos A1_ORIGCT == 1, campo A1_ENTORI se torna obrigatorio. 
		//-----------------------------------------------------------------------------
		If ( lValid .And. oMdlSA1:GetValue("A1_ORIGCT") $ "1|5|7" .And. Empty(oMdlSA1:GetValue("A1_ENTORI")) )    
			Help(,,"MDLPVLDCRM",,STR0001,1,0) //"O campo Ent. Origem tem que ser preenchido."
			lValid := .F. 
		EndIf
	
		//-------------------------------------------------------------------------------------------- 
		// Verifica se o usuario trocou o segmento primario de uma amarracao com os subsegmentos.
		//--------------------------------------------------------------------------------------------
		If lValid 
			lValid := CRMA620TOkSeg(oMdlSA1:GetValue("A1_CODSEG"),A030GAOWMark())
		Endif	
		
		//-------------------------------------------------------------------------------------------- 
		// Faz a avaliação do(s) melhor(es) territorio(s) para atender esta conta.
		//--------------------------------------------------------------------------------------------
		If lMVCRMTERR == Nil
			lMVCRMTERR := SuperGetMV("MV_CRMTERR",.F.,.F.)
		EndIf
		
		If ( lValid .And. lMVCRMTERR)
			aTerritory := CRMA690EvalTerritory("MATA030","SA1",.T.,.F.)
			If !Empty( aTerritory[2] )
				lValid := aTerritory[1] 
			EndIf
		EndIf
	
	EndIf	
Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS
Método responsável por executar regras de negócios do CRM dentro da
transação do modelo de dados.

@type 		Método

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Method InTTS(oModel,cID) Class CRM980EventDEFCRM
		
	Local cChave 		:= ""
	Local cVend			:= ""
	Local cUserAnt		:= ""
	Local cVendAnt		:= ""
	Local aTerritory 	:= {}
	Local aAutoAO4		:= {}
	Local aAutoAO4Aux	:= {}
	Local nPrvOpc		:= 0
	Local nOperation	:= oModel:GetOperation()
	Local lAOWDeleted	:= .F.
	Local aRole		  	:= CRMXGetPaper() 
	Local cCodUsr	  	:= "" 

	If lCRMAZS == Nil
		lCRMAZS  := SuperGetMv("MV_CRMUAZS",, .F.)
	EndIf
	
	cCodUsr := If(lCRMAZS, CRMXCodUser(), RetCodUsr())
	
	//-------------------------------------------
	//  Adiciona o privilegios deste registro.
	//-------------------------------------------
	cChave 	:= PadR(xFilial("SA1")+SA1->A1_COD+SA1->A1_LOJA,TAMSX3("AO4_CHVREG")[1])
	cVend   := SA1->A1_VEND 
	If ( nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_DELETE )
		aAutoAO4	:= CRMA200PAut(nOperation,"SA1",cChave,cCodUsr,/*aPermissoes*/,/*aNvlEstrut*/,/*cCodUsrCom*/,/*dDataVld*/)
		
		If nOperation == MODEL_OPERATION_INSERT
			If lCRMAZS
				AZS->( DBSetOrder( 1 ) ) 
	       
				If AZS->( DbSeek(xFilial("AZS") + aRole[1] + aRole[2] + aRole[3] ) )
					 If ( ! ( Empty( cVend ) ) ) .And. ( AZS->AZS_VEND <> cVend )
					 	AZS->( DBSetOrder( 4 ) ) 
	       
						If AZS->( DbSeek(xFilial("AZS") + cVend ) )					  	
							If ! ( AZS->AZS_CODUSR + AZS->AZS_SEQUEN + AZS->AZS_PAPEL == aRole[1] + aRole[2] + aRole[3] )
								aAutoAO4Aux := CRMA200PAut(nOperation,"SA1",cChave,AZS->AZS_CODUSR,/*aPermissoes*/,/*aNvlEstrut*/,aRole[1],/*dDataVld*/,,,lPropri, AZS->AZS_SEQUEN + AZS->AZS_PAPEL)
								aAdd(aAutoAO4[2],aAutoAO4Aux[2][1])				  	
							EndIf	
					  	EndIf		  
					 EndIf
				EndIf
			Else 	
				DbSelectArea("AO3")
				AO3->(DbSetOrder(1))	// AO3_FILIAL+AO3_CODUSR
				
				If AO3->(DbSeek(xFilial("AO3")+cCodUsr))
					
					// Se o codigo do vendendor logado for diferente do cadastrado, insere na AO4 como compartilhado
					If !Empty(cVend) .AND. AO3->AO3_VEND <> cVend
						
						AO3->(DbSetOrder(2))	// AO3_FILIAL+AO3_VEND
						
						If AO3->(DbSeek(xFilial("AO3")+cVend))
							aAutoAO4Aux := CRMA200PAut(nOperation,"SA1",cChave,AO3->AO3_CODUSR,/*aPermissoes*/,/*aNvlEstrut*/,RetCodUsr(),/*dDataVld*/)
							aAdd(aAutoAO4[2],aAutoAO4Aux[2][1])
						EndIf
						
					EndIf
					
				EndIf
			EndIf 		
		EndIf
		
	ElseIf nOperation == MODEL_OPERATION_UPDATE
		 
		If Empty( Self:cVendAnt )
			Self:cVendAnt := SA1->A1_VEND
		EndIf
		
		cChave := PadR(xFilial("SA1")+SA1->A1_COD+SA1->A1_LOJA,TAMSX3("AO4_CHVREG")[1])
		
		If !Empty( SA1->A1_VEND )
			
			AO3->( DBSetOrder( 2 ) )	// AO3_FILIAL+AO3_VEND
			
			If AO3->( DBSeek(xFilial("AO3")+Self:cVendAnt) )
				
				AO4->( DBSetOrder( 1 ) )		// AO4_FILIAL+AO4_ENTIDA+AO4_CHVREG+AO4_CODUSR
				
				If AO3->(DbSeek(xFilial("AO3")+Self:cVendAnt))
					
					DbSelectArea("AO4")
					AO4->(DbSetOrder(1))		// AO4_FILIAL+AO4_ENTIDA+AO4_CHVREG+AO4_CODUSR
					
					If !AO4->(DbSeek(xFilial("AO4")+"SA1"+cChave+AO3->AO3_CODUSR))
						aAutoAO4 := CRMA200PAut(nOperation,"SA1",cChave,AO3->AO3_CODUSR,/*aPermissoes*/,/*aNvlEstrut*/,RetCodUsr(),/*dDataVld*/)
					Else
						cUserAnt := AO3->AO3_CODUSR
							
						If AO3->AO3_VEND <> cVend
								
							If AO3->(DbSeek(xFilial("AO3")+cVend)) 
									
								DbSelectArea("AO4")
								AO4->(DbSetOrder(1))		// AO4_FILIAL+AO4_ENTIDA+AO4_CHVREG+AO4_CODUSR
								
								//Verifica se o vendedor atual possui privilegios para este registro.
								If AO4->(DbSeek(xFilial("AO4")+"SA1"+cChave+AO3->AO3_CODUSR))
									//Se possui deleta o acesso do vendedor anterior
									If AO4->(DbSeek(xFilial("AO4")+"SA1"+cChave+cUserAnt))
										RecLock("AO4",.F.)
										AO4->(DbDelete())
										AO4->(MsUnlock())
									EndIf	
								Else
									//Senão troca o privilegios.
									If AO4->(DbSeek(xFilial("AO4")+"SA1"+cChave+cUserAnt))
										RecLock("AO4",.F.)
										AO4->AO4_CODUSR := AO3->AO3_CODUSR
										AO4->AO4_IDESTN := AO3->AO3_IDESTN
										AO4->AO4_NVESTN := AO3->AO3_NVESTN
										AO4->(MsUnlock())
									EndIf
									
								EndIf
									
							EndIf
								
						EndIf
							
					EndIf
						
				EndIf
			EndIf
		ElseIf !Empty(Self:cVendAnt)
			cChaveUSR := AO3->AO3_CODUSR
			If lCRMAZS
				DbSelectArea("AZS")
				DBSetOrder(4)		    // AZS_FILIAL+AZS_VEND
			Else
				DbSelectArea("AO3")
				DbSetOrder(2)			// AO3_FILIAL+AO3_VEND
			EndIf
			
			If DbSeek(xFilial()+Self:cVendAnt)
				If lCRMAZS
					cChaveUSR  := AZS->AZS_CODUSR + AZS->AZS_SEQUEN + AZS->AZS_PAPEL
				EndIf
				 
				DbSelectArea("AO4")
				DbSetOrder(1)		// AO4_FILIAL+AO4_ENTIDA+AO4_CHVREG+AO4_CODUSR
				
				If AO4->(DbSeek(xFilial("AO4")+"SA1"+cChave+cChaveUSR))
					RecLock("AO4",.F.)
					AO4->(DbDelete())
					AO4->(MsUnlock())
				EndIf
			EndIf
		EndIf
	EndIf
	
	If Len(aAutoAO4) > 0
		DbSelectArea("AO4")	
		AO4->(DbSetOrder(1)) 	// AO4_FILIAL+AO4_ENTIDA+AO4_CHVREG+AO4_CODUSR
		If !AO4->(DbSeek(xFilial("AO4")+"SA1"+cChave))
			nOperation := MODEL_OPERATION_INSERT 	
		EndIf
		lRet := CRMA200Auto(aAutoAO4[1],aAutoAO4[2],nOperation)
	EndIf

	If nOperation == MODEL_OPERATION_DELETE
		
		//--------------------------
		//  Exclusao de Anotações
		//--------------------------
		CRMA090Del("SA1",SA1->( Recno() ))
	EndIf	
	
	//----------------------------
	// Gravacao do subsegmentos.
	//----------------------------
	If ( Empty( SA1->A1_CODSEG ) .Or. nOperation == MODEL_OPERATION_DELETE )
		lAOWDeleted := .T.
	EndIf
	
	CRMA620GrvAOW(Self:aAOVMark, "SA1", SA1->A1_COD, SA1->A1_LOJA, SA1->A1_CODSEG, lAOWDeleted)	
		
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Metodo responsável por destruir os atributos da classe como 
arrays e objetos.

@type 		Método
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Method Destroy() Class CRM980EventDEFCRM
	aSize(Self:aAOVMark,0)
	Self:aAOVMark := Nil
Return Nil