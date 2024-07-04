#INCLUDE 'PROTHEUS.CH'
#Include 'FWMVCDef.ch'
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH" 
#INCLUDE "UPDREVFIL.CH"
#DEFINE PULALINHA CHR(13)+CHR(10)
//-------------------------------------------------------------------
/*/{Protheus.doc} UPDREVFIL
Programa para fazer a  update na tabela SBZ campo BZ_REVATU, quando
parametro MV_REVFIL estiver ativo
@author  Thiago.Zoppi
@since   14/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Main Function UPDREVFIL()
Local lGravouLog := .F.
Local nTela		 := 0
Local nTamEmp	 := 0
Local nTamUni	 := 0
Local nTamFil	 := 0
Local oOk        := LoadBitmap( GetResources(), "LBOK" )
Local oNOk       := LoadBitmap( GetResources(), "LBNO" )
Local oList		 := NIL
Local cAux		 := ""

Private __cInterNet:= Nil
Private aEmpresas  := {}

Private cTitulo    :=  STR0001	//'Update SBZ' 
Private cAcao      :=  STR0002	//'Update campo BZ_REVATU' 
Private cArqEmp    := 'SIGAMAT.EMP'
Private cApresenta := ''
Private cItemAju   :=  STR0003	//Andamento Update:
Private cTerAceite := ''
Private cLogUpdate := ''

Private lConcordo  := .F.

Private nAtuTotal  := 0
Private nAtuParci  := 0

Private oTitulo
Private oAcao

Private oEmpAtu
Private oSelEmp

Private oMemo1
Private oMemo2
Private oMemo4

Private oDlgUpd

Private oPanel1
Private oPanel2
Private oPanel3
Private oPanel4
Private oPanel5

Private oMtTotal
Private oMtParci
Private oItemAju

Private oAtuTotal

Private oAtuParc1
Private oAtuParc2
Private oAtuParc3

Private oApresenta

Private oTerAceite
Private oChkAceite

Private oBtnAvanca
Private oBtnCancelar
Private oBtnMark

Private lCrtlManual := .F. // Controla quando a revisão é manual, só vai entrar uma vez na funcao

Default lAutoMacao := .F.


cApresenta := STR0004 +PULALINHA //"Este programa destina-se a empresa que irão fazer o controle de estrutura por filial, utilizando os Indicadores de Produtos Tabela SBZ."

cTerAceite := STR0005 +PULALINHA // "Antes de iniciar a Update, leia integralmente o termo a seguir. Somente depois de aceitá-lo a carga poderá ser iniciada."
cTerAceite += Replicate("-",65) +PULALINHA
cTerAceite += PULALINHA
cTerAceite += STR0006 +PULALINHA//"Este programa tem como objetivo atualizar a tabela SBZ, o campo BZ_REVATU, com os dados já gravados no sistema."
cTerAceite += PULALINHA
cTerAceite += STR0007 +PULALINHA //"Quando Revisão de estrutura estiver configurada como automática MV_REVAUT = T:"
cTerAceite += PULALINHA
cTerAceite += STR0008 +PULALINHA //"- Se tabelas SB1 e SBZ exclusiva grava revisao da SB1(B1_REVATU) na SBZ(BZ_REVATU)"
cTerAceite += PULALINHA
cTerAceite += STR0009 +PULALINHA //"- Se tabela SB1 for compartilhada grava a maior revisao da SG1(G1_REVFIM) na SBZ(BZ_REVATU)""
cTerAceite += PULALINHA

cTerAceite += STR0010 +PULALINHA //"Quando Revisão de estrutura estiver configurada como manual MV_REVAUT = F:"
cTerAceite += PULALINHA
cTerAceite += STR0011 +PULALINHA //"Será apresentado em tela um programa com interação do usuário, para definir oque será feito com cada revisão"
cTerAceite += PULALINHA

cTerAceite += STR0012 +PULALINHA //"Eventuais falhas durante o processamento da carga serão registradas em um arquivo de log para visualização ao término desta rotina."
cTerAceite += PULALINHA

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre o arquivo de Empresas de forma compartilhada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !MyOpenSM0(.T.)
	Final(STR0014)//"SIGAMAT.EMP com problemas!"
EndIf     
SM0->(dbGotop())
While !SM0->(EOF())
	If !SM0->(Deleted())
		cAux    := If(Empty(SM0->M0_LEIAUTE),"FF",SM0->M0_LEIAUTE)
		nTamEmp := 0
		nTamUni := 0
		nTamFil := 0
		While !Empty(cAux)
			If Substr(cAux,1,1) == "E"
				nTamEmp++
			ElseIf Substr(cAux,1,1) == "U"
				nTamUni++
			ElseIf Substr(cAux,1,1) == "F"
				nTamFil++
			EndIf
			cAux := Substr(cAux,2)
		End
		aAdd(aEmpresas, {.F.,SM0->M0_CODIGO,Substr(SM0->M0_CODFIL,1,nTamEmp),Substr(SM0->M0_CODFIL,1+nTamEmp,nTamUni),Substr(SM0->M0_CODFIL,1+nTamEmp+nTamUni,nTamFil),SM0->M0_FILIAL})
	EndIf
	SM0->(dbSkip())
End

IF !lAutoMacao
	DEFINE DIALOG oDlgUpd TITLE STR0015  FROM 0, 0 TO 22, 75 SIZE 550, 350 PIXEL //"SIGAPCP - Update SBZ"
	@ 000,000 BITMAP oBmp RESNAME 'Login' OF oDlgUpd SIZE 095, oDlgUpd:nBottom NOBORDER WHEN .F. PIXEL
	@ 005,070 SAY oTitulo VAR cTitulo OF oDlgUpd PIXEL FONT (TFont():New('Arial',0,-13,.T.,.T.))
	@ 015,070 SAY oAcao VAR cAcao OF oDlgUpd PIXEL
	@ 155,140 BUTTON oBtnCancelar PROMPT STR0016 SIZE 60,14 ACTION If(oBtnCancelar:cCaption == STR0016,oDlgUpd:End(),GravaLog(.T.,cLogUpdate,@lGravouLog)) OF oDlgUpd PIXEL//STR0025//"Cancelar"
	@ 155,210 BUTTON oBtnAvanca   PROMPT STR0017  SIZE 60,14 ACTION If(oBtnAvanca:cCaption  ==STR0018,(GravaLog(.F.,cLogUpdate,lGravouLog),oDlgUpd:End()),SelePanel(@nTela)) OF oDlgUpd PIXEL//"Avançar"//'&Finalizar'
	oDlgUpd:nStyle := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )

	oPanel1 := TPanel():New( 028, 072, ,oDlgUpd, , , , , , 200, 120, .F.,.T. )
	@ 002,005 SAY oApresenta VAR STR0019 OF oPanel1 FONT (TFont():New('Arial',0,-13,.T.,.T.)) PIXEL//"Bem-Vindo!"
	@ 015,005 GET oMemo1     VAR cApresenta  OF oPanel1 MEMO PIXEL SIZE 180,100 FONT (TFont():New('Verdana',,-12,.T.)) NO BORDER
	oMemo1:lReadOnly := .T.

	oPanel2 := TPanel():New( 028, 072, ,oDlgUpd, , , , , , 200, 120, .F.,.T. )
	@ 002,005 SAY oTerAceite VAR STR0020 OF oPanel2 FONT (TFont():New('Arial',0,-13,.T.,.T.)) PIXEL//"Atenção:"
	@ 015,005 GET oMemo2     VAR cTerAceite  OF oPanel2 MEMO PIXEL SIZE 180,90 FONT (TFont():New('Verdana',,-12,.T.)) NO BORDER
	@ 107,107 CheckBox oChkAceite VAR lConcordo PROMPT STR0021 SIZE 80,10 Of oPanel2 PIXEL//"Sim, li e aceito o termo acima."
	oMemo2:lReadOnly   := .T.
	oChkAceite:bChange := {|| Concordo(lConcordo)}

	oPanel3 := TPanel():New( 028, 072, ,oDlgUpd, , , , , , 200, 120, .F.,.T. )

	oList := TWBrowse():New( 05, 05, 190, 110,,{"",STR0025,STR0023,STR0026,STR0024,STR0022},,oPanel3,,,,,,,,,,,,.F.,,.T.,,.F.,,,)//"Descrição"//"Empresa"//"Filial"//"Grupo"//"Unidade"
	oList:SetArray(aEmpresas)
	oList:bLine := {|| {If(aEmpresas[oList:nAT,1],oOk,oNOK),aEmpresas[oList:nAt,2],aEmpresas[oList:nAT,3],aEmpresas[oList:nAT,4],aEmpresas[oList:nAT,5],aEmpresas[oList:nAT,6]}}
	oList:bLDblClick := {|| aEmpresas[oList:nAt,1] := !aEmpresas[oList:nAt,1]}

	oTButMarDe := TButton():New(00,00, ,oList,{|| MarcaTodos(oList)},8,10,,,.F.,.T.,.F.,,.F.,,,.F.)
								
	oPanel4 := TPanel():New( 028, 072, ,oDlgUpd, , , , , , 200, 120, .F.,.T. )
	@ 010,000 SAY oSay       VAR STR0027 OF oPanel4 PIXEL FONT (TFont():New('Arial',0,-11,.T.,.T.))//"Atualizações Realizadas:"
	@ 050,000 SAY oItemAju   VAR cItemAju OF oPanel4 PIXEL FONT (TFont():New('Arial',0,-11,.T.,.T.))
	@ 037,000 SAY oAtuTotal  VAR Space(40) OF oPanel4 PIXEL
	@ 077,000 SAY oAtuParc1  VAR Space(40) OF oPanel4 PIXEL
	@ 087,000 SAY oAtuParc2  VAR Space(40) OF oPanel4 PIXEL
	@ 097,000 SAY oAtuParc3  VAR Space(40) OF oPanel4 PIXEL
	@ 020,000 METER oMtTotal VAR nAtuTotal TOTAL 1000 SIZE 190, 15 OF oPanel4 UPDATE PIXEL
	@ 060,000 METER oMtParci VAR nAtuParci TOTAL 1000 SIZE 190, 15 OF oPanel4 UPDATE PIXEL

	oPanel5 := TPanel():New( 028, 072, ,oDlgUpd, , , , , , 200, 120, .F.,.T. )
	@ 002,005 SAY oLogUpdate VAR STR0027 OF oPanel5 FONT (TFont():New('Arial',0,-13,.T.,.T.))PIXEL//"Atualizações Realizadas:"
	@ 015,005 GET oMemo4     VAR cLogUpdate  OF oPanel5 MEMO PIXEL SIZE 180,90 FONT (TFont():New('Verdana',,-12,.T.)) NO BORDER
	oMemo4:lReadOnly   := .T.

	ACTIVATE DIALOG oDlgUpd CENTER ON INIT SelePanel(@nTela)
ENDIF

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |SelePanel ºAutor  ³Microsiga           º Data ³  01/22/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Controla a atualizacao das interfaces visuais              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ UPD                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SelePanel(nTela)
Local lRet := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza variaveis da janela principal ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTitulo:nLeft           := 120; oTitulo:Refresh()
oAcao:nLeft             := 120; oAcao:Refresh()
oBmp:lVisibleControl    := .T.
oPanel1:lVisibleControl := .F.
oPanel2:lVisibleControl := .F.
oPanel3:lVisibleControl := .F.
oPanel4:lVisibleControl := .F.
oPanel5:lVisibleControl := .F.

Do Case
	Case nTela == 0 //-- Apresentacao
		oPanel1:lVisibleControl := .T.
	Case nTela == 1 //-- Termo de aceite
		oPanel2:lVisibleControl := .T.
		oBtnAvanca:lActive      := .F.
	Case nTela == 2 //-- Selecao da empresa
		oPanel3:lVisibleControl := .T.
		cAcao                   := STR0028; oAcao:Refresh()//"Selecione as filiais para carga"
	Case nTela == 3 //-- Execucao do ajuste
	   If (aScan(aEmpresas,{|x| x[1]}) > 0)
			cAcao                   := STR0029; oAcao:Refresh()//"Execução da carga"
			oPanel4:lVisibleControl := .T.
			oBtnCancelar:lActive    := .F. //-- A partir deste ponto nao pode mais ser cancelado
			oBtnAvanca:lActive      := .F.
			AjustaTabs()
			cItemAju                := STR0030 ; oItemAju:Refresh()//"Andamento da carga de cada tabela:"
			oAtuTotal:cCaption      := STR0031; oAtuTotal:Refresh()//"Carga finalizada!"
			oAtuParc1:cCaption      := STR0032; oAtuParc1:Refresh()//"Carga das tabelas finalizada!"
			oAtuParc2:cCaption      := ''; oAtuParc2:Refresh()
			oAtuParc3:cCaption      := ''; oAtuParc3:Refresh()
			oBtnAvanca:lActive      := .T.
		Else
			lRet := .F.
			oPanel3:lVisibleControl := .T.
			Alert(STR0033)//"Selecione as filiais a serem processadas"
		EndIf
	Case nTela == 4
		cAcao                   := STR0031; oAcao:Refresh()//"Carga finalizada!"
		oPanel5:lVisibleControl := .T.
		oBtnCancelar:cCaption   := STR0034//"&Salvar Log"
		oBtnCancelar:lActive    := .T.
		oBtnAvanca:cCaption     := STR0035//"&Finalizar"
EndCase

If lRet
	nTela ++
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AjustaTabs³ Autor ³ Andre Anjos			³ Data ³06/01/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao de processamento da carga das tabelas               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ UPDREVFIL                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AjustaTabs()
Local nX		:= 0
Local nEmp		:= 0
Local nIniEmp	:= 0
Local aCalend	:= {}
Local aErros	:= {}
Local cRoteiro	:= ""
Local cGrupo	:= ""
Local cCodFil	:= ""
Local cCodEmp	:= ""
Local lProces
Local oModel
Local lErroCT   := .F. 
Local cError    := ""  
Local cNome     := ""
Local cErros    := ""
Local aRetorno  := Array(2)

//Retorno de cada processo individualmente
Local lRetProc		:= {,,,,,,,,,,}
Local nHandle
Local lRet := .T.
Local aAreaNNR := {}

Private c780Cod     := ""  //-- Usada na A780IntSFC
Private c780Desc    := ""  //-- Usada na A780IntSFC
Private nPrecisao   := 0   //-- Usada na A780IntSFC
Private dDate	    := NIL   //-- Usada na A640IntSFC
Private cModulo     := 'PCP'
Private lMsFinalAut := .F.
Private nModulo     := 10 //-- SIGAPCP
Private oMemoLog	:= NIL
Private cErroDIC    := ''    
Private lModFilSG1	
Private lModFilSBZ	
Private lModFilSB1	
Private lARQPRODBZ	
Private lRevFil		
Private lRevAut	
Private cErros
Default lAutoMacao := .F.


nAtuTotal       := 0

IF !lAutoMacao
	oMtTotal:nTotal := 0

	aEval(aEmpresas,{|x| If(x[1],oMtTotal:nTotal++,NIL)})
ENDIF

cLogUpdate += STR0037 +DtoC(Date()) +STR0036 +SubStr(Time(), 1, 5) +PULALINHA//", as "//">> Carga iniciada em "
cLogUpdate += PULALINHA
cLogUpdate += STR0038  +PULALINHA//"LOG Update SBZ"
cLogUpdate += '======================'+PULALINHA


For nEmp := 1 to Len(aEmpresas)
	
	//-- Verifica se a filial deve ser atualizada
	If aEmpresas[nEmp,1]	
		
		cCodFil  := aEmpresas[nEmp,3]+aEmpresas[nEmp,4]+aEmpresas[nEmp,5]
		cErroDIC := ''
		cErros   := ""
		
		nHandle := FCreate("\UPDREVFIL-emp" + aEmpresas[nEmp,2] + "-fil" + cCodFil + ".log")
		IF !lAutoMacao
			oAtuParc3:cCaption := STR0039 +AllTrim(cCodFil +' - ' +aEmpresas[nEmp,6])//"Executando carga para a filial: "
			MsgRun(STR0040 +AllTrim(cCodFil +' - ' +aEmpresas[nEmp,6]) +'...',STR0041,{|| CursorWait(), lRet := AbreEmpre(aEmpresas[nEmp,2], cCodFil, cModulo) ,CursorArrow()})//"Aguarde"//"Iniciando ambiente para a filial "
		ENDIF
		cLogUpdate += PULALINHA
		cLogUpdate += STR0057 +AllTrim(cCodFil +' - ' +aEmpresas[nEmp,6]) +":"//"Ocorrências registradas na filial "
		cLogUpdate += PULALINHA

		lModFilSG1	:= FWModeAccess("SG1",3)== "E"  //Filial
		lModFilSBZ	:= FWModeAccess("SBZ",3)== "E"	//Filial
		lModFilSB1	:= FWModeAccess("SB1",3)== "E" //Filial
		lRevAut		:= SuperGetMV("MV_REVAUT",.F.,"")
		lARQPRODBZ	:= SuperGetMV("MV_ARQPROD",.F.,"SB1") == "SBZ"
		lRevFil		:= SuperGetMv("MV_REVFIL",.F.,.F.) // controla revisao estrutura por filial SBZ	

		IF !lModFilSG1 .OR. !lModFilSBZ // Valida se tabela SBZ e SG1 estão em modo exclusivo
			lRet := .F.
			cErroDIC := STR0058 //"Verificar compartilhamento das Tabelas SBZ e SG1"
		ENDIF
		IF ! lARQPRODBZ
			lRet := .F.
			cErroDIC :=  STR0059 //"Necessário a configuração do parametro MV_ARQPROD = SBZ "
		ENDIF
				
		If lRet 
			cCodEmp != aEmpresas[nEmp,2]
			cCodEmp := aEmpresas[nEmp,2]
		
		Else
			aRetorno[1] := .F.
		EndIf

		IF !lRet
			cErros += cErroDIC + PULALINHA
		Else
		
			SBZupdSX6(.T.) // ATIVA O PARAMETRO PARA REVISÃO COM FILIAL
	
			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.
			
			nAtuParci := 0
			oMtParci:nTotal := 1


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza variaveis da janela principal ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oAtuTotal:cCaption := STR0043 +AllTrim(cCodFil +' - ' +aEmpresas[nEmp,6]); oAtuTotal:Refresh()//"Filial: "
				
			//-- 1. UPDATE TABELA 
			oAtuTotal:cCaption := STR0044; SysRefresh()	//"Processando..."
			
			/*CONTROLE DE REVISAO AUTOMATICO */
			IF lRevAut

				IF lModFilSB1 //SB1 EXCLUSIVA - GRAVA BZ_REVATU IGUAL B1_REVATU
					DBSELECTAREA("SBZ")
					DBSetOrder(1)	
					DBGoTop()
					
					WHILE ! SBZ->(EOF()) .AND. SBZ->BZ_FILIAL == xFilial("SBZ")
						SB1->(dbSetOrder(1))
						If SB1->(dbSeek(xFilial("SB1")+SBZ->BZ_COD))
							RECLOCK("SBZ",.F.)
								REPLACE BZ_REVATU WITH SB1->B1_REVATU
							MSUNLOCK()
						
						ENDIF	

						SBZ->(DBSKIP())
					ENDDO
				
				Else // SB1 COMPARTILHADA - GRAVA B1_REVATU COM O MAIOR VALOR SG1
				  	cAliasQry  := GetNextAlias()
					BeginSql Alias cAliasQry
						SELECT G1_FILIAL,G1_COD, MAX(G1_REVFIM) G1_REVFIM FROM %table:SG1% SG1  INNER JOIN 
						%table:SBZ% SBZ  ON SG1.G1_COD = SBZ.BZ_COD 
						WHERE 
						SG1.%notDel%	
						AND SBZ.%notDel%
						AND SG1.G1_FILIAL = %Exp:cCodFil%
						GROUP BY G1_FILIAL,G1_COD	

					EndSql

					WHILE (cAliasQry)->(!EOF())
					
						DBSELECTAREA("SBZ")
						DBSetOrder(1)	
						IF DBSeek((cAliasQry)->G1_FILIAL+(cAliasQry)->G1_COD)
							RECLOCK("SBZ",.F.)
								REPLACE BZ_REVATU WITH (cAliasQry)->G1_REVFIM
							MSUNLOCK()
						ENDIF

						(cAliasQry)->(DBSKIP())
					ENDDO
				ENDIF
			
			Else // Controle de revisao Manual 
			  	IF ! lCrtlManual 
					if AllTrim(cErros) = ""
						cErros:= UPDREV01(aEmpresas)
						lCrtlManual  := .T. 
					Endif
				ENDIF	 
					
			ENDIF
			
			
			oMtParci:Set(++nAtuParci); SysRefresh()	
									
				//Fecha o arquivo com erros da filial
				FClose(nHandle)
				//Verifica se ocorreu erro em algum processo
											
				//Se houver qualquer erro informa o arquivo criado
				If AllTrim(cErros) != ""
					cErros += PULALINHA + STR0045 + "(UPDREVFIL-emp" + aEmpresas[nEmp,2] + "-fil" + cCodFil + ".log)" + STR0046
					cErros += PULALINHA
				EndIf
			
		Endif

		cLogUpdate += cErros
		If !Empty(cErros) 
			if lRet .or. !aRetorno[1] // Quando erro de não existir parâmetro, não deve apresentar esta mensagem
				cLogUpdate += STR0047 //"*IMPORTANTE: o parâmetro de controle dre revisão (MV_REVFIM) foi desativado para que as ocorrências listadas sejam ajustadas. "
				cLogUpdate += STR0048 + PULALINHA //"Após estes ajustes o update deverá ser processado novamente."
			Endif
			
			SBZupdSX6(.F.)
		Else
			cLogUpdate += STR0049 //"*IMPORTANTE: o parâmetro de controle da integração (MV_REVFIL) foi ativado, já que a carga foi processada com sucesso."
			cLogUpdate += PULALINHA
		EndIf
		
		IF !lAutoMacao
			oMtTotal:Set(++nAtuTotal); SysRefresh()	
			MsgRun(STR0050+AllTrim(cCodFil +' - ' +aEmpresas[nEmp,6]),STR0051,/*{|| RpcClearEnv()}*/)//"Aguarde..."//"Finalizando ambiente da filial "
		ENDIF
	EndIf
