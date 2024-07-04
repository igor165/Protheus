#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "QNCA030.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QNCA030  ³ Autor ³ Aldo Marini Junior    ³ Data ³ 29.12.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastramento do Plano de Acao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Eduardo S.  ³01/10/02³ ---- ³ Alterado para permitir a baixa aleatoria ³±±
±±³            ³        ³      ³ de etapas e alterado para permitir a mo- ³±±
±±³            ³        ³      ³ dificacao da descricoes das etapas.      ³±±
±±³Eduardo S.  ³02/10/02³016389³ Acerto para trazer em branco as descri-  ³±±
±±³            ³        ³      ³ coes quando incluida uma nova etapa/acao.³±±
±±³Eduardo S.  ³21/10/02³ ---- ³ Acerto para preencher o titulo do docto. ³±±
±±³Eduardo S.  ³30/10/02³059272³ Alterado para disparar as pendencias so- ³±±
±±³            ³        ³      ³ mente apos definir que a acao Procede.   ³±±
±±³Eduardo S.  ³06/11/02³ Melh ³ Incluido a opcao "Documento Anexo" permi-³±±
±±³            ³        ³      ³ tindo anexar mais de um Docto por Plano. ³±±
±±³Eduardo S.  ³22/11/02³061054³ Incluido o parametro "MV_QNCAPLA" verifi-³±±
±±³            ³        ³      ³ cando se o responsavel pode alterar plano³±±
±±³Eduardo S.  ³10/01/03³ xxxx ³ Alterado para permitir pesquisar usuarios³±±
±±³            ³        ³      ³ entre filiais na consulta padrao.        ³±±
±±³Eduardo S.  ³03/02/03³Ficha ³ Alterado para verificar a existencia do  ³±±
±±³            ³        ³      ³ diretorio de documentos anexos.          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function MenuDef(lRotina)
Local aRotina := {}
Local cFilPend := GETMV("MV_QNCPACO")
Default lRotina := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametro para definir se havera o retorno para um novo cadastro quando a opcao   ³
//³ for de inclusao. 1-Abrira novamente tela de Inclusao 2-Retorno para mbrowse       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nOpcInclui := If(lRotina,If(GETMV("MV_QNCIOPC",.F.,1)==1 .Or.;
				   ! QI3->(DbSeek(xFilial("QI3"))),3,6),3)

aAdd(aRotina, { STR0001 , "AxPesqui" , 0 , 1,,.F.} )  //"Pesquisar"
aAdd(aRotina, { STR0002 , "QNC030Alt", 0 , 2     } )  //"Visualizar"
aAdd(aRotina, { STR0003 , "QNC030Alt", 0 , 3     } )  //"Incluir"
aAdd(aRotina, { STR0004 , "QNC030Alt", 0 , 4     } )  //"Alterar"
aAdd(aRotina, { STR0005 , "QNC030Alt", 0 , 5     } )  //"Excluir"
aAdd(aRotina, { STR0032 , "QNC030Rev", 0 , 6     } )  //"Gera Revisao"
If cFilPend == "N"
	aAdd(aRotina, { STR0042 , "QNC030Sel" , 0 , 6,,.F.} )  //"Muda Selecao"
Endif
aAdd(aRotina, { STR0048 , "QNCA030IMP" , 0 , 6,,.F.} )  // "Imprime"
aAdd(aRotina, { STR0043 , "QNC030Legen" ,0, 6,,.F.} )  // "Legenda"

Return aRotina

Function QNCA030()

Local cFilPend := GETMV("MV_QNCPACO")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametro para definir se havera o retorno para um novo cadastro quando a opcao   ³
//³ for de inclusao. 1-Abrira novamente tela de Inclusao 2-Retorno para mbrowse       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nOpcInclui := If(GETMV("MV_QNCIOPC",.F.,1)==1 .Or.;
					! QI3->(DbSeek(xFilial("QI3"))),3,6)
Local lTMKPMS 		 := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
Local cFil      := ""
Local lQNC030Fil := ExistBlock("QNC030Fil")
Local aIndexQI3  := {}
Local cFiltraQI3 := ""
Local bFiltraBrw := {||} 
Local aRotAdic:={}

Private lFunFNC   := .F. 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ O nOpc = 7 do aRotina esta sendo utilizado pelo do Cad. FNC relacionada  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aCores := {}
Private aQLegenda := {}
Private aRotina := MenuDef(.T.)
Private aHeadAne := {} 
Private aColAnx  := {}
Private aHdQI5   := {}
Private aHdQI8	 := {}
Private lWhenTp  :=.T.

	If !lTMKPMS
	aCores :={{'QI3->QI3_OBSOL=="S"' , 'BR_PRETO'},;
                  {"Empty(QI3->QI3_ENCREA)"  , 'DISABLE'},;
                  {'QI3->QI3_STATUS=="4"'    , 'BR_CINZA'},;   
				  {'QI3->QI3_STATUS=="5"'    , 'BR_MARROM'},;
                  {"!Empty(QI3->QI3_ENCREA)" , 'ENABLE' }}
	aQLegenda := { {'ENABLE' , OemtoAnsi(STR0046) },;	// "Plano de Acao Baixado"
                  {'BR_MARROM', OemtoAnsi(STR0083) },;  // "Cancelada"
                  {'BR_CINZA', OemtoAnsi(STR0082) },;   // "Nao-Procede"                    
                  {'DISABLE', OemtoAnsi(STR0047) },;	// "Plano de Acao Pendente"
                  {'BR_PRETO', OemtoAnsi(STR0053) } }	// "Plano de Acao Obsoleto"
                  
	Else
		If (GetMv("MV_QTMKPMS",.F.,1) == 3) .Or. (GetMv("MV_QTMKPMS",.F.,1) == 4)
		aCores  := { { "Q030VldLeg() == 1",'BR_PRETO'},; 
             	{ "Q030VldLeg() == 2", 'BR_AMARELO' },; 	
             	{ "Q030VldLeg() == 3", 'BR_CINZA'},; 	
				{ "Q030VldLeg() == 4", 'BR_MARROM'  },;
				{ "Q030VldLeg() == 5", 'ENABLE'  },;  	
	             	{ "Q030VldLeg() == 6", 'BR_LARANJA'},; 	
	             	{ "Q030VldLeg() == 7", 'BR_PINK'}} 	// Projeto TDI - TDSFL0 Identificacao de rejeitados

		aQLegenda := { {'ENABLE' , OemtoAnsi(STR0046) },;	// "Plano de Acao Baixado"
                  {'BR_MARROM', OemtoAnsi(STR0083) },;  // "Cancelada"
                  {'BR_CINZA', OemtoAnsi(STR0082) },;   // "Nao-Procede"                    
                  {'BR_AMARELO', OemtoAnsi(STR0047) },;	// "Plano de Acao Pendente"
                  {'BR_PRETO', OemtoAnsi(STR0053) },; // "Plano de Acao Obsoleto"
	                  {'BR_LARANJA', OemtoAnsi(STR0097) },;	// "Plano de Acao s/Projeto/EDT"
	                  {'BR_PINK', OemtoAnsi(STR0112) }}	// "Plano de Acao Rejeitado"
		
		Else
	 	aCores :={{'QI3->QI3_OBSOL=="S"' , 'BR_PRETO'},;
                  {"Empty(QI3->QI3_ENCREA)"  , 'BR_AMARELO'},;
                  {'QI3->QI3_STATUS=="4"'    , 'BR_CINZA'},;   
				  {'QI3->QI3_STATUS=="5"'    , 'BR_MARROM'},;
                  {"!Empty(QI3->QI3_ENCREA)" , 'ENABLE' }}                  

		aQLegenda := { {'ENABLE' , OemtoAnsi(STR0046) },;	// "Plano de Acao Baixado"
                  {'BR_MARROM', OemtoAnsi(STR0083) },;  // "Cancelada"
                  {'BR_CINZA', OemtoAnsi(STR0082) },;   // "Nao-Procede"                    
                  {'BR_AMARELO', OemtoAnsi(STR0047) },;	// "Plano de Acao Pendente"
                  {'BR_PRETO', OemtoAnsi(STR0053) } }	// "Plano de Acao Obsoleto"

		Endif

	Endif

	IF ExistBlock( "QNCSMACO" )
	ExecBlock( "QNCSMACO", .f., .f. )
	Endif

	If cFilPend == "S"
	cFiltraQI3 := " Empty(QI3_ENCREA) "
	Endif

cCadastro := OemToAnsi(STR0006)  //"Cadastro de Plano de Acao"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿	
//³ Ponto de entrada - Adiciona rotinas ao aRotina       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If ExistBlock("QNC030ROT")
	aRotAdic := ExecBlock("QNC030ROT", .F., .F.)
		If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
		EndIf
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para filtrar tabela QI3                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If lQNC030Fil
	cFiltraQI3 := ExecBlock("QNC030Fil",.F.,.F.)        
	EndIf

DbselectArea("QI0")
dbSetOrder(1)
DbselectArea("QI5")
dbSetOrder(1)
dbSelectArea("QI3")
dbSetOrder(1)
dbGoTop()

mBrowse( 6, 1,22,75,"QI3",,,,,,aCores,,,,,,,,,,,,cFiltraQI3 )

DbselectArea("QI3")
Set Filter To
dbSetOrder(1)
dbGoTop()

	If Select("QNSXE") > 0
	QNSXE->(dbCloseArea())
	Endif

	If Select("QNSXF") > 0
	QNSXF->(dbCloseArea())
	Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QNC030Sel ³ Autor ³Aldo Marini Junior       ³ Data ³ 11/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Filtra os Lancamtos Pendentes/Baixados do Plano de Acao       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QNC030Sel                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QNCA030                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/                      
Function QNC030Sel()

dbSelectArea("QI3")

lFunFNC := !lFunFNC

	If !lFunFNC
	oBrw := GetObjBrow()
	oBrw:SetFilterDefault(" .T. ")
	oBrw:Refresh()
	Else
	MsgRun( OemToAnsi( STR0044 ), OemToAnsi( STR0045 ), { || QNC030FIL() } ) //"Selecionando Plano de Acao" ### "Aguarde..."
	Endif

dbSeek(xFilial())

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QNC030FIL  ³ Autor ³Aldo Marini Junior      ³ Data ³ 11/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Filtra os Lactos Pendentes                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QNC030FIL                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QNCA030                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/                      
Function QNC030FIL()
Local oBrw := GetObjBrow()

dbSelectArea("QI3")

oBrw:SetFilterDefault(" Empty(QI3_ENCREA) ")

Return Nil

Function QNC030Top()
Return xFilial("QI3")+Str(Year(dDataBase),4)

