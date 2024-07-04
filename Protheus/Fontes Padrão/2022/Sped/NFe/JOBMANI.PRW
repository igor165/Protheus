#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"   

//-----------------------------------------------------------------------
/*/{Protheus.doc} MANISINC
Função para sincronizar manifestos de destinatarios via JOB

@author Leonardo Kichitaro
@since 27.07.2014
@version 1.00
/*/
//-----------------------------------------------------------------------
Main Function MANISINC(cEmpJob,cFilJob,cTime)

Local cHoraIni  := ""
Local cHoraFim  := ""
Local cHoraUlt  := "00:00:01"
Local cHora     := cHoraUlt
Local cAtivo    := "ON"

Local nIntervalo:= 0

DEFAULT cEmpJob	:= "99"
DEFAULT cFilJob	:= "01"
DEFAULT cTime	:= "5"

//-- Evita que se consuma licenca
RpcSetType( 3 )

PREPARE ENVIRONMENT EMPRESA cEmpJob FILIAL cFilJob MODULO "FAT"

While cAtivo == "ON" .And. !Killapp()
	cHoraIni	:= "00:00:01"
	cHoraFim	:= "23:59:59"
	nIntervalo	:= Val(cTime)
	cAtivo		:= "ON"
	lExecuta	:= .F.

	If Time() >= cHoraIni .And. Time() <= cHoraFim
		cHora := cHoraUlt
		SomaDiaHor(Date(),@cHora,nIntervalo/60)
		If Time() >= cHora .Or. nIntervalo == 0
			cHoraUlt := Time()
			lExecuta := .T.
		EndIf
	Else
		cAtivo := "OFF"
	EndIf

	If lExecuta
		GetMDeSinc(1)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Espera                                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Sleep(1000)

	If KillApp()
		Exit
	EndIf
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Finalisando o ambiente para execucao                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RESET ENVIRONMENT

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} JobMani
Função para sincronizar manifestos de destinatarios via Schedule.

@author  Sergio S. Fuzinaka
@since   26.01.2015
@version 12
/*/
//-----------------------------------------------------------------
Function JobMani()

GetMDeSinc(2)

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} GetMDeSinc
Executa a funcionalidade do menu 'Sincronizar'

@author Leonardo Kichitaro
@since 27.07.2014
@version 1.00
/*/
//-----------------------------------------------------------------------  
Static Function GetMDeSinc( nOpcao )

Local aChave	:= {}
Local aDocs		:= {}

Local cURL		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
local lUsaColab	:= UsaColaboracao("4")
Local cIdEnt	:= RetIdEnti(lUsaColab)
Local cChave	:= ""
Local cCancNSU	:= ""
Local cSitConf	:= ""
Local cAmbiente	:= "" 
Local lContinua	:= .T.
Local lWs		:= .F.

Local dData		:= CtoD("  /  /    ")

Local lOk       := .F.
Local lDestcnpj := .T.
Local nX		:= 0
Local nZ		:= 0
Local aProc		:= {}                 

Private oWs		:= Nil

Private lUsaColab		:= .F.

Default nOpcao	:= 1

If nOpcao == 1
	ConOut("SINCRONIZACAO MD-E VIA JOB => Entidade: "+cIdEnt)
Else
	ConOut("SINCRONIZACAO MD-E VIA SCHEDULE => Entidade: "+cIdEnt)
Endif