Next nEmp

RpcClearEnv()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MyOpenSM0   ³ Autor ³ Microsiga		    ³ Data ³07/01/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a abertura do SM0 exclusivo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ UPD														  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MyOpenSM0(lCompart)
Local lOpen      := .F.
Local nLoop      := 0

If Select('SM0') > 0
	dbSelectArea('SM0')
	dbCloseArea()
EndIf

For nLoop := 1 To 20
	//dbUseArea(.T.,, 'SIGAMAT.EMP', 'SM0', lCompart, lCompart )
	OpenSm0(,.T.)
	If Select('SM0') > 0
		lOpen := .T.
		//dbSetIndex('SIGAMAT.IND')
		Exit
	EndIf
	Sleep(500)
Next nLoop

Return lOpen

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |AbreEmpre ºAutor  ³ Microsiga          º Data ³  01/18/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao que abre conexao para a empresa selecionada         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cCodEmp: Codigo da empresa								  º±±
±±º			 ³ cCodFil: Codigo da filial								  º±±
±±º			 ³ cModulo: Modulo								  			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ UPD                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AbreEmpre(cCodEmp, cCodFil, cModulo)
Local lRet := .T.

IF cCodEmp != SM0->M0_CODIGO
	RpcSetType(3) //-- Nao consome licensas
	RpcSetEnv(cCodEmp, cCodFil,,,cModulo) //-- Inicializa as variaveis genericas e abre a empresa/filial