Function QNC030Bot()
Return xFilial("QI3")+Str(Year(dDataBase),4)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC030Alt ³ Autor ³ Aldo Marini Junior    ³ Data ³ 29/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa generico para alteracao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC030Alt(ExpC1,ExpN1,ExpN2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao do Cadastro                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNC030Alt(cAlias,nReg,nOpcAcao,lAltEAcao)

Local Ni      		:= 0
Local iT            := 0
Local nOpcao    	:= 0
Local lInit   		:= .F.
Local aQI4			:= {}
Local aQI7			:= {}
Local aQI8			:= {}
Local aQI9			:= {}
Local aPosEnch		:= {}
Local cMsg			:= ""
Local cOldFil		:= ""
Local cOldMat		:= ""
Local INCLUI_OLD	:= INCLUI
Local aUsrMat		:= QNCUSUARIO()
Local cChaveQI3		:= QI3->QI3_FILIAL+QI3->QI3_CODIGO
Local nOrdQI3		:= 0
Local nRegQI3		:= 0
Local aButtons      := {}
Local lMvQncAEta    := If(GetMv("MV_QNCAETA",.F.,"2") == "1",.T.,.F.) // Define se usuario pode alterar a etapa
Local cDelAnexo     := GetMv("MV_QDELFNC",.F.,"1") // "Apagar Documentos Anexos no Diretorio Temporario"
Local lErase        := .T.
Local cMvQnAltPla   := GetMv("MV_QNCAPLA",.F.,"1")
Local aMemos		:= {{"QI3_PROBLE" ,"QI3_MEMO1"},;	// Descricao Detalhada
			   			{"QI3_LOCAL"  ,"QI3_MEMO2"},;		// Local de Execucao
						{"QI3_RESESP" ,"QI3_MEMO3"},;		// Resultado Esperado      
						{"QI3_RESATI" ,"QI3_MEMO4"},;		// Resultado Atingido      
						{"QI3_OBSERV" ,"QI3_MEMO5"},;		// Observacoes             
						{"QI3_METODO" ,"QI3_MEMO6"},;		// Metodo Utilizado          
						{"QI3_MOTREV" ,"QI3_MEMO7"}}		// Motivo da Revisao

Local lQN030MEM := Existblock ("QN030MEM")						
Local cChaveRev		:= QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV						
Local lMvPlPrc		:= GetMv("MV_QPLPRC", .F., "N") = "S"
Local i
Local nT
Local aColAnx :={}				     
Local lMvQNCEMTA	:= IF(GetMv("MV_QNCEMTA",.F.,"2") == "1", .T., .F.) //Define se Envia e-mail para todas as Etapas do Plano na Inclusao e Alteracao.

Local lTela			:= .T. //AVB
Local aRet			:= {} //AVB

Local lSigilo		:= .T.
Local aNomes		:= {}
Local cMensagem		:= ""
Local nConta		:= 0

Local lQNCEACAO 	:= ExistBlock( "QNCEACAO" )

Local aHabilidades   := {}
Local aAreaQI3       := {}
Local aRequisitaResp := {}
Local aTrfDatas      := {}
Local aUsrPlAcao     := {}
Local cHRIni   		 := ""
Local cHRFin   		 := ""
Local lTMKPMS 		 := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
Local cSeek          := "" 
Local aAreaQI5       := {}
Local cPMSTarefa     := ""
Local cQI52MAT       := ""
Local aQI5Aux		 := {}
Local cHoraQI5       := ""
Local cRecurso       := ""
Local aRecPMS		 := {}
Local dQI5Prazo		 := CTOD("  /  /  ")
Local cQI3DEPTO	     := ""  
LOCAL cRecPMS     	 := ""
local lRetPE         := .T.
Local aStruQI3       := FWFormStruct(3, "QI3",, .F.)[3]
Local nX
Local cBarRmt        := IIF(IsSrvUnix(),"/","\")
Local aCpos 		 := {}

Private aQI5 := {}
Private aQI6 := {}

Private __lQNSX8 := .F.
Private aQNQI3   := {}
Private aAliasQN := {}
Private lSX3Seq  := .F.						

Private nQaConPad   := 2
Private nPosFilQI4  := 0
Private nPosFilQI5  := 0
Private lDlgEtapa   := .F.
Private nEtapas     := 0
Private lBaixaAle   := If(GetMv("MV_QNCBALE",.f.,"2") == "1",.T.,.F.) // Baixa Aleatoria de Etapas
Private cQPathFNC   := QA_TRABAR(Alltrim(GetMv("MV_QNCPDOC")))
Private aQPath      := QDOPATH()
Private cQPathTrm   := aQPath[3]

Private lAltEta     := .F.
Private lAutorizado := .T.

Private lApelido    := aUsrMat[1]
Private cMatFil     := aUsrMat[2]
Private cMatCod     := aUsrMat[3]
Private cMatDep     := aUsrMat[4]

Private cOldPlan    := " "
Private cOldRev     := " "

Private lRevisao	:= .F.
Private bCampo		:= { |nCPO| Field( nCPO ) }
Private cFilMat		:= cMatFil
Private cMail		:= ""
Private cTpMail		:= "1"
Private cAttach		:= ""
Private aUsuarios	:= {}
Private oDlg
Private nTamMotR    := TamSX3("QI3_MEMO7")[1]
Private cTitMotR    := TitSX3("QI3_MEMO7")[2]
Private lDuplDoc    := .F.
Private nPosRec     := 0
Private nPosAli     := 0
Private aMemUsr     :={}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aTELA[0][0]
Private aGETS[0]
Private aHeader[0]
Private aHeadRev 	:= {}
Private aMsSize		:= MsAdvSize()
Private aObjects  	:= {{ 100, 100, .T., .T., .T. }}
Private aInfo		:= { aMsSize[ 1 ], aMsSize[ 2 ], aMsSize[ 3 ], aMsSize[ 4 ], 4, 4 } 
Private aPosObj		:= MsObjSize( aInfo, aObjects, .T. , .T. )

Private lWhenSt		:= .T.
Private nOpc		:= nOpcAcao
Private nPosStaQI5	:= 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura a funcao de numeracao sequencial parecido com SXE/SXF                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(GetSx3Cache("QI3_CODIGO","X3_CAMPO"))
		If "GETQNCNUM" $ GetSx3Cache("QI3_CODIGO","X3_RELACAO")
			lSX3Seq  := .T.
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para adicao de campos memo do usuario       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If lQN030MEM
		If ValType (aMemUser := ExecBlock( "QN030MEM", .F., .F. ) ) =="A"
			AEval( aMemUser, { |x| AAdd( aMemos, x ) } ) 	
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Quando este cadastro for acessado via opcoes "Pendencias" nao sera apagado os     ³
	//³ anexo temporarios.                                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cAlias == "PEN"
		cAlias := "QI3"
		lErase := .F.
	Endif

	If !Right( cQPathFNC,1 ) == cBarRmt
		cQPathFNC := cQPathFNC + cBarRmt
	Endif

	If !Right( cQPathTrm,1 ) == cBarRmt
		cQPathTrm := cQPathTrm + cBarRmt
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se foi passado o parametro de Inclusao atraves da FNC.          ³
	//³ O nOpc = 7 do aRotina esta sendo utilizado pelo do Cad.  FNC relacionada ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private lFNC := If(nOpc == 7,.T.,.F.)
	If nOpc == 3
		INCLUI := .T.
		If GetMv("MV_QTMKPMS",.F.,1) == 2 .Or. GetMv("MV_QTMKPMS",.F.,1) == 4
			Alert(STR0113) // "Integracao MV_QTMKPMS ativada, deve ser utilizado o modulo Call Center para inclusão de Chamado/Atendimento"
			Return
		Endif
	Endif
	If nOpc == 7
		INCLUI := .T.
		nOpc := 3
	Endif
	If nOpc == 2
		INCLUI:= .F.
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se foi passado o parametro para alteracao das descricoes das    ³
//³ etapas utilizado pelo Cad. FNC Relacionada.                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType(lAltEAcao) == "L"
		lAltEta:= lAltEAcao
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se foi passado o parametro de Geracao de Revisao.               ³
//³ O nOpc = 6 do aRotina esta sendo utilizada para Geracao de Revisao       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 8
		lRevisao := .T.
		INCLUI   := .F.
		nOpc     := 3
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se Usuario Logado esta cadastrado no Cad.Usuarios/Responsaveis atraves   ³
//³ do Apelido cadastrado no Configurador                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lApelido
		Help( " ", 1, "QD_LOGIN") // "O usuario atual nao possui um Login" ### "cadastrado igual do configurador."
		return 1
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o diretorio para gravacao do Docto Anexo Existe. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 3 .Or. nOpc == 4
		nHandle := fCreate(cQPathFNC+"SIGATST.CEL")
		If nHandle <> -1  // Consegui criar e vou fechar e apagar novamente...
			fClose(nHandle)
			fErase(cQPathFNC+"SIGATST.CEL")
		Else
			Help("",1,"QNCDIRDCNE") // "O Diretorio definido no parametro MV_QNCPDOC" ### "para o Documento Anexo nao existe."
			Return 3
		EndIf
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se for opcao de exclusao e valida se existe Lancamentos de FNC           ³
//³ relacionados                                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 5	// Excluir
	QI2->(dbSetOrder(5))
		If QI2->(dbSeek(QI3->QI3_FILIAL + QI3->QI3_CODIGO + QI3->QI3_REV ))
		Help(" ",1,"QNC030LFNC")	// Existe Lancamento de FNC relacionada
		QI2->(dbSetOrder(1))
		Return
		Endif
	QI2->(dbSetOrder(1))
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa campos MEMO                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For i:=1 to Len(aMemos)
	cMemo := aMemos[i][2]
		If Type(cMemo) <> "M"
		cMemo := "QI3->"+cMemo
		EndIf
		If GetSx3Cache(cMemo, "X3_CONTEXT") == "V"
			If ExistIni(cMemo)
			&cMemo := InitPad(GetSx3Cache(cMemo,"X3_RELACAO"))
			Else
			&cMemo := ""
			EndIf
		Else
			If ExistIni(cMemo) .And. Empty(&cMemo) .And. nOpc <> 3
			Reclock("QI3", .F.)
			&cMemo := InitPad(GetSx3Cache(cMemo,"X3_RELACAO"))
			QI3->(MsUnlock())
			EndIf
		EndIf
	Next i

	DbSelectArea("QI3")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva a integridade dos campos de Bancos de Dados            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 3  	//-- Inclusao

		If lRevisao

			cOldRev  := QI3->QI3_REV

			For nI := 1 To FCount()
				M->&(Eval(bCampo,nI)) := FieldGet(nI)
			Next

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega os registros dos sub-Cadastros               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			QNC030CARR(nOpc,@aQI4,@aQI5,@aQI6,@aQI7,@aQI8,@aQI9,lRevisao)
			aHeadRev := aClone(aHeader)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Carrega os registros dos sub-Cadastros               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			M->QI3_REV    := StrZero(Val(M->QI3_REV)+1,2)
			M->QI3_ABERTU := dDataBase
			M->QI3_ENCPRE := dDatabase+30
			M->QI3_ENCREA := Ctod("  /  /  ")
			M->QI3_OBSOL  := "N"
			M->QI3_STATUS := "1"	// "1"-Registrada

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializa as descricoes dos campos memos            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			INCLUI := .F.	// Seta .F. para inicializar os campos memos com a revisao anterior
		
			For nX := 1 To Len(aStruQI3)
				If GetSx3Cache(aStruQI3[nX,1], "X3_TIPO") == "M"
					&("M->"+AllTrim(aStruQI3[nX,1])) := InitPad(GetSx3Cache(aStruQI3[nX,1], "X3_RELACAO"))
				ElseIf aScan(aMemos,{|X| X[1] == AllTrim(aStruQI3[nX,1]) }) > 0 .And. ;
					ALLTRIM(UPPER(aStruQI3[nX,1])) <> "QI3_MEMO7"
					&("M->"+AllTrim(aStruQI3[nX,1])) := Space(6)
				Endif
				If ALLTRIM(UPPER(aStruQI3[nX,1])) == "QI3_MEMO7"
					dbSelectArea("SX3")
					dbSetOrder(2)
					If dbSeek( aStruQI3[nX,1] )
						cTitMotR := X3DescriC(aStruQI3[nX,1])
					EndIf
					nTamMotR := GetSx3Cache(aStruQI3[nX,1], "X3_TAMANHO")
				Endif
			Next nX
		
			dbSelectArea("QI3")

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta tela de edicao do Motivo da Revisao            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !QNCEDMOTREV(nOpc,@M->QI3_MEMO7,cTitMotR,nTamMotR)
				Return 3
			Endif
		
		Else
			For nI := 1 To FCount()
				M->&(Eval(bCampo,nI)) := FieldGet(nI)
				lInit := .F.

				If ( ExistIni(Eval(bCampo,nI)) )
					lInit := .T.
					M->&(Eval(bCampo,nI)) := InitPad(GetSx3Cache(Eval(bCampo,nI),"X3_RELACAO"))
					If ( ValType(M->&(Eval(bCampo,nI))) == "C" )
						M->&(Eval(bCampo,nI)) := Padr(M->&(Eval(bCampo,nI)),GetSx3Cache(Eval(bCampo,nI),"X3_TAMANHO"))
					Endif
					If ( M->&(Eval(bCampo,nI)) == NIL )
						lInit := .F.
					EndIf
				EndIf
				If ( ! lInit )
					If ( ValType(M->&(Eval(bCampo,nI))) == "C" )
						M->&(Eval(bCampo,nI)) := Space(Len(M->&(Eval(bCampo,nI))))
					ElseIf ( ValType(M->&(Eval(bCampo,nI))) == "N" )
						M->&(Eval(bCampo,nI)) := 0
					ElseIf ( ValType(M->&(Eval(bCampo,nI))) == "D" )
						M->&(Eval(bCampo,nI)) := Ctod("  /  /  ","DDMMYY")
					ElseIf ( ValType(M->&(Eval(bCampo,nI))) == "L" )
						M->&(Eval(bCampo,nI)) := .F.
					EndIf
				EndIf
			Next
		Endif
		M->QI3_FILIAL := xFilial("QI3")
		M->QI3_FILMAT := cMatFil
		M->QI3_MAT    := cMatCod
		M->QI3_NUSR   := QA_NUSR(cMatFil,cMatCod,.T.)
		If len(M->QI3_CODIGO) < 15
			M->QI3_ANO    := SubStr(M->QI3_CODIGO,7,4)        
		Else
			M->QI3_ANO    := SubStr(M->QI3_CODIGO,12,4)        		
		Endif
		M->QI3_OBSOL  := "N"
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se Plano eh Sigiloso. Somente Responsavel e Reponsaveis pelas Etapas podem Manipular  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		If QI3->QI3_SIGILO == "1"

			lSigilo := .T.
		
			If cMatFil+cMatCod <> QI3->QI3_FILMAT+QI3->QI3_MAT

				aNomes 		:= {AllTrim(Posicione("QAA",1, QI3->QI3_FILMAT+QI3->QI3_MAT,"QAA_NOME")) }   
				cMensagem 	:= ""
				
				QI5->(dbSetOrder(1))
				If QI5->(dbSeek(QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV))
					While QI5->(!Eof()) .And. QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV == QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV
						If QI5->QI5_FILMAT + QI5->QI5_MAT <> cMatFil + cMatCod
							cNome := AllTrim(Posicione("QAA",1, QI5->QI5_FILMAT+QI5->QI5_MAT,"QAA_NOME"))
							If Ascan(aNomes,{ |x| x == cNome }) == 0
								Aadd(aNomes,cNome)
							Endif
						Else
							lSigilo := .f.
						Endif
						QI5->(dbSkip())
					Enddo
				Endif

				For nConta := 1 To Len(aNomes)
				cMensagem += ", " + aNomes[nConta] 
				Next nConta
			Else
				lSigilo := .F.
			Endif
		
			If lSigilo .And. Existblock("QNC30SIG") // Ponto de Entrada para deixar que um Plano sigiloso seja visualizado por alguns usuarios
				lSigilo := Execblock("QNC30SIG",.F.,.F.,{cMatFil,cMatCod})
			Endif
			
			If lSigilo
				If Len(aNomes) == 1
					MsgAlert(OemToAnsi(STR0086)+Chr(13)+;					// "Plano de Ação Sigiloso"
					OemToAnsi(STR0087 + Substr(cMensagem,3) + STR0088 ))  	// "Somente o usuario " ### " tem acesso"
				Else
					MsgAlert(OemToAnsi(STR0086)+Chr(13)+;					// "Plano de Ação Sigiloso"
					OemToAnsi(STR0089 + Substr(cMensagem,3) + STR0088 ))	// "Somente os usuarios " ### " tem acesso"
				Endif

			Return 
			Endif
		Endif
	
		cOldPlan := QI3->QI3_CODIGO
		cOldRev  := QI3->QI3_REV

		nOrdQI3 := QI3->(IndexOrd())
		nRegQI3 := QI3->(Recno())
	                                                   
		dbSetOrder(2)
		If dbSeek(cChaveQI3+QI3->QI3_REV)
    		dbSkip()
			While !Eof() .And. QI3->QI3_FILIAL+QI3->QI3_CODIGO == cChaveQI3
				lAutorizado := .F.
				nOpc := 2
				dbSkip()
			Enddo
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso seja Exclusao verifica se existe revisoes anteriores ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc == 5 .And. QI3->QI3_OBSOL <> "S"
			dbGoTo(nRegQI3)
        	M->QI3_REV := QI3->QI3_REV
			If dbSeek(cChaveQI3)
				While !Eof() .And. QI3->QI3_FILIAL+QI3->QI3_CODIGO == cChaveQI3
					If QI3->QI3_REV <> M->QI3_REV
						lRevisao := .T.
						Exit
					Endif
					dbSkip()
				Enddo
			Endif
		Endif
	
		dbSetOrder(nOrdQI3)
		dbGoTo(nRegQI3)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o usuario corrente podera fazer manutencoes ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	
		If nOpc <> 2 .Or. QI3->QI3_OBSOL == "S" // Visualizar
	
			If !Empty(QI3->QI3_ENCREA) .OR. (cMvQnAltPla == "1"  .AND. cMatFil+cMatCod <> QI3->QI3_FILMAT+QI3->QI3_MAT)
				If GetMv("MV_QTMKPMS",.F.,1) == 2
					lAutorizado := .T.
				Else
					lAutorizado := .F.
				Endif
			Endif
       
       		// Ponto de entrada para liberar alteracao e inclusao  por usuarios que nao sejam o Responsavel
			If ExistBlock('QNC030USU')
          		lRetPE := ExecBlock('QNC030USU',.F., .F.,{cMatFil,cMatCod})
				If ValType(lRetPE) == "L"
            		lAutorizado := lRetPE
				EndIf
			EndIf
       
			If lAutorizado
				If nOpc <> 5
               		nOpc := 4
				EndIf
			Else
           		nOpc := 2
			EndIf
       
		Endif
    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o usuario corrente podera alterar descricoes das etapas ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpcAcao == 4 .And. QI3->QI3_OBSOL <> "S" .And. lMvQncAEta
			If !lAutorizado
				If QN030VdAlt(QI3->QI3_FILIAL,QI3->QI3_CODIGO,QI3->QI3_REV)
				lAltEta:= .T.
				EndIf
			EndIf
		EndIf

		If !lAutorizado
			If !lAltEta
			MsgAlert(OemToAnsi(STR0030)+Chr(13)+;	// "Usuario nao autorizado a fazer Manutencao neste Plano de Acao,"
					OemToAnsi(STR0031))				// "sera apenas visualizada."
			EndIf
		Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Visualizacao ou Chamada FNC, nao exibe mensagem e nao permite ³
	//³realizar manutencao no Plano\Etapas.                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpcAcao == 2
		lAutorizado:= .F.
		EndIf

		If lAutorizado .AND. nOpc == 4 .OR. nOpc == 5
			DbSelectArea("QI3")
			dbSetOrder(nOrdQI3)
			dbGoTo(nRegQI3)	
			IF !SoftLock("QI3")
				Return		
			Endif
			DbSelectArea("QI5")
			QI5->(dbSetOrder(1))
			If QI5->(dbSeek(QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV))
				While QI5->(!Eof()) .And. QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV == QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV
					If QI5->QI5_PEND == "S" .Or. QI5->QI5_STATUS < "4"
						IF !SoftLock("QI5")
							Return		 
						Endif
					Endif
				QI5->(dbSkip())
				Enddo
			Endif
			DbSelectArea("QI3")
			dbSetOrder(nOrdQI3)
			dbGoTo(nRegQI3)		
		Endif
		
		FOR iT := 1 TO FCount()
	    	M->&(EVAL(bCampo,iT)) := FieldGet(iT)
		NEXT i

		M->QI3_NUSR	:= QA_NUSR(M->QI3_FILMAT,M->QI3_MAT,.T.)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega os registros dos sub-Cadastros               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		QNC030CARR(nOpc,@aQI4,@aQI5,@aQI6,@aQI7,@aQI8,@aQI9)

		If lTMKPMS
			If (nOpc == 2) .Or. (nOpc == 4)
				aQI5Aux := aClone(aQI5)
			Endif
		Endif
			
	EndIf

	If lFNC .And. nOpc == 3
	M->QI2_CODACA := M->QI3_CODIGO
	M->QI2_REVACA := M->QI3_REV
	Endif

	IF QIE->(MsSeek(M->QI3_FILIAL+M->QI3_CODIGO+M->QI3_REV))
	cAliasAnex 	:= "QIE"   	// Variaveis utilizadas em QncACols, QncAHead e 
	aCols 		:= {}		// QncGAnexo
	aHeader		:= {}
	nAColsAtu 	:= 0   
	nUsado		:= 0     
	Endif

cCadastro := OemToAnsi(STR0006)  //"Cadastro de Plano de Acao"

// Nao chamo essa tela e faco uma rotina parecida com a QNC030MTGET para preparar a tela do QI5
// e na hora de chamar a tela chama essa tela abaixo e o get das etapas na mesma tela e retorna
// no ponto apos o activate abaixo


	IF ExistBlock( "QNCTELAC" )
		aRet := ExecBlock( "QNCTELAC", .f., .f. ,{ "QI5",If(lAltEta,4,nOpc),@aQI5,@aQI6,@aQI7,@aQI8,@aQI4,@aQI9,@aColAnx, @nOpcao })
		If ValType(aRet) = "A" .And. Len(aRet) >= 2
			lTela	:= aRet[1]
			nOpcao	:= aRet[2]
			If Len(aRet) > 2
				aQI5	:= aClone(aRet[3])
				aQI6	:= aClone(aRet[4])
				aQI7	:= aClone(aRet[5])
				aQI8	:= aClone(aRet[6])
				aQI4	:= aClone(aRet[7])
				aQI9	:= aClone(aRet[8]) 
				aColAnx	:= aClone(aRet[9])
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica os campos que serao editados na Enchoice			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCpos := {}
	aStrut := FWFormStruct(3,"QI3")[3] // Busca os campos usados (X3_USADO) da tabela
	For nX := 1 to Len(aStrut)
		If cNivel >= GetSx3Cache(aStrut[nX,1],"X3_NIVEL")
			If !(aStrut[nX,1] $ "QI3_ANO|QI3_PROBLE|QI3_LOCAL|QI3_RESESP|QI3_RESATI|QI3_OBSERV|QI3_METODO|QI3_OBSOL|QI3_MEMO7|QI3_MOTREV|QI3_CODCLI|QI3_LOJCLI|QI3_NOMCLI")
				Aadd(aCpos,aStrut[nX,1])
			EndIf
		EndIf
	Next nX

	If lTela
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para processamento dos Gets                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM aMsSize[7],000 TO aMsSize[6],aMsSize[5] OF oMainWnd Pixel
	
	aPosEnch := {aPosObj[1,1],aPosObj[1,2],aPosObj[1,4],aPosObj[1,3]}  // ocupa todo o  espaço da janela
	
	nReg 	:=IIf(nReg==NIL,RecNo(),nReg)
	nOpcao  := EnChoice( cAlias, nReg, nOpc, ,"CA", OemToAnsi(STR0007), aCpos,aPosEnch,,,,,,oDlg )	//"Quanto …s altera‡”es?"
	
	aAdd(aButtons,{"AUTOM"     , {|| QNC030MTGET("QI5",If(lAltEta,4,nOpc),@aQI5,@nPosStaQI5)}, OemToAnsi(STR0015), OemToansi(STR0074) } )	// "Acoes/Etapas"  //"Acao/Etap"
	aAdd(aButtons,{"OBJETIVO"  , {|| QNC030MTGET("QI6",nOpc,@aQI6)}, OemToAnsi(STR0016) } )	// "Causas" 
	aAdd(aButtons,{"RELATORIO" , {|| QNC030MTGET("QI7",nOpc,@aQI7)}, OemToAnsi(STR0017),OemToAnsi(STR0075) } )	// "Documentos"  //"Docs"
	aAdd(aButtons,{"SALARIOS"  , {|| QNC030MTGET("QI8",nOpc,@aQI8)}, OemToAnsi(STR0018) } )	// "Custos" 
	aAdd(aButtons,{"RESPONSA"  , {|| QNC030MTGET("QI4",nOpc,@aQI4)}, OemToAnsi(STR0019) } )	// "Equipes" 
	aAdd(aButtons,{"CRITICA"   , {|| QNC030MTGET("QI9",nOpc,@aQI9)}, OemToAnsi(STR0020),OemtoAnsi(STR0076) } )	// "Ocorrencias/Nao-conformidades" //"N-Confor"
	aAdd(aButtons,{"SDUPROP"   , {|| FQNCANEXO("QIE",nOpc,M->QI3_STATUS,@aColAnx) }, OemToAnsi( STR0068 ), OemtoAnsi(STR0077) } )  //"Documento Anexo"  //"Doc.Anexo"
	         
	If (GetMv("MV_QTMKPMS",.F.,1) == 4)
		aAdd(aButtons,{"DISCAGEM"   , {|| QNC030TMK() }, OemToAnsi(STR0100), OemtoAnsi(STR0100) } ) 
	EndIf

	//Seta o dado do banco caso esteja vazio - DMANQUALI-1323
	If Empty(M->QI3_MEMO7)
		M->QI3_MEMO7 := MSMM(QI3->QI3_MOTREV,80)
	EndIf

	If !Empty(M->QI3_MEMO7)
		aAdd(aButtons,{"NOTE", {|| QNCEDMOTREV(nOpc,@M->QI3_MEMO7,cTitMotR,nTamMotR)}, OemToAnsi( STR0033 ),Oemtoansi(STR0078) } )  // "Motivo da Revisao" //"Mot.Rev"
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada criado para mudar os botoes da enchoicebar                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF ExistBlock( "QNCPLNBT" )
		aButtons := ExecBlock( "QNCPLNBT", .f., .f., {nOpc,M->QI3_CODIGO,M->QI3_REV,aButtons} )
	Endif
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,;
						{||If(Qnc030VldACO(aGets,aTela,aQI9,aQI5,nOpc,aQI6,nPosStaQI5),Iif(QNC030VLDPLN(),(nOpcao := 1,oDlg:End()),),) },;
						{||nOpcao := 3,oDlg:End() },,aButtons)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida opcao de Inclusao / Alteracao / Exclusao / OK ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcao == 1	// Ok

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Usuario autorizado a fazer manutencao nas descricoes. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAltEta
		nOpc:= 4
		EndIf

		If nOpc == 3 .Or. nOpc == 4 // Inclusao ou Alteracao

			If nOpc == 3
				cOldFil := M->QI3_FILMAT
				cOldMat := M->QI3_MAT
			Else
				cOldFil := QI3->QI3_FILMAT
				cOldMat := QI3->QI3_MAT
			Endif

		//Ponto de Entrada executado na confirmação do Plano de Acao
			IF ExistBlock( "QNCPLNET" )
				ExecBlock( "QNCPLNET", .F., .F., {aQI5} )
			Endif
		                         
			aUsuarios := {}
			Qnc030Grava( bCampo, nOpc, aQI4, aQI5, aQI6, aQI7, aQI8, aQI9, AQI5Aux)
			If nOpc == 3
				If __lQNSX8
					ConfirmeQE(aQNQI3)
				EndIf
			Endif

			IF Len(aColAnx) >= 1
			cAliasAnex 	:= "QIE"   	// Variaveis utilizadas em QncACols, QncAHead e 
			aCols 		:= aClone(aColAnx)  // FQNCANEXO
			aHeader		:= {}
			nAColsAtu 	:= 0        
			nUsado  	:= 0
  			QNCGAnexo(nOpc,,aCols)
			ENDIF

			If lFNC
			QI9->(dbSetOrder(1))
				If !QI9->(dbSeek(QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV+M->QI2_FNC+M->QI2_REV))
				RecLock("QI9",.T.)
				QI9->QI9_FILIAL := QI3->QI3_FILIAL
				QI9->QI9_CODIGO := QI3->QI3_CODIGO
				QI9->QI9_REV    := QI3->QI3_REV
				QI9->QI9_FNC    := M->QI2_FNC
				QI9->QI9_REVFNC := M->QI2_REV
				MsUnLock()			
				FKCOMMIT()
				Endif
			Endif
                                                  
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                 
		//³ Integracao com o PMS ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Realizado bloqueio de geracao de tarefa no PMS na opção  ³
		//³de inclusão para evitar que o Plano seja cancelado quando³
		//³ele estiver sendo criado via Ficha de Não conformidade   ³
		//³ocorrendo inconsistencia na base do tipo:                ³
		//³- gerou tarefa no PMS e o Plano e a Ficha foi cancelado  ³
		//³enquanto ambas estava sendo aberta. 28/01/2009           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
			If lTMKPMS //.And. nOpc == 4
				If (GetMv("MV_QTMKPMS",.F.,1) == 3)  .Or. (GetMv("MV_QTMKPMS",.F.,1) == 4)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³aHabilidades = Array com as habilidades para executar a tarefa.                    ³                          ³
				//³dDTEncer     = Dt de Encerramento                                                  ³			  
				//³cHRParcial   = HR ref a Porcentagem p/ executar a etapa, cadastrada no arquivo QUP ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
				aAreaQI3 := QI3->(GetArea())
				ProcessaDoc({||Q030GeraTarefa()})        
		        RestArea(aAreaQI3)                         
				Endif
			Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envio de e-Mail para o responsavel do Plano de Acao e da Etapa vigente   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  ( cMatFil+cMatCod <> QI3->QI3_FILMAT+QI3->QI3_MAT .Or. ;
			( cOldFil+cOldMat <> QI3->QI3_FILMAT+QI3->QI3_MAT .And. cOldFil+cOldMat <> cMatFil+cMatCod ) ) .And. !lAltEta
			QAA->(dbSetOrder(1))
					If QAA->(dbSeek(QI3->QI3_FILMAT + QI3->QI3_MAT )) .And. QAA->QAA_RECMAI == "1"
				cMail := AllTrim(QAA->QAA_EMAIL)
				Endif
			Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envio de e-Mail para o responsavel do Plano de Acao                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cMail)

			cTpMail:= QAA->QAA_TPMAIL

			// Plano de Acao
				If cTpMail == "1"
				cMsg := QNCSENDMAIL(2,OemToAnsi(STR0034),.T.)	// "Plano de Acao iniciado."
				Else
				cMsg := OemToAnsi(STR0037)+DtoC(QI3->QI3_ABERTU)+Space(10)+OemToAnsi(STR0038)+DtoC(QI3->QI3_ENCPRE)+CHR(13)+CHR(10)	 // "Plano de Acao Iniciado em " ### " Data Prevista p/ Conclusao: "
				cMsg += CHR(13)+CHR(10)
				cMsg += OemToAnsi(STR0051)+CHR(13)+CHR(10)	// "Descricao Detalhada:"
				cMsg += M->QI3_MEMO1+CHR(13)+CHR(10)
				cMsg += CHR(13)+CHR(10)
				cMsg += OemToAnsi(STR0052)+CHR(13)+CHR(10)	// "Atenciosamente "
				cMsg += M->QI3_NUSR+CHR(13)+CHR(10)
				cMsg += QA_NDEPT(QAA->QAA_CC,.T.,QAA->QAA_FILIAL)+CHR(13)+CHR(10)
				cMsg += CHR(13)+CHR(10)
				cMsg += OemToAnsi(STR0059) + CRLF	// "Mensagem gerada automaticamente pelo Sistema SIGAQNC - Controle de Nao-conformidades"
				Endif
			
			cAttach := ""
			aMsg:={{OemToAnsi(STR0036)+" "+TransForm(M->QI3_CODIGO,PesqPict("QI3","QI3_CODIGO"))+"-"+M->QI3_REV+Space(10)+DTOC(Date())+"-"+SubStr(TIME(),1,5), cMsg, cAttach} }	// "Plano de Acao No. "
	
			// Geracao de Mensagem para o Responsavel do Plano de Acao 
				IF ExistBlock( "QNCRACAO" )
				aMsg := ExecBlock( "QNCRACAO", .f., .f., { OemToAnsi(STR0034),.T. } )
				Endif

			aAdd(aUsuarios,{QAA->QAA_LOGIN, cMail,aMsg} )

			Endif
            
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envio de e-Mail para o responsavel da Etapa vigente                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cMail := ""
			If 	If(lMvPlPrc, M->QI3_STATUS == "3", .T.) .And.;
			(nOpc == 3 .Or. nOpc == 4) .And. Empty(M->QI3_ENCREA)
			dbSelectArea("QI5")
			dbSetOrder(1)
					If dbSeek(QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV)
					While !Eof() .And. QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV == QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV
						If QI5->QI5_PEND == "S" .OR. lMvQNCEMTA
							If cMatFil+cMatCod <> QI5->QI5_FILMAT+QI5->QI5_MAT
								If QAA->(dbSeek(QI5->QI5_FILMAT + QI5->QI5_MAT )) .And. QAA->QAA_RECMAI == "1"
								cMail := AllTrim(QAA->QAA_EMAIL)
								Endif
							Endif

							If Ascan(aUsuarios,{ |x| x[1] == QAA->QAA_LOGIN }) == 0

								If !Empty(cMail)
	
								cTpMail:= QAA->QAA_TPMAIL
	
								// Etapa do Plano de Acao
									If cTpMail == "1"
									cMsg := QNCSENDMAIL(3,OemToAnsi(STR0035),.T.)	// "Existe(m) Etapa(s) para voce neste Plano de Acao para ser executado."
									Else
									cMsg := OemToAnsi(STR0037)+DtoC(QI3->QI3_ABERTU)+Space(10)+OemToAnsi(STR0038)+DtoC(QI5->QI5_PRAZO)+CHR(13)+CHR(10)	 // "Plano de Acao Iniciado em " ### " Data Prevista p/ Conclusao: "
									cMsg += CHR(13)+CHR(10)
									cMsg += OemToAnsi(STR0060)+QI5->QI5_TPACAO+"-"+FQNCDSX5("QD",QI5->QI5_TPACAO)+CHR(13)+CHR(10)	// "Tipo Acao/Etapa: "
									cMsg += Replicate("-",80)+CHR(13)+CHR(10)
									cMsg += OemToAnsi(STR0051)+CHR(13)+CHR(10)	// "Descricao Detalhada:"
									cMsg += M->QI3_MEMO1+CHR(13)+CHR(10)
									cMsg += Replicate("-",80)+CHR(13)+CHR(10)
									cMsg += CHR(13)+CHR(10)
									cMsg += OemToAnsi(STR0052)+CHR(13)+CHR(10)	// "Atenciosamente "
									cMsg += M->QI3_NUSR+CHR(13)+CHR(10)
									cMsg += QA_NDEPT(QAA->QAA_CC,.T.,QAA->QAA_FILIAL)+CHR(13)+CHR(10)
									cMsg += CHR(13)+CHR(10)
									cMsg += OemToAnsi(STR0059) + CRLF	// "Mensagem gerada automaticamente pelo Sistema SIGAQNC - Controle de Nao-conformidades"
									Endif
								
								cAttach := ""
								aMsg:={{OemToAnsi(STR0036)+" "+TransForm(M->QI3_CODIGO,PesqPict("QI3","QI3_CODIGO"))+"-"+M->QI3_REV+Space(10)+DTOC(Date())+"-"+SubStr(TIME(),1,5), cMsg, cAttach} }	// "Plano de Acao No. "
		
								// Geracao de Mensagem para o Responsavel da Etapa do Plano de Acao 
									IF lQNCEACAO
									aMsg := ExecBlock( "QNCEACAO", .f., .f., { OemToAnsi(STR0035) } ) // "Existe(m) Etapa(s) para voce neste Plano de Acao para ser executado."
									Endif
	
								aAdd(aUsuarios,{QAA->QAA_LOGIN, cMail, aMsg} )
								EndIf
							Endif
						Endif
					dbSkip()
					Enddo
				Endif
			Endif

			If lRevisao
			dbSelectArea("QI2")
			QI2->(dbSetOrder(5))
				If QI2->(dbSeek(QI9->QI9_FILIAL + QI9->QI9_CODIGO + QI9->QI9_REV ))
					If MsgYesNo(OemToAnsi(STR0057),OemToAnsi(STR0058))     //"Deseja reativar as Fichas de Ocorrencias/Nao-Conformidades relacionadas?" ### "AVISO"
						While !Eof() .And. QI2->QI2_FILIAL+QI2->QI2_CODACA+QI2->QI2_REVACA == QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI9->QI9_REV
						RecLock("QI2",.F.)
						QI2->QI2_REVACA := QI3->QI3_REV
						QI2->QI2_CONREA := CTOD("  /  /  ")
						QI2->QI2_CONPRE := CTOD("  /  /  ")
						MsUnLock()
					    FKCOMMIT()
						dbSkip()
						Enddo
					Endif
				Endif
			dbSelectArea("QI3")
			Endif

			If Len(aUsuarios) > 0
			QaEnvMail(aUsuarios,,,,aUsrMat[5],"2")
			Endif
    	
    	
		ElseIf nOpc == 5				// Exclusao
		QNC030Del(lRevisao,@aQNQI3)
		Endif
	Else
		If nOpc == 3 .And. !lRevisao	// Inclusao
			If __lQNSX8
			RollbackQE(aQNQI3)
			EndIf
			If !lSX3Seq
			GETQNCSEQ("QI3","QI3_CODIGO",M->QI3_CODIGO,.T.,nOpc)
			Endif
				
			If lFNC
			M->QI2_CODACA := Space(10)
			M->QI2_REVACA := Space(2)
			Endif

		//Caso tenha cancelado o plano de acao, verifica se existe Etapa x Habilidades cadastradas e realiza a delecao...
			If lTMKPMS
			dbSelectArea("QUR")
			dbSetOrder(1)
				If DbSeek(xFilial("QUR")+M->QI3_CODIGO)
					While !Eof() .and. QUR->QUR_FILIAL+QUR->QUR_CODIGO == M->QI3_FILIAL+M->QI3_CODIGO
	            	RecLock("QUR",.F.)
	            	dbDelete()
	            	MsUnlock()
					dbSkip()
					Enddo
				Endif
			Endif
		Endif

		If nOpc == 3
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui Documento anexo             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If QIE->(DbSeek(M->QI3_FILIAL+M->QI3_CODIGO+M->QI3_REV))
				While QIE->(!Eof()) .And. QIE->QIE_FILIAL+QIE->QIE_CODIGO+QIE->QIE_REV == M->QI3_FILIAL+M->QI3_CODIGO+M->QI3_REV
				cFileTrm:= AllTrim(QIE->QIE_ANEXO)
					If File(cQPathFNC+cFileTrm)
					FErase(cQPathFNC+cFileTrm)	
					Endif
				RecLock("QIE",.F.)
				QIE->(DbDelete())
				MsUnlock()
			    FKCOMMIT()	
				QIE->(DbSkip())
				EndDo
			EndIf
		Endif
	
		IF nOPC == 4 .OR. nOpc == 5
		DbSelectARea("QI3")
		MsUnlock()
	    FKCOMMIT()         
		DbSelectARea("QI5")	    
		QI5->(dbSetOrder(1))
			If QI5->(dbSeek(QI3->QI3_FILIAL+QI3->QI3_CODIGO+M->QI3_REV))
				While QI5->(!Eof()) .And. QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV == QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV
					If QI5->QI5_PEND == "S" .Or. QI5->QI5_STATUS < "4"
					MsUnlock() 
					FKCOMMIT()
					Endif
				QI5->(dbSkip())
				Enddo
			Endif
		Endif
	EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava ou Exclui o Documento anexo                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcao == 1 //-- OK
		If nOpc == 3 .Or. nOpc == 4	// Inclusao ou Alteracao

			If QIE->(DbSeek(M->QI3_FILIAL+M->QI3_CODIGO+M->QI3_REV))
				While QIE->(!Eof()) .And. QIE->QIE_FILIAL+QIE->QIE_CODIGO+QIE->QIE_REV == M->QI3_FILIAL+M->QI3_CODIGO+M->QI3_REV
				cFileTrm:= AllTrim(QIE->QIE_ANEXO)
					If !File(cQPathFNC+cFileTrm)
						If File(cQPathTrm+cFileTrm)
							If !CpyT2S(cQPathTrm+cFileTrm,cQPathFNC,.T.)
							Help(" ",1,"QNAOCOPIOU")
							Endif
						Else
							If File(cQPathFNC+cFileTrm)
							FErase(cQPathFNC+cFileTrm)
							Endif
						Endif
					EndIf
				QIE->(DbSkip())
				EndDo
			EndIf
		Endif
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variavel de flag para identificar se pode apagar os anexos da FNC ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lErase
		If cDelAnexo == "1"
		aArqFNC := DIRECTORY(cQPathTrm+"*.*")
			For nT:= 1 to Len(aArqFNC)
				If 	M->QI3_CODIGO + "_" + M->QI3_REV + "_" =;
				Left(aArqFNC[nT,1], Len(M->QI3_CODIGO + "_" + M->QI3_REV + "_")) .And.;
				File(cQPathTrm+AllTrim(aArqFNC[nT,1]))
				FErase(cQPathTrm+AllTrim(aArqFNC[nT,1]))
					Endif
			Next
		EndIf
	Endif

	If lFNC
		INCLUI := INCLUI_OLD
	Endif

	If FindFunction("QNCATULEG")
		QNCATULEG(QI3->QI3_FILMAT,QI3->QI3_MAT)
	
		If !Empty(aQI5) .And. nOpc <> 2
			If QI5->(DbSeek(QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV))
				While QI5->(!Eof()) .And. (QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV == QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV)
					If Ascan(aQI5,{ |x| x[4] == QI5->QI5_MAT }) > 0 .And. Ascan(aUsrPlAcao,{ |x| x[1] == QI5->QI5_MAT }) == 0
						QNCATULEG(QI5->QI5_FILMAT,QI5->QI5_MAT)
						aAdd(aUsrPlAcao,{QI5->QI5_MAT} )			
					EndIf
					QI5->(DbSkip())
				EndDo
			EndIf
		EndIf
	Endif

	//Inibir o comportamento de loop após a confirmação de inclusão de um novo registro pela MBrowse.
	If nOpcao == 1 //-- OK
		IF SUPERGETMV("MV_QNCIOPC",.F.,1) == 2
			Return( MbrChgLoop( .F. ) ) //https://tdn.totvs.com/x/Vf1n
		ENDIF
	ENDIF