If ReadyTSS()

	oWs:=WSMANIFESTACAODESTINATARIO():New()
	oWs:cUserToken   := "TOTVS"
	oWs:cIDENT	     := cIdEnt
	oWs:cINDNFE		 := "0"
	oWs:cINDEMI      := "0"
	oWs:cAMBIENTE	 := ""
	oWs:cVERSAO      := ""
	oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw"
	
	oWs:CONFIGURARPARAMETROS()
	cAmbiente		 := oWs:OWSCONFIGURARPARAMETROSRESULT:CAMBIENTE 
	
	//Tratamento para solicitar a sincronização enaquanto o IDCONT não retornar zero.

	While lContinua

		lWs := oWs:SINCRONIZARDOCUMENTOS()

		If lWs <> Nil .And. lWs

			If Type ("oWs:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO") <> "U"

				If Type("oWs:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO")=="A"
					aDocs := oWs:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO                  
				Else
					aDocs := {oWs:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO}
				EndIf
			
				For nX := 1 To Len(aDocs)
					lDestcnpj:=.T.
					If Type(aDocs[nX]:CCHAVE) <> "U" .and. Type(aDocs[nX]:CSITCONF) <> "U" 

					    cSitConf  := aDocs[Nx]:CSITCONF
					    cChave    := aDocs[Nx]:CCHAVE  
					    cCancNSU  := aDocs[Nx]:CCANCNSU
					    
					    If ValType(aDocs[Nx]:CCODEVENTO) <> "U"
					    	cCodEvento:= aDocs[Nx]:CCODEVENTO
					    Else
					    	CodEvento:= ""
					    EndIf
					    
					    If ValType(aDocs[Nx]:cDESTCNPJ) <> "U" .AND. !empty(aDocs[Nx]:cDESTCNPJ)
					    	If SM0->M0_CGC <> aDocs[Nx]:cDESTCNPJ
					    		lDestcnpj:= .F.
					   		EndIf
					    EndIf
					    
						// Caso o doc sincronizado tenha TPEVENTO não deve ir pra tabela C00
						If !cCodEvento $ "411500|411501|411502|411503" .and. lDestcnpj
							C00->( dbSetOrder( 1 ) )
							If C00->( !dbSeek( xFilial("C00") + cChave) )
							
								RecLock("C00",.T.)
								C00->C00_FILIAL     := xFilial("C00")
								C00->C00_STATUS     := cSitConf
								C00->C00_CHVNFE		:= cChave
								dData := CtoD("01/"+Substr(cChave,5,2)+"/"+Substr(cChave,3,2))
								C00->C00_ANONFE		:= Strzero(Year(dData),4)
								C00->C00_MESNFE		:= Strzero(Month(dData),2)
								C00->C00_SERNFE		:= Substr(cChave,23,3)
								C00->C00_NUMNFE		:= Substr(cChave,26,9)
								C00->C00_CODEVE		:= Iif(cSitConf $ '0',"1","3")
								C00->( MsUnLock() )
								
								aadd(aChave,cChave)
								
								lOk := .T.
	
								If ExistBlock("MANIGRV")
									ExecBlock("MANIGRV",.F.,.F.,{Substr(cChave,23,3),Substr(cChave,26,9),cChave,cSitConf})
								EndIf
	
							Else
	
								If !Empty(cCancNSU)
									RecLock("C00",.F.)
									C00->C00_SITDOC := "3"
									C00->( MsUnLock() )
								EndIf
	
							EndIf					
						EndIf
					EndIf	

				Next                   
				
				If lOk

					For nZ := 1 To Len( aChave )
					
						AADD( aProc, aChave[nZ] )
					                             
						If Len( aProc ) >= 30
							MonitoraManif( aProc, cAmbiente, cIdEnt, cUrl, .T. )
							aProc := {}
						Endif
						
					Next

					If Len( aProc ) > 0
						MonitoraManif( aProc, cAmbiente, cIdEnt, cUrl, .T. )
					Endif

				EndIf
				
				If Type("oWs:OWSSINCRONIZARDOCUMENTOSRESULT:CINDCONT") <> "U"
						
					If oWs:OWSSINCRONIZARDOCUMENTOSRESULT:CINDCONT == "0"
						lContinua := .F.						               
					endif	
				else
					lContinua := .F.				
				endif

			EndIf	
			
		Else
		
			lContinua := .F.

		EndIf

	EndDo	

EndIf

oWs := Nil
DelClassIntf()

Return

Static Function ReadyTSS(cURL,nTipo,lHelp)
Return (CTIsReady(cURL,nTipo,lHelp))

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Retorna as perguntas definidas no schedule.

@return aReturn			Array com os parametros

@author  Sergio S. Fuzinaka
@since   26.01.2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function SchedDef()

Local aParam  := {}

aParam := { "P",;			//Tipo R para relatorio P para processo
            "PARAMDEF",;		//Pergunte do relatorio, caso nao use passar ParamDef
            ,;				//Alias
            ,;				//Array de ordens
            }				//Titulo

Return aParam