Else
	dbSelectArea('SM0')
	SM0->(dbSetOrder(1))
	SM0->(dbSeek(cCodEmp+cCodFil))
	
	cFilAnt := SM0->M0_CODFIL
Endif

DBSELECTAREA("SX6")
DBSetOrder(1)
IF DBSeek(xFilial("SX6")+"MV_REVFIL")
    cErroDIC := STR0052  //"Crie o parâmetro MV_REVFIL e execute o UPDREVFIL novamente. "
	lRet := .T. 

EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  | Concordo ºAutor  ³ Microsiga          º Data ³  01/18/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para controlar a marcacao do checkbox				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ lConcordo: indica se o checkbox esta marcado ou nao		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ UPD                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Concordo(lConcordo)

If lConcordo
	oBtnAvanca:lActive := .T.
Else
	oBtnAvanca:lActive := .F.
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  | GravaLog ºAutor  ³ Microsiga          º Data ³  01/26/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para gerar o arquivo de log do update.			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ lSalvaUsu: indica se abre dialog para o usuario digitar	  º±±
±±º			 ³ cTexto: texto a ser gravado no arquivo					  º±±
±±º			 ³ lRet: indica se o log ja foi gerado pelo usuario			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ UPD                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GravaLog(lSalvaUsu, cTexto, lRet)
Local cFile  := ''
Local cMask	 := STR0053//"Arquivos de Log (*.LOG) |*.log|"
Local nOcorr := 0