Return nOpcao

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ-ÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Qnc030Grava³ Autor ³ Aldo Marini Junior   ³ Data ³28/12/99  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄ-ÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava os campos do arquivo de Acoes                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Qnc030Grava( bCampo, nOpc, aQI4,aQI5,aQI6,aQI7,aQI8,aQI9,aQI5Aux)
Local nC
Local lQN030MEM := ExistBlock("QN030MEM")
Local nI        := 0
Local cEncAutPla:= AllTrim(GetMv("MV_QNEAPLA",.F.,"1"))       // Encerramento Automatico de Plano
Local lQNCCACAO := ExistBlock( "QNCCACAO" )
Private aMsg	:= {}
Private cMsg	:= ""
Private cMail	:= ""
Private cTpMail	:= ""

Default aQI5Aux := {}

DbSelectArea( "QI3" )    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida se houve alteracao do Codigo+Revisao                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 4 .And. !Empty(AllTrim(cOldPlan+cOldRev)) .And. cOldPlan+cOldRev <> M->QI3_CODIGO+M->QI3_REV
	dbSetOrder(2)
	dbSeek(xFilial("QI3")+cOldPlan+cOldRev)
	dbSetOrder(1)
	Endif

	Begin Transaction

		If nOpc == 3
			RecLock( "QI3", .T. )
		Else
			RecLock( "QI3", .F. )
		EndIf
		For nC := 1 TO FCount()
			FieldPut( nC, M->&( Eval( bCampo, nC ) ) )
		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Chamada via FNC o plano Procede.           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFNC
			M->QI3_STATUS  := "3"
			QI3->QI3_STATUS:= M->QI3_STATUS
		EndIf

    	MsUnlock()
    	FKCOMMIT()
    
		If nOpc == 3 .or. nOpc == 4
			//Gravacao das chaves dos Campos Memo na Inclusao/Alteracao
			//Desta forma gera apenas as chaves se o conteudo for preenchido evitando
			//registros em branco e tambem nao gera buracos na numeracao do SYP.
			If (nOpc == 3 .And. !Empty(M->QI3_MEMO1)) .Or. ;
			   (nOpc == 4 .And. !Empty(QI3->QI3_PROBLE)) .Or. ;
			   (nOpc == 4 .And. !Empty(M->QI3_MEMO1) .And. Empty(QI3->QI3_PROBLE)) 
				MSMM(QI3_PROBLE,,,M->QI3_MEMO1,1,,,"QI3","QI3_PROBLE")
			Endif
			If (nOpc == 3 .And. !Empty(M->QI3_MEMO2)) .Or. ;
			   (nOpc == 4 .And. !Empty(QI3->QI3_LOCAL)).Or. ;
			   (nOpc == 4 .And. !Empty(M->QI3_MEMO2) .And. Empty(QI3->QI3_LOCAL)) 
				MSMM(QI3_LOCAL ,,,M->QI3_MEMO2,1,,,"QI3","QI3_LOCAL" )
			Endif
			If (nOpc == 3 .And. !Empty(M->QI3_MEMO3)) .Or. ;
			   (nOpc == 4 .And. !Empty(QI3->QI3_RESESP)).Or. ;
			   (nOpc == 4 .And. !Empty(M->QI3_MEMO3) .And. Empty(QI3->QI3_RESESP)) 
				MSMM(QI3_RESESP,,,M->QI3_MEMO3,1,,,"QI3","QI3_RESESP")
			Endif
			If (nOpc == 3 .And. !Empty(M->QI3_MEMO4)) .Or. ;
			   (nOpc == 4 .And. !Empty(QI3->QI3_RESATI)).Or. ;
			   (nOpc == 4 .And. !Empty(M->QI3_MEMO4) .And. Empty(QI3->QI3_RESATI)) 
				MSMM(QI3_RESATI,,,M->QI3_MEMO4,1,,,"QI3","QI3_RESATI")
			Endif
			If (nOpc == 3 .And. !Empty(M->QI3_MEMO5)) .Or. ;
			   (nOpc == 4 .And. !Empty(QI3->QI3_OBSERV)) .Or. ;
			   (nOpc == 4 .And. !Empty(M->QI3_MEMO5) .And. Empty(QI3->QI3_OBSERV)) 
				MSMM(QI3_OBSERV,,,M->QI3_MEMO5,1,,,"QI3","QI3_OBSERV")
			Endif
			If (nOpc == 3 .And. !Empty(M->QI3_MEMO6)) .Or. ;
			   (nOpc == 4 .And. !Empty(QI3->QI3_METODO)) .Or. ;
			   (nOpc == 4 .And. !Empty(M->QI3_MEMO6) .And. Empty(QI3->QI3_METODO)) 
				MSMM(QI3_METODO,,,M->QI3_MEMO6,1,,,"QI3","QI3_METODO")
			Endif
			If (nOpc == 3 .And. !Empty(M->QI3_MEMO7)) .Or. ;
			   (nOpc == 4 .And. !Empty(QI3->QI3_MOTREV)) .Or. ;
			   (nOpc == 4 .And. !Empty(M->QI3_MEMO7) .And. Empty(QI3->QI3_MOTREV)) 
				MSMM(QI3_MOTREV,,,M->QI3_MEMO7,1,,,"QI3","QI3_MOTREV")
			Endif
			If lQN030MEM
				For nI := 1 to Len(aMemUser)
					If SubStr(aMemUser[nI,1],1,3) == "QI3"
						If (nOpc == 3 .And. !Empty(&("M->"+aMemUser[nI,2]))) .Or. ;
						   (nOpc == 4 .And. !Empty(aMemUser[nI,1])) .Or. ;
						   (nOpc == 4 .And. !Empty(&("M->"+aMemUser[nI,2])) .And. Empty(aMemUser[nI,1])) 
							MSMM(&(aMemUser[nI,1]),,,&("M->"+aMemUser[nI,2]),1,,,"QI3",aMemUser[nI,1] )
						Endif
					Endif
				Next
			Endif
		Endif
	
	MsUnlock() 
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava os Lactos dos Sub-Cadastros do array para arquivo      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QNC030GrLacto("QI4",aQI4,nOpc)	//  Equipe
	QNC030GrLacto("QI5",aQI5,nOpc,aQI5Aux)  //  Acoes/Etapas
	QNC030GrLacto("QI6",aQI6,nOpc)  //  Causas
	QNC030GrLacto("QI7",aQI7,nOpc)  //  Documentos
	QNC030GrLacto("QI8",aQI8,nOpc)  //  Custos
	QNC030GrLacto("QI9",aQI9,nOpc)  //  Ocorrencias/Nao-conformidades
	
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se foram baixadas todas etapas para baixar o Plano   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cEncAutPla == '1' .And. (QI5->QI5_STATUS == '4' .Or. QI5->QI5_STATUS == '5')
			QN030BxPla()
		Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Baixa das Etapas quando Plano de Acao for Cancelado          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QI3->QI3_STATUS == "5" .And. Len(aQI5) > 0 		// Plano de Acao Cancelado
		dbSelectArea("QI5")
			If dbSeek(QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV)
				While !Eof() .And. QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV == QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV
					If QI5->QI5_PEND == "S" .Or. QI5->QI5_STATUS < "4" .Or. Empty(QI5->QI5_REALIZ)
					RecLock("QI5",.F.)
						If Empty(QI5->QI5_PRAZO)
						QI5->QI5_PRAZO := QI3->QI3_ENCREA
						Endif
						If Empty(QI5->QI5_REALIZ)
						QI5->QI5_REALIZ := QI3->QI3_ENCREA
						Endif
					QI5->QI5_PEND	:= "N"
					QI5->QI5_STATUS	:= "4"
					QI5->QI5_DESCRE	:= OemToAnsi(STR0039)	// "Plano de Acao Cancelado"
					MsUnLock()
					FKCOMMIT()
					Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Envia e-mail para os responsaveis das Etapas                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If cMatFil+cMatCod <> QI5->QI5_FILMAT+QI5->QI5_MAT
						If QAA->(dbSeek(QI5->QI5_FILMAT + QI5->QI5_MAT )) .And. QAA->QAA_RECMAI == "1"
 
						cMail := AllTrim(QAA->QAA_EMAIL)			
							If !Empty(cMail)

								If Ascan(aUsuarios,{ |x| x[1] == QAA->QAA_LOGIN }) == 0
		
								cTpMail:= QAA->QAA_TPMAIL
	
								// Plano de Acao
									If cTpMail == "1"
										cMsg := QNCSENDMAIL(2,OemToAnsi(STR0040)+DtoC(QI3->QI3_ENCREA)+Space(2)+OemToAnsi(STR0041))  // "Plano de Acao Cancelado em " ### "pelo Responsavel."
									Else
										cMsg := OemToAnsi(STR0040)+DtoC(QI3->QI3_ENCREA)+Space(2)+OemToAnsi(STR0041)+CHR(13)+CHR(10)	 // "Plano de Acao Cancelado em " ### "pelo Responsavel."
										cMsg += CHR(13)+CHR(10)
										cMsg += CHR(13)+CHR(10)
										cMsg += OemToAnsi(STR0052)+CHR(13)+CHR(10)	// "Atenciosamente "
										cMsg += M->QI3_NUSR+CHR(13)+CHR(10)
										cMsg += QA_NDEPT(cMatDep,.T.,cMatFil)+CHR(13)+CHR(10)
										cMsg += CHR(13)+CHR(10)
										cMsg += OemToAnsi(STR0059) + CRLF	// "Mensagem gerada automaticamente pelo Sistema SIGAQNC - Controle de Nao-conformidades"
								
									Endif
								
									cAttach := ""
									aMsg:={{OemToAnsi(STR0036)+" "+TransForm(M->QI3_CODIGO,PesqPict("QI3","QI3_CODIGO"))+"-"+M->QI3_REV+Space(10)+DTOC(Date())+"-"+SubStr(TIME(),1,5), cMsg, cAttach} }	// "Plano de Acao No. "
		
									// Geracao de Mensagem para o Responsavel da Etapa do Plano de Acao
									IF lQNCCACAO
										aMsg := ExecBlock( "QNCCACAO", .f., .f. )
									Endif
	
									aAdd(aUsuarios,{QAA->QAA_LOGIN, cMail, aMsg} )
								EndIf
							EndIf
						EndIf
					EndIf
					QI5->(DbSkip())
				Enddo
			Endif
			dbSelectArea("QI3")
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Baixa as Fichas de Nao-Conformidades relacionadas ao Plano.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc == 4 .And. !Empty(QI3->QI3_ENCREA)
			QN030BxFNC()
		EndIf

	End Transaction

	IF ExistBlock( "QNCGRACO" )
		ExecBlock( "QNCGRACO", .f., .f., {nOpc,aQI5} )
	Endif

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄ-ÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC030MTGET³ Autor ³ Aldo Marini Junior   ³ Data ³ 24.04.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄ-ÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Montar o aCols e o aHeader Para Cadastros                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC030MTGET(cAliasB,nOpc,aArray)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do Cadastro a ser Atualizado                 ³±±
±±³          ³ ExpN1 = Opcao devolvida pela funcao                        ³±±
±±³          ³ ExpA1 = Array a ser adicionado os registros                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNC030MTGET(cAliasB,nOpc,aArray,nPosStaQI5)

Local oDlg1
Local oGet
Local oCodAca
Local oRvAca
Local cFil 	 	:= cAliasB+"_FILIAL"
Local cCod 	 	:= cAliasB+"_CODIGO"
Local cRv    	:= cAliasB+"_REV"
Local a030Field := {cFil,cCod,cRv}

Local cRvAca	:= M->QI3_REV
Local nCnt    	:= 0
Local nUsado  	:= 0
Local nT		:= 0
Local nCntMod	:= 0
Local nPos1		:= 0
Local nPos2		:= 0
Local aColsFNC  := {}
Local aButtonFNC	:= {}
Local aButtonEtapa 	:= {}
Local oPanel
Local aArea  	    := {}                   
Local cHRTotal, cHRParcial, cHRDecimal
Local cTPAcao    := ""
Local lTMKPMS    := ChkFile("QUO") 
Local cElse 	 := .F.
Local nModelo    := 0
Local nPsHabb	 := 0 	
Local oCodCli
Local oLojCli
Local oNomCli
Local cCodCli	:= ""
Local cLojCli   := ""
Local cNomCli   := ""
Local lQNCGEVAL := .T.
Local aStruAlias := FWFormStruct(3, cAliasB)[3]
Local nX

Private cCodAca   := M->QI3_CODIGO																	 
Private aTELA[0][0]
Private aGETS[0]
Private aHeader[0]
Private Continua:=.F.
Private nOpca1  	:= 0
Private nOpcGet 	:= nOpc	// Variavel Criada para JNJ - especifico
Private cAliasGet 	:= cAliasB	// Utilizado na funcao QNC030LiOk()
Private nPosTP  	:= Ascan( aHeader, { |X| Upper( Alltrim( X[2] ) ) = "QI5_TPACAO" } )
Private aCols
Private nPosPrj     := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se os campos QI3_CODCLI e QI3_LOJCLI existem no SX3		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Default nOpc:= 2 

lDlgEtapa:= .T.
cCodCli	:= M->QI3_CODCLI 
cLojCli := M->QI3_LOJCLI
cNomCli := FQNCDESCLI(M->QI3_CODCLI,M->QI3_LOJCLI,"1")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ P.E. Permite criar uma validação customizada para execução QNC030MTGET  - TSC815    ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF ExistBlock( "QNCGEVAL" )
    lQNCGEVAL := ExecBlock( "QNCGEVAL", .f., .f. , {cAliasB,nOpc,aArray})
		IF !lQNCGEVAL
       return     
		ENDIF
	Endif

	IF ExistBlock( "QNCGEACO" )
	ExecBlock( "QNCGEACO", .f., .f. )
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se Codigo Acao e RV estao em Branco	             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(M->QI3_CODIGO) .Or. Empty(M->QI3_REV)
	Return( .F. )
	EndIf

	If lTMKPMS
		If (GetMv("MV_QTMKPMS",.F.,1) == 0) .or. (GetMv("MV_QTMKPMS",.F.,1) == 1)
 		nModelo := 0
		Else
		nModelo := 1    
		Endif
	Else
 	nModelo := 0
	Endif

	If nModelo == 0
	dbSelectArea("QIC")
	dbSetOrder(1)	
		If dbseek( xFilial("QIC")+AllTrim(M->QI3_MODELO))
			While !Eof() .And. xFilial("QIC")+AllTrim(QIC_CODIGO) == xFilial("QIC")+AllTrim(M->QI3_MODELO)
			nCntMod++
			dbSkip()
			Enddo
		Endif
	Else
	dbSelectArea("QUP")
		If dbseek( xFilial("QUP")+M->QI3_MODELO )
			While !Eof() .And. xFilial("QUP")+Alltrim(QUP_GRUPO) == xFilial("QUP")+Alltrim(M->QI3_MODELO)
			nCntMod++
			dbSkip()
			Enddo
		EndiF
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o cabecalho da MsGetDados                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader:={}

	For nX := 1 To Len(aStruAlias)
		If cNivel >= GetSx3Cache(aStruAlias[nX,1], "X3_NIVEL") .and. !ASCAN(a030Field,{|x| x == Trim(aStruAlias[nX,1])}) > 0;
	  	   .And. !aStruAlias[nX,1] $ "QI5_DESCCO|QI5_DESCOB|QI5_PEND|QI5_PLAGR|QI5_AGREG|QI5_REJEIT|QI5_CJCOD|QI5_ETPRLA|QI6_SEQ|QI6_DESCR|QI7_SEQ|QI8_SEQ|QI9_PLAGRE"
			AADD(aHeader, Q030GetSX3(aStruAlias[nX,1], "", "") )
		EndIf
	Next nX

	// Adiciona no aHeader para montagem da legenda
	If cAliasB == "QI5"
		aSize(aHeader,Len(aHeader)+1)
		aIns(aHeader,1)
		aHeader[1] := {"","OK_ALI_WT","@BMP",1,0,"","","C",""} 
	EndIf
	
	// Inclui coluna de registro atraves de funcao generica
	ADHeadRec(cAliasB,aHeader)

	nUsado := Len(aHeader)

	nPosAli := Ascan(aHeader,{|X| Upper( Alltrim(X[2])) = cAliasB+"_ALI_WT"})
	nPosRec := Ascan(aHeader,{|X| Upper( Alltrim(X[2])) = cAliasB+"_REC_WT"})
	nPosFilQI4:= Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI4_FILMAT"})
	nPosFilQI5:= Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI5_FILMAT"})
	nPosPrj   := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI5_PROJET"})

	nCnt := Len(aArray)

	If nCnt > 0

		aCols := aClone(aArray)
		If cAliasB == "QI5"
			For nCnt := 1 To Len(aCols)
				aSize(aCols[nCnt],Len(aCols[nCnt])+1)
				aIns(aCols[nCnt],1)
			Next nCnt
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso seja Acao Corretiva atraves da Ficha de Nao-Conformidades³
		//³ atualiza as FNC relacionadas.                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFNC .And. cAliasB == "QI9"
			nPos1 := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI9_FNC"  	})
			nPos2 := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI9_REVFNC"})
			If nPos1 > 0 .And. nPos2 > 0

				If Ascan(aCols,{ |X| X[nPos1]+X[nPos2] == M->QI2_FNC+M->QI2_REV }) == 0
					aColsFNC := aClone(aCols[Len(aCols)])
					aAdd(aCols,aColsFNC)
					aCols[Len(aCols),nPos1] := M->QI2_FNC
					aCols[Len(aCols),nPos2] := M->QI2_REV
				Endif

			Endif
		Endif

	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega os passos/etapas do Tipo de Modelo de Plano de Acao  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nModelo == 1
			//nPosPrj   := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI5_PROJET"})
			If	cAliasB == "QI5" .And. !Empty(M->QI3_MODELO) .And. nCntMod > 0
				aCols := Array(nCntMod,nUsado+1)
				dbSelectArea("QUP")
				dbSetOrder(2)
				If dbseek( xFilial("QUP")+M->QI3_MODELO )
				nCnt    := 0		
					While !EOF() .And. xFilial("QUP")+AllTrim(QUP_GRUPO) == xFilial("QUP")+AllTrim(M->QI3_MODELO)
					nCnt++
					nUsado:=1
						For nX := 1 To Len(aStruAlias)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Carrega as sequencias dos Tipos de Modelos                   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If cNivel >= GetSx3Cache(aStruAlias[nX,1], "X3_NIVEL") .and. !ASCAN({cFil,cCod,cRv},{|x| x == Trim(aStruAlias[nX,1])}) > 0;
							.And. !aStruAlias[nX,1] $ "QI5_DESCCO|QI5_DESCOB|QI5_PEND|QI5_PLAGR|QI5_AGREG|QI5_REJEIT|QI5_CJCOD|QI5_PROJET|QI5_ETPRLA|QI6_SEQ|QI6_DESCR|QI7_SEQ|QI8_SEQ|QI9_PLAGRE"
								nUsado++
									If GetSx3Cache(aStruAlias[nX,1], "X3_CONTEXT") == "V"
									If UPPER(ALLTRIM(aStruAlias[nX,1])) == "QI5_DESCTP"//X3_CAMPO
										aCols[nCnt,nUsado] := FQNCDESETA(QUP->QUP_TPACAO) 
									Else
										If UPPER(ALLTRIM(aStruAlias[nX,1])) == "QI5_NUSR"//X3_CAMPO
											dbSelectArea("QAA")
											dbSetOrder(1)
											If QAA->(dbSeek(XFILIAL("QAA")+Alltrim(QUP->QUP_RESP)))
												aCols[nCnt,nUsado] :=QAA->QAA_NOME
											Endif
										Else
											aCols[nCnt,nUsado] := CriaVar(AllTrim(aStruAlias[nX,1]))//X3_CAMPO
										Endif
									Endif
								Else
									Do Case
									Case UPPER(ALLTRIM(aStruAlias[nX,1])) == "QI5_TPACAO"//X3_CAMPO
										aCols[nCnt,nUsado] := QUP->QUP_TPACAO
									Case UPPER(ALLTRIM(aStruAlias[nX,1])) == "QI5_MAT"//X3_CAMPO
										aCols[nCnt,nUsado] := QUP->QUP_RESP
									Case UPPER(ALLTRIM(aStruAlias[nX,1])) == "QI5_PLAGR"//X3_CAMPO
										aCols[nCnt,nUsado] := QUP->QUP_OBRIGA
									Case UPPER(ALLTRIM(aStruAlias[nX,1])) == "QI5_GRAGR"//X3_CAMPO
										aCols[nCnt,nUsado] := QUP->QUP_GRAGR
									Case UPPER(ALLTRIM(aStruAlias[nX,1])) == "QI5_PRJEDT"//X3_CAMPO
										aCols[nCnt,nUsado] := QUP->QUP_CJCOD
									Case UPPER(ALLTRIM(aStruAlias[nX,1])) == "QI5_PROJET"//X3_CAMPO
										aCols[nCnt,nUsado] := QUP->QUP_PROJET									     		
									Case UPPER(ALLTRIM(aStruAlias[nX,1])) == "QI5_REVISA"//X3_CAMPO
											aCols[nCnt,nUsado] := PMSAF8VER(QUP->QUP_PROJET)								
									Case UPPER(ALLTRIM(aStruAlias[nX,1])) == "QI5_OBRIGA"//X3_CAMPO
										aCols[nCnt,nUsado] := QUP->QUP_OBRIGA									     										
									Case UPPER(ALLTRIM(aStruAlias[nX,1])) == "QI5_TRFACT"//X3_CAMPO
										aCols[nCnt,nUsado] := QUP->QUP_TRFACT									     																		
									Case UPPER(ALLTRIM(aStruAlias[nX,1])) == "QI5_PRZHR"//X3_CAMPO
										DbselectArea("QUO")        	
										QUO->(dbSetOrder(1))   
										If QUO->(dbSeek(xFilial("QUO")+M->QI3_MODELO))
											cHRTotal    := Hrs2Min(QUO->QUO_PRZHR)
											cHRParcial  := QNCCalcPercHR(cHRTotal,QUP->QUP_PERC)
											cHRDecimal  := Padl(Alltrim(TransForm(Min2Hrs(cHRParcial),"@R 9999.99")),7,"0")   
											aCols[nCnt,nUsado] := Alltrim(StrTran(cHRDecimal,".",":"))
										Endif
									Otherwise
										If ExistIni(aStruAlias[nX,1])//X3_CAMPO
											aCols[nCnt,nUsado] := InitPad(GetSx3Cache(aStruAlias[nX,1], "X3_RELACAO"))
											If ValType(aCols[nCnt,nUsado]) == "C"
												aCols[1,nUsado] := Padr(aCols[1,nUsado],GetSx3Cache(aStruAlias[nX,1], "X3_TAMANHO"))
											Endif
										Else
											aCols[nCnt,nUsado] := CriaVar(AllTrim(aStruAlias[nX,1]))
										Endif
									EndCase
								Endif
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Amarra as Habilidades as Etapas. ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
							aArea := GetArea()
								If cTPAcao <>  QUP->QUP_TPACAO
								QNCCARHAB(QUP->QUP_TPACAO,M->QI3_FILIAL,M->QI3_CODIGO)
								Endif
							RestArea(aArea)  	    
							cTPAcao := QUP->QUP_TPACAO
							EndIf
							If nPosAli > 0 .and. nPosRec > 0
							aCols[nCnt,nPosAli] := QUP->(Alias())
								If IsHeadRec(aHeader[nPosRec,2])
								aCols[nCnt,nPosRec] := QUP->(RecNo())
								EndIf
							Endif
						aCols[nCnt,Len(aHeader)+1] := .F.
						Next nX
					
					DbSelectArea( "QUP" )
					DbSkip()
					EndDo
				Endif
			Else
		 	cElse := .T.		
			Endif
		Else
			If	cAliasB == "QI5" .And. !Empty(M->QI3_MODELO) .And. nCntMod > 0
			aCols := Array(nCntMod,nUsado+1)
			cElse := .F.
			dbSelectArea("QIC")
			dbSetOrder(1)
				If dbseek( xFilial("QIC")+AllTrim(M->QI3_MODELO))
				nCnt := 0
					While !EOF() .And. xFilial("QIC")+AllTrim(QIC_CODIGO) == xFilial("QIC")+AllTrim(M->QI3_MODELO)
					nCnt++
					nUsado:=1
					
						For nX := 1 To Len(aStruAlias)
							If cNivel >= GetSx3Cache(aStruAlias[nX,1], "X3_NIVEL") .and. !ASCAN({cFil,cCod,cRv},{|x| x == Trim(aStruAlias[nX,1])}) > 0;
	   					   .And. !aStruAlias[nX,1] $ "QI5_DESCCO|QI5_DESCOB|QI5_PEND|QI5_PLAGR|QI5_AGREG|QI5_REJEIT|QI5_CJCOD|QI5_ETPRLA|QI6_SEQ|QI6_DESCR|QI7_SEQ|QI8_SEQ|QI9_PLAGRE"
							nUsado++
									If GetSx3Cache(aStruAlias[nX,1], "X3_CONTEXT") == "V"
									If UPPER(ALLTRIM(aStruAlias[nX,1])) == "QI5_DESCTP"//X3_CAMPO
									aCols[nCnt,nUsado] := Padr(FQNCDSX5("QD",QIC->QIC_TPACAO),30)
									ElseIf UPPER(ALLTRIM(aStruAlias[nX,1])) == "QI5_NUSR"//X3_CAMPO
									aCols[nCnt,nUsado] := Space(30)
									Else
									aCols[nCnt,nUsado] := CriaVar(AllTrim(aStruAlias[nX,1]))//X3_CAMPO
									Endif
								Else
									If UPPER(ALLTRIM(aStruAlias[nX,1])) == "QI5_TPACAO"//X3_CAMPO
									aCols[nCnt,nUsado] := QIC->QIC_TPACAO
									Else
										If ExistIni(aStruAlias[nX,1])//X3_CAMPO
										aCols[nCnt,nUsado] := InitPad(GetSx3Cache(aStruAlias[nX,1], "X3_RELACAO"))
											If ValType(aCols[nCnt,nUsado]) == "C"
											aCols[1,nUsado] := Padr(aCols[1,nUsado],GetSx3Cache(aStruAlias[nX,1], "X3_TAMANHO"))
											Endif
										Else
										aCols[nCnt,nUsado] := CriaVar(AllTrim(aStruAlias[nX,1]))//X3_CAMPO
										Endif
									Endif
								EndIf
							EndIf
							If nPosAli > 0 .and. nPosRec > 0
							aCols[nCnt,nPosAli] := QIC->(Alias())
								If IsHeadRec(aHeader[nPosRec,2])
								aCols[nCnt,nPosRec] := QIC->(RecNo())
								EndIf
							Endif
						aCols[nCnt,Len(aHeader)+1] := .F.
						Next nX
	
					DbSelectArea( "QIC" )
					DbSkip()
					EndDo
				Endif
			Else
		 		cElse := .T.
			Endif
		Endif
	Endif

	If cElse
		aCols := Array(1,nUsado+1)
		If cAliasB == "QI5"
		nUsado	:= 1
		Else
		nUsado	:= 0
		EndIf
	
		For nX := 1 To Len(aStruAlias)
			If cNivel >= GetSx3Cache(aStruAlias[nX,1], "X3_NIVEL") .and. ! ASCAN({cFil,cCod,cRv},{|x| x == Trim(aStruAlias[nX,1])}) > 0;
	   	   		.And. !aStruAlias[nX,1] $ "QI5_DESCCO|QI5_DESCOB|QI5_PEND|QI5_PLAGR|QI5_AGREG|QI5_REJEIT|QI5_CJCOD|QI5_ETPRLA|QI6_SEQ|QI6_DESCR|QI7_SEQ|QI8_SEQ|QI9_PLAGRE"
				nUsado++
				lInit := .F.
				If UPPER(ALLTRIM(aStruAlias[nX,1])) == "QI5_DESCTP"//X3_CAMPO
					aCols[1,nUsado] := Padr(FQNCDSX5("QD",QI5->QI5_TPACAO),30)
				ElseIf UPPER(ALLTRIM(aStruAlias[nX,1])) == "QI5_NUSR"//X3_CAMPO
					aCols[1,nUsado] := Padr(QA_NUSR(QI5->QI5_FILMAT,QI5->QI5_MAT,.T.),40)
				ElseIf ExistIni(aStruAlias[nX,1])//X3_CAMPO
					lInit := .T.
					aCols[1,nUsado] := InitPad(GetSx3Cache(aStruAlias[nX,1], "X3_RELACAO"))
					If ValType(aCols[1,nUsado]) == "C"
						aCols[1,nUsado] := Padr(aCols[1,nUsado],GetSx3Cache(aStruAlias[nX,1], "X3_TAMANHO"))
					Endif
					If aCols[1,nUsado] == NIL
						lInit := .F.
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Caso seja Acao Corretiva atraves da Ficha de Nao-Conformidades³
				//³ atualiza as FNC relacionadas.                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lFNC
					If UPPER(AllTrim(aStruAlias[nX,1])) == "QI9_FNC"//X3_CAMPO
						aCols[1,nUsado] := M->QI2_FNC
						lInit := .T.
					Endif
					If UPPER(AllTrim(aStruAlias[nX,1])) == "QI9_REVFNC"//X3_CAMPO
						aCols[1,nUsado] := M->QI2_REV
						lInit := .T.
					Endif
					If UPPER(AllTrim(aStruAlias[nX,1])) == "QI9_DESRES"//X3_CAMPO
						aCols[1,nUsado] := M->QI2_DESCR
						lInit := .T.
					Endif
				Endif

				If !lInit
					If GetSx3Cache(aStruAlias[nX,1], "X3_TIPO") == "C"
						aCols[1,nUsado] := SPACE(GetSx3Cache(aStruAlias[nX,1], "X3_TAMANHO"))
					ELSEIf GetSx3Cache(aStruAlias[nX,1], "X3_TIPO") == "N"
						aCols[1,nUsado] := 0
					ELSEIf GetSx3Cache(aStruAlias[nX,1], "X3_TIPO") == "D"
						aCols[1,nUsado] := CTOD("  /  /  ","DDMMYY")
					ELSE
						aCols[1,nUsado] := .F.
					EndIf
				Endif
			EndIf
		Next nX
	
		If nPosAli > 0 .and. nPosRec > 0
			aCols[Len(aCols),nPosAli] := cAliasB
			If IsHeadRec(aHeader[nPosRec,2])
				aCols[Len(aCols),nPosRec] := 0
			EndIf
		Endif
		aCols[1,Len(aHeader)+1] := .F.
	Endif


	If cAliasB == "QI5"
		nEtapas:= Len(Acols)
	EndIf
	If GetMv("MV_QTMKPMS",.F.,1) == 2
		lAltEta := .F.
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o Titulo da MSDIALOG conforme opcao escolhida          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If     cAliasB == "QI4"	; cCad1 := OemToAnsi( STR0023 )	//"Equipes"
	ElseIf cAliasB == "QI5"	; cCad1 := OemToAnsi( STR0024 )	//"Acoes/Etapas"
	ElseIf cAliasB == "QI6"	; cCad1 := OemToAnsi( STR0025 ) //"Causas Potenciais"
	ElseIf cAliasB == "QI7"	; cCad1 := OemToAnsi( STR0026 )	//"Documentos"
	ElseIf cAliasB == "QI8"	; cCad1 := OemToAnsi( STR0027 )	//"Custos"
	ElseIf cAliasB == "QI9"	; cCad1 := OemToAnsi( STR0020 )	//"Ocorrencias/Nao-conformidades"
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Quando visualização das Acoes/Etapas, adiciona legenda		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cAliasB == "QI5"
		nTAREFA := If(SuperGetMV("MV_QTMKPMS",.F.,1)>2,aScan(aHeader,{|x| AllTrim(x[2]) == "QI5_TAREFA"}),0)
		nSTATUS := aScan(aHeader,{|x| AllTrim(x[2]) == "QI5_STATUS"})
		
		For nCnt := 1 To Len(aCols)
			Do Case
			Case AllTrim(aCols[nCnt,nSTATUS]) == '5' 			//-- Rejeitado
				aCols[nCnt,1] := LoadBitmap(GetResources(),"BR_PRETO")
			Case AllTrim(aCols[nCnt,nSTATUS]) == '4' 			//-- Finalizado
				aCols[nCnt,1] := LoadBitmap(GetResources(),"BR_VERDE")
			Case AllTrim(aCols[nCnt,nSTATUS]) $ '1*2*3' 		//-- Em execucao
				aCols[nCnt,1] := LoadBitmap(GetResources(),"BR_AMARELO")
			Case nTAREFA > 0 .And. Empty(aCols[nCnt,nTAREFA]) 	//-- Não Gerada
				aCols[nCnt,1] := LoadBitmap(GetResources(),"BR_BRANCO")
			Otherwise  											//-- Nao iniciado
				aCols[nCnt,1] := LoadBitmap(GetResources(),"BR_LARANJA")
			EndCase
		Next nCnt
	EndIf

DEFINE MSDIALOG oDlg1 TITLE cCad1 FROM aMsSize[7],000 TO  (aMsSize[6]/1.5),aMsSize[5] OF oMainWnd Pixel

@ 00,00 MSPANEL oPanel PROMPT "" SIZE 008,025 OF oDlg1 
oPanel:Align := CONTROL_ALIGN_TOP

@ 013, 005 TO 35, (aMsSize[5]/2)-5 OF oDlg1 PIXEL

@010, 008 SAY OemToAnsi( STR0028 ) SIZE 35,7 PIXEL OF oPanel	//	"Codigo Acao: "
@010, 100 SAY OemToAnsi( STR0029 ) SIZE 20,7 PIXEL OF oPanel	//	"Revisao: "

@010,045 MSGET oCodAca VAR cCodAca  PICTURE PesqPict("QI5","QI5_CODIGO")  SIZE  53, 8 PIXEL OF oPanel
@010,123 MSGET oRvAca  VAR cRvAca                                          SIZE  03, 8 PIXEL OF oPanel

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifico se Há Integração TMK/QNC/PMS e os campos QI3_CODCLI e QI3_LOJCLI	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (GetMv("MV_QTMKPMS",.F.,1) == 4)
		@010, 150 SAY OemToAnsi( "Cliente" ) 	SIZE 35,7 PIXEL OF oPanel
		@010, 170 MSGET oCodCli VAR cCodCli  	SIZE 27,8 PIXEL OF oPanel
		
		@010, 204 SAY OemToAnsi( "Loja" ) 		SIZE 35,7 PIXEL OF oPanel
		@010, 218 MSGET oLojCli VAR cLojCli     SIZE 03,8 PIXEL OF oPanel
		
		@010, 238 SAY OemToAnsi( "Nome" ) 		SIZE 020,7 PIXEL OF oPanel
		@010, 255 MSGET oNomCli VAR cNomCli    	SIZE 133,8 PIXEL OF oPanel
			
		oCodCli :lReadOnly:= .T.
		oLojCli :lReadOnly:= .T. 
		oNomCli :lReadOnly:= .T.
		oCodAca :lReadOnly:= .T.
		oRvAca  :lReadOnly:= .T.
	EndIf



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Quando cAliasB = QI9 - Fichas Relacionadas sera apenas visualizacao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ       
	If (nOpcGet == 3 .And. If(cAliasB = "QI9" .And. UPPER(AllTrim(FunName())) = "QNCA040", .F., .T.) .or.;
		nOpcGet == 4)	// Inclusao ou Alteracao
		cAliasLiok := cAliasB
		oGet := MSGetDados():New(038,001,226,315,nOpcGet,"QNC030LiOk(,cAliasLiok)","","",!lAltEta,,,,If(lAltEta,Len(aArray),9999))
		oGet:ForceRefresh()
	Else				// Visualizar ou Exclusao
		oGet := MSGetDados():New(38,1,226,315,2,,,,,,,,9999)
	EndIf
	oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apenas cAliasB = QI9 - Fichas Relacionadas aparecera botao de visualizacao FNC ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cAliasB == "QI5"
		If (GetMv("MV_QTMKPMS",.F.,1) > 2)
	 		aAdd(aButtonEtapa,{"POSCLI" ,{ || nPsHabb := Ascan( aHeader, { |X| Upper( Alltrim( X[2] ) ) = "QI5_TPACAO" } ),If(!Empty(aCols[n,nPsHabb]),QNCA160(nOpc,aCols[n,nPsHabb],n),),oGet:oBrowse:Refresh(),OemToAnsi("Habilidades") },OemToAnsi(STR0091),OemToAnsi("Habilidades")}) //"Habilidade" ##"Habilidade(s) Adicionais" 	 	
		Endif
		aAdd(aButtonEtapa,{"PMSCOLOR"/*SVM"*/ ,{ || Q030LegAXE()},STR0101,STR0043}) //"Legenda" ##"Legenda dos itens"
		oGet:aInfo[1,3] := "'BR_LARANJA'" //-- Inicializador padrao da legenda
		oGet:aInfo[1,4] := .F.			  //-- When da legenda
		ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{||IF(Qnc030VldMTG(aGets,aTela,nOpcGet,aCols,cAliasB),(nOpca1:= 1,oDlg1:End()),nOpca1:=0) },{|| nOpca1:= 3,oDlg1:End()},,aButtonEtapa)
		
		aDel(aHeader,1)   
		aSize(aHeader,Len(aHeader)-1)       
	             
		For nCnt := 1 To Len(aCols)
			aDel(aCols[nCnt],1)
			aSize(aCols[nCnt],Len(aCols[nCnt])-1)
		Next nCnt
	Else
		If cAliasB == "QI9"
			aButtonFNC := {{"PESQUISA"  ,{ || QNC030VFNC(),oGet:oBrowse:Refresh() },OemToAnsi( STR0061 ), OemtoAnsi(STR0079) }}  //"Visualiza FNC" //"FNC"
			ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{||IF(Qnc030VldMTG(aGets,aTela,nOpcGet,aCols,cAliasB),(nOpca1:= 1,oDlg1:End()),nOpca1:=0) },{|| nOpca1:= 3,oDlg1:End()},,aButtonFNC)
		Else
			ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{||IF(Qnc030VldMTG(aGets,aTela,nOpcGet,aCols,cAliasB),(nOpca1:= 1,oDlg1:End()),nOpca1:=0) },{|| nOpca1:= 3,oDlg1:End()})												
		Endif
	Endif

	If nOpcGet <> 2 .And. nOpcGet <> 5 //-- Se nao for Visualizacao ou Exclusao
		If nOpca1 == 1	// Ok

 			For nCnt := 1 To Len(aHeader)
				If UPPER(ALLTRIM(aHeader[nCnt,2])) == "QI5_STATUS"
					nPosStaQI5 := nCnt
				EndIf
			Next nCnt

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava os lactos dos cadastros de acordo com a opcao em ARRAY    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aArray:={}
			For nT := 1 to Len(aCols)
				If aCols[nT,Len(aCols[nT])] == .F.
					aAdd(aArray,aCols[nT])
				Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Deleta as habilidades(QUR) amarradas as Etapas. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
				DbSelectArea("QUR")
				DbSetOrder(1)
					If QUR->(DbSeek(xFilial("QI5")+ QI5->QI5_CODIGO + aCols[nT,1]))
						While !Eof() .And. QUR->QUR_FILIAL+QUR->QUR_CODIGO+QUR->QUR_TPACAO == xFilial("QI5")+QI5->QI5_CODIGO+aCols[nT,1]
							RecLock("QUR",.F.)
							dbDelete() 
							MsUnlock()
							FKCOMMIT()            
							dbSkip()
						Enddo
					Endif
				Endif
			Next nT
		EndIf
	EndIf

lDlgEtapa:= .T.
nEtapas  := 0

Return nOpca1

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC030LiOk ³ Autor ³ Aldo Marini Junior   ³ Data ³ 29.12.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Critica linha digitada                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNC030LiOk(o,cAliasB)

Local nx        := 0
Local nCont		:= 0
Local nQI5      := 0
Local nPos1 	:= 0, nPos2 := 0, nPos3 := 0, nPos4 := 0, nPos5 := 0, nPos6 := 0
Local nPos7 	:= 0, nPos8 := 0, nPos9 := 0, nPosA := 0, nPosB := 0, nPosC := 0
Local nPosD 	:= 0, nPosE := 0, nPosF := 0, nPosG := 0, nPosH := 0, nPosI := 0
//Local nPosM     := 0, nPosN := 0
Local nVar 		:= 0
Local lRet 		:= .T.
Local aAllCpo	:={}
Local cQncPrz  	:= GetMV("MV_QNCPRZ",.F.,"2")		// 1=Sim, 2=Nao
Local cMvValid 	:= GetMV("MV_QNCVFNC",.F.,"1")		// 1=Valida,2=Nao Valida
Local cVldUSER	:=""
Local lTMKPMS   := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
Local lAltDeta := If(GetMv("MV_QNCADET",.F.,"1")=="1",.T.,.F.) // 1=SIM 2=NAO - ALTERACAO DO CAMPO DESCRICAO DETALHADA
Local lVcausa	 := GetMv('MV_VCAUSA',.F.,.F.)