Default lAutomacao := .F.

If !lRet
	If lSalvaUsu
		cFile := cGetFile(cMask, '')
	EndIf	
	If Empty(cFile)
		cFile := 'Log_UPD'+Right(CriaTrab(,.F.), 3)+'.LOG'
		Do While File(cFile)
			cFile := 'Log_UPD'+Right(CriaTrab(,.F.), 3)+'.LOG'
		EndDo
		nOcorr := 1
	ElseIf !(Upper(Right(cFile, 3))=='.LOG')	
		cFile += '.LOG'
		nOcorr := 2
	EndIf
	
	lRet := MemoWrite(cFile, cTexto)
	
	If !lAutomacao 
		If nOcorr == 1
			Aviso('Ajuste SBZ', STR0068 +cFile, {'Ok'}) //"Log gerado : "   
		ElseIf nOcorr == 2
			Aviso('Ajuste SBZ',STR0056 +cFile +').', {'Ok'})//"A extencao '.LOG' foi adicionada ao arquivo, que foi salvo do diretorio escolhido ("
		EndIf
	EndIf 
EndIf	

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SBZupdSX6 ºAutor  ³ Samantha Preima    º Data ³  17/01/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualiza parametro MV_REVFIL.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ UPDREVFIL                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SBZupdSX6(lconteud)
	PutMv('MV_REVFIL',lconteud)
Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MarcaTodosºAutor  ³ Leonardo Quintania º Data ³  18/03/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cria parametro MV_INTSFC.                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ UPDREVFIL                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MarcaTodos( oBrowse )