Private  nPosJ     := 0, nPosk := 0, nPosl := 0

	If aCols[n,Len(aCols[n])] == .F.
	// VerIfica a Posicao dos Campos na Matriz de Cabecalho
		If cAliasGet == "QI4"
			nPos1 := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI4_FILMAT"})
			nPos2 := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI4_MAT"   })
		ElseIf cAliasGet == "QI5"
			nPos3 := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI5_FILMAT"})
			nPos4 := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI5_MAT"   })
			nPosF := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI5_TPACAO"})
			nPosG := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI5_PRAZO" })
			nPosI := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI5_STATUS"})
			nPosJ := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI5_REALIZ"})
			nPosK := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI5_DESCRE"})
			nPosL := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI5_MEMO1"})	
		ElseIf cAliasGet == "QI6"
			nPosA := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI6_CAUSA" })
			nPosB := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI6_METODO"})
			nPosC := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI6_MEMO1" })
			nPosH := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI6_TIPO"  })
		ElseIf cAliasGet == "QI7"
			nPos7 := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI7_TPDOC" })
			nPos8 := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI7_DOC"   })
			nPos9 := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI7_RV"   })
		ElseIf cAliasGet == "QI8"
			nPos5 := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI8_CUSTO" })
			nPos6 := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI8_VLCUST"})
		ElseIf cAliasGet == "QI9"
			nPosD := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI9_FNC"   })
			nPosE := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI9_REVFNC"})
		Endif
		
		If !lBaixaAle
			If nPosG > 0 .and. cQncPrz == "2"
				If Len(aCols) > 0 .And. n > 1
					If aCols[n,nPosG] < aCols[n-1,nPosG]
						Help(" ",1,"QNCDTMENOR")	// Data menor que o Lacto anterior
						Return( .F. )
					Endif
				Endif
			Endif
		    
			If nPosG > 0 .And. !Empty(aCols[n,nPosG]) .And. aCols[n,nPosG] < M->QI3_ABERTU
				msgAlert(STR0115) //"Data do prazo execução menor que a data de abertura do plano de ação."
				return (.F.) 
			EndIf
				
			If Len(aCols) > 1 .And. n > 1 .And. cAliasB == 'QI5'
				If aCols[n,nPosI] <> "0"
					for nVar := 1 to n-1
						if aCols[nVar,nPosI] <> "4"
							msgAlert("Baixa sequencial - Etapa anterior não Concluida")
							return (.F.)
						EndIf
					Next nVar
				EndIf
			EndIf
		Else
			If nPosG > 0 .And. !Empty(aCols[n,nPosG]) .And. aCols[n,nPosG] < M->QI3_ABERTU
		   		msgAlert(STR0115) //"Data do prazo execução menor que a data de abertura do plano de ação."
		   		return (.F.)
			EndIf
		EndIf
	
		If	(nPos1 <> 0 .And. nPos2 <> 0) .Or. ;
			(nPos3 <> 0 .And. nPos4 <> 0) .Or. ;
			(nPosA <> 0 .And. nPosB <> 0 .And. nPosC <> 0 .And. nPosH <> 0) .Or. ;
			(nPosD <> 0 .And. nPosE <> 0 ) .Or. ;
			 nPos5 <> 0 .Or. nPos6 <> 0 .Or. nPos7 <> 0 .Or. nPos8 <> 0 .Or. nPos9 <> 0 

		// Plano de Acao por Equipe
				If nPos1 <> 0 .And. nPos2 <> 0
			Aeval(aCols,{ |X| If( aCols[N,Len(aCols[N])]==.F. .And.;
								X[nPos1]==aCols[N,nPos1] .And.;
								X[nPos2]==aCols[N,nPos2], nCont ++ , nCont ) } )
			EndIf

		// Plano de Acao por Acoes/Epatas
			If nPos3 <> 0 .And. nPos4 <> 0
				QAA->(dbSetOrder(1))
				If aCols[N,nPosI] <> "4"
					If QAA->(dbSeek(aCols[N,nPos3]+aCols[N,nPos4])) .And. ! QA_SitFolh()
						Help( " ", 1, "A090DEMITI" )
						Return(.F.)
					Endif
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³no STATUS 100% sera obrigatorio o Preechimento das                 ³
				//³Prazo, Realizacao , Descr Resumida e Descri Compl.                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
				IF aCols[N,nPosI] == "4"
					DO Case
						Case aCols[N,nPosG]==CTOD(SPACE(8))
							HELP("  ",1,"OBRIGAT",,RetTitle(aHeader[nPosG,2])+Space(30),3,0)									
							Return(.F.)		
						Case aCols[N,nPosJ]==CTOD(SPACE(8))
							HELP("  ",1,"OBRIGAT",,RetTitle(aHeader[nPosJ,2])+Space(30),3,0)									
							Return(.F.)
						Case Empty(aCols[N,nPosK])
							HELP("  ",1,"OBRIGAT",,RetTitle(aHeader[nPosK,2])+Space(30),3,0)					
							Return(.F.)
						Case EMPTY(aCols[N,nPosL])
							If lAltDeta
								HELP("  ",1,"OBRIGAT",,RetTitle(aHeader[nPosL,2])+Space(30),3,0)					
								Return(.F.)											
							EndIf
					EndCase
				Endif
			EndIf

			// Plano de Acao por Custo
			If nPos5 <> 0
				Aeval(aCols,{ |X| If( aCols[N,Len(aCols[N])]==.F. .And. X[nPos5]==aCols[N,nPos5],  nCont ++ , nCont ) } )
			EndIf

			// Plano de Acao por Documentos
			If nPos8 <> 0 .And. nPos9 <> 0
				Aeval(aCols,{ |X| If( aCols[N,Len(aCols[N])]==.F. .And. ;
									X[nPos8]==aCols[N,nPos8] .And. ;
								    X[nPos9]==aCols[N,nPos9], nCont ++ , nCont ) } )
			EndIf

		// Plano de Acao por Causas
			If nPosA <> 0 .And. nPosB <> 0 .And. nPosC <> 0 .And. nPosH <> 0
				Aeval(aCols,{ |X| If( aCols[N,Len(aCols[N])]==.F. .And.;
								    X[nPosA]==aCols[N,nPosA] .And.;
								    X[nPosB]==aCols[N,nPosB] .And.;
								    X[nPosH]==aCols[N,nPosH], nCont ++ , nCont ) } )
			
				If nCont == 1 .And. Len(aCols) > 1
			    nCont:= 0
				Aeval(aCols,{ |X| If( aCols[N,Len(aCols[N])]==.F. .And.;
			 			X[nPosH]==aCols[N,nPosH], nCont++ , nCont ) } )
					If nCont > 19 //Limitacao fisica do Tamanho do Relatorio
						Help("",1,"QALCTOMAX",,OemToAnsi(STR0080+TitSX3("QI6_TIPO")[1]+STR0081),1)  //"Excedeu a quantidade de "###" por Plano de Acao. A quantidade maxima permitida é 19"
						Return( .F. )
					Else
						nCont:=1				 	
					Endif
				EndIf
			
				If !aCols[N][Len(aCols[N])]
					If Empty(aCols[N][nPosA])
						msgAlert(STR0085+SX3Desc({"QI6_CAUSA"})[1])//"E necessario preencher o campo "
						Return .F.
					EndIf
					If Empty(aCols[n][nPosH])
						Messagedlg(STR0098)
						Return .F.
					Endif
				EndIf
			EndIf

			// Plano de Acao por Ocorrencias/Nao-conformidades
			If nPosD <> 0 .And. nPosE <> 0
				Aeval(aCols,{ |X| If( aCols[N,Len(aCols[N])]==.F. .And.;
									X[nPosD]==aCols[N,nPosD] .And. ;
								   X[nPosE]==aCols[N,nPosE], nCont ++ , nCont ) } )
			EndIf

			If nCont > 1 .And. Len(aCols) > 1
				Help(" ",1,"QALCTOJAEX")
				Return( .F. )
			EndIf
		EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Campo a serem validados quanto ao seu conteudo					³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAllCpo:={ "QI4_FILMAT","QI4_MAT"  ,"QI5_FILMAT","QI5_MAT"   ,"QI8_CUSTO" ,;
				"QI8_VLCUST","QI7_TPDOC","QI7_DOC"   ,"QI7_REV"    ,"QI9_FNC"   ,;
				"QI9_REVFNC", "QI5_TPACAP" }
				
	
		For nx := 1 To Len(aHeader)
			If Empty(aCols[n][nx])
				nItem := Ascan(aAllCpo,{ |X| UPPER(ALLTRIM(X)) == UPPER(ALLTRIM(aHeader[nx][2]))})
				If nItem > 0
					If Lastkey() # 27
						HELP("  ",1,"OBRIGAT",,RetTitle(aAllCpo[nItem])+Space(30),3,0)					
						lRet := .F.
					EndIf
					Exit
				EndIf
				// Plano de Acao por Acoes/Epatas
				If lRet .And. nPos3 <> 0 .And. nPos4 <> 0
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Realiza o X3_VALID e/ou X3_VLDUSER dos campos do QI5 no aheader ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
					cVadUSER:=GetSx3cache(aHeader[nx,2],"X3_VLDUSER")
					
					M->&(Alltrim(aHeader[nx,2])):=aCols[n][nx]
					__ReadVar := 'M->'+Alltrim(aHeader[nx,2])
						
					lRet:=IF(!Empty(aHeader[nx,6]),&(aHeader[nx,6]),.T.) .And. IF(!Empty(cVadUSER),&(cVadUSER),.T.)			
					IF !lRet
						Aviso(STR0094,aHeader[nx,1],{"OK"},1,STR0095)//"Atenção"##"Preencha o campo:"
						Exit
					EndIf
				Endif
			EndIf
		Next nx
	
		If lRet .And. cAliasGet == "QI9" .And. cMvValid == "1"
			QI9->(DbSetOrder(2))
			If 	QI9->(DbSeek(xFilial("QI9") + aCols[n][nPosD] + aCols[n][nPosE])) .And.;
				QI9->QI9_CODIGO <> M->QI3_CODIGO
				If !lTMKPMS //Na integracao do QNC com o TMK uma FNC podera estar associada a mais de um Plano.
					Help(" ",1,"QALCTOJAEX",, STR0036 + TransForm(QI9->QI9_CODIGO,PesqPict("QI9","QI9_CODIGO") ),3,1)	// "Plano de Acao No. "
					lRet := .F.
				Endif
			Endif
			QI9->(DbSetOrder(1))

			// Verifica se FNC PROCEDE E/OU OBSOLETA
			If !FQNCCHKFNC(aCols[n][nPosD],aCols[n][nPosE])
				lRet := .F.
			Endif
		Endif
	EndIf
	If Existblock("QN030LOK")
		lRet := Execblock("QN030LOK",.F.,.F.)
	Endif

	IF cAliasGet == "QI6"
		INCLUI := .T.
	ENDIF

	If lRet
		lRet:= QNC030St()
	EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ-ÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC030GrLacto³Autor  ³ Aldo Marini Junior ³ Data ³ 29/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄ-ÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava os Lactos do Cadastros (Ex: Equipes,Causas,Custos...)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC030GrLacto(cAlias,aArray)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Alias do Cadastro a ser atualizado                 ³±±
±±³          ³ ExpC2 - Array Contendo os campos a serem gravados          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QNC030GrLacto(cAlias,aArray,nOpc,aQI5Aux)

Local aHeader   := {}
Local nX		:= 0
Local nC    	:= 0
Local nPosD		:= 0, nPosE:= 0, nPosF:= 0, nPosG:= 0
Local cFilAca	:= cAlias+"_FILIAL"
Local cCodAca	:= cAlias+"_CODIGO"
Local cRvAca 	:= cAlias+"_REV"
Local cCod  	:= cAlias+"->"+cAlias+"_FILIAL+"+cAlias+"->"+cAlias+"_CODIGO+"+cAlias+"->"+cAlias+"_REV"
Local lAtuPend  := .T.
Local nPosQi9C	:= nPosQi9R := 0		// Posicao do codigo e Revisao do QI9
Local lMvPlPrc	:= GetMv("MV_QPLPRC", .F., "N") = "S"
Local cMvValid  := GetMV("MV_QNCVFNC",.F.,"1")		// 1=Valida,2=Nao Valida
Local cDurPLAN  := 0
Local dDTQI5    := CTOD("  /  /  ")
Local dNewPrazo := CTOD("  /  /  ") 
Local lTMKPMS   := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
Local nAlt      := 0
Local nHrAcum   := 0
Local nHRQI5    := 0
Local lNFz      := .T.
Local lQN030MEM	:= Existblock ("QN030MEM")
Local dPrazoAnt := CTOD("  /  /  ")
Local aStruAlias := FWFormStruct(3, cAlias)[3]
Local nMVQTMKPMS := GetMv("MV_QTMKPMS",.F.,1)
Default nOpc    := 2
Default aQI5Aux	:= {}


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VerIfica o cabecalho da MsGetDados                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader:={}

	If cAlias == "QI5"
		If lRevisao
	    	dPrazoAnt := QI5->QI5_PRAZO
	   		aHeader := aClone(aHdQI5)
		Else
			For nX := 1 To Len(aStruAlias)
				If cNivel >= GetSx3Cache(aStruAlias[nX,1], "X3_NIVEL") .and. ! ASCAN({cFilAca,cCodAca,cRvAca},{|x| x == Trim(aStruAlias[nX,1])}) > 0;
	   		   	   .And. !aStruAlias[nX,1] $ "QI5_DESCCO|QI5_DESCOB|QI5_PEND|QI5_PLAGR|QI5_AGREG|QI5_REJEIT|QI5_CJCOD|QI5_ETPRLA|QI6_SEQ|QI6_DESCR|QI7_SEQ|QI8_SEQ|QI9_PLAGRE"
					AADD(aHeader, Q030GetSX3(aStruAlias[nX,1], "", "") )
				EndIf
			Next nX
		Endif
	Else
		For nX := 1 To Len(aStruAlias)
			If cNivel >= GetSx3Cache(aStruAlias[nX,1], "X3_NIVEL") .and. ! ASCAN({cFilAca,cCodAca,cRvAca},{|x| x == Trim(aStruAlias[nX,1])}) > 0;
	       	   .And. !aStruAlias[nX,1] $ "QI5_DESCCO|QI5_DESCOB|QI5_PEND|QI5_PLAGR|QI5_AGREG|QI5_REJEIT|QI5_CJCOD|QI5_ETPRLA|QI6_SEQ|QI6_DESCR|QI7_SEQ|QI8_SEQ|QI9_PLAGRE"
				AADD(aHeader, Q030GetSX3(aStruAlias[nX,1], "", "") )
			EndIf
		Next nX
	Endif
                                                  
	If cAlias == "QI8"
		If lRevisao
		aHeader := aClone(aHdQI8)
		Else
			For nX := 1 To Len(aStruAlias)
				If cNivel >= GetSx3Cache(aStruAlias[nX,1], "X3_NIVEL") .and. ! ASCAN({cFilAca,cCodAca,cRvAca},{|x| x == Trim(aStruAlias[nX,1])}) > 0;
	   		       .And. !aStruAlias[nX,1] $ "QI5_DESCCO|QI5_DESCOB|QI5_PEND|QI5_PLAGR|QI5_AGREG|QI5_REJEIT|QI5_CJCOD|QI5_ETPRLA|QI6_SEQ|QI6_DESCR|QI7_SEQ|QI8_SEQ|QI9_PLAGRE"
					AADD(aHeader, Q030GetSX3(aStruAlias[nX,1], "", "") )
				EndIf
			Next nX
		Endif
	Endif

	nPosD := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == (cAlias+"_MEMO1") })
	nPosE := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == (cAlias+"_MEMO2") })
	If cAlias == "QI5"
		nPosF := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == ("QI5_PRAZO")})
		nPosG := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == ("QI5_PRZHR")})	
	Endif

	Begin Transaction

	DbSelectArea(cAlias)
		If DbSeek( M->QI3_FILIAL + M->QI3_CODIGO + M->QI3_REV )
			While ! Eof() .And.  &(cCod) == M->QI3_FILIAL + M->QI3_CODIGO + M->QI3_REV
				If cAlias = "QI9"	// Procuro pela ficha e limpo o conteudo
					If nPosQi9C = 0
						nPosQi9C := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI9_FNC" })
						nPosQi9R := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI9_REVFNC" })
					Endif
			
					QI2->(DbSetOrder(2))
					If Ascan(aArray, { |x| 	x[nPosQi9C] = QI9->QI9_FNC .And.;
									 x[nPosQi9R] = QI9->QI9_REV }) = 0 .And.; 
						QI2->(DbSeek( QI9->QI9_FILIAL + QI9->QI9_FNC + QI9->QI9_REVFNC ))
						If Empty(QI2->QI2_CODACA) .Or. cMvValid == "1"
							DbSelectArea("QI2")
							RecLock("QI2")
							Replace	QI2_CODACA With Space(Len(QI9->QI9_FNC)),;
									QI2_REVACA With Space(Len(QI9->QI9_REV)),;
									QI2_CONREA With Ctod("")
							DbSelectArea(cAlias)  
							MsUnLock()
							FKCOMMIT()
						Endif
					Endif
					QI2->(DbSetOrder(1))
				Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Deleta lancamentos do arquivo MEMO                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cAlias == "QI5"
					MSMM(QI5->QI5_DESCCO,,,,2)
					MSMM(QI5->QI5_DESCOB,,,,2)
				ElseIf  cAlias == "QI6"
					MSMM(QI6->QI6_DESCR,,,,2)
					If lQN030MEM
						For nX := 1 To Len(aMemUser)
							If SubStr(aMemUser[nX,1],1,3) == "QI6"
								MSMM((QI6->&(aMemUser[nX,1])),,,,2)
							Endif
						Next
					Endif
				Endif

				RecLock(cAlias)
				dbDelete()
				MsUnlock()            
				FKCOMMIT()
				DbSkip()
			Enddo
		EndIf

		If lTMKPMS
			DbselectArea("QUO")
			QUO->(dbSetOrder(1))	
			IF QUO->(MsSeek(xFilial("QUO")+M->QI3_MODELO))
				cDurPLAN := QUO->QUO_PRZHR	
			Endif
		Endif
	
		DbSelectArea(cAlias)
		For nC := 1 TO Len(aArray)

			If aArray[nC,Len(aArray[nC])] == .F. .and. !Empty(aArray[nC,1]) // Quando comentei esse cara, gravou correto em todas as tabelas

				RecLock(cAlias,.T.,.T.)
				&(cAlias+"->"+cAlias+"_FILIAL") := M->QI3_FILIAL
				&(cAlias+"->"+cAlias+"_CODIGO") := M->QI3_CODIGO
				&(cAlias+"->"+cAlias+"_REV")    := M->QI3_REV    
				If cAlias $ "QI5,QI6,QI7,QI8"
					&(cAlias+"->"+cAlias+"_SEQ"):= StrZero(Val(aArray[nC][1]),Len(AllTrim(aArray[nC][1])))
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava os campos um a um dos lactos dos sub-cadastros            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				QNC_GRAVCPS(nC,aArray,aHeader)
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza o campo de Pendencia S/N                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IF If(lMvPlPrc, M->QI3_STATUS == "3", .T.) .And. cAlias == "QI5" .And. (lAtuPend .Or. lBaixaAle)
					If (QI5->QI5_SEQ == "01" .And. QI5->QI5_STATUS <> "4") .Or. ;
					   (nC >= 1 .And. QI5->QI5_STATUS <> "4")
					    QI5->QI5_PEND := "S"
						lAtuPend := .F.
					Else
						IF QI5->QI5_STATUS == "4"
							If Empty(QI5->QI5_PRAZO)
								QI5->QI5_PRAZO := QI3->QI3_ENCREA
							Endif
							If Empty(QI5->QI5_REALIZ)
								QI5->QI5_REALIZ := QI3->QI3_ENCREA
							Endif
							QI5->QI5_PEND	:= "N"
						Endif
					Endif
				Endif
				MsUnlock()
				FKCOMMIT()		
				If cAlias = "QI9"	// Procuro pela ficha e indico o plano de acao
					QI2->(DbSetOrder(2))
					If QI2->(DbSeek( QI9->QI9_FILIAL + QI9->QI9_FNC + QI9->QI9_REVFNC ))
						If Empty(QI2->QI2_CODACA) .Or. cMvValid == "1"
							DbSelectArea("QI2")
							RecLock("QI2")
							Replace	QI2_CODACA With M->QI3_CODIGO,;
									QI2_REVACA With M->QI3_REV
							If QI2->QI2_STATUS == "1"
		                    	Replace QI2_STATUS With "3"
							Endif
							MsUnLock()
							FKCOMMIT()
							DbSelectArea(cAlias)
						Endif
					Endif
					QI2->(DbSetOrder(1))
				Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava os campos tipo MEMO de acordo com os arquivos             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nPosD > 0
					If cAlias == "QI5" .And. ;
					   ((nOpc == 3 .And. !Empty(aArray[nC,nPosD])) .Or. ;
					   (nOpc == 4 .And. !Empty(QI5->QI5_DESCCO)) .Or. ;
					   (nOpc == 4 .And. !Empty(aArray[nC,nPosD]) .And. Empty(QI5->QI5_DESCCO)))
						MSMM(QI5_DESCCO,,,aArray[nC,nPosD],1,,,"QI5","QI5_DESCCO")
					ElseIf cAlias == "QI6" .And. ;
						   ((nOpc == 3 .And. !Empty(aArray[nC,nPosD])) .Or. ;
						   (nOpc == 4 .And. !Empty(QI6->QI6_DESCR)) .Or. ;
						   (nOpc == 4 .And. !Empty(aArray[nC,nPosD]) .And. Empty(QI6->QI6_DESCR)))
						MSMM(QI6_DESCR,,,aArray[nC,nPosD],1,,,"QI6","QI6_DESCR")
					Endif
				Endif

				If nPosE > 0
					If cAlias == "QI5" .And. ;
					   ((nOpc == 3 .And. !Empty(aArray[nC,nPosE])) .Or. ;
					   (nOpc == 4 .And. !Empty(QI5->QI5_DESCOB)) .Or. ;
					   (nOpc == 4 .And. !Empty(aArray[nC,nPosE]) .And. Empty(QI5->QI5_DESCOB)))
						MSMM(QI5_DESCOB,,,aArray[nC,nPosE],1,,,"QI5","QI5_DESCOB")
					Endif
				Endif
			
				If lQN030MEM .And. cAlias == "QI6"
					QN030AdMem(aMemUser,nOpc,aArray[nC],aHeader)
				Endif
			
				If lTMKPMS
					If nMVQTMKPMS > 2
						If (cAlias == "QI5") .And. (nOpc == 4)
							//Tratamento da alteracao da data
							If Len(aQI5Aux) > 0 .and. Len(aArray) > 0
								If Len(aQI5Aux) == Len(aArray)
									If aQI5Aux[nC,nPosF] <> aArray[nC,nPosF] .Or.;  //Se as datas forem diferentes prevale a data alterada
									   aQI5Aux[nC,nPosG] <> aArray[nC,nPosG]				
									   dDTQI5:= QI5->QI5_PRAZO
										lNFz := .F.
									Endif
								Endif
								If lNFz
									If !Empty(dDTQI5)//Se as datas forem iguais prevalecera o ultimo prazo alterado
										If Empty(QI5->QI5_REALIZ)
											dNewPrazo := QN5CalPrz(dDTQI5,@nHrAcum,M->QI3_ENCPRE,aArray[nC,nPosG],cDurPLAN)
											RecLock("QI5",.F.)			
											If Empty(dNewPrazo) .and. Empty(QI5->QI5_PRAZO)
												QI5->QI5_PRAZO  := dDataBase   
											Else
												QI5->QI5_PRAZO  := dNewPrazo 
											EndIf
											QI5->(MsUnLock())		
											dDTQI5 := QI5->QI5_PRAZO						
										Endif
									Endif
								Endif
							Endif
						Endif
					Endif
				Endif
			Endif
		Next

	End Transaction

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC030Del ³ Autor ³ Aldo Marini Junior    ³ Data ³ 29/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para Exclusao de Acao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC030Del()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC030Del(lRevisao,aQNQI3)
Local nOrdQI3    := QI3->(IndexOrd())
Local nRegQI3    := QI3->(Recno())
Local cChaveQI3  := ""
Local cRevAnt    := ""
Local cRevQI3    := ""
Local nI
Local lTMKPMS  := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³
Local lQN030MEM := ExistBlock("QN030MEM")
Local nx        := 0


Default lRevisao := .F.
Default aQNQI3   := {}

QI2->(dbSetOrder(5))
	If QI2->(dbSeek(QI3->QI3_FILIAL + QI3->QI3_CODIGO + QI3->QI3_REV ))
	Help(" ",1,"QNC030LFNC")	// Existe Lancamento de FNC relacionada
	QI2->(dbSetOrder(1))
	Return
	Endif
QI2->(dbSetOrder(1))

	Begin Transaction

	aArq := {"QI4",;  //"Equipes"
			  "QI5",;   //"Acoes/Etapas"
			  "QI6",;   //"Causas Potenciais"
			  "QI7",;   //"Documentos"  
			  "QI8",;   //"Custos"
			  "QI9"}	   //"Ocorrencias/Nao-conformidades"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta Lancamentos dos arquivos associados         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nI:=1 to Len(aArq)
		cChaveArq := aArq[nI]+"->"+aArq[nI]+"_FILIAL+"+aArq[nI]+"->"+aArq[nI]+"_CODIGO+"+aArq[nI]+"->"+aArq[nI]+"_REV"
		dbSelectArea(aArq[nI])
			If dbSeek(QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV)
				While !Eof() .And. &cChaveArq == QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Deleta lancamentos do arquivo MEMO                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If aArq[nI] == "QI5"
					MSMM(QI5->QI5_DESCCO,,,,2)
					MSMM(QI5->QI5_DESCOB,,,,2)
					ElseIf aArq[nI] == "QI6"
					MSMM(QI6->QI6_DESCR,,,,2)
						If lQN030MEM
							For nX := 1 To Len(aMemUser)
								If SubStr(aMemUser[nX,1],1,3) == "QI6"
								MSMM((QI6->&(aMemUser[nX,1])),,,,2)
								Endif
							Next
						Endif
					Endif

        		RecLock(aArq[nI])
				dbDelete()
        		MsUnlock()
        		FKCOMMIT()
				dbSkip()
				Enddo
			Endif
		Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta Documentos Anexos                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    dBSelectArea("QIE")
		If dbSeek(QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV)
			While !Eof() .And. QIE->QIE_FILIAL+QIE->QIE_CODIGO+QIE->QIE_REV == QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV
			cFileTrm := QIE->QIE_ANEXO
				If File(cQPathFNC+cFileTrm)
				FErase(cQPathFNC+cFileTrm)	
				Endif

			RecLock("QIE",.F.)
			dbDelete()
			MsUnlock()    
			FKCOMMIT()
			dbSkip()
			Enddo
		Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta lancamentos do arquivo MEMO                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MSMM(QI3->QI3_PROBLE,,,,2)
	MSMM(QI3->QI3_LOCAL ,,,,2)
	MSMM(QI3->QI3_RESESP,,,,2)
	MSMM(QI3->QI3_RESATI,,,,2)
	MSMM(QI3->QI3_OBSERV,,,,2)
	MSMM(QI3->QI3_METODO,,,,2)
	MSMM(QI3->QI3_MOTREV,,,,2)
		If lQN030MEM
			For nX := 1 To Len(aMemUser)
				If SubStr(aMemUser[nX,1],1,3) == "QI3"
				MSMM(&("QI3->"+aMemUser[nX,1]),,,,2)
				Endif
			Next
		EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o codigo sequencial                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lRevisao
        // Voltar codigo caso parametro for "S"
		GETQNCSEQ("QI3","QI3_CODIGO",QI3->QI3_CODIGO,.T.,5,@aQNQI3)
		Endif

	cChaveQI3 := QI3->QI3_FILIAL+QI3->QI3_CODIGO
	cRevQI3   := QI3->QI3_REV

		If lTMKPMS
		DbSelectArea("QUR")
		DbSetOrder(1)
			If QUR->(DbSeek(xFilial("QUR")+QI3->QI3_CODIGO))
				While !Eof() .And. QUR->QUR_FILIAL+QUR->QUR_CODIGO+QUR->QUR_TPACAO == xFilial("QUR")+QI3->QI3_CODIGO
			 	RecLock("QUR",.F.)
				dbDelete() 
				MsUnlock()
				FKCOMMIT()            
		   		dbSkip()
				Enddo
			Endif
		Endif
		
	RecLock("QI3")
	dbDelete()
	MsUnlock()
	FKCOMMIT()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Volta a penultima sequencia de Revisao para situacao normal (nao obsoleto) ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QI3")
	dbSetOrder(2)

		If dbSeek(QI3->QI3_FILIAL+QI3->QI3_CODIGO)
			While !Eof() .And. QI3->QI3_FILIAL+QI3->QI3_CODIGO == cChaveQI3
				If QI3->QI3_REV == cRevQI3
				Exit
				Endif
			cRevAnt := QI3->QI3_REV
			dbSkip()
			Enddo
			If !Empty(cRevAnt)
				If dbSeek(cChaveQI3+cRevAnt)
				RecLock("QI3")
				QI3->QI3_OBSOL := "N"
				MsUnlock()
				FKCOMMIT()
				Endif
			Endif
		Else
		dbGoTo(nRegQI3)
		Endif
	dbSetOrder(nOrdQI3)
	
	End Transaction

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FQNC030SEQ³ Autor ³ Aldo Marini Junior    ³ Data ³ 06/01/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa generico para Buscar Sequencias                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Function FQNC030SEQ()

Local nRet	  := 1
Local nCont   := 1
Local nSoma   := 'AA'
Local nResult := ''
Local nPos    := aScan(aHeader, { |x| AllTrim(x[2]) == "QI5_SEQ" })

		While nRet < Len(aCols) .And. !Empty(aCols[nRet,2])
			nRet += 1
			nCont := nRet - 1
		EndDo

		If nRet == 100 
			nResult := nSoma
		ElseIf nRet > 100
			nResult :=	Soma1(aCols[nRet-1][2])
		Else
			IF ValType(aCols[nCont][1]) == "O"
				If AllTrim(aCols[nCont][2]) > StrZero(nRet,2)
					nRet := Val(aCols[nCont][nPos]) +1
				Else
					If AllTrim(aCols[nCont][2]) == StrZero(nRet,2)
						nRet += 1
					EndIF
				Endif
			Else
				If AllTrim(aCols[nCont][1]) > StrZero(nRet,2) 
					nRet := Val(aCols[nCont][nPos]) +1
				Else
					If AllTrim(aCols[nCont][1]) == StrZero(nRet,2) 
						nRet += 1
					EndIF
				Endif
			Endif
			nResult := StrZero(nRet,2) 
		Endif

Return nResult

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FQNCCHKFNC³ Autor ³ Aldo Marini Junior    ³ Data ³ 24/01/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para Validacao das FNC relacionas                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FQNCCHKFNC(cCodFNC,cCodRev)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Ficha Nao-Conformidade                   ³±±
±±³          ³ ExpC2 = Codigo da Revisao da Ficha Nao-Conformidade        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FQNCCHKFNC(cCodFNC,cCodRev,lMsg)
Local lRet  := .F. 
Local cChave := AllTrim(Right(cCodFNC,4)) + cCodFNC + IF(cCodRev<>NIL,cCodRev,"")
Local cMvValid := GetMV("MV_QNCVFNC",.F.,"1")		// 1=Valida,2=Nao Valida
Local cStatusPlano := AllTrim(GetMv("MV_QNCSFNC",.F.,"3"))

Default lMsg := .T.
dbSelectArea("QI2")
dbGoTop()
QI2->(dBSetOrder(1))
	If QI2->(dbSeek(xFilial("QI2")+cChave))
		If cMvValid == "1"
			If !Empty(cCodRev)
				If QI2->QI2_STATUS $ cStatusPlano .And. QI2->QI2_OBSOL=="N"
				lRet := .T.
				Endif
			Else
			lRet := .T.	
			Endif
		Else
		lRet := .T.	
		Endif
	Endif

	If FUNNAME()=="QNCA040"
		lRet := .T.           
	ElseIf !lRet .AND. lMsg
    	Help(" ",1,"QNC040NCAC")
	Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FQNCWHENQI3³ Autor ³ Aldo Marini Junior   ³ Data ³ 09/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Desabilitar a Edicao dos campos QI3 qdo Acao for Baixada   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FQNCWHENQI3()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FQNCWHENQI3
Local lRet  := .T.

	If !Empty(QI3->QI3_ENCREA)
	lRet := .F.
	Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FQNCQI3BX ³ Autor ³ Aldo Marini Junior   ³ Data ³ 09/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se existem lactos pendentes das Etapas da Acoes   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FQNCQI3BX()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FQNCQI3BX()

Local lRet  := .T.

QI5->(dbSetOrder(1))
	If M->QI3_STATUS <>	"5"	// Cancelada
		If QI5->(dbSeek(M->QI3_FILIAL+M->QI3_CODIGO+M->QI3_REV))
			While QI5->(!Eof()) .And. QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV == M->QI3_FILIAL+M->QI3_CODIGO+M->QI3_REV
				If QI5->QI5_PEND == "S" .Or. QI5->QI5_STATUS < "4"
					Help(" ",1,"QNCEXILCPD")	// Existe(m) Lancamento(s) Pendente(s) de Etapas das Acoes Corretivas,
					lRet := .F.					// nao sera possivel a Baixa. 
				Endif
			QI5->(dbSkip())
			Enddo
		Endif
	Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FQNCDQIB  ³ Autor ³ Aldo Marini Junior    ³ Data ³ 01/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para buscar a descricao do Cad.de Modelos         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FQNCDQIB(cCodMod)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Tipo de Modelo                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FQNCDQIB(cCodMod)
Local cDescr   := Space(1)
Local lTMKPMS  := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³

	If QIB->(dbSeek(xFilial("QIB")+cCodMod))
	cDescr := QIB->QIB_DESC
	Endif

	If lTMKPMS
		If Empty(cDescr)
		DbselectArea("QUO")        	
		QUO->(dbSetOrder(1))   
			If QUO->(dbSeek(xFilial("QUO")+cCodMod))
			cDescr:= QUO->QUO_DESCGP
			Endif
		Endif
	Endif
	
Return cDescr

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Qnc030VldACO³ Autor ³ Aldo Marini Junior  ³ Data ³ 18/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para validacao da Ficha de Nao-Conformidades      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Qnc030VldACO(aGets,aTela,aQI9,aQI5)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array de controle dos Gets                         ³±±
±±³          ³ ExpA2 = Array de controle dos campos da tela               ³±±
±±³          ³ ExpA3 = Array onde contem as FNC relacionadas              ³±±
±±³          ³ ExpA4 = Array onde contem as Etapas/Passos do Plano        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/                 

Function Qnc030VldACO(aGets,aTela,aQI9,aQI5,nOpc,aQI6,nPosStaQI5)
Local lRet       := .F.
Local nRegObs    := QI3->(Recno())
Local nOrdObs    := QI3->(IndexOrd())
Local nQI5       := 0
Local nPos1      := 0
Local nPos2      := 0
Local nPos3      := 0
Local aHeader    := {}
Local cFil 	     := "QI5_FILIAL"
Local cCod 	     := "QI5_CODIGO"
Local cRv        := "QI5_REV"          
Local lACoB	     := GetMV("MV_QNCACOB") == "1"	 // 1=Sim, 2=Nao
Local aStruQI5   := FWFormStruct(3, "QI5")[3]
Local nX         := 0
Local cEncAutPla := AllTrim(SuperGetMv("MV_QNEAPLA",.f.,"1")) // Encerramento Automatico de Plano
Local lVcausa    := SuperGetMv("MV_VCAUSA",.F.,.F.)

	IF ExistBlock( "QNCVLACO" )
		lRet := ExecBlock( "QNCVLACO", .f., .f. ,{ aQI9,aQI5,aQI6,aGets,aTela,nOpc })
	Else
		If nOpc <> 2 .And. nOpc <> 5
			lRet := Obrigatorio(aGets,aTela)
		Else
			lRet := .T.
		Endif
	Endif

	If lRet .And. ! Empty(M->QI3_ENCREA) .And. M->QI3_STATUS < "3"
		MsgAlert(STR0073) //"O Plano de Acao nao podera ser encerrado em status [Registrado/Em Analise]"
		lRet := .F.
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida se filial/usuario do responsavel estao validos               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(M->QI3_FILMAT) .And. !Empty(M->QI3_MAT)
		If !QA_CHKMAT(M->QI3_FILMAT,M->QI3_MAT)
			lRet := .F.
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida se esta sendo Incluida/Alterada uma revisao com numeracao    ³
	//³ inferior a revisao atual.                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("QI3")
	dbSetOrder(1)
	If lRet .And. dbSeek(M->QI3_FILIAL+M->QI3_CODIGO)
		While !Eof() .And. M->QI3_FILIAL+M->QI3_CODIGO == QI3->QI3_FILIAL+QI3->QI3_CODIGO
			If QI3->QI3_REV >= M->QI3_REV
				MsgAlert(OemToAnsi(STR0055)+Chr(13)+;	// "Nao sera possivel a Inclusao/Alteracao de Plano de Acao com "
						OemToAnsi(STR0056))				// "numeracao inferior ao ultimo cadastrado."
				lRet := .F.
				Exit
			Endif
			dbSkip()
		Enddo
	Endif

	dbSetOrder(nOrdObs)
	dbGoTo(nRegObs)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se os Usuarios das Etapas/Passos sao validos               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aQI5) > 0 .And. lRet
		aHeader := {}

		dbSelectArea("QAA")
		dbSetOrder(1)

		If lRevisao
			If Len(aHdQI5) > 0
				aHeader := aClone(aHdQI5)
			Else
				For nX := 1 To Len(aStruQI5)
					If cNivel >= GetSx3Cache(aStruQI5[nX,1], "X3_NIVEL") .and. !ASCAN({"QI5_CODIGO","QI5_REV","QI5_DESCCO", "QI5_DESCOB", "QI5_PEND", "QI5_PLAGR", "QI5_AGREG", "QI5_REJEIT", "QI5_CJCOD", "QI5_ETPRLA"},{|x| x == Trim(aStruQI5[nX,1])}) > 0
						AADD(aHeader, Q030GetSX3(aStruQI5[nX,1], "", "") )
					EndIf
				Next nX
			Endif
		Else
			For nX := 1 To Len(aStruQI5)
				If cNivel >= GetSx3Cache(aStruQI5[nX,1], "X3_NIVEL") .and. !ASCAN({"QI5_CODIGO","QI5_REV","QI5_DESCCO", "QI5_DESCOB", "QI5_PEND", "QI5_PLAGR", "QI5_AGREG", "QI5_REJEIT", "QI5_CJCOD", "QI5_ETPRLA"},{|x| x == Trim(aStruQI5[nX,1])}) > 0
					AADD(aHeader, Q030GetSX3(aStruQI5[nX,1], "", "") )
				EndIf
			Next nX
		Endif

		nPos1 := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI5_FILMAT"})
		nPos2 := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI5_MAT"   })
		nPos3 := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI5_STATUS"})

		IF nPosStaQI5 <> 0
			nPos3 := nPosStaQI5
		ENDIF

		For nQI5 := 1 To Len(aQI5)
			If aQI5[nQI5,nPos3] <> "4"
				If QAA->(dbSeek(aQI5[nQI5,nPos1]+aQI5[nQI5,nPos2])) .And. ! QA_SitFolh()
					Help( " ", 1, "A090DEMITI" )
					lRet := .F.
				Endif
			Endif
			If nOpc <> 2 .And. nOpc <> 5
				IF !aQI5[nQI5,nPos3] $ "0|1|2|3|4|5"
					nPos3 := 12
				ENDIF

				If lRet .AND. !Empty(M->QI3_ENCREA) .AND. aQI5[nQI5,nPos3] < "4"
						Help(" ",1,"QNCEXILCPD")	// Existe(m) Lancamento(s) Pendente(s) de Etapas das Acoes Corretivas,
						lRet := .F.					// nao sera possivel a Baixa. 
					Exit
				Endif
			Endif
		Next
	Else
		If lACoB .AND. lRet
			Help(" ", 1, "QN030NEETA") // "Nao e possivel finalizar o plano sem cadastrar as Acoes/Etapas, Conforme Parametro MV_QNCACOB"
			lRet:= .F.	
		EndIf
	Endif

	IF lRet .AND. cEncAutPla == "2" .AND. lVcausa .AND. LEN(aQI6) == 0 .AND. !Empty(M->QI3_ENCREA)
		msgAlert("Para Baixa total é necessario ao menos uma causa cadastrada no plano de ação")
		lRet := .F.
	ENDIF

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Qnc030FNCAUT³ Autor ³ Aldo Marini Junior  ³ Data ³ 07/02/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para incluir da FNC Relacionada qdo for automatica³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Qnc030FNCAUT()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCA030FNCAUT()

Local nPosFNC := 0
Local nPosFNCR:= 0
Local lRet := .F.

nPosFNC := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI9_FNC"   })
nPosFNCR:= Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI9_REVFNC"})

	If nPosFNC > 0 .And. nPosFNCR > 0
		If aScan(aCols,{|X| X[nPosFNC] + X[nPosFNCR] == M->QI2_FNC + M->QI2_REV }) == 0
		lRet := .T.
		Endif
	Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC030CARR³ Autor ³ Aldo Marini Junior    ³ Data ³ 20/01/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para Atualizacao dos arrays dos sub-cadastros	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC030CARR(aQI4,aQI5,aQI6,aQI7,aQI8,aQI9,lRevisao)         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array do arquivo QI4                               ³±±
±±³          ³ ExpA2 = Array do arquivo QI5                               ³±±
±±³          ³ ExpA3 = Array do arquivo QI6                               ³±±
±±³          ³ ExpA4 = Array do arquivo QI7                               ³±±
±±³          ³ ExpA5 = Array do arquivo QI8                               ³±±
±±³          ³ ExpA6 = Array do arquivo QI9                               ³±±
±±³          ³ ExpL1 = Logico definindo se eh Geracao de Revisao          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNC030CARR                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC030CARR(nOpc,aQI4,aQI5,aQI6,aQI7,aQI8,aQI9,lRevisao)
Local aCad  	 := {"QI4","QI5","QI6","QI7","QI8","QI9"}
Local nT 		 := 0
Local nCnt		 := 0
Local cFil 	 	 := ""
Local cCod 	 	 := ""
Local cRv    	 := ""
Local lAddFNC    := .F.
Local cSeek      := ""
Local bWhile     := ""
Local nPosG 	 := 0
Local nPosI 	 := 0
Local nPosJ 	 := 0
Local nx		 := 1
Default lRevisao := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seta ordem 2(dois) para Busca de Acao Corretiva no QI9-ACao X FNC  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QI9->(dbSetOrder(1))

	For nT := 1 to Len(aCad)

		cFil := aCad[nT]+"_FILIAL"
		cCod := aCad[nT]+"_CODIGO"
		cRv  := aCad[nT]+"_REV"

		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ VerIfica se existe algum dado no arquivo                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea( aCad[nT] )
		dbSetOrder(1)
		IF DbSeek( M->QI3_FILIAL + M->QI3_CODIGO + M->QI3_REV )
			nCnt := 0
			While !EOF() .And. &(cFil+"+"+cCod+"+"+cRv) == M->QI3_FILIAL + M->QI3_CODIGO + M->QI3_REV
				nCnt++
				DbSkip()
			EndDo
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Adiciona a FNC relacionada caso seja inclusao automatica     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lFNC .And. aCad[nT] == "QI9" .And. nCnt > 0
				If QNCA030FNCAUT()
					lAddFNC := .T. 
					nCnt++
				Endif
			Endif
		
			aHeader := {}
			aCols   := {}      
			
			dbSelectArea(aCad[nT])
			dbSetOrder(1)
			If dbSeek(M->QI3_FILIAL + M->QI3_CODIGO + M->QI3_REV)
		
				If !lRevisao
					cSeek  := &(cFil+"+"+cCod+"+"+cRv)
					cWhile :=  (cFil+"+"+cCod+"+"+cRv)
					FillGetDados(nOpc,aCad[nT],1     ,cSeek ,{|| &cWhile},         ,{aCad[nT]+"_CODIGO",aCad[nT]+"_REV", "QI5_DESCCO", "QI5_DESCOB", "QI5_PEND", "QI5_PLAGR", "QI5_AGREG", "QI5_REJEIT", "QI5_CJCOD", "QI5_ETPRLA", "QI6_DESCR", "QI9_PLAGR", "QI6_SEQ", "QI8_SEQ", "QI9_PLAGRE"},          ,        ,      ,        ,       ,          ,        ,          ,           ,            ,)

					If aCad[nT] == "QI6" .and. nOpc <> 3 //Carrega descricao em caso de alteracao , visualizacao e exclusao
						nPosG := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI6_NCAUSA" }) 
						nPosI := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI6_TIPO" })
						nPosJ := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI6_CAUSA" })				
						For nx := 1 To Len(aCols)
							aCols[nx,nPosG]	:= Posicione("QI0",1,xFilial("QI0")+"1"+aCols[nx][nPosJ],"QI0_DESC")		  	
						Next nx
					Endif
				Else

					cFil := M->QI3_FILIAL
					cCod := M->QI3_CODIGO
					cRv  := M->QI3_REV

					cSeek  := xFilial("QI3") + M->QI3_CODIGO + M->QI3_REV
					cWhile := Alltrim(aCad[nT])+"_FILIAL+" + Alltrim(aCad[nT])+"_CODIGO+" +Alltrim(aCad[nT])+"_REV"
		
					If aCad[nT] $ "QI4|QI6|QI7|QI8|QI9"
						FillGetDados(6,aCad[nT],1     ,cSeek ,{|| &cWhile},         ,{aCad[nT]+"_CODIGO",aCad[nT]+"_REV",aCad[nT]+"_SEQ", "QI6_DESCR", "QI9_PLAGR"},          ,        ,        ,        ,    ,          ,        ,          ,           ,            ,)						  
						//Quando da revisao carrega os campos Virtuais...
						If aCad[nT] == "QI6"
							nPosG := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI6_NCAUSA" }) 
							nPosI := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI6_TIPO" })
							nPosJ := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI6_CAUSA" })				
							For nx := 1 To Len(aCols)
								aCols[nx,nPosG]	:= Posicione("QI0",1,xFilial("QI0")+aCols[nx][nPosI]+aCols[nx][nPosJ],"QI0_DESC")		  	
							Next nx
						Endif
					ElseIf aCad[nT] == "QI5"
						FillGetDados(6,aCad[nT],1     ,cSeek ,{|| &cWhile},         ,{"QI5_CODIGO","QI5_REV","QI5_DESCCO", "QI5_DESCOB", "QI5_PEND", "QI5_PLAGR", "QI5_AGREG", "QI5_REJEIT", "QI5_CJCOD", "QI5_ETPRLA"},          ,        ,        ,        , .f.   ,          ,        ,          ,           ,            ,)		  
						nPosG 	 := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI5_PRAZO" })
						nPosI 	 := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI5_STATUS"})
						nPosJ 	 := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI5_REALIZ"})
				
						For nx := 1 To Len(aCols)
							aCols[nx,nPosG] := CTOD("")				   
							aCols[nx,nPosJ] := CTOD("")				  
							aCols[nx,nPosI] := "0"
						Next nx
					Endif
				EndIf
			Endif

			If     nT == 1 ; aQI4 := aClone(aCols)
			Elseif nT == 2 ; (aQI5 := aClone(aCols),aHdQI5 := aClone(aHeader))
			Elseif nT == 3 ; aQI6 := aClone(aCols)
			Elseif nT == 4 ; aQI7 := aClone(aCols)
			Elseif nT == 5 ; (aQI8 := aClone(aCols),aHdQI8 := aClone(aHeader))
			Elseif nT == 6 ; aQI9 := aClone(aCols)
			Endif
		Endif
	Next nT

	//Guarda a posição do campo Status Acao para validação na função Qnc030VldACO
	If Type('aHdQI5') == "A" //Existem etapas vinculadas ao plano de ação
		nPosStaQI5 := ASCAN(aHdQI5, { |X| UPPER(ALLTRIM(X[2])) == "QI5_STATUS" })
	EndIf