If aScan(oBrowse:aArray, {|x| !x[1] }) > 0
	aEval(@oBrowse:aArray, {|x| x[1] := .T.})
Else
	aEval(@oBrowse:aArray, {|x| x[1] := .F.})
EndIf

oBrowse:Refresh()

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} UPDREV01
Ajuste da base de dados
@author  Thiago.Zoppi
@since   20/09/2018
/*/
//-------------------------------------------------------------------
STATIC Function UPDREV01(aEmpresas )
    local oFont1 := TFont():New("MS Sans Serif",,018,,.F.,,,,,.F.,.F.)
	Local oFont2 := TFont():New("MS Sans Serif",,018,,.T.,,,,,.F.,.F.)
    Local oSay1, oSay2
    Local aButtons      := {}  
    Local oRadMenu1
    Local nROpc := 0
    Local nEmp
    Local lOk   := .T.
    Static oDlg
    Private oGet1
    Private cGet1 := SPACE(6)
    Private aHeaderEx   := {}
	Private aColsEx     := {}
    Private oMSNewGe1
    Private cFil     := ''
    Private cExpFil  := ''
	Private acodEmp	 := {} 	
    Private cErro   :=  STR0060 //"--> Update nao Processado" 
   	
    Static oDlg
	
	Default lAutoMacao := .F.

    FOR nEmp := 1 TO LEN(aEmpresas) 
        IF aEmpresas[nEmp,1]
         		// VERIFICA SE EXISTE MAIS QUE UMA EMPRESA
				//PEGA A PRIMEIRA FILIAL, SÓ VAI SER NECESSÁRIO PARA ALTERAR O GRUPO DE EMPRESA
			IF aScan(acodEmp,{|x| Upper(Alltrim(x[1])) ==  aEmpresas[nEmp,2] } ) = 0 
				AADD(acodEmp,{aEmpresas[nEmp,2],aEmpresas[nEmp,3]+aEmpresas[nEmp,4]+aEmpresas[nEmp,5],aEmpresas[nEmp,6] })
			EndIf	
        Endif
    NEXT N
    
	IF !lAutoMacao
		DEFINE MSDIALOG oDlg TITLE STR0015 FROM 0,0 TO 700, 820 COLORS 0, 16777215 PIXEL //"SIGAPCP - Update SBZ"
		fMSNewGe1()
			@ 049, 008 RADIO oRadMenu1 VAR nROpc ITEMS STR0061 ,STR0062 ,STR0063 ,STR0064 ;  // "Menor revisão","Maior Revisao","Revisao Atual","Limpar Marcações"
			SIZE 111, 031 OF oDlg COLOR 0, 16777215 ON CHANGE markrev(nROpc) PIXEL
			@ 023, 006 SAY oSay2 PROMPT STR0065  SIZE 116, 008 OF oDlg COLORS 0, 16777215 PIXEL //"Programa de Ajustes de campos
			@ 041, 006 SAY oSay1 PROMPT STR0066 SIZE 109, 007 OF oDlg COLORS 0, 16777215 PIXEL //"Selecionar Opções "

		
		ACTIVATE MSDIALOG oDlg CENTER ON INIT (EnchoiceBar(oDlg,{||Processa({||GERARB(@cErro), IIF(EMPTY(cErro),oDlg:End(),lOk := .F. ) }, "Ajustando Base","Processando",)},{||oDlg:End()},,@aButtons))    
	ENDIF
Return cErro

Static Function fMSNewGe1(aPosicao)
	Local nX, Ny
    Local nLinha        := 0
	Local aFieldFill    := {}
	Local aFieldL       := {}
    Local aFields   	:= {}
	Local aAlterFields  := {"REVISAO"}
	Local lRet			:= .T.
    Private cAlias		:= ''
	Default lAutoMacao  := .F.
	
	
	aHeaderEx  := {}
	aColsEx    := {}
	
	// Define field properties
    Aadd(aHeaderEx,{"Linha"     	,"LINHA"        ,'@!',5                                         ,0,".T.","","","","R","","",.F.,"V","","","",""})
    Aadd(aHeaderEx,{"Filial"    	,"FILIAL"       ,'@!',IIF(!lAutoMacao,TAMSX3("G1_FILIAL")[1],08),0,".T.","","","","R","","",.F.,"V","","","",""})
    Aadd(aHeaderEx,{"Codigo"    	,"CODIGO"       ,'@!',IIF(!lAutoMacao,TAMSX3("B1_COD")[1]   ,15),0,".T.","","","","R","","",.F.,"V","","","",""})
    Aadd(aHeaderEx,{"Descricao" 	,"DESCRICAO"    ,'@!',IIF(!lAutoMacao,TAMSX3("B1_DESC")[1]  ,30),0,".T.","","","","R","","",.F.,"V","","","",""})
    Aadd(aHeaderEx,{"Revisao"   	,"REVISAO"      ,"@!",IIF(!lAutoMacao,TAMSX3('B1_REVATU')[1],03),0,".T.","","","","R","",""})
    Aadd(aHeaderEx,{"Menor.Rev" 	,"REVMENOR"     ,"@!",IIF(!lAutoMacao,TAMSX3('B1_REVATU')[1],03),0,".T.","","","","R","","",.F.,"V","","","",""})
    Aadd(aHeaderEx,{"Maior.Rev" 	,"REVMAIOR"     ,"@!",IIF(!lAutoMacao,TAMSX3('B1_REVATU')[1],03),0,".T.","","","","R","","",.F.,"V","","","",""})
    Aadd(aHeaderEx,{"Rev.Atual" 	,"REVATUAL"     ,"@!",IIF(!lAutoMacao,TAMSX3('B1_REVATU')[1],03),0,".T.","","","","R","","",.F.,"V","","","",""})
	Aadd(aHeaderEx,{"Gr.Emp/Filial" ,"GRPFIL"	    ,"@!",40					                    ,0,".T.","","","","R","","",.F.,"V","","","",""})
	
    
	// Define field values
	aAdd(aFieldFill,Array(Len(aHeaderEx)+1))
    
	
    Aadd(aFieldFill, )
    
    Aadd(aFieldFill,SPACE(5)                                             )
    Aadd(aFieldFill,IIF(!lAutoMacao, CRIAVAR("G1_FILIAL",.F.), SPACE(08)))
    Aadd(aFieldFill,IIF(!lAutoMacao, CRIAVAR("B1_COD",.F.)	 , SPACE(15)))
    Aadd(aFieldFill,IIF(!lAutoMacao, CRIAVAR("B1_DESC",.F.)	 , SPACE(30)))
    Aadd(aFieldFill,IIF(!lAutoMacao, CRIAVAR('B1_REVATU',.F.), SPACE(03)))
    Aadd(aFieldFill,IIF(!lAutoMacao, CRIAVAR('B1_REVATU',.F.), SPACE(03)))
    Aadd(aFieldFill,IIF(!lAutoMacao, CRIAVAR('B1_REVATU',.F.), SPACE(03)))
    Aadd(aFieldFill,IIF(!lAutoMacao, CRIAVAR('B1_REVATU',.F.), SPACE(03)))
	
	Aadd(aFieldFill, .F.)
    
	FOR NY := 1 TO LEN(acodEmp)
		
		lRet:= trocaGrp(acodEmp[NY][1], acodEmp[NY][2] ) 

		If lRet 
			cExpFil		:= GrpFil(acodEmp[NY][1])
			cAlias		:= getnextalias()
			

			Beginsql Alias cAlias
				SELECT 
				G1_FILIAL, 
				G1_COD,
				B1_DESC, 
				MIN(G1_REVFIM)  MENOR  ,
				B1_REVATU, 
				(SELECT MAX(SG1M.G1_REVFIM) FROM %table:SG1% SG1M WHERE  SG1M.G1_COD = SG1.G1_COD AND SG1.G1_FILIAL = SG1M.G1_FILIAL AND SG1M.%NotDel%  )  MAIOR
				FROM %table:SG1% SG1 
				INNER JOIN %table:SB1% SB1  ON B1_COD = G1_COD
				INNER JOIN %table:SBZ% SBZ  ON BZ_COD = G1_COD AND BZ_FILIAL = G1_FILIAL
				WHERE SG1.%notDel%		
				AND SB1.%notDel%	
				AND SBZ.%notDel%
				AND SG1.G1_FILIAL IN ( %Exp:cExpFil% )	
				GROUP BY G1_FILIAL, G1_COD , B1_REVATU, B1_DESC

				ORDER BY 1,2 

			ENDSQL
		
			WHILE !(Eof())
			nlinha++
				aFieldl    := aclone(aFieldFill)
					aFieldl[1] := StrZero(nlinha,5)		 
					aFieldl[2] := (cAlias)->G1_FILIAL 
					aFieldl[3] := (cAlias)->G1_COD		
					aFieldl[4] := (cAlias)->B1_DESC		 
					aFieldl[6] := (cAlias)->MENOR		
					aFieldl[7] := (cAlias)->MAIOR			
					aFieldl[8] := (cAlias)->B1_REVATU
					aFieldl[9] := acodEmp[NY][1] +'-'+ALLTRIM((cAlias)->G1_FILIAL)
					
				Aadd(aColsEx, aFieldl)
				
				aFieldl := {}
		
				DBSKIP()
			ENDDO
		Endif

	Next Ny

	IF !lAutoMacao
		oMSNewGe1 := MsNewGetDados():New(  096, 007, 348, 404,GD_UPDATE,"AllwaysTrue" ,"AllwaysTrue" ,"+Field1+Field2",aAlterFields,, 99999, "AllwaysTrue",'',/*bfDeleta*/, oDlg, aHeaderEx, aColsEx)
	ENDIF