Return Nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC030Legen³ Autor ³ Aldo Marini Junior   ³ Data ³ 20.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC030Legen
                     
BrwLegenda(cCadastro,STR0043,aQLegenda) 	// "Legenda"

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNCA030IMP ³ Autor ³ Aldo Marini Junior   ³ Data ³ 20.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o Plano de Acao em formato Grafico/Formulario      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNCA030IMP()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime o Plano de Acao no formato MsPrint                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("QNCR061")
	ExecBlock( "QNCR061",.f.,.f.,{QI3->(Recno())})
	Else
	QNCR060(QI3->(Recno()))
	Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC030Rev ³ Autor ³ Aldo Marini Junior    ³ Data ³ 03/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para geracao de Revisao do Plano de Acao          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC030Rev(ExpC1,ExpN1,ExpN2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao do Cadastro                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC030Rev(cAlias,nReg,nOpcAcao)
Local nRegObs   := QI3->(Recno())
Local nOrdObs   := QI3->(IndexOrd())
Local aUsrMat   := QNCUSUARIO()
Local cChaveQI3 := QI3->QI3_FILIAL+QI3->QI3_CODIGO

Private lApelido := aUsrMat[1]
Private cMatFil  := aUsrMat[2]
Private cMatCod  := aUsrMat[3]                                                           
Private cMatDep  := aUsrMat[4]

DbSelectArea("QAA")
DbSetOrder(1)
DbSelectArea ("QAD")
DbSetOrder(1)
	If QAA->(DbSeek(xFilial("QAA")+QI3->QI3_MAT)).And. QAA->QAA_STATUS == "2"
		IF QAD->(DbSeek(xFilial("QAD")+QAA->QAA_CC)) .And. !Empty(QAD->QAD_MAT) .And. QAD->QAD_MAT <> cMatCod
		MsgAlert(OemToAnsi(STR0099)) //"O usuário responsável pelo plano está inativo, somente o responsável pelo Departamento poderá efetuar a revisão."       
		Else
			If dbSeek(cChaveQI3+QI3->QI3_REV)
    		dbSkip()
				If QI3->QI3_FILIAL+QI3->QI3_CODIGO == cChaveQI3
				MsgAlert(OemToAnsi(STR0050)) // "Ja existe uma Revisao em andamento ou superior."
				dbSetOrder(nOrdObs)
				dbGoTo(nRegObs)
				Return Nil
				Endif
			Endif

		dbSetOrder(nOrdObs)
		dbGoTo(nRegObs)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Permite apenas a Geracao de Revisao se o Plano de Acao estiver BAIXADO e ³
		//³ se o numero da revisao for menor que "99"(limite de revisoes)            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(QI3->QI3_ENCREA)
				If Val(QI3->QI3_REV) < 99
					If QNC030Alt(cAlias,nReg,8) == 1    //  Terceiro parametro "8" = Gera Revisao
						dbSelectArea("QI3")
						dbGoTo(nRegObs)
						RecLock("QI3",.F.)
						QI3->QI3_OBSOL := "S"
						MsUnLock()
						FKCOMMIT()
						dbSkip()
					Endif
				Endif
			Else
			MsgAlert(OemToAnsi(STR0054)) // "Nao sera permitida a Geracao de Revisao para Lancamentos pendentes."
			Endif
		Endif
	ElseIf cMatFil+cMatCod <> QI3->QI3_FILMAT+QI3->QI3_MAT
	MsgAlert(OemToAnsi(STR0049)) // "Usuario nao autorizado a gerar Revisao."
	Else
	QI3->(dbSetOrder(2))
		If QI3->(dbSeek(cChaveQI3+QI3->QI3_REV))
    	QI3->(dbSkip())
			If QI3->QI3_FILIAL+QI3->QI3_CODIGO == cChaveQI3
			MsgAlert(OemToAnsi(STR0050)) // "Ja existe uma Revisao em andamento ou superior."
			dbSetOrder(nOrdObs)
			dbGoTo(nRegObs)
			Return Nil
			Endif
		Endif

	QI3->(dbSetOrder(nOrdObs))
	QI3->(dbGoTo(nRegObs))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Permite apenas a Geracao de Revisao se o Plano de Acao estiver BAIXADO e ³
	//³ se o numero da revisao for menor que "99"(limite de revisoes)            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(QI3->QI3_ENCREA)
			If Val(QI3->QI3_REV) < 99
				If QNC030Alt(cAlias,nReg,8) == 1    //  Terceiro parametro "8" = Gera Revisao
					dbSelectArea("QI3")
					dbGoTo(nRegObs)
					RecLock("QI3",.F.)
					QI3->QI3_OBSOL := "S"
					MsUnLock()
					FKCOMMIT()
					dbSkip()
				Endif
			Endif
		Else
		MsgAlert(OemToAnsi(STR0054)) // "Nao sera permitida a Geracao de Revisao para Lancamentos pendentes."
		Endif
	Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC030VFNC ³ Autor ³ Aldo Marini Junior   ³ Data ³ 03/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para Visualizar Ficha Ocorrencia/Nao-conformidade ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNC030VFNC()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QNC030VFNC()
Local cAliasOld := Alias()
Local nIndexOrd := IndexOrd()
Local nPos1     := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI9_FNC"  	})
Local nPos2     := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI9_REVFNC"})
Local aMv_QI2	:= {}, nMv_QI2 := 0
Local aColsPL	:= aClone(aCols) 
Local aStruQI2 := FWFormStruct(3, "QI2",, .F.)[3]
Local nX

Private aRotina := { {"","",0,0}, {STR0002,"QNC040Alt",0,2}, {"","",0,0}, {"","",0,0}, {"","",0,0}, {"","",0,0} } //"Visualizar"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao de Visualizacao da Ocorrencia/Nao-conformidade do Progr. QNCA040           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aCols[n,nPos1]+aCols[n,nPos2])
	QI2->(dbSetOrder(2))
		If QI2->(dbSeek(M->QI3_FILIAL+aCols[n,nPos1]+aCols[n,nPos2]))
			For nX := 1 To Len(aStruQI2)
				If Type("M->" + AllTrim(aStruQI2[nX,1])) <> "U"
				Aadd(aMv_QI2, { "M->" + AllTrim(aStruQI2[nX,1]),;
								&("M->" + AllTrim(aStruQI2[nX,1])) })
				Endif
			Next nX
		QNC040Alt("QI2",QI2->(Recno()),9)
		
			For nMv_QI2 := 1 To Len(aMv_QI2)
			&(aMv_QI2[nMv_QI2, 1]) := aMv_QI2[nMv_QI2, 2]
			Next
		Endif
	QI2->(dbSetOrder(1))	
	Endif

dbSelectArea(cAliasOld)
dbSetOrder(nIndexOrd)
aCols:=aClone(aColsPL)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QN030VdAlt ³ Autor ³ Eduardo de Souza     ³ Data ³ 03/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida se Usuario pode alterar o Plano/Etapas.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QN030VdAlt()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QN030VdAlt(cPlaFil,cPlaCod,cPlaRev)

Local lRet:= .F.

	If QI5->(DbSeek(cPlaFil+cPlaCod+cPlaRev))
		While QI5->(!Eof()) .And. QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV == cPlaFil+cPlaCod+cPlaRev
			If cMatFil+cMatCod == QI5->QI5_FILMAT+QI5->QI5_MAT
			lRet:= .T.
			Exit
			EndIf
		QI5->(DbSkip())
		EndDo
	EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QN030AEtap ³ Autor ³ Eduardo de Souza     ³ Data ³ 03/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida se Usuario pode alterar o Plano/Etapas.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QN030AEtap()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QN030AEtap()

Local nPosFil:= Ascan( aHeader, { |X| Upper( Alltrim( X[2] ) ) = "QI5_FILMAT" } )
Local nPosMat:= Ascan( aHeader, { |X| Upper( Alltrim( X[2] ) ) = "QI5_MAT"    } )
Local lRet   := .F.

	If nPosFil > 0 .AND. nPosMat > 0
		If cMatFil+cMatCod == aCols[n,nPosFil]+aCols[n,nPosMat] .Or. lAutorizado
		lRet:= .T.
		EndIf
	Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QN030INIMEM³ Autor ³ Eduardo de Souza     ³ Data ³ 02/10/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a Inicializacao padrao dos campos memo.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QN030INIMEM(cExpC1)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Campo que recebera a inicializacao                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QN030INIMEM(cCampo)
Local Ni 

	If Type("lDlgEtapa") = "U"
	lDlgEtapa := .F.
	Endif

	If INCLUI
	cRet:= " "
	Else
		If lDlgEtapa
			If Type("n") = "U"
			Ni:= 1
			Else
			Ni:= n	
			Endif

			If nEtapas < Ni
			cRet:= " "
			Else
			cRet:= MSMM(cCampo,80)	
			EndIf
		Else
		cRet:= MSMM(cCampo,80)
		EndIf
	EndIf

Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QN030TitDc ³ Autor ³ Eduardo de Souza     ³ Data ³ 21/10/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gatilho para preencher o titulo do documento.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QN030TitDc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QN030TitDc()

Local cTitulo:= ""

	If QDH->(DbSeek(xFilial("QDH")+SubStr(QI7->QI7_DOC,1,16)+QI7->QI7_RV))
	cTitulo:= QDH->QDH_TITULO
	Endif

Return cTitulo

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QN030BxFNC ³ Autor ³ Eduardo de Souza     ³ Data ³ 30/10/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Baixa as Fichas de Nao-Conformidades referentes ao Plano.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QN030BxFNC()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QN030BxFNC()

Local nOrdQI2:= QI2->(IndexOrd())
Local nPosQI2:= QI2->(RecNo())
Local cMensag:= ""
Local cMsg   := ""
Local lQNCBXFNC := ExistBlock( "QNCBXFNC" )

QI2->(DbSetOrder(5))
	If QI2->(DbSeek(M->QI3_FILIAL+M->QI3_CODIGO+M->QI3_REV))
		While QI2->(!Eof()) .And. QI2->QI2_FILIAL+QI2->QI2_CODACA+QI2->QI2_REVACA == M->QI3_FILIAL+M->QI3_CODIGO+M->QI3_REV
	
			If Empty(QI2->QI2_CONREA)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Baixa Ficha de Ocorrencia/Nao-conformidades caso Plano de Acao estaja baixado ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("QI2",.F.)
				If !Empty(M->QI3_ENCREA)
				QI2->QI2_CONREA := M->QI3_ENCREA
				Else
				QI2->QI2_CONREA := dDatabase
				EndIf
				If Empty(QI2->QI2_CONPRE)
				QI2->QI2_CONPRE := dDataBase
				Endif
				If QI2->QI2_STATUS < "3"
				QI2->QI2_STATUS := "3"		// 3-Procede
				Endif
			MsUnlock()
			FKCOMMIT()
					
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Encerra atendimento no TMK³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IF QI2->QI2_ORIGEM == "TMK"
      			QNCbxTMK(QI2->QI2_FNC,QI2->QI2_REV) //SE ESTA  BAIXADA BAIXO O ATENDIMENTO
				EndIf
      					
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se ultima Etapa foi realizada para avisar Resp. Acao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cMatFil+cMatCod <> QI2->QI2_FILRES+QI2->QI2_MATRES
					If QAA->(dbSeek(QI2->QI2_FILRES + QI2->QI2_MATRES )) .And. QAA->QAA_RECMAI == "1"
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Envio de e-Mail para o responsavel das FNC relacionadas                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !Empty(QAA->QAA_EMAIL)

							If Ascan(aUsuarios,{ |x| x[1] == QAA->QAA_LOGIN }) == 0

							cMail := AllTrim(QAA->QAA_EMAIL)
							cTpMail:= QAA->QAA_TPMAIL
							
							// ETAPAS DO PLANO DE ACAO
								If cTpMail == "1"
								cMensag := OemToAnsi(STR0063)+DtoC(QI3->QI3_ENCREA)+CHR(13)+CHR(10)	// "Este Plano de Acao foi baixado no dia "
								cMensag += OemToAnsi(STR0064) // "Favor verificar a Baixa da Ficha de Ocorrencia/Nao-conformidade."
								cMsg := QNCSENDMAIL(2,cMensag,.T.)
								Else
								cMsg := OemToAnsi(STR0063)+DtoC(QI3->QI3_ENCREA)+CHR(13)+CHR(10)	 // "Este Plano de Acao foi baixado no dia "
								cMsg += CHR(13)+CHR(10)
								cMsg += OemToAnsi(STR0065)+Space(1)+TransForm(QI2->QI2_FNC,PesqPict("QI2","QI2_FNC"))+"-"+QI2->QI2_REV+Space(1)+OemToAnsi(STR0066)+CHR(13)+CHR(10)	// "A Ficha de Ocorrencia/Nao-conformidade " ### "esta relacionada."
								cMsg += Replicate("-",80)+CHR(13)+CHR(10)
								cMsg += OemToAnsi(STR0067)+CHR(13)+CHR(10)	// "Descricao Detalhada da Ocorrencia/Nao-conformidade:"
								cMsg += CHR(13)+CHR(10)
								cMsg += MSMM(QI2->QI2_DDETA,80)+CHR(13)+CHR(10)
								cMsg += Replicate("-",80)+CHR(13)+CHR(10)
								cMsg += CHR(13)+CHR(10)
								cMsg += OemToAnsi(STR0064)+CHR(13)+CHR(10) // "Favor verificar a Baixa da Ficha de Ocorrencia/Nao-conformidade."
								cMsg += CHR(13)+CHR(10)
								cMsg += CHR(13)+CHR(10)
								cMsg += OemToAnsi(STR0052)+CHR(13)+CHR(10)	// "Atenciosamente "
								cMsg += QA_NUSR(QI3->QI3_FILMAT,QI3->QI3_MAT,.F.)+CHR(13)+CHR(10)
								cMsg += QA_NDEPT(QAA->QAA_CC,.T.,QAA->QAA_FILIAL)+CHR(13)+CHR(10)
								cMsg += CHR(13)+CHR(10)
								cMsg += OemToAnsi(STR0059) + CRLF	// "Mensagem gerada automaticamente pelo Sistema SIGAQNC - Controle de Nao-conformidades"
								Endif
							
							cAttach := ""
							aMsg:={{OemToAnsi(STR0036)+" "+TransForm(QI3->QI3_CODIGO,PesqPict("QI3","QI3_CODIGO"))+"-"+QI3->QI3_REV+Space(10)+DTOC(Date())+"-"+SubStr(TIME(),1,5), cMsg, cAttach } }	// "Plano de Acao No. "
							
							// Geracao de Mensagem para o Responsavel da Ficha de Ocorrencias/Nao-conformidades
								IF lQNCBXFNC
								aMsg := ExecBlock( "QNCBXFNC", .f., .f. )
								Endif
						
							aAdd(aUsuarios,{QAA->QAA_LOGIN, cMail,aMsg} )
							Endif
						Endif
					Endif
				Endif
			Endif
		QI2->(DbSkip())
		Enddo
	Endif

QI2->(DbSetOrder(nOrdQI2))
QI2->(DbGoto(nPosQI2))

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QN030INICpo³ Autor ³ Wagner Mobile Costa  ³ Data ³ 24/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a Inicializacao padrao dos campos.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QN030INICpo(cExpC1)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Campo que recebera a inicializacao                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QN030INICpo(cCampo, uConteudo)

Local uRet

	If Type("lDlgEtapa") != "L"
	Private lDlgEtapa := .F.
	Endif

	If INCLUI
	uRet:= CriaVar(cCampo, .F.)
	Else
		If lDlgEtapa
			If nEtapas < n
			uRet:= CriaVar(cCampo, .F.)
			Else
			uRet:= uConteudo
			EndIf
		Else
		uRet:= uConteudo
		EndIf
	EndIf

Return uRet
            

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Qnc030VldMTG³ Autor ³ Telso Carneiro      ³ Data ³20/05/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para validacao dos Gets do aButtons               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Qnc030VldMTG(aGets,aTela,aQI9,aQI5)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array de controle dos Gets                         ³±±
±±³          ³ ExpA2 = Array de controle dos campos da tela               ³±±
±±³          ³ ExpA3 = Opcao de escolha                                   ³±±
±±³          ³ ExpA4 = Array onde contem os Dados (acols)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/                 


Static Function Qnc030VldMTG(aGets,aTela,nOpcGet,aCols,cAliasB)
Local lRet 	     := .F.
Local nI	     := 0
Local nPosI      := Ascan(aHeader,{ |X| UPPER(ALLTRIM(X[2])) == "QI5_STATUS"})
Local lVcausa    := SuperGetMv("MV_VCAUSA",.F.,.F.)
Local cEncAutPla := AllTrim(SuperGetMv("MV_QNEAPLA",.f.,"1")) // Encerramento Automatico de Plano

	IF ExistBlock( "QNCVLMTG" )
		lRet := ExecBlock( "QNCVLMTG", .f., .f. ,{ cAliasB,Aclone(aCols),aGets,aTela,nOpcGet })
	Else
		If nOpcGet <> 2 .And. nOpcGet <> 5
			lRet := Obrigatorio(aGets,aTela) 
			IF lRet
				For nI:=1 To Len(aCols)
		        	n:=nI
		   			lRet := QNC030LiOk(,cAliasB)
					IF !lRet
		   				Return(.F.)
					Endif
				Next
				//Somente Obriga o vinculo de uma causa se todas as "Acoes/Etapas" estiverem com "Status Acao" em 100% e o parametro "MV_VCAUSA" estiver .T.
				IF cAliasB == "QI5"
					lRet := .F.
					For nI:=1 To Len(aCols)
						IF aCols[nI,nPosI] <> "4"
							lRet := .T.
							EXIT
						ENDIF
					Next
					IF !lRet .AND. lVcausa .AND. Len(aQI6) == 0 .AND. cEncAutPla <> '2'
						msgAlert("Para Baixa total é necessario ao menos uma causa cadastrada no plano de ação")
						Return(.F.)
					ELSE
						lRet := .T.
					ENDIF
				ENDIF
			Endif
		Else
			lRet := .T.
		Endif
	Endif

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNC030VLDPLN³ Autor ³ Cicero Cruz         ³ Data ³21/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a Data de encerramento do Plano de Acao             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                 
Function QNC030VLDPLN
	Local lRet := .T.

	If !Empty(M->QI3_ENCREA) .AND. (M->QI3_ENCREA > dDataBase) // Caso a data de conclusao seja maior que a data base bloqueio
		MsgAlert(STR0084) // "Data de encerramento do Plano de Acao nao pode ser maior que a data base do sistema! "
		M->QI3_ENCREA := Ctod("  /  /  ")
		lRet := .F.
	EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Q030IniFNC  ³ Autor ³ Rafael S. Bernardi  ³ Data ³15/02/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inicializador padrao do campo QI9_DESRES                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/                 
Function Q030IniFNC(cFnc,cFncRev)
Local cRetorno := ""

	If FQNCCHKFNC(cFnc,cFncRev,.F.)
	cRetorno := QI2->QI2_DESCR
	Endif
Return cRetorno

                                                                 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QNCXDOCREV ³ Autor ³ Sergio S. Fuzinaka   ³ Data ³ 10.04.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Consiste se ha documento com revisao vigente na tabela QDH  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cParm => Documento para pesquisa                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QNCXDOCREV(cDoc)

	Local aArea		:= GetArea()
	Local aAreaQDH	:= QDH->(GetArea())
	Local lFound	:= .F.
	Local cDocto	:= PadR(Alltrim(cDoc),TamSx3("QDH_DOCTO")[1])	//Ajuste de tamanho conforme dicionario

	If !Empty(cDocto)
		dbSelectArea("QDH")
		dbSetOrder(6)
		If QDH->(dbSeek(xFilial("QDH")+cDocto))
			While QDH->(!Eof()) .And. xFilial("QDH")+cDocto == QDH->(QDH_FILIAL+QDH_DOCTO)
				If QDH->QDH_CANCEL <> "S" .AND. QDH->QDH_OBSOL <> "S" .AND. QDH->QDH_STATUS == "L  "
					lFound := .T.
					Exit
				Endif
				QDH->(dbSkip())
			Enddo
			If !lFound
				Help(" ",1,"QDNEXISREV")	//"Nao existe revisao vigente"
			Endif
		Else
			Help(" ",1,"QD120DNE") //"Documento nao encontrado"
		Endif
	Endif

	RestArea(aAreaQDH)
	RestArea(aArea)

Return(lFound)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QNCA030   ºAutor Iolanda Vilanova      º Data ³  01/16/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gravacao do campo QI6_NCAUSA                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P10                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Q030NCAU

	Local cDesc

	If Type("INCLUI") != "L"
		Private INCLUI := .F.
	EndIf

	IF !INCLUI
		cDesc:=POSICIONE("QI0",1,XFILIAL("QI0")+"1"+QI6->QI6_CAUSA,"QI0_DESC")
	Else
		cDesc:=""
	Endif

Return cDesc


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNCVALMOD   ³ Autor ³ Leandro Sabino      ³ Data ³20/01/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida se e permitido alterar o campo modelo               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                 
Function QNC030VLMOD(cPlano,cRev,cModelo)
	Local aAreaQI3 := QI3->(GetArea())
	Local lRet     := .T.

	DbSelectArea("QI5")
	QI5->(dbSetOrder(1))
	If QI5->(MsSeek(xFilial("QI5")+cPlano+cRev))
		While QI5->(!Eof()) .And. QI5->QI5_CODIGO+QI5->QI5_REV == cPlano+cRev
			If !Empty(QI5->QI5_PROJET) .And. !Empty(QI5->QI5_PRJEDT) .And. !Empty(QI5->QI5_TAREFA) //.AND. !Empty(QI5->QI5_REALIZ)
				lRet :=  .F.
				Exit
			End
			QI5->(dbSkip())
		Enddo
	Endif

	RestArea(aAreaQI3)

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QNCVALETP   ³ Autor ³ Leandro Sabino      ³ Data ³20/01/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida se e permitido alterar o campo modelo               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                 
Function QNC030VLETP(cCampo)
	Local nPosTarefa  := Ascan( aHeader, { |X| Upper( Alltrim( X[2] ) ) = "QI5_TAREFA" } )
	Local aAreaQI3    := QI3->(GetArea())
	Local cCoCpo      := cCampo
	Local lRet        := .T.
	Local nPosCam     := 0
	Local nPosCC      := ""
	Local lTMKPMS 	  := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³

///pegar parametro e colocar os valids. Fazer teste com e sem integracao
	If lTMKPMS
		If (GetMv("MV_QTMKPMS",.F.,1) == 3)  .Or. (GetMv("MV_QTMKPMS",.F.,1) == 4)
			nPosCC := At(">",cCampo)
			If nPosCC > 0
				cCampo := SubStr(cCampo,nPosCC+1,Len(cCampo))
			Endif

			nPosCam := Ascan( aHeader, { |X| Upper( Alltrim( X[2] ) ) = cCampo } )

			If Alltrim(cCoCpo) == Alltrim(readvar())
				If !Empty(aCols[n,nPosTarefa])
					lRet :=  .F.
					Aviso(STR0094,STR0096, {"ok"})//"Atencao"##"Devido a tarefa gerada no PMS, esse campo nao pode ser alterado."
					If nPosCam > 0
						aCols[n,nPosCam] := CriaVar(cCampo,.f.)
					Endif
				Endif
			Endif
		Endif
	Endif

	RestArea(aAreaQI3)

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QNC030Vld  ³ Autor ³Leandro Sabino        ³ Data ³ 21/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Retorna o numero da opcao correspondente a cor da situacao ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QNC030Vld(ExpN1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Situacao do Registro                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/                      
Function Q030VldLeg()
Local aAreaQI5 := GetArea()
Local nRet     := 0
Local lTarefa  := .F.

//A validação deve obedecer a sequencia abaixo:
//1	BR_PRETO   - QI3->QI3_OBSOL=="S"
//2 BR_AMARELO - Empty(QI3->QI3_ENCREA)
//3 BR_CINZA   - QI3->QI3_STATUS=="4"
//4 BR_MARRON  - QI3->QI3_STATUS=="5"
//5 ENABLE     - !Empty(QI3->QI3_ENCREA
//6 Laranja    - !Empty(QI5_TAREFA)
//7 Pink			- rejeitados

DbselectArea("QI5")
dbSetOrder(1)

	If QI5->(dbSeek(QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV))
		While QI5->(!Eof()) .And. QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV == QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV
			If !Empty(AllTrim(QI5->QI5_TAREFA))
			lTarefa := .T.
			Exit
			Endif
		QI5->(dbSkip())
		Enddo
	Endif

	If QI3->QI3_OBSOL=="S"
	nRet:= 1
	Endif
	If nRet <> 1
		If Empty(QI3->QI3_ENCREA)
			If !lTarefa
			nRet:= 6
			Else
			// Projeto TDI - TDSFL0 Identificacao de rejeitados
				if QNC030REJ(QI3->QI3_FILIAL, QI3->QI3_CODIGO, QI3->QI3_REV)
				nRet := 7 // rejeitada
				Else
				nRet:= 2				
				Endif
			Endif
		Endif
		If (nRet <> 2) .And. (nRet <> 6)
			If QI3->QI3_STATUS=="4"
			nRet:= 3
			Endif
			If nRet <> 3
				If QI3->QI3_STATUS=="5"
				nRet:= 4
				Endif
				If nRet <> 4
					If !Empty(QI3->QI3_ENCREA)
					nRet:= 5
					Endif
					If nRet <> 5
						If !lTarefa
						nRet:= 6				
						Endif
					Endif
				Endif
			Endif
		Endif
	Endif
	
RestArea(aAreaQI5)                         

Return nRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Q030GeraTarefa  ³ Autor ³Leandro Sabino   ³ Data ³ 28/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cria tarefa no PMS                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Q030GeraTarefa                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/                      
Function Q030GeraTarefa()
Local aHabilidades   := {}
Local aRequisitaResp := {}
Local aTrfDatas      := {}
Local aAreaQI5       := {}
Local cPMSTarefa     := ""
Local cQI52MAT       := ""
Local cHoraQI5       := ""
Local cRecurso       := ""
Local aRecPMS		 := {}
Local dQI5Prazo		 := If( DTOS(QI5->QI5_PRAZO) < DTOS(dDataBase), dDataBase, QI5->QI5_PRAZO )
Local cQI3DEPTO	     := ""  
LOCAL cRecPMS     	 := ""

DbSelectArea("QI5")
QI5->(dbSetOrder(1))
	If QI5->(MsSeek(xFilial("QI5")+QI3->QI3_CODIGO+QI3->QI3_REV+'01'))//Fixando a sequencia 01, garanto que por esse cadastro so gera tarefa para a primeira etapa
                  
		If !Empty(QI5->QI5_PROJET) .And. !Empty(QI5->QI5_PRJEDT)

			DbselectArea("QI9")
			QI9->(dbSetOrder(1))
			If QI9->(MsSeek(QI5->QI5_FILIAL+QI5->QI5_CODIGO+QI5->QI5_REV))

				DbselectArea("AF9")
				AF9->(dbSetOrder(6))
				If !AF9->(MsSeek(xFilial("AF9")+QI9->QI9_CODIGO+QI9->QI9_REV+QI5->QI5_TPACAO))
							
					If MsgYesNo(STR0092,STR0058)//"Deseja gerar tarefa no PMS agora?"##"Aviso"
						
						IncProc("Aguarde....Processando abertura de tarefa!")
									    						 
						cHRParcial	:= QNCPrzHR2(QI5->QI5_PRZHR	,"H","H","D","H")
						If cHRParcial <= 0
							cHRParcial := 1
						EndIf
						//Busca pelo recurso que está disponivel	
						aAreaQI5 := QI5->(GetArea())
						If QI5->QI5_TRFACT == "0"   //Alocação da Tarefa: 0=Não Gera, será baixada a pendencia atual no QNC e gerada a proxima no PMS
								Q50BXTMKPMS(xFilial("QI5"),QI5->QI5_CODIGO,QI5->QI5_REV,QI5->QI5_TPACAO,.F.)
								Return
						Endif
						If QI5->QI5_TRFACT$("23") /// Alocação Tarefa PMS: 0=Não Gera; 1=Força alocação QNC; 2=Semi-Auto ou 3=Automatica
							QNCCARHAB(QI5->QI5_TPACAO,QI5->QI5_FILIAL,QI5->QI5_CODIGO,@aHabilidades)
							aRequisitaResp := PMSRECDISP(aHabilidades,dQI5PRAZO,cHRParcial,QI5->QI5_PROJET, @aRecPMS)			                
						EndIf
						RestArea(aAreaQI5)
		                cQI52MAT	:= QNCRespDef(@cRecurso,QI3->QI3_MODELO,QI5->QI5_TPACAO,QI3->QI3_MAT,QI5->QI5_CODIGO,QI5->QI5_REV)///Obtem o código do responsável QNC correspondente ao Recurso PMS.

						If Empty(aRequisitaResp)
							If Empty(aTrfDatas)
		    			     	aTrfDatas := QNCPMSDtDf( dQI5PRAZO,cHRParcial,QI5->QI5_PROJET,cRecurso, aTrfDatas ) /// Assume Data Prazo da FNC Realizando superalocação de usuario.									   
							EndIf
						Else
							cRecurso  := aRequisitaResp[1] //Recurso PMS retornado pela PMSRECDisp().										
							RecLock("QI5",.F.)//Alterar o responsavel de acordo com a locacao do PMS
							If !Empty(cRecurso) .And. (cRecurso <> "STOP")
			                	QI5->QI5_MAT := cRecurso
							Endif
		                	QI5->QI5_PRAZO  := aRequisitaResp[4]//Data de Vecto estabelecido via PMS - AGUARDAR ALTERACAO DE FONTE DO PMS PARA RETORNAR A QUARTA POSICAO
							If Empty(aTrfDatas)
								aTrfDatas := {aRequisitaResp[2],aRequisitaResp[3],aRequisitaResp[4],aRequisitaResp[5]}											
							EndIf
			                MsUnLock()			
							FKCOMMIT()
						Endif

						IncProc("Aguarde...")
						
						If cQI52MAT <> "STOP"
							dbSelectArea("QAA")
							aAreaQAA		:= GetArea()
							dbSetOrder(1)
							If MsSeek(xFilial("QAA")+QI3->QI3_MAT,.F.)
								cQI3DEPTO	:= QAA->QAA_CC
							EndIf
							
							If QI5->QI5_TRFACT == "2" .and. Type("oMainWnd") == "O"	//Alocação Semi-Automatica ou Manual. (se tiver janela aberta)
								cHoraQI5 := QI5->QI5_PRZHR
								QAlocPMS(QI5->QI5_CODIGO,QI5->QI5_REV,QI5->QI5_TPACAO,@aRequisitaResp,@cHoraQI5,aHabilidades,@aRecPMS)
								If Len(aRequisitaResp) > 0
									aTrfDatas := {aRequisitaResp[2],aRequisitaResp[3],aRequisitaResp[4],aRequisitaResp[5]}
								EndIf
								IF !Empty(aRequisitaResp[1])
									cQI52MAT := QNCRespDef(aRequisitaResp[1],QI3->QI3_MODELO,QI5->QI5_TPACAO,cQI3DEPTO,QI5->QI5_CODIGO,QI5->QI5_REV)///Obtem o código do responsável QNC correspondente ao Recurso PMS.
									IF !Empty(cQI52MAT) .And. (cQI52MAT <> "STOP")
										RecLock("QI5",.F.)
										QI5->QI5_MAT := aRequisitaResp[1]
										If !Empty(cHoraQI5)
											QI5->QI5_PRZHR := cHoraQI5
										Endif
										QI5->(MsUnlock())                                         
									Endif
								Endif
							Else
								cQI52MAT := QNCRespDef(@cRecPMS,QI3->QI3_MODELO,QI5->QI5_TPACAO,cQI3DEPTO,QI5->QI5_CODIGO,QI5->QI5_REV)///Obtem o código do responsável QNC correspondente ao Recurso PMS.
								IF !Empty(cQI52MAT) .And. (cQI52MAT <> "STOP")
									RecLock("QI5",.F.)
									QI5->QI5_MAT := cQI52MAT
									QI5->(MsUnlock())
								Endif
							EndIf
		              
		            		IncProc("Aguarde....Processando abertura de tarefa!")
		            		
		            		cPMSTarefa := QNCGeraTarefa(QI9->QI9_FNC,QI5->QI5_FILIAL,QI5->QI5_CODIGO,QI5->QI5_REV,QI5->QI5_TPACAO,aTrfDatas,QI9->QI9_REVFNC)
				            
							If cPMSTarefa == "STOP"
								Return ()
							Endif
							
							If Empty(QI5->QI5_TAREFA) .and. !Empty(cPMSTarefa)
								RecLock("QI5",.F.)
								QI5->QI5_TAREFA	:= cPMSTarefa
								QI5->(MsUnlock())
							EndIf
						Endif
					Endif
				Endif
			Endif
		Endif
	Endif
Return  


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QN030Stat       ³ Autor ³Leandro Sabino   ³ Data ³ 28/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica o WHEN do campo QI3_STATUS                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QNC030Stat()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/


Function QNC030Stat()

Local cOrigem   := AllTrim(QI2->QI2_ORIGEM)
Local lTMKPMS 	:= If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)

	If nOpc == 4 .AND. lTMKPMS .AND. cOrigem =="TMK"
	lWhenSt := .F.
	EndIf

Return lWhenSt	 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QN030AdMem ³ Autor ³ Paulo Fco. Cruz Nt. ³ Data ³ 19/06/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funçao para gerenciar as chamadas ao PE QN030MEM           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QN030AdMem(aMemUser, nOpc)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aMemUser = Array de campos memo                            ³±±
±±³          ³ nOpc     = Número da opera‡ão a executar                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QNCA030                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QN030AdMem(aMemUser,nOpc,aArray,aHeader)

	Local aCampos	:= {}
	Local nI		:= 0
	Local nPosCpo	:= 0

	For nI := 1 to Len(aMemUser)
		If SubStr(aMemUser[nI,1],1,3) == "QI6"
			If (nPosCpo := Ascan(aHeader,{|x| Upper(Alltrim(x[2])) == aMemUser[nI,2]})) > 0
				AADD(aCampos,{nPosCpo,aMemUser[nI,1],aMemUser[nI,2]})
			Endif
		Endif
	Next

	For nI := 1 to Len(aCampos)
		If nOpc < 5
			If  (nOpc == 3 .And. !Empty(aArray[aCampos[nI,1]])) .Or. ;
					(nOpc == 4 .And. !Empty(QI6->&(aCampos[nI,2]))) .Or. ;
					(nOpc == 4 .And. !Empty(aArray[aCampos[nI,1]]) .And. Empty(QI6->&(aCampos[nI,2])))
				MSMM(QI6->&(aCampos[nI,2]),,,aArray[aCampos[nI,1]],1,,,"QI6",aCampos[nI,2])
			Endif
		EndIf
	Next

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QNC030TMK ³ Autor ³Adriano da Silva         ³ Data ³ 10/08/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Botão Para Visualizar Chamados do TMK					        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³QNC030TMK()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³QNCA030                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNC030TMK()

Local aArea 	:= GetArea()
Local nAuxMod   := nModulo

DbselectArea("QI9")		//Ação Corretiva x Não Conformidade
QI9->(DbSetOrder(1))	//QI9_FILIAL+QI9_CODIGO+QI9_REV+QI9_FNC+QI9_REVFNC	
	If QI9->(DbSeek(QI3->QI3_FILIAL+QI3->QI3_CODIGO+QI3->QI3_REV))

	DbselectArea("QI2")		//Não Conformidade
	QI2->(DbSetOrder(2))	//QI2_FILIAL+QI2_FNC+QI2_REV	
		If QI2->(DbSeek(xFilial("QI2")+QI9->QI9_FNC+QI9->QI9_REV))
        
		DbselectArea("ADE")		//Chamados de Help Desk
		ADE->(DbSetOrder(1))	//ADE_FILIAL+ADE_CODIGO	
			If ADE->(DbSeek(xFilial("ADE")+QI2->QI2_NCHAMA))
        	
       	    nModulo := 13
        	
        	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Função Padrão Para Manutenção do Chamado - Visualização	-TMKA503A			 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			TK503AOpc("ADE", ADE->(Recno()),2,,)
		
			EndIf

		EndIf
	
	EndIf

RestArea(aArea)

nModulo := nAuxMod

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Q030LegAXEºAutor  ³Andre Anjos		 º Data ³  23/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Monta a legenda dos itens da tela de Acoes X Etapas.       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QNCA030                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Q030LegAXE()
	Local aLegenda := {}

	aAdd(aLegenda,{'BR_VERDE',STR0103})					   //Etapa concluida
	aAdd(aLegenda,{'BR_AMARELO',STR0102})	               //Etapa em execução
	aAdd(aLegenda,{'BR_LARANJA',STR0111})                  //Etapa não iniciada
	If SuperGetMV("MV_QTMKPMS",.F.,1) > 2
		aAdd(aLegenda,{'BR_PRETO',STR0104})		           //Etapa rejeitada
		aAdd(aLegenda,{'BR_BRANCO',STR0105})	           //Etapa não gerada
	EndIf

	BrwLegenda(STR0015,STR0043,aLegenda) //Legenda
Return

/*                                                                               			
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±                          	
±±ºPrograma  ³QNC030VLEG   ºAutor  ³Leonardo Quintania Data ³  03/18/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Altera a legenda dos itens da tela de Acoes X Etapas       º±±
±±º          ³ quando é alterado                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QNCA030                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/      
Function QNC030VLEG()
	Local cStatus := &(ReadVar())
	nTAREFA := If(SuperGetMV("MV_QTMKPMS",.F.,1)>2,aScan(aHeader,{|x| AllTrim(x[2]) == "QI5_TAREFA"}),0)
	nSTATUS := aScan(aHeader,{|x| AllTrim(x[2]) == "QI5_STATUS"})
	Do Case
	Case AllTrim(cStatus) == '5' 			//-- Rejeitado
		aCols[N,1] := LoadBitmap(GetResources(),"BR_PRETO")
	Case AllTrim(cStatus) == '4' 			//-- Finalizado
		aCols[N,1] := LoadBitmap(GetResources(),"BR_VERDE")
	Case AllTrim(cStatus) $ '1*2*3' 		//-- Em execucao
		aCols[N,1] := LoadBitmap(GetResources(),"BR_AMARELO")
	Case nTAREFA > 0 .And. Empty(aCols[N,nTAREFA]) 	//-- Não Gerada
		aCols[N,1] := LoadBitmap(GetResources(),"BR_BRANCO")
	Otherwise  											//-- Nao iniciado
		aCols[N,1] := LoadBitmap(GetResources(),"BR_LARANJA")
	EndCase

Return .T.




/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±                          	
±±ºPrograma  ³QNC030REJ ºAutor  ³Aldo Barbosa dos Santos    ³  12/04/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Idenfifica se o chamado foi rejeitado                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QNCA030 - Projeto TDI - TDSFL0 Identificacao de rejeitados º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/      
Function QNC030REJ(cFil, cCodAca, cRev, cTpAcao)
Local lRejTarefa := .T.
Local lRejeit    := .F.
Local aArea	     := {AN8->( GetArea("AN8")), AFA->( GetArea("AFA")), QI9->( GetArea("QI9")), GetArea()}
Local nA
Local lTMKPMS 		 := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)//Integracao do QNC com TMK e PMS: 1-Sem integracao,2-TMKxQNC,3-QNCxPMS,4-TMKxQNCxPMS ³

AFA->( dbSetOrder(5))
	If AFA->(MsSeek(AF9->AF9_FILIAL+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA )) //xFilial("AFA")
	lRejeit  := .F.
	lRejNIni := .F.
	lPredRej := .F.
		If lRejTarefa
		AN8->(dbSetOrder(1)) //AN8_FILIAL+AN8_PROJET+AN8_REVISA+AN8_TAREFA+DTOS(AN8_DATA)+AN8_HORA+AN8_TRFORI
			If AN8->( MsSeek( xFilial("AN8")+AFA->(AFA_PROJET+AFA_REVISA+AFA_TAREFA) ) )
				Do While !AN8->(Eof()) .And. AN8->(AN8_FILIAL+AN8_PROJET+AN8_REVISA+AN8_TAREFA)==xFilial("AN8")+AFA->(AFA_PROJET+AFA_REVISA+AFA_TAREFA) .And. (AN8->AN8_STATUS=='2' .Or. AN8->AN8_STATUS=='3')
				AN8->(dbSkip())
				EndDo
			lRejeit  := !AN8->(Eof()) .And. AN8->(AN8_FILIAL+AN8_PROJET+AN8_REVISA+AN8_TAREFA)==xFilial("AN8")+AFA->(AFA_PROJET+AFA_REVISA+AFA_TAREFA)
			lRejNIni := lRejeit .And. Empty(AN8->AN8_STATUS)
			EndIf

		AN8->(dbSetOrder(2)) //AN8_FILIAL+AN8_PROJET+AN8_REVISA+AN8_TRFORI+DTOS(AN8_DATA)+AN8_HORA+AN8_TAREFA
			If AN8->( MsSeek( xFilial("AN8")+AFA->(AFA_PROJET+AFA_REVISA+AFA_TAREFA) ) )
				Do While !AN8->(Eof()) .And. AN8->(AN8_FILIAL+AN8_PROJET+AN8_REVISA+AN8_TAREFA)==xFilial("AN8")+AFA->(AFA_PROJET+AFA_REVISA+AFA_TAREFA) .And. (AN8->AN8_STATUS=='2' .Or. AN8->AN8_STATUS=='3')
				AN8->(dbSkip())
				EndDo
			lPredRej := !AN8->(Eof())  .And. AN8->(AN8_FILIAL+AN8_PROJET+AN8_REVISA+AN8_TAREFA)==xFilial("AN8")+AFA->(AFA_PROJET+AFA_REVISA+AFA_TAREFA)
			EndIf
		EndIf
	Endif
					   
// Projeto TDI - TDSLF0 - Identificacao de chamados rejeitados no Monitor de Tarefas
	if ! lRejeit .and. lTMKPMS
		If lRejTarefa .and. Val(cRev) > 0 // tem revisao

	    // como tem revisao a principio e rejeitado
	    lRejeit := .T. 
		
	    QI9->(dBSetOrder(1)) // QI9_FILIAL+QI9_CODIGO+QI9_REV+QI9_FNC+QI9_REVFNC
			if QI9->(DbSeek(cFil+cCodAca+cRev))
		    QI9->(dbSkip()) // localiza a proxima revisao 
				if QI9->QI9_FILIAL+QI9->QI9_CODIGO == xFilial("QI2")+cCodAca
			    lRejeit := .F. // localizou a proxima entao a atual e obsoleta
				Else
			    lRejeit := .T. // nao localizou a proxima entao a atual e rejeitada
				Endif
			Endif
		Endif
	Endif

	For nA := 1 to Len(aArea)
	RestArea(aArea[nA])
	Next

Return( lRejeit )

//-------------------------------------------------------------------
/*/{Protheus.doc} QNC030VlPJ() 
Validase tem integração e conteúdp inserido no campo
@author taniel.silva
@since 09/10/2014
@version P12
/*/
//-------------------------------------------------------------------
Function QNC030VlPJ()
Local cCampo  := AllTrim(ReadVar()) 
Local lTMKPMS := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)
Local lRet    := .T.

	If lTMKPMS
		If cCampo = 'M->QI5_PROJET'
		lRet := ExistCpo('AF8')				
		ElseIf cCampo = 'M->QI5_PRJEDT'
		lRet := Q_CHKEDT(aCols[n,nPosPRJ],M->QI5_PRJEDT)		 	
		EndIf
	EndIf


Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} QNC030St() 
Validas Status Informado Caso seja 5-"Reprovado", será aceito somente se 
Tiver integração com TMK ou PMS
@author andre.maximo
@since 10/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function QNC030St()

Local cStatus := &(ReadVar())
Local lTMKPMS := If(GetMv("MV_QTMKPMS",.F.,1) == 1,.F.,.T.)
Local lRet    := .T.

	IF Empty(cStatus)
	cStatus:= QI5->QI5_STATUS 
	EndIf

	If  AllTrim(cStatus) == '5' .And. !lTMKPMS	//-- Rejeitado
	MsgAlert(STR0114)
	lRet := .F.
	EndIf

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} Q030GetSX3 
Busca dados da SX3 
@author Brunno de Medeiros da Costa
@since 17/04/2018
@version 1.0
@return aHeaderTmp
/*/
//---------------------------------------------------------------------- 
Static Function Q030GetSX3(cCampo, cTitulo, cWhen)
Local aHeaderTmp := {}
aHeaderTmp:= {IIf(Empty(cTitulo), QAGetX3Tit(cCampo), cTitulo),;
              GetSx3Cache(cCampo,'X3_CAMPO'),;
              GetSx3Cache(cCampo,'X3_PICTURE'),;
              GetSx3Cache(cCampo,'X3_TAMANHO'),;
              GetSx3Cache(cCampo,'X3_DECIMAL'),;
              GetSx3Cache(cCampo,'X3_VALID'),;              
              GetSx3Cache(cCampo,'X3_USADO'),;
              GetSx3Cache(cCampo,'X3_TIPO'),;
              GetSx3Cache(cCampo,'X3_ARQUIVO') }
Return aHeaderTmp