Return

Static Function GERARB()
	Local Nx
    Local N
    Local nlinha  	:= aScan(aHeaderex,{|x| Upper(Alltrim(x[2])) == "LINHA"})
    Local nFilial   := aScan(aHeaderex,{|x| Upper(Alltrim(x[2])) == "FILIAL"})
    Local nRev      := aScan(aHeaderex,{|x| Upper(Alltrim(x[2])) == "REVISAO"})
    Local nCod      := aScan(aHeaderex,{|x| Upper(Alltrim(x[2])) == "CODIGO"})
    Local nDesc     := aScan(aHeaderex,{|x| Upper(Alltrim(x[2])) == "DESCRICAO"})
    Local nRevMenor := aScan(aHeaderex,{|x| Upper(Alltrim(x[2])) == "REVMENOR"})
    Local nRevMaior := aScan(aHeaderex,{|x| Upper(Alltrim(x[2])) == "REVMAIOR"})
    Local nRevAtual := aScan(aHeaderex,{|x| Upper(Alltrim(x[2])) == "REVATUAL"})
	Local NGRPFIL	:= aScan(aHeaderex,{|x| Upper(Alltrim(x[2])) == "GRPFIL"})
	Local lErro     := .F.
   

    For n := 1 to LEN(oMSNewGe1:aCols)
        
		If empty( OMSNEWGE1:ACOLS[N][nRev] )
            HELP(' ',1,STR0015,,STR0067 +Alltrim(OMSNEWGE1:ACOLS[N][nCod])+'-'+alltrim(OMSNEWGE1:ACOLS[N][nDesc]) ,2,0,,,,,, {"Preencher a Revisão da Linha: "+ OMSNEWGE1:ACOLS[N][nLinha]    }) // "Item sem Revisão:"
        Return 
        
        EndIf
    Next n 

	FOR nX := 1 to LEN(oMSNewGe1:aCols) 
		cEmpalt 	:= substr(OMSNEWGE1:ACOLS[NX][NGRPFIL],1,AT("-",OMSNEWGE1:ACOLS[NX][NGRPFIL])-1) 
		
		IF  SM0->M0_CODIGO  != cEmpalt
			trocaGrp(cEmpalt,OMSNEWGE1:ACOLS[NX][nFilial] )
		ENDIF

        cUpdate :=" UPDATE " 
        cUpdate += RetSqlName("SBZ")  
        cUpdate += " SET BZ_REVATU = '" + OMSNEWGE1:ACOLS[NX][nRev]      +"'"
        cUpdate += " WHERE BZ_FILIAL ='"+ OMSNEWGE1:ACOLS[NX][nFilial]   +"'" 
        cUpdate += " AND BZ_COD = '"    + OMSNEWGE1:ACOLS[NX][nCod]+"'"  + " AND D_E_L_E_T_ = ''"
        
        If TcSqlExec(cUpdate) < 0
          cErro += PULALINHA 
          cErro += "Erro Base : " + TCSQLError()
          lErro := .T.          
        EndIf
    Next Nx    	

    // se nao tiver erros segue o
    IF ! lErro 
         cErro := ''   
    Endif

RETURN cErro


Static function markrev(nROpc)
Local nRev      := aScan(aHeaderex,{|x| Upper(Alltrim(x[2])) == "REVISAO"})
Local nRevMenor := aScan(aHeaderex,{|x| Upper(Alltrim(x[2])) == "REVMENOR"})
Local nRevMaior := aScan(aHeaderex,{|x| Upper(Alltrim(x[2])) == "REVMAIOR"})
Local nRevAtual := aScan(aHeaderex,{|x| Upper(Alltrim(x[2])) == "REVATUAL"})
Local N

FOR N := 1 TO LEN(oMSNewGe1:aCols)
    
    IF nROpc = 1
        OMSNEWGE1:ACOLS[N][nRev] := OMSNEWGE1:ACOLS[N][nRevMenor]
    ElseIf nROpc = 2 
        OMSNEWGE1:ACOLS[N][nRev] := OMSNEWGE1:ACOLS[N][nRevMaior]
    ElseIf nROpc = 3 
        OMSNEWGE1:ACOLS[N][nRev] := OMSNEWGE1:ACOLS[N][nRevAtual]
    ElseIf nROpc = 4 
        OMSNEWGE1:ACOLS[N][nRev] := CRIAVAR("B1_REVATU")
    Endif    

next N

oMSNewGe1:refresh()
Return


Static Function trocaGrp(cCodEmp, cCodFil)
	Local lRet := .T.
	Default lAutoMacao := .F.

		dbCloseAll() //Fecho todos os arquivos abertos
		OpenSM0() //Abrir Tabela SM0 (Empresa/Filial)
		
		dbSelectArea("SM0") //Abro a SM0
		SM0->(dbSetOrder(1))
		SM0->(dbSeek(cCodEmp+cCodFil))

		cEmpAnt := SM0->M0_CODIGO //Seto as variaveis de ambiente
		cFilAnt := SM0->M0_CODFIL
		IF !lAutoMacao
			OpenFile(cEmpAnt + cFilAnt) //Abro a empresa que eu desejo trabalhar
		ENDIF

Return lRet 

// buscas as filias por grupo de empresas
Static FUnction GrpFil(cCodEmp)
local cFil     := ''
Local cExpFil  := ''
Local nEmp

 FOR nEmp := 1 TO LEN(aEmpresas) 
    
    IF aEmpresas[nEmp,2] = cCodEmp 
	    IF aEmpresas[nEmp,1]
	        
	        if Empty(cfil)
	            cfil := "'"+ aEmpresas[nEmp,3]+aEmpresas[nEmp,4]+aEmpresas[nEmp,5] +"'" 
	        Else
	            cfil += ",'" + aEmpresas[nEmp,3]+aEmpresas[nEmp,4]+aEmpresas[nEmp,5] +"'" 
	        Endif  

	    Endif
	Endif
	    
NEXT N

 // RETIRA A PRIMEIRA E ULTIMA "'" ASPAS DA STRING PARA SER UTILIZAD NO %EXP: DO BEGINSQL. 
  cExpFil := substr(cfil,AT("'",cfil)+1,RAT("'",cfil)-2  )

return cExpFil
