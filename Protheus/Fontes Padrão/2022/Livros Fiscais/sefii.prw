#INCLUDE "PROTHEUS.CH"
#INCLUDE "SEFII.CH"
#INCLUDE "FWCOMMAND.CH"

STATIC lTop := .F.

/*/ 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ SEFII    ³ Autor ³Sueli C. Santos        ³ Data ³10.05.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao do meio-magnetico para atender a exigencia do    ³±±
±±³          ³ Ato Cotepe 35 de 17/06/2005. DOU(13/07/2005)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Funcao inicial do processamento. Esta funcao apresenta ao   ³±±
±±³          ³ usuario o wizard de configuracao, recebe os parametros e   ³±±
±±³          ³ chama a funcao PrcSefII, responsavel pelo processamento    ³±±
±±³          ³ dos livros fiscais e geracao do meio magnetico.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tabelas   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function SEFII()
Local	lEnd		:=	.F.
Local	cNomWiz		:=	""
Local	aWizard		:=	{}
Local 	lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)

Private	lBloqCD		:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chamada para o Wizard da rotina³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lVerpesssen
	#IFDEF TOP	
		If TcSrvType() <> "AS/400"
			lTop 	:= .T.		
		Endif
	#ENDIF

	If !SIX->(dbSeek("SFI"+"3"))
		MsgAlert(STR0104) //"Deve ser criado um indice no arquivo SFI. Verificar os procedimentos para execução do U_UPDLOJ28 conforme o Boletim Tecnico do SPED Fiscal"
		Return
	EndIf

	cNomWiz	:= "SEFII"

	If !(MontWiz (cNomWiz))
		Return 	//Se o wizard for cancelado aborto o processamento.
	EndIf

	Processa({||PrcSefII(@lEnd, aWizard)},,,.T.)
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PrcSefII ³ Autor ³Gustavo Rueda/Liber Esteban ³ 28/08/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao do meio-magnetico para atender a exigencia do    ³±±
±±³          ³ Ato Cotepe 35 de 17/06/2005. DOU(13/07/2005)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Funcao principal de processamento. Esta funcao tem como     ³±±
±±³          ³ objetivo filtrar a tabela SFT(Livros Fiscais por item) e   ³±±
±±³          ³ montar os registros necessarios atraves de funcoes auxilia-³±±
±±³          ³ res.                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> Array com parametros informados pelo usuario no  ³±±
±±³          ³Wizard de configuracao do meio magnetico                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PrcSefII(lEnd,aWizard)
Local	dDataDe			:=	CToD ("//")
Local	dDataAte		:=	CToD ("//")
Local	cNomeCfp		:=	"SEFII"
Local	cAlias			:=	""
Local	aArq			:=	{}
Local	cDir			:=	""
Local	nDocumento		:=	1
Local	aLisFil			:=	{}
Local	cFileDest		:=	"SEFII.TXT"

Private cNrLivro		:=	""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do TRB para ser alimentado durante o processamento da rotina³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GeraTrb (1, @aArq, @cAlias)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atribuo o conteudo do CFP gerado pelo wizard no array aWizard³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (!xMagLeWiz (cNomeCfp, @aWizard, .T.))
	Return	//Se por algum motivo a leitura do CFP falhar aborto a rotina.
EndIf       

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|Decide qual arquivo será gerado pela opção que o usuário escolheu³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case "1" $ aWizard[1][8]
		nDocumento := 1 //GIA-LA-ICMS
	Case "2" $ aWizard[1][8]
		nDocumento := 2 //eDoc-Extrato
	Case "3"$ aWizard[1][8]
		nDocumento :=3 //RI - Registro de Inventario
	Case "4"$ aWizard[1][8]
		nDocumento :=4 //PRODEPE
EndCase 

dDataDe		:=	SToD (aWizard[1][1])
dDataAte	:=	SToD (aWizard[1][2])
cNrLivro	:=	aWizard[1][5]
cDir		:=	AllTrim(aWizard[1][6])
cFileDest	:=	AllTrim(aWizard[1][7])
DumpFile(1, @cDir, @cFileDest)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico se devo abrir a tela para fazer o processamento de multifiliais³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If "0"$aWizard[1][10]
	If "0"$aWizard[1][12]		// Verifica se deve consolidar a seleção por CNPJ + I.E.
		aLisFil  :=	MatFilCalc(.T.,,,.T.,,2)	
	Else
		aLisFil  :=	MatFilCalc(.T.)
	EndIf
	If Empty(aLisFil)
		MsgAlert(OemToAnsi(STR0127))	//"Nenhuma filial foi selecionada para o processamento. Será considerada a filial corrente."
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Para considerar a filial corrente, preciso alem de atribuir o cFilAnt, preciso forcar a ³
		//³   opcao 2 neste array que eh o resultado do wizard                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aWizard[1][10]	:=	"1 - Não"
		aAdd (aLisFil,{})
		aAdd (aLisFil[1], .T.)				
		aAdd (aLisFil[1], cFilAnt)  
	EndIf
Else
	aAdd (aLisFil,{})
	aAdd (aLisFil[1], .T.)				
	aAdd (aLisFil[1], cFilAnt)  
EndIf  
                  

//DEFINICAO DE ORDEM DAS TABELAS
DbSelectArea ("SX5")
SX5->(DbSetOrder (1))

DbSelectArea ("SA1")	//Cadastro do Cliente/Fornecedor
SA1->(DbSetOrder (1))

DbSelectArea ("SA2")	//Cadastro do Cliente/Fornecedor
SA2->(DbSetOrder (1))
		
DbSelectArea ("SF1")	//Cabecalho das Notas Fiscais de Entrada/Saida
SF1->(DbSetOrder (1))
		
DbSelectArea ("SF2")	//Cabecalho das Notas Fiscais de Entrada/Saida
SF2->(DbSetOrder (1))
				
DbSelectArea ("SE4")	//Condicao de pagamento
SE4->(DbSetOrder (1))
		
DbSelectArea ("SF3")	//Posicionando Livros Fiscais
SF3->(DbSetOrder (1))

DbSelectArea ("SD1")	//Itens das NF´s de Entrada
SD1->(DbSetOrder (1))

DbSelectArea ("SD2")	//Itens das NF´s de Saida
SD2->(DbSetOrder (3))

DbSelectArea ("SB1")	//Cadastro de Produtos
SB1->(DbSetOrder (1))
	
DbSelectArea ("SB5")	//Complemento do cadastro de produto
SB5->(DbSetOrder (1))

DbSelectArea ("SF4")	//Cadastro de TES
SF4->(DbSetOrder (1))

DbSelectArea ("SFI") //REDUCAO Z
SFI->(DbSetOrder (3))

DbSelectArea ("SF6") // Guias de Recolhimento
SF6->(DbSetOrder (3))

If AliasIndic ("SFU")
	DbSelectArea ("SFU")	//Informacoes complementares das NF de Energia Eletrica
	SFU->(DbSetOrder (1))
EndIf

If AliasIndic ("SFX")
	DbSelectArea ("SFX")	//Informacoes complementares das NF de Comunicacao/Telecomunicacao
	SFX->(DbSetOrder (1))
EndIf	

If "0"$aWizard[3][7] // Se selecionou "Sim" para as notas de frete
	If IntTms ()
		DbSelectArea ("DT6")
		DT6->(DbSetOrder (1))	
	EndIf
EndIf
 
Do Case	
	Case nDocumento == 1
		//PROCESSA LAYOUTS DOS ARQUIVOS LA-ICMS E GIAM_GIA_ICMS
		LA_GIA_ICM(aLisFil,cAlias,aWizard,lEnd) 
	Case nDocumento == 2                             
		//PROCESSA LAYOUT DO ARQUIVO EDOC_EXTRATO
		eDoc(aLisFil,cAlias,aWizard,lEnd)
	Case nDocumento == 3
		//PROCESSA LAYOUT DO ARQUIVO RI (REGISTRO DE INVENTARIO)
		Inventario(aLisFil,aWizard,cAlias) 	 
	Case nDocumento == 4 
	 	GIICMSG8(aLisFil,cAlias,aWizard,lEnd) 
EndCase	

//Gravacao dos indicadores de movimento dos registros
GrvIndMov (cAlias,nDocumento)

//Gero meio-magnetico
OrgTxt (cAlias, cFileDest)

//Fecho TRB criado
GeraTrb (2, @aArq, @cAlias)	

DumpFile(2,,cFileDest)

Return (.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³LA_GIA_ICM³ Autor ³Erick G. Dias          ³ Data ³ 21.10.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±	GERACAO DOS ARQUIVOS LA-ICMS E EDOC_ESTRATO.                           ±±
±±	SERAO GERADOS OS SEGUINTES BLOCOS:                                     ±±
±±	BLOCO 0, BLOCO E, BLOCO G, BLOCO 8 E BLOCO 9						   ±±
±±	OBS: ESTES DOIS LAYOUTS SERAO GERADOS EM UM UNICO ARQUIVO, CONFORME    ±±
±±	ORIENTACAO DA SEFII                                                    ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LA_GIA_ICM(aLisFil,cAlias,aWizard,lEnd)
Local	aAreaSM0		:=	SM0->(GetArea())
Local	dDataDe			:=	SToD (aWizard[1][1])
Local	dDataAte		:=	SToD (aWizard[1][2])
Local	aPartDoc		:=	{}
Local	aReg0400		:=	{}
Local	cAlsSF			:=	""
Local	cAlsSD			:=	""
Local	cAlsSA			:=	""
Local	cEntSai			:=	""
Local	aTotaliza		:=	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
Local	aTotalISS		:=	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
Local	cEspecie		:=	""
Local	nRelacDoc		:=	0
Local	aCmpAntSFT		:=	{}
Local	aObs			:=	{}
Local	nX				:=	0
Local 	nItem			:=	0
Local	cObs			:=	""
Local	cSituaDoc		:=	""
Local	aLeis			:=	{}
Local   aRegE003        :=  {}
Local	aRegE025		:=	{}
Local	aRegE050		:=	{}
Local	aRegE055		:=	{} 
Local	aRegE060		:=	{} 
Local	aRegE065		:=	{}
Local	aRegE080		:=	{}
Local	aRegE085		:=	{}     
Local	aRegE120		:=	{}    
Local   aRegE305        :=  {}
Local	aRegE310		:=	{}
Local   aRegE320        :=  {}
Local	aRegE360  		:=	{} 
Local	aRegE520		:=	{}
Local	aRegE525		:=	{}
Local   aRegE330		:=	{}
Local 	aReg0470		:=	{}
Local 	aRegE560		:=	{}
Local   aRegC020        :=  {}
Local	nAcImport		:=	0
Local   nAcRetEsta      :=  0   // ICMS substituto pelas saidas para o Estado.
Local	nAcRetInter		:=	0   // ICMS substituto pelas saidas para outros Estados.
Local	nDbCompIcm		:=	0
Local	nCrCompIcm		:=	0
Local	nAcCredTerc		:=	0
Local	nAcCredProp		:=	0
Local   nChv0450        :=  0 
Local	cCmpCondP		:=	""
Local	aRegE105		:=	{}
Local	lAchouSFU		:=	.F.
Local	lAchouSFX		:=	.F.
Local	lAchouSE4		:=	.T.
Local	lCompIcm		:=	.F.
Local 	lCompFre		:=  .F.
Local	lIss			:=	.F.
Local	lIcms			:=	.F.
Local	cCmpFrete		:=	0
Local	cRecIss			:=	""
Local	cCmpRecIss		:= ""
Local	cClasFis		:=	""
Local	cLancam			:=	""
Local	cChaveF3		:=	"" 
Local	cChv0450		:=	"" 
Local	cEspAux			:=	""
Local	cCfps			:=	""
Local	cCmpLocal		:=	""
Local	cCmpLtCtl		:=	""
Local	cCmpNLote		:=	""
Local	lIssRet			:=	.F.
Local	lSm0			:=	.F.
Local   lGrava          :=  .F.
Local	cCmpVlAcr		:=	"" 
Local	aLog			:=	{}
Local	aConjugada		:=	{.F.,.F.}
Local   cEspeNFS        := " "
Local   cPdv            := 0
Local   cCodSef         := ""
Local   cCodCOP         := ""
Local 	nFilial			:= 0 
Local 	nForFilial		:= 0
Local  	lEnergia		:= .F.
Local 	nRemType 		:= GetRemoteType()
Local 	cMV_SEFELE		:= SuperGetMv("MV_SEFELE",.F.,'')
Local 	nTpMov 			:= 0
Local 	aTpMov 			:= {'E','S'}
Local 	cCmpRecSA 		:= ""
Local 	nContDoc 		:= 0
Local 	aReg0455		:={}
Local  	lConjugada		:= .F.

Private cNrLivro		:= alltrim(aWizard[1][5]) 
Private nFreteCIF		:=	0
Private nFreteFOB		:=	0 

Default aLisFil			:={}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO 0000 - ABERTURA DO ARQUIVO DIGITAL E IDENTIFICACAO DO CONTRIBUINTE³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Reg0000 (aWizard, cAlias, dDataDe, dDataAte)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO 0005 - DADOS COMPLEMENTARES DO CONTRIBUINTE³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Reg0005 (aWizard, cAlias)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³REGISTRO 0025 - BENEFICIO FISCAL³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Reg0025(cAlias)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO 0030 - PERFIL CONTRIBUINTE  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Reg0030 (aWizard, cAlias)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO 0100 - DADOS DO CONTABILISTA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Reg0100 (aWizard, cAlias)     

If SM0->M0_ESTCOB == "PE"
    RegE003(cAlias, @aRegE003)
Endif

DbSelectArea ("SM0")

For nForFilial := 1 To Len( aLisFil ) 

	If aLisFil [ nForFilial, 1 ]
  	   
  		cFilAnt := aLisFil[nForFilial][2]
  		SM0->(DbSeek (cEmpAnt + cFilAnt, .T.))		  		  			
				
		For nTpMov := 1 to Len(aTpMov)
			
			IncProc("Consultando dados...")
			
			nContDoc := 0
			cAliasSFT := SelSFT(dDataDe, dDataAte, cNrLivro, aTpMov[nTpMov])
					
			Do While !(cAliasSFT)->(Eof ()) //LOOP DAS NOTAS
		
				If Interrupcao(@lEnd)
					Exit
				EndIf
				
				// Controle para executar menos vezes o comando IncProc.
				If Mod(nContDoc, 500) == 0
					IncProc("Processando Notas (" + aTpMov[nTpMov] + ")..." + StrZero(nContDoc,6) + Chr(13) + Chr(10) + STR0050 + cFilAnt)
				EndIf	

				cPdv := (cAliasSFT)->FT_PDV //NUMERO DO CAIXA
				cLancam := AllTrim((cAliasSFT)->FT_CONTA)
				cEspecie := cEspAux := AModNot((cAliasSFT)->FT_ESPECIE)		//Modelo NF
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³FT_PDV somente estarah alimentado quando se referir a nota fiscais de saida ³
				//³   geradas pelo SIGALOJA.                                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty((cAliasSFT)->FT_PDV) .And. AllTrim((cAliasSFT)->FT_ESPECIE)$"CF"
					cEspecie := "2D"
					cEspAux := "2D"
				EndIf
				
				cChaveF3 := xFilial("SF3") + DToS((cAliasSFT)->FT_ENTRADA)+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA
				cCodSef := ""

				If SEFIISeek("SF3",1,cChaveF3,Iif(lTop,(cAliasSFT)->SF3RECNO,0))
					cCodSef := Alltrim(SF3->F3_CODRSEF)
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³SOMENTE MODELOS:                               ³
				//³01 - NOTA FISCAL NORMAL                        ³
				//³02 - NOTA FISCAL DE VENDA A CONSUMIDOR FINAL   ³
				//³03 - NOTA FISCAL DE SERVICO                    ³
				//³04 - NOTA FISCAL PRODUTOR                      ³
				//³06 - NOTA FISCAL/CONTA DE ENERGIA ELETRICA     ³
				//³07 - NOTA FISCAL SERVICO DE TRANSPORTE         ³
				//³08 - CONHECIMENTO DE TRANSPORTE RODOVIARIO     ³
				//³09 - CONHECIMENTO DE TRANSPORTE AQUAVIARIO     ³
				//³10 - CONHECIMENTO DE TRANSPORTE AEREO          ³
				//³11 - CONHECIMENTO DE TRANSPORTE FERROVIARIO    ³
				//³21 - NOTA FISCAL DE SERVICO DE COMUNICACAO     ³
				//³22 - NOTA FISCAL DE SERVICO DE TELECOMUNICACAO ³
				//³55 - NOTA FISCAL ELETRONICA                    ³
				//³57 - CONHECIMENTO DE TRANSPORTE ELETRONICO     ³
				//³65 - NOTA FISCAL ELETRONICA CONSUMIDOR FINAL   ³
				//³67 - CONHECIMENTO DE TRANSPORTE ELETRONICO - OS³
				//³63 - BILHETE DE PASSAGEM ELETRÔNICO			  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !(cEspecie$"01#02#03#04#06#07#08#09#10#11#21#22#2D#55#57#65#1B#67#63")
					(cAliasSFT)->(DbSkip ())
					Loop
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³As informacoes CTR e NFST necessarias para o SINTEGRA somente estao disponiveis           |
				//³ quando o TMS estiver envolvido (SAIDAS) ou ENTRADAS quando envolver aviso de recebimento.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//If ((cEspecie$"07#08") .And. (!IntTms () .And. "S"$(cAliasSFT)->FT_TIPOMOV))
				//	(cAliasSFT)->(DbSkip ())
				//	Loop
				//EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Para as notas fiscais de transportes vindas do TMS sempre deverah      ³
				//³   haver um DT6 correspondente, caso nao haja, montar o arquivo de     ³
				//³   log e saltar para a proxima nota. Instrucoes passadas pela equipe do³
				//³   TMS.                                                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cEspecie$"#07#08#09#10#11#" .And. "S"$(cAliasSFT)->FT_TIPOMOV .And. IntTms()
					If !DT6->(DbSeek (xFilial ("DT6")+(cAliasSFT)->(FT_FILIAL+FT_NFISCAL+FT_SERIE)))			
						(cAliasSFT)->(DbSkip ())
						Loop				
					EndIf
				EndIf
				
				//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Inicializacao de variaveis utilizadas no processamento ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Determina o Alias para as Tabelas SF1/SF2 e SD1/SD2.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
				cEntSai		:=	Iif ("E" $ (cAliasSFT)->FT_TIPOMOV, "1", "2")
				cAlsSF			:=	"SF"+cEntSai	//Determina o Alias para as Tabelas SF1/SF2
				cAlsSD			:=	"SD"+cEntSai	//Determina o Alias para as Tabelas SD1/SD2
				
				//Determina o Alias para as Tabelas SA1/SA2
				If ((cEntSai == "2" .And. (cAliasSFT)->FT_TIPO$"BD") .Or. (cEntSai == "1" .And. !(cAliasSFT)->FT_TIPO $ "BD"))
					cAlsSA	:= "SA2"			
				Else
					cAlsSA	:= "SA1"
				EndIf				
								//   1  2  3  4  5   6  7  8  9  10 11 12 13 14 15 16  17 18 19 20 21 22 23 24 25 26
				aTotaliza		:=	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
								//   1  2  3  4  5   6  7  8  9  10 11 12 13 14 15 16  17 18 19 20 21 22 23 24 25
				aTotalISS		:=	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
				nRelacDoc++		//Utilizado para relacionar os documentos fiscais aos seus elementos inferiores/dependentes
				cObs			:=	""
				nItem			:=	0
				aRegC020		:=	{}
				aRegE025		:=	{}
				aRegE105		:=	{}
				lAchouSFU		:=	.F.
				lAchouSFX		:=	.F.
				lAchouSE4		:=	.F.
				lCompIcm		:=	.F.
				lCompFre		:=  .F.
				cSituaDoc		:=	RetSitDoc((cAliasSFT)->FT_TIPO,cAliasSFT,cCodSef)

				
				nAcImport		+=	Iif (Left((cAliasSFT)->FT_CFOP, 1) == "3", (cAliasSFT)->FT_VALICM, 0)  
				nAcRetEsta		+=	Iif (Left((cAliasSFT)->FT_CFOP, 1) == "5", (cAliasSFT)->FT_ICMSRET, 0)		
				nAcRetInter	+=	Iif (Left((cAliasSFT)->FT_CFOP, 1) == "6", (cAliasSFT)->FT_ICMSRET, 0)
				nAcCredTerc	+=	Iif ("E"$(cAliasSFT)->FT_TIPOMOV .And. Empty((cAliasSFT)->FT_FORMUL), (cAliasSFT)->FT_ICMSRET, 0)  		
				nAcCredProp	+=	Iif ("E"$(cAliasSFT)->FT_TIPOMOV .And. !Empty((cAliasSFT)->FT_FORMUL), (cAliasSFT)->FT_ICMSRET, 0)  		
				
				cCfps			:=	""
				
				aCmpAntSFT		:=	{(cAliasSFT)->FT_NFISCAL,;		//01
									(cAliasSFT)->FT_SERIE,;			//02
									(cAliasSFT)->FT_CLIEFOR,;		//03
									(cAliasSFT)->FT_LOJA,;			//04
									(cAliasSFT)->FT_ENTRADA,;		//05
									(cAliasSFT)->FT_EMISSAO,;		//06
									(cAliasSFT)->FT_DTCANC,;		//07
									(cAliasSFT)->FT_FORMUL,;		//08
									(cAliasSFT)->FT_CFOP,;			//09
									cLancam,;						//10	//(cAliasSFT)->FT_CONTA
									(cAliasSFT)->FT_ALIQICM,;		//11
									(cAliasSFT)->FT_PDV,;			//12
									(cAliasSFT)->FT_BASEICM,;		//13
									(cAliasSFT)->FT_CLASFIS,;		//14
									(cAliasSFT)->FT_VALICM,;		//15
									(cAliasSFT)->FT_ISENICM,;		//16
									(cAliasSFT)->FT_OUTRICM,;		//17
									(cAliasSFT)->FT_ICMSRET,;       //18
									(cAliasSFT)->FT_TIPO,;   		//19  TIPO 
									(cAliasSFT)->FT_CHVNFE,;		//20 Chave
							   		(cAliasSFT)->FT_OBSERV,; 		//21 OBSERV
									(cAliasSFT)->FT_FILIAL} 		//22 FILIAL
									
				cCmpCondP		:=	cAlsSF+"->"+SubStr(cAlsSF, 2, 2)+"_COND" 
				cCmpFrete		:=	cAlsSF+"->"+SubStr(cAlsSF, 2, 2)+"_FRETE"
				cCmpRecIss		:=	cAlsSA+"->"+SubStr(cAlsSA, 2, 2)+"_RECISS"
				cCmpTes			:=	cAlsSD+"->"+SubStr(cAlsSD, 2, 2)+"_TES"
				cCmpLocal		:=	cAlsSD+"->"+SubStr(cAlsSD, 2, 2)+"_LOCAL"
				cCmpLtCtl		:=	cAlsSD+"->"+SubStr(cAlsSD, 2, 2)+"_LOTECTL"
				cCmpNLote		:=	cAlsSD+"->"+SubStr(cAlsSD, 2, 2)+"_NUMLOTE"
				cCmpVlAcr		:=	cAlsSD+"->"+SubStr(cAlsSD, 2, 2)+"_VALACRS"
				cCmpRecSA     	:= cAlsSA + "RECNO"
			
				cRecIss			:=	""
				lSm0			:=	Iif((cAliasSFT)->FT_FORMUL == "S" .And. cEntSai == "1", .T., .F.)	
				
				//Quando a NF de Entrada for formulario proprio o validador exige que os dados do remetente sejam os mesmos do declarante.
				If "E" $ (cAliasSFT)->FT_TIPOMOV 																							
					nFreteCIF += Iif(cAlsSF+"->"+SubStr (cAlsSF, 2, 2)+"_TPFRETE" == "C", cAlsSF+"->"+SubStr (cAlsSF, 2, 2)+"FRETE", 0)
					nFreteFOB += Iif(cAlsSF+"->"+SubStr (cAlsSF, 2, 2)+"_TPFRETE" == "F", cAlsSF+"->"+SubStr (cAlsSF, 2, 2)+"FRETE", 0)																								
				ElseIf "S" $ (cAliasSFT)->FT_TIPOMOV .And. cAlsSF == "SF2"
					nFreteCIF += Iif((cAlsSF)->F2_TPFRETE == "C", (cAlsSF)->F2_FRETE, 0)
					nFreteFOB += Iif((cAlsSF)->F2_TPFRETE == "F", (cAlsSF)->F2_FRETE, 0)	
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Posicionando tabelas³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				SEFIISeek(cAlsSA,,xFilial(cAlsSA)+(cAliasSFT)->(FT_CLIEFOR+FT_LOJA),Iif(lTop,(cAliasSFT)->&(cCmpRecSA),0))
				SEFIISeek(cAlsSF,,xFilial(cAlsSF)+(cAliasSFT)->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA),Iif(lTop,(cAliasSFT)->SFRECNO,0))
				lAchouSE4	:=	SEFIISeek("SE4",1,xFilial("SE4")+&(cCmpCondP),IIf(lTop,(cAliasSFT)->SE4RECNO,0))
						
				lCompIcm	:=	(&(cAlsSF + "->" + SubStr(cAlsSF, 2, 2) + "_TIPO") == "I") // Indica se NF de complemento de ICMS
				lCompFre	:=	(&(cAlsSF + "->" + SubStr(cAlsSF, 2, 2) + "_TIPO") == "C") // Indica se NF de complemento de Frete
								
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Processo todas as observacoes para o documento fiscal contidas na tabela SF3 (F3_OBSERV)³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !cEspecie $ "02/2D" .Or. !aCmpAntSFT[19] $ "F"	//O registro de observacao nao deve ser gerado para consumidor final, inclusive cupom fiscal
					aObs := LivrObs(cAliasSFT, Val (cEntSai), 65536, @aLeis, cChaveF3,lCompFre)
					For nX := 1 To Len (aObs)
						cObs	+=	aObs[nX]+", "
					Next (nX)
				EndIf	
							
				If AliasIndic ("SFU")
					//Informacoes complementares das NF de Energia Eletrica
					lAchouSFU	:=	SFU->(DbSeek (xFilial ("SFU")+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA+(cAliasSFT)->FT_ITEM))
				EndIf
				
				If AliasIndic ("SFX")
					//Informacoes complementares das NF de Comunicacao/Telecomunicacao
					lAchouSFX	:=	SFX->(DbSeek (xFilial("SFX")+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA+(cAliasSFT)->FT_ITEM))
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Segundo instrucoes da SEF-DF, as notas de complemento de ICMS deverao ser lancadas no |
				//³ registro de ajustes da apuracao de ICMS (E340)                                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lCompIcm
					If "S" $ (cAliasSFT)->FT_TIPOMOV
						nDbCompIcm	 += (cAliasSFT)->FT_VALICM
					Else
			      		nCrCompIcm += (cAliasSFT)->FT_VALICM
					EndIf
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Retornando dados do participante em um array³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aPartDoc	:=	InfPartDoc (cAlsSA, Nil,cAliasSFT) 
						
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³SOMENTE MODELOS:                               ³
				//³01 - NOTA FISCAL NORMAL                        ³
				//³03 - NOTA FISCAL DE SERVICO                    ³
				//³04 - NOTA FISCAL PRODUTOR                      ³
				//³06 - NOTA FISCAL/CONTA DE ENERGIA ELETRICA     ³
				//³07 - NOTA FISCAL SERVICO DE TRANSPORTE         ³
				//³08 - CONHECIMENTO DE TRANSPORTE RODOVIARIO     ³
				//³09 - CONHECIMENTO DE TRANSPORTE AQUAVIARIO     ³
				//³10 - CONHECIMENTO DE TRANSPORTE AEREO          ³
				//³11 - CONHECIMENTO DE TRANSPORTE FERROVIARIO    ³
				//³21 - NOTA FISCAL DE SERVICO DE COMUNICACAO     ³
				//³22 - NOTA FISCAL DE SERVICO DE TELECOMUNICACAO ³
				//³55 - NOTA FISCAL ELETRONICA                    ³
				//³57 - CONHECIMENTO DE TRANSPORTE ELETRONICO     ³
				//³67 - CONHECIMENTO DE TRANSPORTE ELETRONICO - OS³
				//³63 - BILHETE DE PASSAGEM ELETRÔNICO			  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cEspecie$"01#03#04#06#07#08#09#10#11#21#22#55#57#1B#67#63"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³REGISTRO 0150 - TABELA DE CADASTRO DE PARTICIPANTES³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Reg0150 (aPartDoc,aWizard,cEspecie)
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Processando os itens do documento fiscal.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cChave	:=	(cAliasSFT)->FT_FILIAL+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA
				
				If !Empty(cObs)
					nChv0450 += 1
					cChv0450 := StrZero(nChv0450,9)
				Else
					cChv0450 := ''
				EndIf	     

				// Inicializando variáveis para nota conjugada
				aConjugada		:=	{.F.,.F.}				
				lConjugada		:= .F.
			
				Do While !(cAliasSFT)->(Eof ()) .And.;
					cChave==(cAliasSFT)->FT_FILIAL+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA
					
					If Interrupcao(@lEnd)
						Exit
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Inicializacao de variaveis utilizadas no processamento do item³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nItem+= 1
					cCodCOP := ""
					cClasFis := ""
					lIss := .F.
					cEspeNFS := ""
					cCfps := ""
					lIssRet := .F.
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Posicionando tabelas de acordo com os itens dos documentos fiscais.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					
					SEFIISeek(cAlsSD,,xFilial(cAlsSD)+(cAliasSFT)->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_PRODUTO+FT_ITEM),IIf(lTop,(cAliasSFT)->SDRECNO,0))
					SEFIISeek("SB1",,xFilial("SB1")+(cAliasSFT)->FT_PRODUTO,IIf(lTop,(cAliasSFT)->SB1RECNO,0))
					
					If lTop
						cCodCOP := (cAliasSFT)->F4_COP
					Else
						If SEFIISeek("SF4",,xFilial("SF4") + &(cCmpTes))
							cCodCOP := SF4->F4_COP
						EndIf
					EndIf
					
					If Empty(cCodCOP)
						cCodCOP := RetCOP(Alltrim((cAliasSFT)->FT_CFOP))
					EndIf
					
					cClasFis := RetCodCst(cAliasSFT, cAlsSA)
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³verifica se este item da nota eh um servico ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lIss := ((cAliasSFT)->FT_TIPO == "S")
					cEspeNFS := AllTrim((cAliasSFT)->FT_ESPECIE )
					cCfps := Iif(Empty(cCfps), (cAliasSFT)->FT_CFPS, cCfps)
					
					If lIss
						If !Empty ((cAliasSFT)->FT_RECISS)
							cRecIss		:=	(cAliasSFT)->FT_RECISS
						Else
							cRecIss		:=	&(cCmpRecIss)
						EndIf
						
						If (cEntSai == "1" .And. cRecIss $ "2N") .Or. (cEntSai == "2" .And. cRecIss $ "1S")
							lIssRet		:=	.T.
						EndIf
					Else
						lIcms := .T.
					EndIf

					// Verifica se é Nota Conjugada
					// aConjugada --> Array aConjugada, 1o.Item é se a NF é de Produto, 2o.Item é se a NF é de Serviços
					If lIss
						aConjugada[2]	:=	.T.
					Else
						aConjugada[1]	:=	.T.
					EndIf

					If Len(aCmpAntSFT) > 0  .And. aCmpAntSFT[1]+aCmpAntSFT[2] == (cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE
						If aConjugada[1] == .T. .And. aConjugada[2] == .T.
							lConjugada	:= .T.
						EndIf
					Else
						lConjugada	:= .F.
					EndIf
					
					If (cEspecie$"01#02#2D#03#04#06#21#22#55#65#1B")
						If (cEspecie$"01#04#55#65#1B")
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³REGISTRO E025 - DETALHE - VALORES PARCIAIS(MODELOS 01, 04, 55 E 65)³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							RegE025 (cAliasSFT, @aRegE025, cSituaDoc, lIss, aWizard, cEspecie)
						ElseIf (cEspecie$"02")	//NFCF e CF
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³REGISTRO E050 - REGISTRO MESTRE DE NOTA FISCAL DE VENDA A CONSUMIDOR (MODELO 02)³
							//³REGISTRO E055 - REGISTRO ANALITICO DO DOCUMENTO (MODELO 02)                     ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							E050E055 (@aRegE050, @aRegE055, aCmpAntSFT, cAliasSFT, cEspecie, cSituaDoc,cChv0450,cCodCOP)
						EndIf				
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³SOMENTE MODELOS:                                          ³
						//³07 - NOTA FISCAL SERVICO DE TRANSPORTE - SAIDA/ENTRADA    ³
						//³08 - CONHECIMENTO DE TRANSPORTE RODOVIARIO - SAIDA/ENTRADA³
						//³09 - CONHECIMENTO DE TRANSPORTE AQUAVIARIO - ENTRADA      ³
						//³10 - CONHECIMENTO DE TRANSPORTE AEREO - ENTRADA           ³
						//³11 - CONHECIMENTO DE TRANSPORTE FERROVIARIO - ENTRADA     ³
						//³57 - CONHECIMENTO DE TRANSPORTE ELETRONICO                ³
						//³67 - CONHECIMENTO DE TRANSPORTE ELETRONICO - OUTROS SERVI ³
						//³63 - BILHETE DE PASSAGEM ELETRÔNICO						 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					ElseIf (cEspecie$"#07#08#09#10#11#57#67#63")
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO E120:                                     ³
						//³- NOTA FISCAL DE SERVICO DE TRANSPORTE (MODELO 07) ³
						//³- CONHECIMENTO DE FRETE (MODELO 08)                ³
						//³- CONHECIMENTO DE TRANSPORTE (MODELO 57)           ³
						//³- CONHECIMENTO DE TRANSPORTE - OS (MODELO 67)	  ³
						//³- BILHETE DE PASSAGEM ELETRÔNICO (MODELO 63) 	  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						RegE120 (cAlias, nRelacDoc, @aRegE120, cEntSai, aPartDoc, cEspecie, cSituaDoc, aCmpAntSFT, cAliasSFT, cChv0450,lAchouSE4,cCodCOP,aWizard)
					EndIf			
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³SOMENTE MODELOS:                               ³
					//³01 - NOTA FISCAL NORMAL                        ³
					//³02 - NOTA FISCAL DE VENDA A CONSUMIDOR FINAL   ³
					//³03 - NOTA FISCAL DE SERVICO                    ³
					//³04 - NOTA FISCAL PRODUTOR                      ³
					//³06 - NOTA FISCAL/CONTA DE ENERGIA ELETRICA     ³
					//³07 - NOTA FISCAL SERVICO DE TRANSPORTE         ³
					//³08 - CONHECIMENTO DE TRANSPORTE RODOVIARIO     ³
					//³09 - CONHECIMENTO DE TRANSPORTE AQUAVIARIO     ³
					//³10 - CONHECIMENTO DE TRANSPORTE AEREO          ³
					//³11 - CONHECIMENTO DE TRANSPORTE FERROVIARIO
					//³21 - NOTA FISCAL DE SERVICO DE COMUNICACAO     ³
					//³22 - NOTA FISCAL DE SERVICO DE TELECOMUNICACAO ³
					//³55 - NOTA FISCAL ELETRONICA                    ³
					//³57 - CONHECIMENTO DE TRANSPORTE ELETRONICO     ³
					//³67 - CONHECIMENTO DE TRANSPORTE ELETRONICO -OS ³
					//³63 - BILHETE DE PASSAGEM ELETRÔNICO			  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (cEspecie$"01#02#2D#04#06#07#08#09#10#11#21#22#55#57#65#1B#67#63")
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO E305 - MAPA RESUMO DE OPERACOES³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						RegE305 (cAliasSFT, cEntSai, @aRegE305, cEspecie, cSituaDoc, aCmpAntSFT, lIss, aTotalISS,cCodCOP,aWizard,  .F.)			
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO E310 - CONSOLIDACAO DOS VALORES DE ICMS POR CFOP³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						RegE310 (cAliasSFT, cEntSai, @aRegE310, cSituaDoc, lIss, cEspecie)				
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO E330 - TOTALIZACAO DOS VALORES DE ENTRADAS E SAIDAS³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						RegE330 (cAlias,cAliasSFT, cEntSai, cSituaDoc, lIss,cEspecie, aRegE330)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO E520 - CONSOLIDACAO DOS VALORES DE IPI POR CFOP E CODIGO DE SITUACAO TRIBUTARIA³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						RegE520 (cAliasSFT, @aRegE520, cSituaDoc, cEntSai)				
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO E525 - TOTALIZACAO DAS ENTRADAS E SAIDAS DO IPI      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						RegE525 (cAlias, aRegE525, aRegE520)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO 0400 - TABELA DE NATUREZA DA OPERACAO/PRESTACAO³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
						If !lIss
							Reg0400 ((cAliasSFT)->FT_CFOP, @aReg0400,cCodCOP)
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Como esta tabela possui escrituracao fiscal   |
						//| por item de documento fiscal, acumulo valores|
						//| necessarios independente dos itens, ou seja, |
						//| por NF.                                      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lIss // Se eh servico
							aTotalISS[1]	+=	(cAliasSFT)->FT_VALCONT
							aTotalISS[2]	+=	(cAliasSFT)->FT_BASEICM
							aTotalISS[3]	+=	(cAliasSFT)->FT_VALICM
							aTotalISS[4]	+=	(cAliasSFT)->FT_BASERET
							aTotalISS[5]	+=	(cAliasSFT)->FT_ICMSRET
							aTotalISS[7]	+=	(cAliasSFT)->FT_ISENICM
							aTotalISS[6]	+=	(cAliasSFT)->FT_VALIPI
							aTotalISS[8]	+=	(cAliasSFT)->FT_QUANT
							aTotalISS[9]	+=	(cAliasSFT)->FT_DESCONT
							aTotalISS[10]	+=	(cAliasSFT)->FT_TOTAL
							aTotalISS[11]	+=	(cAliasSFT)->FT_FRETE
							aTotalISS[12]	+=	(cAliasSFT)->FT_SEGURO
							aTotalISS[13]	+=	(cAliasSFT)->FT_DESPESA
							aTotalISS[14]	+=	(cAliasSFT)->FT_OUTRICM
							aTotalISS[15]	+=	(cAliasSFT)->FT_BASEIPI
							aTotalISS[16]	+=	(cAliasSFT)->FT_ISENIPI
							aTotalISS[17]	+=	(cAliasSFT)->FT_OUTRIPI
							aTotalISS[18]	+=	(cAliasSFT)->FT_ICMSCOM
							aTotalISS[19]	+=	(cAliasSFT)->FT_BASEICM //	Base ISS
							aTotalISS[20]	+=	(cAliasSFT)->FT_VALICM	//	Vlr ISS
							If lIssRet
								aTotalISS[21]	+=	(cAliasSFT)->FT_BASEICM //	Base ISS RET
								aTotalISS[22]	+=	(cAliasSFT)->FT_VALICM	//	Vlr ISS RET
							EndIf
							aTotalISS[23]	+=	(cAliasSFT)->FT_ISENICM
							aTotalISS[24]	+=	(cAliasSFT)->FT_ISSSUB
							If cEntSai == "2" .And. cEspecie $ "2D"
								aTotalISS[25]	+=	&(cCmpVlAcr)
							Else
								aTotalISS[25]	:= 0
							EndIf
						Else
							aTotaliza[1]	+=	iif(cSituaDoc	==	"20" .AND. ((cAliasSFT)->FT_TOTAL > (cAliasSFT)->FT_VALCONT),(cAliasSFT)->FT_TOTAL,(cAliasSFT)->FT_VALCONT)	   
							aTotaliza[2]	+=	(cAliasSFT)->FT_BASEICM
							aTotaliza[3]	+=	Round((cAliasSFT)->FT_VALICM,2)
							aTotaliza[4]	+=	(cAliasSFT)->FT_BASERET
							aTotaliza[5]	+=	(cAliasSFT)->FT_ICMSRET
							aTotaliza[6]	+=	(cAliasSFT)->FT_VALIPI
							//Quando configuro a TES para escriturar o Livro de ICMS/ST como OUTROS, na tabela SF3 o valor do campo
							//  F3_ICMSRET eh transportado para o campo F3_OUTRICM, ficando com os mesmos valores. Na tabela SFT, que
							//  possui o campo proprio FT_OUTRRET, recebe este valor deixando o campo FT_OUTRICM e FT_ICMSRET zerado.
							aTotaliza[7]	+=	(cAliasSFT)->FT_ISENICM+(cAliasSFT)->FT_ISENRET
							aTotaliza[8]	+=	(cAliasSFT)->FT_QUANT
							aTotaliza[9]	+=	(cAliasSFT)->FT_DESCONT
							aTotaliza[10]	+=	(cAliasSFT)->FT_TOTAL
							aTotaliza[11]	+=	(cAliasSFT)->FT_FRETE
							aTotaliza[12]	+=	(cAliasSFT)->FT_SEGURO
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Tratamento para nao levar valor negativo³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If (cAliasSFT)->(FT_DESPESA-(FT_SEGURO+FT_FRETE))>0
								aTotaliza[13]	+=	(cAliasSFT)->(FT_DESPESA-(FT_SEGURO+FT_FRETE))	//Totaliza as outras despesas do documento fiscal. Este tratamento se faz necessario porque FRETE e SEGURO incorporam o valor da despesa no sistema
							EndIf                                             
							//Quando configuro  a TES para escriturar o Livro de ICMS/ST como OUTROS, na tabela SF3 o valor do campo
							//  F3_ICMSRET eh transportado para o campo F3_OUTRICM, ficando com os mesmos valores. Na tabela SFT, que
							//  possui o campo proprio FT_OUTRRET, recebe este valor deixando o campo FT_OUTRICM e FT_ICMSRET zerado.
							aTotaliza[14]	+=	(cAliasSFT)->FT_OUTRICM+(cAliasSFT)->FT_OUTRRET
							aTotaliza[23]	+=	If("5405"$(cAliasSFT)->FT_CFOP,0,iif("41"$(cAliasSFT)->FT_CLASFIS,(cAliasSFT)->FT_OUTRICM+(cAliasSFT)->FT_OUTRRET,0))					
							aTotaliza[25]	+=	If("5405"$(cAliasSFT)->FT_CFOP,iif("40"$(cAliasSFT)->FT_CLASFIS,((cAliasSFT)->FT_ISENICM+(cAliasSFT)->FT_ISENRET),(cAliasSFT)->FT_OUTRICM+(cAliasSFT)->FT_OUTRRET),0)										
							aTotaliza[15]	+=	(cAliasSFT)->FT_BASEIPI
							aTotaliza[16]	+=	(cAliasSFT)->FT_ISENIPI
							aTotaliza[17]	+=	(cAliasSFT)->FT_OUTRIPI
							aTotaliza[18]	+=	(cAliasSFT)->FT_ICMSCOM
							aTotaliza[26]	+=	(cAliasSFT)->FT_VALANTI
							If cEntSai == "2" .And. cEspecie $ "2D"
								aTotaliza[19]	+=	&(cCmpVlAcr)
							Else
								aTotaliza[19]	:= 0
							EndIf	
							nItem++
						EndIf										
					EndIf
					
					IF (cEspecie$"01#04#55#1B")
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO C020 - NOTA FISCAL CODIGO 01, NOTA FISCAL PRODUTOR CODIGO 04, NOTA FISCAL ELETRONICA CODIGO 55³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						lGrava := .F. //Somente sera gravado para os modelos 01/04/55, no outros casos, sera somente montado o array.
					   	RegC020(cEntSai,aPartDoc,cEspecie,cAlias,nRelacDoc,aCmpAntSFT,aTotaliza,@aRegC020,cChv0450,cSituaDoc,lAchouSE4,lGrava,aTotalIss,"0"$aWizard[1][11],lConjugada)
					Endif
					
					(cAliasSFT)->(DbSkip ())
					
				EndDo	//ENDDO do item
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Este tratamento se dah devido a troca da especie quando for nota fiscal de servico ou nota fiscal conjugada.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cEspecie	:=	cEspAux
			
				If Interrupcao(lEnd)
					Exit
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³SOMENTE MODELOS:                              ³
				//³01 - NOTA FISCAL NORMAL                       ³
				//³02 - NOTA FISCAL PRODUTOR                     ³
				//³03 - NOTA FISCAL DE SERVICOS                  ³
				//³04 - NOTA FISCAL DE VENDA A CONSUMIDOR FINAL  ³
				//³06 - NOTA FISCAL/CONTA DE ENERGIA ELETRICA    ³
				//³21 - NOTA FISCAL DE SERVICO DE COMUNICACAO    ³
				//³22 - NOTA FISCAL DE SERVICO DE TELECOMUNICACAO³
				//³55 - NOTA FISCAL ELETRONICA                   ³
				//³65 - NOTA FISCAL ELETRONICA CONSUMIDOR FINAL  ³
				//³67 - NOTA FISCAL ELETRONICA TRANSPORTE - OS   ³
				//³63 - BILHETE DE PASSAGEM ELETRÔNICO			 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (cEspecie$"01#02#2D#04#06#07#08#09#10#11#21#22#55#57#65#1B#67#63")
					If aTotalISS[24]<>0 .And. Empty(cObs)
						cObs	:=	"ISS SUBEMPREITADA"
					EndIf				                     
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Processanto geracao dos REGISTROS 0450, 0460 e 0465³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			    	If  !Empty (cObs)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO 0450 - TABELA DE INFORMACOES COMPLEMENTARES/OBSERVACOES³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Reg0450 (cAlias, nRelacDoc, cObs, cChv0450) 
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO 0455 - NORMA REFERENCIADA³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Reg0455 (cAlias, nRelacDoc, aLeis,aReg0455)
					Endif
					If !cEspecie$"02" .And. !(cSituaDoc$"90/80")          
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO 0460 - DOCUMENTO DE ARREADACAO REFERENCIADO³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Reg0460 (aWizard, cAlias, dDataDe, dDataAte, nRelacDoc, aCmpAntSFT, aPartDoc, lSm0, cValToChar(nTpMov))
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO 0465 - DOCUMENTO FISCAL REFERENCIADO³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If ("CF/SERIE:" $ cObs) .Or. (aCmpAntSFT[19] $ "D/I/P/C")
							Reg0465 (cAlias, nRelacDoc, @aRegC020, cEntSai, @aPartDoc, aTotalISS, lSm0, aCmpAntSFT)
						EndIf 			
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO 0470 - CUPOM FISCAL REFERENCIADO³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If cEspecie$"02" 
							Reg0470(cAlias,cEspecie,aCmpAntSFT, aTotaliza,cPdv,nRelacDoc)				
						EndIf 			
					EndIf	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³TIDXE7 -  TRATAMENTO PARA CONSIDERAR NO REGISTRO E110E105 MODELO 55  ³
					//³QUANDO AS OPERAÇÕES FOREM FEITA COM CFOP PARA ENERGIA ELETRICA       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lEnergia	:=  ((cEspecie$"01/55") .And. Alltrim(aCmpAntSFT[9])$ cMV_SEFELE )
					
					If (cEspecie$"01#04#55#65#1B") .And. !lEnergia
					    // Eh necessário buscar o codigo do COP por Nota a partir do array (aCmpAntSFT).
						If !Empty(aCmpAntSFT[9])
							cCodCOP := RetCOP(@Alltrim(aCmpAntSFT[9]))
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³GRAVACAO REGISTRO E020 - REGISTRO MESTRE NOTA FISCAL (MODELO 01). NOTA FISCAL DE PRODUTOR (MODELO 04) E NF ELETRONICA (MODELO 55)      ³
						//³GRAVACAO REGISTRO E025 - REGISTRO ANALITICO DE NOTA FISCAL (MODELO 01), NOTA FISCAL DE PRODUTOR (MODELO 04) E NF ELETRONICA (MODELO 55)³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						RegE020 (cAlias, cEntSai, aCmpAntSFT, aPartDoc, aTotaliza, nRelacDoc, cChv0450, cEspecie, aRegE025, cSituaDoc, lAchouSE4, aTotalISS,cCodCOP,aWizard, lIss, lConjugada)				
					EndIf				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³SOMENTE MODELOS:                               ³
					//³06 - NOTA FISCAL/CONTA DE ENERGIA ELETRICA     ³
					//³21 - NOTA FISCAL DE SERVICO DE COMUNICACAO     ³
					//³22 - NOTA FISCAL DE SERVICO DE TELECOMUNICACAO ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
					If (cEspecie$"06#21#22") .Or. lEnergia 
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO E100 - MESTRE DE NOTA FISCAL CONTA DE ENERGIA ELETRICA (MODELO 06), COMUNICACAO (MODELO 21) E TELECOMUNICACAO (MODELO 22)³
						//³REGISTRO E105 - REGISTRO ANALITICO POR CFOP DOS DOCUMENTOS (MODELOS 06, 21 E 22)                                                  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						E100E105 (cAlias, cEntSai, aCmpAntSFT, aPartDoc, aTotaliza, nRelacDoc, cChv0450, cEspecie, aRegE105, cSituaDoc, lAchouSFU, lAchouSFX, aTotalISS,cCodCOP)
					EndIf	
				EndIf
				
				nContDoc++   	        
				 	  		
			EndDo	//ENDDO da NF
						
		Next nTpMov // FOR DE aTpMov
	
	EndIf
	
	SM0->(DbSkip ())
	
Next (nForFilial)

RestArea (aAreaSM0)
cFilAnt := SM0->M0_CODFIL

IncProc("Gerando registros de apuração..." + Chr(13) + Chr(10) + STR0050 + cFilAnt)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³REGISTRO E060 - LANCAMENTO  - REDUCAO Z/ICMS         ³
//³REGISTRO E065 - DETALHE     - VALORES PARCIAIS       ³
//³REGISTRO E080 - LANCAMENTO  - MAPA RESUMO DE ecf/ICMS³
//³REGISTRO E085 - DETALHE     - VALORES PARCIAIS       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegE060(aRegE060,aRegE065,dDataDe,dDataAte,cAlias,cChv0450,aWizard)
RegE080(aRegE080,aRegE085,dDataDe,dDataAte,cAlias,cChv0450,aWizard)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO 0150 - TABELA DE CADASTRO DE PARTICIPANTE ³
//|GRAVACAO - REGISTRO 0175 - ENDERECO DO PARTICIPANTE           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
R150R175 (cAlias)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gravacao do REGISTRO 0400 - TABELA DE NATUREZA DA OPERACAO/PRESTACAO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GrvRegSef (cAlias,, aReg0400)  
                                        
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO E050 - REGISTRO MESTRE DE NOTA FISCAL DE VENDA A CONSUMIDOR (MODELO 02)³
//³GRAVACAO - REGISTRO E055 - REGISTRO ANALITICO DO DOCUMENTO (MODELO 02)                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GrRegDep (cAlias, aRegE050, aRegE055)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO E120                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aRegE120) > 0
	GrvRegSef (cAlias,, aRegE120)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO E300 - PERIODO DA APURACAO DO ICMS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aRegE310)>0 .OR. ( ( Len( aRegE080 ) > 0  ) .AND. Len( aRegE310 ) == 0 )
	RegE300 (cAlias, dDataDe, dDataAte)	
EndIf 
    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO E305 -  MAPA RESUMO DE OPERACOES                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Chamo novamento o RegE305 pata certificar que todos os dias do período selecionado foram gerados. 
If Len(aRegE305) > 0
	RegE305 (cAliasSFT, cEntSai, @aRegE305, cEspecie, cSituaDoc, aCmpAntSFT, lIss, aTotalISS,cCodCOP,aWizard, .T.)
	GrvRegSef (cAlias,,aRegE305)  
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO E310 - CONSOLIDACAO DOS VALORES DE ICMS POR CFOP       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aRegE310) > 0
	GrvRegSef (cAlias,, aRegE310)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO E320 - TOTALIZACAO DOS VALORES POR UNIDADE DE FEDERACAO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GrvRegSef (cAlias,, aRegE320)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO E330 - TOTALIZACAO DOS VALORES DE ENTRADAS E SAIDAS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GrvRegSef (cAlias,,aRegE330)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO E340 - APURACAO DO ICMS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (Len (aRegE310)>0)
	//adicionado tratamento, pois como foi adicionado um if lá em cima limpando a variavel, se chegar aqui em branco irá duplicar a chave
	//por este motivo aqui a variavel é realimentada com o valor que esta no nchv450, pois dentro há o tratamento para +1
	If Empty(cChv0450)
		cChv0450 := StrZero(nChv0450,9)
	EndIf
	E340E360 (cAlias, dDataAte, cNrLivro, nAcImport, nAcRetInter, nDbCompIcm, nCrCompIcm, @aLog,nAcRetEsta,nAcCredTerc,nAcCredProp,aPartDoc,@cChv0450)
	if Val(cChv0450)!=nChv0450
		nChv0450:=Val(cChv0450)
	EndIf
EndIf      

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO E360 - APURACAO DO ICMS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (Len (aRegE310)>0)
	RegE360(aRegE360,cAlias,dDataDe,dDataAte,cChv0450,nRelacDoc)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO E540 - APURACAO DO IPI ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (Len (aRegE520)>0)
	RegE540 (cAlias, dDataAte, cNrLivro, dDataDe, cChv0450)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO E500 - PERIODO DA APURACAO DO IPI ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (Len (aRegE520)>0)
	RegE500 (cAlias, dDataDe, dDataAte)	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³REGISTRO E560 - OBRIGACOES DO IPI A RECOLHER³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (Len (aRegE520)>0)
	RegE560(cAlias,aRegE560,dDataDe,dDataAte,cChv0450)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO E520 - CONSOLIDACAO DOS VALORES DE IPI POR CFOP E CODIGO DE TRIBUTACAO DO IPI³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GrvRegSef (cAlias,, aRegE520) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO E525 - TOTALIZACAO DAS ENTRADAS E SAÍDAS DO IPI³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GrvRegSef (cAlias,, aRegE525)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO E560 - OBRIGACOES DO IPI A RECOLHER³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GrvRegSef (cAlias,, aRegE560) 
//GRAVAÇÃO DO REGISTRO 0455
GrvRegSef (cAlias, 0, aReg0455)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³eDoc      ³ Autor ³Erick G. Dias          ³ Data ³ 21.10.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±	GERACAO DO LAYOUT EDOC_EXTRATO           							   ±±	
±±	BLOCOS QUE SERAO GERADOS: BLOCO 0, BLOCO C E BLOCO 9				   ±±	
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±   
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function eDoc(aLisFil,cAlias,aWizard,cAliasSFT,lEnd)
Local	aAreaSM0		:=	SM0->(GetArea())
Local	dDataDe			:=	SToD(aWizard[1][1])
Local	dDataAte		:=	SToD(aWizard[1][2])
Local	aPartDoc		:=	{}
Local	aReg0400		:=	{}
Local	cAlsSF			:=	""
Local	cAlsSD			:=	""
Local	cAlsSA			:=	""
Local	cEntSai			:=	""
Local	aTotaliza		:=	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
Local	aTotalISS		:=	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
Local	cEspecie		:=	""
Local	nRelacDoc		:=	0
Local	aCmpAntSFT		:=	{}
Local	aObs			:=	{}
Local	nX				:=	0
Local 	nItem			:=	0
Local	cObs			:=	""
Local	cSituaDoc		:=	""
Local	aLeis			:=	{}
Local	nAcImport		:=	0
Local   nAcRetEsta      :=  0   // ICMS substituto pelas saidas para o Estado.
Local	nAcRetInter		:=	0   // ICMS substituto pelas saidas para outros Estados.
Local	nDbCompIcm		:=	0
Local	nCrCompIcm		:=	0
Local	nAcCredTerc		:=	0
Local	nAcCredProp		:=	0
Local   nChv0450        :=  0 
Local   nItemNF         :=  0    
Local 	nItemC300       :=  0
Local	cCmpCondP		:=	""
Local	lAchouSFU		:=	.F.
Local	lAchouSFX		:=	.F.
Local	lAchouSE4		:=	.T.
Local	lCompIcm		:=	.F.
Local   lCompFre		:=  .F.
Local	lIss			:=	.F.
Local	lIcms			:=	.F.
Local   lGrava          :=  .F.
Local 	lGravac560      :=  .F.
Local   lGrvFil         :=  .F. 
Local   lGrvFiC560      :=  .F.    
Local	cCmpFrete		:=	0
Local	cRecIss			:=	""
Local	cCmpRecIss		:=	""
Local	cClasFis		:=	""
Local	cLancam			:=	""
Local	cChaveF3		:=	"" 
Local	cChv0450		:=	"" 
Local   aRegC020        :=  {}
Local	aRegC040		:=	{} 
Local	aRegC300		:=	{} 
Local	aRegC310		:=	{} 
Local	aRegC550		:=	{} 
Local	aRegC560		:=	{} 
Local	aRegC600		:=	{} 
Local	aRegC605		:=	{} 
Local	aRegC610		:=	{} 
Local	aRegC615		:=	{} 
Local   aReg0200        :=  {}
Local	cEspAux			:=	""
Local	cCfps			:=	""
Local	cCmpLocal		:=	""
Local	cCmpLtCtl		:=	""
Local	cCmpNLote		:=	""
Local	lIssRet			:=	.F.
Local	cCmpVlAcr		:=	"" 
Local	aLog			:=	{}
Local	aConjugada		:=	{.F.,.F.}
Local   cEspeNFS        := " "
Local   cCop            :=""    
Local   cPdv            := ""
Local   cCSTICM         := ""
Local   cCSTISS         := ""
Local   cCodSef         := ""
Local   cCodCOP         := ""
Local 	nFilial			:= 0
Local 	nForFilial		:= 0
Local 	nTpMov 			:= 0
Local 	aTpMov 			:= {'E','S'}
Local 	cCmpRecSA		:= ""
Local 	nContDoc 		:= 0
Local 	cAlsSB1 		:= "SB1"
Local 	aReg0455 		:= {}
Local 	aReg0205		:=	{}
Local 	nI				:= 0
Local 	nJ				:= 0
Local 	nPos			:= 0
Local 	nPosApLV 		:= 0
Local 	aReg  			:= {}
Local 	cMV_SEFELE		:= SuperGetMv("MV_SEFELE",.F.,'')

Default	aLisFil			:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO 0000 - ABERTURA DO ARQUIVO DIGITAL E IDENTIFICACAO DO CONTRIBUINTE³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Reg0000 (aWizard, cAlias, dDataDe, dDataAte)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO 0005 - DADOS COMPLEMENTARES DO CONTRIBUINTE³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Reg0005 (aWizard, cAlias)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO 0030 - PERFIL CONTRIBUINTE  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Reg0030 (aWizard, cAlias)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO 0100 - DADOS DO CONTABILISTA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Reg0100 (aWizard, cAlias)

DbSelectArea ("SM0")
                                                                        
For nForFilial := 1 To Len( aLisFil ) 

	If aLisFil [ nForFilial, 1 ]
  	   
  		cFilAnt := aLisFil[nForFilial][2]
  		SM0->(DbSeek (cEmpAnt+cFilAnt, .T.))
  		
		For nTpMov := 1 to Len(aTpMov)
		
			IncProc("Consultando dados...")
			
			nContDoc := 0
			cAliasSFT := SelSFT(dDataDe, dDataAte, cNrLivro, aTpMov[nTpMov])
			
			//DbSelectArea (cAliasSFT)
			//ProcRegua ((cAliasSFT)->(RecCount ()))
			
			Do While !(cAliasSFT)->(Eof ())
				
				If Interrupcao(@lEnd)
					Exit
				EndIf		
			
				// Controle para executar menos vezes o comando IncProc.
				If Mod(nContDoc, 500) == 0
					IncProc("Processando Notas (" + aTpMov[nTpMov] + ")..." + StrZero(nContDoc,6) + Chr(13) + Chr(10) + STR0050 + cFilAnt)
				EndIf
							
				cPdv            := (cAliasSFT)->FT_PDV
				cLancam			:= AllTrim((cAliasSFT)->FT_CONTA)
				cEspecie		:=	cEspAux	:=	AModNot ((cAliasSFT)->FT_ESPECIE)		//Modelo NF
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³FT_PDV somente estarah alimentado quando se referir a nota fiscais de saida ³
				//³   geradas pelo SIGALOJA.                                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty((cAliasSFT)->FT_PDV) .AND. AllTrim((cAliasSFT)->FT_ESPECIE)$"CF"
					cEspecie	:=	"2D"
					cEspAux		:=	"2D"
				EndIf
				
				cChaveF3 := xFilial ("SF3")+DToS ((cAliasSFT)->FT_ENTRADA)+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA
				cCodSef := ""

				If SEFIISeek("SF3",1,cChaveF3,Iif(lTop,(cAliasSFT)->SF3RECNO,0))
					cCodSef := Alltrim(SF3->F3_CODRSEF)
				EndIf

				// Conforme Portaria SF n° 190/2011, art. 18, III no EDOC não devem ir as NF Inutilizadas
				cSituaDoc	:=	RetSitDoc((cAliasSFT)->FT_TIPO,cAliasSFT,cCodSef)
				IF (cSituaDoc$"81")
					(cAliasSFT)->(DbSkip())
					Loop
				Endif
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³SOMENTE MODELOS:                               ³
				//³01 - NOTA FISCAL NORMAL                        ³
				//³02 - NOTA FISCAL DE VENDA A CONSUMIDOR FINAL   ³
				//³03 - NOTA FISCAL DE SERVICO                    ³
				//³04 - NOTA FISCAL PRODUTOR                      ³
				//³06 - NOTA FISCAL/CONTA DE ENERGIA ELETRICA     ³
				//³07 - NOTA FISCAL SERVICO DE TRANSPORTE         ³
				//³08 - CONHECIMENTO DE TRANSPORTE RODOVIARIO     ³
				//³09 - CONHECIMENTO DE TRANSPORTE AQUAVIARIO     ³
				//³10 - CONHECIMENTO DE TRANSPORTE AEREO          ³
				//³11 - CONHECIMENTO DE TRANSPORTE FERROVIARIO    ³
				//³21 - NOTA FISCAL DE SERVICO DE COMUNICACAO     ³
				//³22 - NOTA FISCAL DE SERVICO DE TELECOMUNICACAO ³
				//³55 - NOTA FISCAL ELETRONICA                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !(cEspecie$"01#02#2D#04#55#1B")
					(cAliasSFT)->(DbSkip ())
					Loop
				EndIf
				
				//TRATAMENTO PARA NÃO CONSIDERAR NO REGISTRO C020/C300 MODELO 55, QUANDO AS OPERAÇÕES FOREM FEITA COM CFOP PARA ENERGIA ELETRICA     
				IF ((cEspecie$"55") .And. Alltrim((cAliasSFT)->FT_CFOP) $ cMV_SEFELE)
					(cAliasSFT)->(DbSkip ())
					Loop
				Endif

				//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Inicializacao de variaveis utilizadas no processamento ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Determina o Alias para as Tabelas SF1/SF2 e SD1/SD2.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cCop            := ""
				aRegC020        :=  {}
				aRegC040		:=	{}
				aRegC300		:=	{}
				aRegC310		:=	{}
				aRegC550		:=	{}
				aRegC560		:=	{}
				aRegC600		:=	{}
				aRegC610		:=	{}
				aRegC615		:=	{}
				cEntSai			:=	Iif ("E"$(cAliasSFT)->FT_TIPOMOV, "1", "2")
				cAlsSF			:=	"SF"+cEntSai	//Determina o Alias para as Tabelas SF1/SF2
				cAlsSD			:=	"SD"+cEntSai	//Determina o Alias para as Tabelas SD1/SD2
				cAlsSA			:=	"SA"+Iif ((cEntSai=="1" .And. !(cAliasSFT)->FT_TIPO$"BD") .or.;
				(cEntSai=="2" .And. (cAliasSFT)->FT_TIPO$"BD"), "2", "1")	//Determina o Alias para as Tabelas SA1/SA2
				//   1  2  3  4  5   6  7  8  9  10 11 12 13 14 15 16  17 18 19 20 21 22 23 24 25
				aTotaliza		:=	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
				//   1  2  3  4  5   6  7  8  9  10 11 12 13 14 15 16  17 18 19 20 21 22 23 24 25
				aTotalISS		:=	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
				nRelacDoc++		//Utilizado para relacionar os documentos fiscais aos seus elementos inferiores/dependentes
				cObs			:=	""
				nItem			:=	0
				nItemNF         :=  0
				nItemC300  		:=  0		
				lAchouSFU		:=	.F.
				lAchouSFX		:=	.F.
				lAchouSE4		:=	.F.
				lCompIcm		:=	.F.
				lCompFre		:=  .F.
				nAcImport		+=	Iif (Left ((cAliasSFT)->FT_CFOP, 1)=="3", (cAliasSFT)->FT_VALICM, 0)
				nAcCredTerc	+=	Iif ("E"$(cAliasSFT)->FT_TIPOMOV .And. Empty((cAliasSFT)->FT_FORMUL), (cAliasSFT)->FT_ICMSRET, 0)
				nAcCredProp	+=	Iif ("E"$(cAliasSFT)->FT_TIPOMOV .And. !Empty((cAliasSFT)->FT_FORMUL), (cAliasSFT)->FT_ICMSRET, 0)
				nAcRetEsta		+=	Iif (Left ((cAliasSFT)->FT_CFOP, 1)=="5", (cAliasSFT)->FT_ICMSRET, 0)
				nAcRetInter	+=	Iif (Left ((cAliasSFT)->FT_CFOP, 1)=="6", (cAliasSFT)->FT_ICMSRET, 0)
				cCfps			:=	""
				
				aCmpAntSFT		:=	{(cAliasSFT)->FT_NFISCAL,;		//01
									(cAliasSFT)->FT_SERIE,;			//02
									(cAliasSFT)->FT_CLIEFOR,;		//03
									(cAliasSFT)->FT_LOJA,;			//04
									(cAliasSFT)->FT_ENTRADA,;		//05
									(cAliasSFT)->FT_EMISSAO,;		//06
									(cAliasSFT)->FT_DTCANC,;		//07
									(cAliasSFT)->FT_FORMUL,;		//08
									(cAliasSFT)->FT_CFOP,;			//09
									cLancam,;						//10 (cAliasSFT)->FT_CONTA
									(cAliasSFT)->FT_ALIQICM,;		//11
									(cAliasSFT)->FT_PDV,;			//12
									(cAliasSFT)->FT_BASEICM,;		//13
									(cAliasSFT)->FT_CLASFIS,;		//14
									(cAliasSFT)->FT_VALICM,;		//15
									(cAliasSFT)->FT_ISENICM,;		//16
									(cAliasSFT)->FT_OUTRICM,;		//17
									(cAliasSFT)->FT_ICMSRET,;       //18
									(cAliasSFT)->FT_TIPO,;   		//19  TIPO
									(cAliasSFT)->FT_CHVNFE,;		//20 Chave
									(cAliasSFT)->FT_OBSERV,; 		//21 OBSERV
									(cAliasSFT)->FT_FILIAL} 		//22 FILIAL
									
				cCmpCondP		:=	cAlsSF+"->"+SubStr (cAlsSF, 2, 2)+"_COND"
				cCmpFrete		:=	cAlsSF+"->"+SubStr (cAlsSF, 2, 2)+"_FRETE"
				cCmpRecIss		:=	cAlsSA+"->"+SubStr (cAlsSA, 2, 2)+"_RECISS"
				cCmpTes			:=	cAlsSD+"->"+SubStr (cAlsSD, 2, 2)+"_TES"
				cCmpLocal		:=	cAlsSD+"->"+SubStr (cAlsSD, 2, 2)+"_LOCAL"
				cCmpLtCtl		:=	cAlsSD+"->"+SubStr (cAlsSD, 2, 2)+"_LOTECTL"
				cCmpNLote		:=	cAlsSD+"->"+SubStr (cAlsSD, 2, 2)+"_NUMLOTE"
				cCmpVlAcr		:=	cAlsSD+"->"+SubStr (cAlsSD, 2, 2)+"_VALACRS"
				cCmpRecSA    	:= cAlsSA + "RECNO"
				
				cRecIss			:=	""
				
				//Quando a NF de Entrada for formulario proprio o validador exige que os dados do remente.
				lSm0		:=	Iif((cAliasSFT)->FT_FORMUL == "S" .And. cEntSai == "1", .T., .F.) .Or. ;
								Iif((cAliasSFT)->FT_FORMUL == "S" .And. cEntSai == "2" .And. (cAliasSFT)->FT_TIPO=="B" .And. (cAliasSFT)->FT_ESTADO=="EX" , .T., .F.)
								
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Posicionando tabelas³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				SEFIISeek(cAlsSA,,xFilial(cAlsSA)+(cAliasSFT)->(FT_CLIEFOR+FT_LOJA),Iif(lTop,(cAliasSFT)->&(cCmpRecSA),0))
				SEFIISeek(cAlsSF,,xFilial(cAlsSF)+(cAliasSFT)->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA),Iif(lTop,(cAliasSFT)->SFRECNO,0))
				lAchouSE4	:=	SEFIISeek("SE4",1,xFilial("SE4")+&(cCmpCondP),IIf(lTop,(cAliasSFT)->SE4RECNO,0))
				
				lCompIcm	:=	( &(cAlsSF+"->"+SubStr (cAlsSF, 2, 2)+"_TIPO") == "I" ) // Indica se NF de complemento de ICMS
				lCompFre	:=	( &(cAlsSF+"->"+SubStr (cAlsSF, 2, 2)+"_TIPO") == "C" ) // Indica se NF de complemento de Frete
						
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Processo todas as observacoes para o documento fiscal contidas na tabela SF3 (F3_OBSERV)³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !cEspecie$"02/2D" .Or. !aCmpAntSFT[19]$"F"	//O registro de observacao nao deve ser gerado para consumidor final, inclusive cupom fiscal
					aObs	:=	LivrObs (cAliasSFT, Val (cEntSai), 65536, @aLeis, cChaveF3,lCompFre)
					For nX := 1 To Len (aObs)
						cObs	+=	aObs[nX]+", "
					Next (nX)
				EndIf
				
				If AliasIndic ("SFU")
					//Informacoes complementares das NF de Energia Eletrica
					lAchouSFU	:=	SFU->(DbSeek (xFilial ("SFU")+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA+(cAliasSFT)->FT_ESPECIE))
				EndIf
				
				If AliasIndic ("SFX")
					//Informacoes complementares das NF de Comunicacao/Telecomunicacao
					lAchouSFX	:=	SFX->(DbSeek (xFilial ("SFX")+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA+(cAliasSFT)->FT_ESPECIE))
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Segundo instrucoes da SEF-DF, as notas de complemento de ICMS deverao ser lancadas no     |
				//³ registro de ajustes da apuracao de ICMS (E340)                                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lCompIcm
					If "S"$(cAliasSFT)->FT_TIPOMOV
						nDbCompIcm	+=	(cAliasSFT)->FT_VALICM
					Else
						nCrCompIcm	+=	(cAliasSFT)->FT_VALICM
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Retornando dados do participante em um array³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aPartDoc	:=	InfPartDoc (cAlsSA, Nil,cAliasSFT)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³SOMENTE MODELOS:                               ³
				//³01 - NOTA FISCAL NORMAL                        ³
				//³03 - NOTA FISCAL DE SERVICO                    ³
				//³04 - NOTA FISCAL PRODUTOR                      ³
				//³06 - NOTA FISCAL/CONTA DE ENERGIA ELETRICA     ³
				//³07 - NOTA FISCAL SERVICO DE TRANSPORTE         ³
				//³08 - CONHECIMENTO DE TRANSPORTE RODOVIARIO     ³
				//³09 - CONHECIMENTO DE TRANSPORTE AQUAVIARIO     ³
				//³10 - CONHECIMENTO DE TRANSPORTE AEREO          ³
				//³11 - CONHECIMENTO DE TRANSPORTE FERROVIARIO    ³
				//³21 - NOTA FISCAL DE SERVICO DE COMUNICACAO     ³
				//³22 - NOTA FISCAL DE SERVICO DE TELECOMUNICACAO ³
				//³55 - NOTA FISCAL ELETRONICA                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³REGISTRO 0150 - TABELA DE CADASTRO DE PARTICIPANTES³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cEspecie$"01#02#2D#04#55#1B"
					Reg0150 (aPartDoc,aWizard,cEspecie)
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Processando os itens do documento fiscal.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cChave	:=	(cAliasSFT)->FT_FILIAL+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA
				cChv0450:= ""
				
				If !Empty(cObs)
					nChv0450 += 1
					cChv0450 := StrZero(nChv0450,9)
				EndIf
				
				Do While !(cAliasSFT)->(Eof ()) .And.;
					cChave==(cAliasSFT)->FT_FILIAL+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA
					
					If Interrupcao(@lEnd)
						lEnd := .T.
						Exit
					EndIf	
							
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Inicializacao de variaveis utilizadas no processamento do item³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nItem += 1
					nItemNF += 1
					nItemC300 += 1
					cCodCOP := ""
					lIss := ((cAliasSFT)->FT_TIPO == "S")
					cEspeNFS :=  AllTrim((cAliasSFT)->FT_ESPECIE )
					cCfps  := Iif(Empty(cCfps), (cAliasSFT)->FT_CFPS, cCfps)
					cCSTICM := ""
					cCSTISS := ""
					lIssRet :=	.F.
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Posicionando tabelas de acordo com os itens dos documentos fiscais.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					
					SEFIISeek(cAlsSD,,xFilial(cAlsSD)+(cAliasSFT)->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_PRODUTO+FT_ITEM),IIf(lTop,(cAliasSFT)->SDRECNO,0))
					SEFIISeek("SB1",,xFilial("SB1")+(cAliasSFT)->FT_PRODUTO,IIf(lTop,(cAliasSFT)->SB1RECNO,0))

					If lTop
						cCodCOP := (cAliasSFT)->F4_COP
					Else
						If SEFIISeek("SF4",,xFilial("SF4") + &(cCmpTes))
							cCodCOP := SF4->F4_COP
						EndIf
					EndIf
					
					If Empty(cCodCOP)
						cCodCOP := RetCOP(@Alltrim((cAliasSFT)->FT_CFOP))
					EndIf
										
					cClasFis := RetCodCst(cAliasSFT, cAlsSA)
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³verifica se este item da nota eh um servico ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					
					If lIss
						cCSTISS := SF4->F4_CSTISS
						If !Empty ((cAliasSFT)->FT_RECISS)
							cRecIss		:=	(cAliasSFT)->FT_RECISS
						Else
							cRecIss		:=	&(cCmpRecIss)
						EndIf
						If (cEntSai=="1" .And. cRecIss$"2N") .Or.;
							(cEntSai=="2" .And. cRecIss$"1S")
							lIssRet		:=	.T.
						EndIf
					Else
						lIcms := .T.
						If !Empty((cAliasSFT)->FT_CLASFIS)
							cCSTICM := (cAliasSFT)->FT_CLASFIS
						Else
							cCSTICM := SB1->B1_ORIGEM + SF4->F4_SITTRIB
						EndIf
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³SOMENTE MODELOS:                               ³
					//³01 - NOTA FISCAL NORMAL                        ³
					//³02 - NOTA FISCAL DE VENDA A CONSUMIDOR FINAL   ³
					//³03 - NOTA FISCAL DE SERVICO                    ³
					//³04 - NOTA FISCAL PRODUTOR                      ³
					//³06 - NOTA FISCAL/CONTA DE ENERGIA ELETRICA     ³
					//³07 - NOTA FISCAL SERVICO DE TRANSPORTE         ³
					//³08 - CONHECIMENTO DE TRANSPORTE RODOVIARIO     ³
					//³09 - CONHECIMENTO DE TRANSPORTE AQUAVIARIO     ³
					//³10 - CONHECIMENTO DE TRANSPORTE AEREO          ³
					//³11 - CONHECIMENTO DE TRANSPORTE FERROVIARIO    ³
					//³21 - NOTA FISCAL DE SERVICO DE COMUNICACAO     ³
					//³22 - NOTA FISCAL DE SERVICO DE TELECOMUNICACAO ³
					//³55 - NOTA FISCAL ELETRONICA                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (cEspecie$"01#02#2D#04#55#1B")
						Reg0400 ((cAliasSFT)->FT_CFOP, @aReg0400,cCodCOP)
					EndIf
					
					If lIss // Se for servico
						aTotalISS[1]	+=	(cAliasSFT)->FT_VALCONT
						aTotalISS[2]	+=	(cAliasSFT)->FT_BASEICM
						aTotalISS[3]	+=	(cAliasSFT)->FT_VALICM
						aTotalISS[4]	+=	(cAliasSFT)->FT_BASERET
						aTotalISS[5]	+=	(cAliasSFT)->FT_ICMSRET
						aTotalISS[7]	+=	(cAliasSFT)->FT_ISENICM
						aTotalISS[6]	+=	(cAliasSFT)->FT_VALIPI
						aTotalISS[8]	+=	(cAliasSFT)->FT_QUANT
						aTotalISS[9]	+=	(cAliasSFT)->FT_DESCONT
						aTotalISS[10]	+=	(cAliasSFT)->FT_TOTAL
						aTotalISS[11]	+=	(cAliasSFT)->FT_FRETE
						aTotalISS[12]	+=	(cAliasSFT)->FT_SEGURO
						aTotalISS[13]	+=	(cAliasSFT)->FT_DESPESA
						aTotalISS[14]	+=	(cAliasSFT)->FT_OUTRICM
						aTotalISS[15]	+=	(cAliasSFT)->FT_BASEIPI
						aTotalISS[16]	+=	(cAliasSFT)->FT_ISENIPI
						aTotalISS[17]	+=	(cAliasSFT)->FT_OUTRIPI
						aTotalISS[18]	+=	(cAliasSFT)->FT_ICMSCOM
						aTotalISS[19]	+=	(cAliasSFT)->FT_BASEICM //	Base ISS
						aTotalISS[20]	+=	(cAliasSFT)->FT_VALICM	//	Vlr ISS
						aTotaliza[20]   +=  (cAliasSFT)->FT_VALICM	//	Vlr ISS no aTotaliza tbm
						If lIssRet
							aTotalISS[21]	+=	(cAliasSFT)->FT_BASEICM //	Base ISS RET
							aTotalISS[22]	+=	(cAliasSFT)->FT_VALICM	//	Vlr ISS RET
						EndIf
						aTotalISS[23]	+=	(cAliasSFT)->FT_ISENICM
						aTotalISS[24]	+=	(cAliasSFT)->FT_ISSSUB
						If cEntSai == "2" .And. cEspecie $ "2D"
							aTotalISS[25]	+=	&(cCmpVlAcr)
						Else
							aTotalISS[25]	:= 0
						EndIf
					Else
						aTotaliza[1]	+=	(cAliasSFT)->FT_VALCONT
						aTotaliza[2]	+=	(cAliasSFT)->FT_BASEICM
						aTotaliza[3]	+=	Round((cAliasSFT)->FT_VALICM,2)
						aTotaliza[4]	+=	(cAliasSFT)->FT_BASERET
						aTotaliza[5]	+=	(cAliasSFT)->FT_ICMSRET
						aTotaliza[6]	+=	(cAliasSFT)->FT_VALIPI
						//Quando configuro a TES para escriturar o Livro de ICMS/ST como OUTROS, na tabela SF3 o valor do campo
						//  F3_ICMSRET eh transportado para o campo F3_OUTRICM, ficando com os mesmos valores. Na tabela SFT, que
						//  possui o campo proprio FT_OUTRRET, recebe este valor deixando o campo FT_OUTRICM e FT_ICMSRET zerado.
						aTotaliza[7]	+=	(cAliasSFT)->FT_ISENICM+(cAliasSFT)->FT_ISENRET
						aTotaliza[8]	+=	(cAliasSFT)->FT_QUANT
						aTotaliza[9]	+=	(cAliasSFT)->FT_DESCONT
						aTotaliza[10]	+=	(cAliasSFT)->FT_TOTAL
						aTotaliza[11]	+=	(cAliasSFT)->FT_FRETE
						aTotaliza[12]	+=	(cAliasSFT)->FT_SEGURO
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Tratamento para nao levar valor negativo³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If (cAliasSFT)->(FT_DESPESA-(FT_SEGURO+FT_FRETE))>0
							aTotaliza[13]	+=	(cAliasSFT)->(FT_DESPESA-(FT_SEGURO+FT_FRETE))	//Totaliza as outras despesas do documento fiscal. Este tratamento se faz necessario porque FRETE e SEGURO incorporam o valor da despesa no sistema
						EndIf
						//Quando configuro a TES para escriturar o Livro de ICMS/ST como OUTROS, na tabela SF3 o valor do campo
						//  F3_ICMSRET eh transportado para o campo F3_OUTRICM, ficando com os mesmos valores. Na tabela SFT, que
						//  possui o campo proprio FT_OUTRRET, recebe este valor deixando o campo FT_OUTRICM e FT_ICMSRET zerado.
						aTotaliza[14]	+=	(cAliasSFT)->FT_OUTRICM+(cAliasSFT)->FT_OUTRRET
						aTotaliza[23]	+=	If("5405"$(cAliasSFT)->FT_CFOP,0,iif("41"$(cAliasSFT)->FT_CLASFIS,(cAliasSFT)->FT_OUTRICM+(cAliasSFT)->FT_OUTRRET,0))				
						aTotaliza[25]	+=	If("5405"$(cAliasSFT)->FT_CFOP,iif("40"$(cAliasSFT)->FT_CLASFIS,((cAliasSFT)->FT_ISENICM+(cAliasSFT)->FT_ISENRET),(cAliasSFT)->FT_OUTRICM+(cAliasSFT)->FT_OUTRRET),0)								
						aTotaliza[15]	+=	(cAliasSFT)->FT_BASEIPI
						aTotaliza[16]	+=	(cAliasSFT)->FT_ISENIPI
						aTotaliza[17]	+=	(cAliasSFT)->FT_OUTRIPI
						aTotaliza[18]	+=	(cAliasSFT)->FT_ICMSCOM
						If cEntSai == "2" .And. cEspecie $ "2D"
							aTotaliza[19]	+=	&(cCmpVlAcr)
						Else
							aTotaliza[19]	:= 0
						EndIf
						nItem++
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³MODELOS: 01 - NOTA FISCAL, 04 - NOTA FISCAL DE PRODUTOR E 55 - NOTA FISCAL ELETRONICA³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					IF (cEspecie$"01#04#55#1B")
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO C300 - ITENS DO DOCUMENTO³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !("CF/SERIE:" $ aCmpAntSFT[21])
							RegC300(cAliasSFT,@aRegC300,@aReg0200,@nItemC300,cCSTISS,cCSTICM,cAlsSB1,aWizard,@aReg0205)
						Endif
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO C310 - COMPLEMENTO DO ITEM -ISS³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lIss
							RegC310(aTotalISS,@aRegC310,(cAliasSFT)->FT_ALIQICM,cCSTISS)
						EndIf
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³REGISTRO C560 - INTES DO DOCUMENTO MODELO 02 - VENDA A CONSUMIDOR³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					IF (cEspecie$"02")
						RegC560(cAliasSFT,@aRegC560,@aReg0200,cCSTICM,cAlsSB1,aWizard,@aReg0205)
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³REGISTRO C610 - ITENS DO DOCUMENTO - CUPOM FISCAL³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					IF (cEspecie$"2D")
						RegC610(cAliasSFT,@aRegC610,@aReg0200,cCSTICM,@nItemNF,aWizard,@aReg0205)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO C615 - COMPLEMENTO DO ITEM -ISS³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lIss
							RegC615(aTotalISS,@aRegC615,(cAliasSFT)->FT_ALIQICM)
						EndIf
					EndIf
					(cAliasSFT)->(DbSkip ())
				EndDo	//ENDDO do item
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Este tratamento se dah devido a troca da especie quando for nota fiscal de servico ou nota fiscal conjugada.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cEspecie	:=	cEspAux
				
				If Interrupcao(@lEnd)
					Exit
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³SOMENTE MODELOS:                              ³
				//³01 - NOTA FISCAL NORMAL                       ³
				//³02 - NOTA FISCAL PRODUTOR                     ³
				//³03 - NOTA FISCAL DE SERVICOS                  ³
				//³04 - NOTA FISCAL DE VENDA A CONSUMIDOR FINAL  ³
				//³06 - NOTA FISCAL/CONTA DE ENERGIA ELETRICA    ³
				//³21 - NOTA FISCAL DE SERVICO DE COMUNICACAO    ³
				//³22 - NOTA FISCAL DE SERVICO DE TELECOMUNICACAO³
				//³55 - NOTA FISCAL ELETRONICA                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (cEspecie$"01#02#2D#04#55#1B")
					If aTotalISS[24]<>0 .And. Empty(cObs)
						cObs	:=	"ISS SUBEMPREITADA"
					EndIf
					IF (cEspecie$"01#04#55#1B")
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO C020 - NOTA FISCAL CODIGO 01, NOTA FISCAL PRODUTOR CODIGO 04, NOTA FISCAL ELETRONICA CODIGO 55³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						lGrava :=  .T.         //Somente sera gravado para os modelos 01/04/55, no outros casos, sera somente montado o array.
						lGrvFil := Iif(!("CF/SERIE:"$aCmpAntSFT[21]),RegC020(cEntSai,aPartDoc,cEspecie,cAlias,nRelacDoc,aCmpAntSFT,aTotaliza,@aRegC020,cChv0450,cSituaDoc,lAchouSE4,lGrava,aTotalIss,"0"$aWizard[1][11]),.F.)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO C040 - COMPLEMENTO DO DOCUMENTO DE ISS³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
						If aTotalISS[20] > 0 .And. lGrvFil .And. cEntSai == "2" //se tiver valor de ISS
							RegC040(cAlias,aTotalISS, @aRegC040,nRelacDoc)
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³GRAVA REGISTRO C300 - ITENS DO DOCUMENTO³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lGrvFil
							GrvRegSef (cAlias,nRelacDoc, aRegC300)
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³GRAVA REGISTRO C310 - COMPLEMENTO DO ITEM ISS³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If Len(aRegC310) > 0 .And. lGrvFil    
							GrvRegSef (cAlias,nRelacDoc, aRegC310)
						EndIf
					EndIf
					IF (cEspecie$"02")
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO C550 - NOTA FISCAL DE VENDA A CONSUMIDOR(CÓDIGO 02)³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						lGravac560 :=  .T.
						lGrvFiC560 := 	RegC550 (cEspecie, cAlias, nRelacDoc, aCmpAntSFT,aTotaliza, @aRegC550, cSituaDoc,lAchouSE4,cCodCOP,cChv0450,lGravac560)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³GRAVA REGISTRO C560 - ITENS DO DOCUMENTO³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lGrvFiC560
							GrvRegSef (cAlias,nRelacDoc, aRegC560)
						Endif
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³REGISTRO C600 - CUPOM FISCAL/ICMS³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (cEspecie$"2D")
						RegC600(cEspecie, cAlias, nRelacDoc, aCmpAntSFT,aTotaliza, @aRegC600, cPdv, cSituaDoc,cCodCOP,cCSTICM)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³GRAVA REGISTRO C605 - COMPLEMENTO DO DOCUMENTO - ISS³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If aTotalISS[20] > 0 //se tiver valor de ISS
							RegC605(cAlias,aTotalISS, aRegC605,nRelacDoc)
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³GRAVA REGISTRO C610 - ITENS DO DOCUMENTO³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						GrvRegSef (cAlias,nRelacDoc, aRegC610)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³GRAVA REGISTRO C615 - COMPLEMENTO DO ITEM - ISS³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						GrvRegSef (cAlias,nRelacDoc, aRegC615)
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Processanto geracao dos REGISTROS 0450, 0460 e 0465³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If  !Empty (cObs)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO 0450 - TABELA DE INFORMACOES COMPLEMENTARES/OBSERVACOES³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Reg0450 (cAlias, nRelacDoc, cObs, cChv0450)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO 0455 - NORMA REFERENCIADA³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Reg0455 (cAlias, nRelacDoc, aLeis,areg0455)
					Endif
					If !cEspecie$"02" .And. !(cSituaDoc$"90#80")
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO 0460 - DOCUMENTO DE ARREADACAO REFERENCIADO³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Reg0460 (aWizard, cAlias, dDataDe, dDataAte, nRelacDoc, aCmpAntSFT, aPartDoc, lSm0, cValToChar(nTpMov))
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO 0465 - DOCUMENTO FISCAL REFERENCIADO³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If ("CF/SERIE:" $ cObs) .Or. (aCmpAntSFT[19] $ "D/B/I/P/C")
							Reg0465 (cAlias, nRelacDoc, @aRegC020, cEntSai, @aPartDoc, aTotalISS, lSm0, aCmpAntSFT)
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO 0470 - CUPOM FISCAL REFERENCIADO³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If cEspecie$"02"
							Reg0470(cAlias,cEspecie,aCmpAntSFT, aTotaliza,cPdv,nRelacDoc)
						EndIf
						
					EndIf
					
				EndIf  
				
				nContDoc++
	
			EndDo	//ENDDO da NF

			#IFDEF TOP
				If (TcSrvType ()<>"AS/400")
					DbSelectArea (cAliasSFT)
					(cAliasSFT)->(dbclosearea())
				Else
			#ENDIF
				RetIndex("SFT")
			#IFDEF TOP
				EndIf
			#ENDIF

		Next nTpMov
	
	EndIf
	
	SM0->(dbSkip())
	
Next (nForFilial)

RestArea(aAreaSM0)  
cFilAnt := SM0->M0_CODFIL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO 0150 - TABELA DE CADASTRO DE PARTICIPANTE ³
//|GRAVACAO - REGISTRO 0175 - ENDERECO DO PARTICIPANTE           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
R150R175 (cAlias)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gravacao do REGISTRO 0200 - TABELA DE IDENTIFICACAO DOS ITENS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Len(aReg0200) > 0
	nI := 0
	nJ := 0
	For nI := 1 To Len(aReg0200)
		nPosApLV := aReg0200[nI,1]
		aReg := {}
		aAdd(aReg, {})
		nPos	:=	Len (aReg)
		For nJ := 2 To Len(aReg0200[nI])
			aAdd(aReg[nPos], aReg0200[nI,nJ])
		Next nJ
		GrvRegSef (cAlias,nPosApLV, aReg)
	Next nI
EndIf
//0205: CÓDIGO ANTERIOR DO ITEM
If Len(aReg0205) > 0
	nI := 0
	nJ := 0
	For nI := 1 To Len(aReg0205)
		nPosApLV := aReg0205[nI,1]
		aReg := {}
		aAdd(aReg, {})
		nPos	:=	Len (aReg)
		For nJ := 2 To Len(aReg0205[nI])
			aAdd(aReg[nPos], aReg0205[nI,nJ])
		Next nJ
		GrvRegSef (cAlias,nPosApLV, aReg)
	Next nI
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gravacao do REGISTRO 0400 - TABELA DE NATUREZA DA OPERACAO/PRESTACAO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GrvRegSef (cAlias,, aReg0400)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gravacao do REGISTRO 0455 - TABELA DE NATUREZA DA OPERACAO/PRESTACAO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GrvRegSef (cAlias,, aReg0455)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GIICMSG8

Geração do Arquivo SEF II - LFPD 07 - SEF_GI-ICMS (GIAF-GIAM-GIA)
Informações sobre o ECONÔMICO-FISCAIS, PRODEPE - 
Programa de Desenvolvimento do Estado de Pernambuco

Bloco 0 - ABERTURA, IDENTIFICAÇÃO E REFERÊNCIAS
Bloco G - INFORMAÇÕES ECONÔMICO-FISCAIS
Bloco 8 - INFORMAÇÕES COMPLEMENTARES DA SEFAZ/UF
Bloco 9 - CONTROLE E ENCERRAMENTO DO ARQUIVO DIGITAL

@author Jorge Souza
@since 09/12/2014
@version 11 
/*/
//-------------------------------------------------------------------
Static Function GIICMSG8(aLisFil,cAlias,aWizard,lEnd)

Local aAreaSM0		:= SM0->(GetArea())
Local dDataDe		:= SToD (aWizard[1][1])
Local dDataAte		:= SToD (aWizard[1][2])
Local nApuracao		:= GetSx1 (PadR("MTA951",10), "04", .T.)	//1-Decendial, 2-Quinzenal, 3-Mensal, 4-Semestral ou 5-Anual
Local nPeriodo		:= 1								//GetSx1 ("MTA951", "05", .T.)	//1-1., 2-2., 3-3.

Local aPartDoc		:= {}
Local aCmpAntSFT	:= {}
Local aObs			:= {}
Local aLeis			:= {}
Local aReg8525		:= {}
Local aReg8020		:= {}
Local aReg8030		:= {}
Local aReg8040		:= {}
Local aReg8110		:= {}
Local aReg8505		:= {}
Local aReg8510		:= {}
Local aReg8530		:= {}
Local aReg8535		:= {}
Local aReg8515		:= {}
Local aReg8540		:= {}
Local aReg8545		:= {}
Local aReg8550		:= {}
Local aReg8555		:= {}
Local aReg8560		:= {}
Local aReg8565		:= {}
Local aReg8580		:= {}
Local aReg8585		:= {}
Local aReg8590		:= {}
Local aRegG025		:= {}
Local aRegG050		:= {}
Local aRegG400		:= {}
Local aRegG410		:= {}
Local aRegG440		:= {}
Local aRegG450		:= {}
Local aRegG460		:= {}
Local aRegG030		:= {}
Local aReg8100		:= {}
Local aRegG020		:= {}
Local aLog			:= {}
Local aConjugada	:= {.F.,.F.}
Local aTotaliza		:= {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
Local aTotalISS		:= {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
Local aRegSubAP		:= {}
Local aReg8570		:= {}
Local aReg90 		:= {}
Local nRelacDoc		:= 0
Local nItem8535		:= 0
Local nX			:= 0
Local nItem			:= 0
Local nAcImport		:= 0
Local nAcRetEsta	:= 0 // ICMS substituto pelas saidas para o Estado.
Local nAcRetInter	:= 0 // ICMS substituto pelas saidas para outros Estados.
Local nDbCompIcm	:= 0
Local nCrCompIcm	:= 0
Local nAcCredTerc	:= 0
Local nAcCredProp	:= 0
Local cCmpFrete		:= 0
Local cPdv			:= 0
Local nFilial		:= 0
Local nForFilial	:= 0
Local nY			:= 0
Local nPosApLv		:= 0
Local nJ			:= 0
Local nI			:= 0
Local i				:= 0
Local lAchouSE4		:= .T.
Local lCompIcm		:= .F.
Local lCompFre		:= .F.
Local lIss			:= .F.
Local lIcms			:= .F.
Local lIssRet		:= .F.
Local lSm0			:= .F.
Local lGrava		:= .F.
Local cAlsSF		:= ""
Local cAlsSD		:= ""
Local cAlsSA		:= ""
Local cEntSai		:= ""
Local cEspecie		:= ""
Local cObs			:= ""
Local cSituaDoc		:= ""
Local cCmpCondP		:= ""
Local cRecIss		:= ""
Local cClasFis		:= ""
Local cLancam		:= ""
Local cChaveF3		:= ""
Local cEspAux		:= ""
Local cCfps			:= ""
Local cCmpLocal		:= ""
Local cCmpLtCtl		:= ""
Local cCmpNLote		:= ""
Local cCmpVlAcr		:= ""
Local cEspeNFS		:= ""
Local cCodSef		:= ""
Local cCodCOP		:= ""
Local cCmpRecIss	:= ""
Local cPosApLV		:= ""
Local cPosALiv		:= ""
Local cNrLvSub		:= ""
Local lContinua		:= .F.
Local aProAPFil		:= {}
Local aProAPST		:= {}
Local nTpMov		:= 0
Local aTpMov		:= {'E','S'}
Local cCmpRecSA		:= ""
Local nContDoc		:= 0
Local cAliasSFT		:= ""
Local cChaveVld		:= ""
Local aMVPROPERC := &(SuperGetMv("MV_PROPERC",.F.,'{}'))

Private cNrLivro	:= AllTrim(aWizard[1][5])
Private aBloco8		:= {0,0,0,0,0,0,0,0,0,0,0,0,0,0}
Private aProdImpo	:= {}
Private nFreteCIF	:= 0
Private nFreteFOB	:= 0
Private aPro8525	:= {}

Default aLisFil		:={}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO 0000 - ABERTURA DO ARQUIVO DIGITAL E IDENTIFICACAO DO CONTRIBUINTE³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Reg0000 (aWizard, cAlias, dDataDe, dDataAte)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO 0005 - DADOS COMPLEMENTARES DO CONTRIBUINTE³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Reg0005 (aWizard, cAlias)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³REGISTRO 0025 - BENEFICIO FISCAL³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Reg0025(cAlias)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO 0030 - PERFIL CONTRIBUINTE  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Reg0030 (aWizard, cAlias)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO 0100 - DADOS DO CONTABILISTA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Reg0100 (aWizard, cAlias)

aRegSubAP := SubAp(aWizard)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Leio o arquivo de apuracao ICMS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aRegSubAP) > 0
	For i=1 to Len(aRegSubAP)
		aApICM	:=	FisApur ("IC", Year (dDataAte), Month (dDataAte), nApuracao, nPeriodo, aRegSubAP[i][1], .F., {}, 1, .F., "")
		If Len(aApICM)>0
			aAdd(aProAPFil, {})
			nPos := Len(aProAPFil)
			aAdd (aProAPFil[nPos], aRegSubAP[i][1])
			aAdd (aProAPFil[nPos], aApICM)
		Endif
	Next i
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Leio o arquivo de apuracao ICMS/ST³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If Len(aRegSubAP) > 0
	For i=1 to Len(aRegSubAP)
		aApST	:=	FisApur ("ST", Year (dDataAte), Month (dDataAte), nApuracao, nPeriodo, aRegSubAP[i][1], .F., {}, 1, .F., "")
		If Len(aApST)>0
			aAdd(aProAPST, {})
			nPos := Len(aProAPST)
			aAdd (aProAPST[nPos], aRegSubAP[i][1])
			aAdd (aProAPST[nPos], aApST)
		Endif
	Next i
Endif

DbSelectArea ("SM0")

For nForFilial := 1 To Len( aLisFil )

	If aLisFil [ nForFilial, 1 ]

		cFilAnt := aLisFil[nForFilial][2]
		SM0->(DbSeek (cEmpAnt+cFilAnt, .T.))

		For nTpMov := 1 to Len(aTpMov)

			IncProc("Consultando dados...")
			nContDoc := 0
			if len(cAliasSFT)>0
				(cAliasSFT)->(dbclosearea())
				cAliasSFT:=''
			endif
			cAliasSFT := SelSFT(dDataDe, dDataAte, cNrLivro, aTpMov[nTpMov])
			cChaveVld := ""

			Do While !(cAliasSFT)->(Eof ()) //LOOP DAS NOTAS

				If Interrupcao(@lEnd)
					Exit
				EndIf

				// Controle para executar menos vezes o comando IncProc.
				If Mod(nContDoc, 500) == 0
					IncProc("Processando Notas (" + aTpMov[nTpMov] + ")..." + StrZero(nContDoc,6) + Chr(13) + Chr(10) + STR0050 + cFilAnt)
				EndIf

				//Filtra o documento se houve calculo de prodepe em algum item
				If !(cChaveVld == (cAliasSFT)->(FT_NFISCAL)+(cAliasSFT)->(FT_SERIE)+(cAliasSFT)->(FT_CLIEFOR)+(cAliasSFT)->(FT_LOJA))
					lContinua := .T. //VldSFT(cAliasSFT) valida todas notas que estão no livro de prodepe
				Endif

				cChaveVld := (cAliasSFT)->(FT_NFISCAL)+(cAliasSFT)->(FT_SERIE)+(cAliasSFT)->(FT_CLIEFOR)+(cAliasSFT)->(FT_LOJA)

				If !lContinua
					(cAliasSFT)->(DbSkip ())
					Loop
				Endif

				// Tratamento para a Especie de cada documento fiscal
				cPdv := (cAliasSFT)->FT_PDV //NUMERO DO CAIXA
				cLancam := AllTrim((cAliasSFT)->FT_CONTA)
				cEspecie := cEspAux := AModNot ((cAliasSFT)->FT_ESPECIE)		//Modelo NF

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³FT_PDV somente estarah alimentado quando se referir a nota fiscais de saida ³
				//³   geradas pelo SIGALOJA.                                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty((cAliasSFT)->FT_PDV) .AND. AllTrim((cAliasSFT)->FT_ESPECIE)$"CF"
					cEspecie := "2D"
					cEspAux := "2D"
				EndIf

				cChaveF3 := xFilial ("SF3")+DToS ((cAliasSFT)->FT_ENTRADA)+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA
				cCodSef  := ""

				If SEFIISeek("SF3",1,cChaveF3,Iif(lTop,(cAliasSFT)->SF3RECNO,0))
					cCodSef := Alltrim(SF3->F3_CODRSEF)
				EndIf


				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³SOMENTE MODELOS:                               ³
				//³01 - NOTA FISCAL NORMAL                        ³
				//³02 - NOTA FISCAL DE VENDA A CONSUMIDOR FINAL   ³
				//³03 - NOTA FISCAL DE SERVICO                    ³
				//³04 - NOTA FISCAL PRODUTOR                      ³
				//³06 - NOTA FISCAL/CONTA DE ENERGIA ELETRICA     ³
				//³07 - NOTA FISCAL SERVICO DE TRANSPORTE         ³
				//³08 - CONHECIMENTO DE TRANSPORTE RODOVIARIO     ³
				//³09 - CONHECIMENTO DE TRANSPORTE AQUAVIARIO     ³
				//³10 - CONHECIMENTO DE TRANSPORTE AEREO          ³
				//³11 - CONHECIMENTO DE TRANSPORTE FERROVIARIO    ³
				//³21 - NOTA FISCAL DE SERVICO DE COMUNICACAO     ³
				//³22 - NOTA FISCAL DE SERVICO DE TELECOMUNICACAO ³
				//³55 - NOTA FISCAL ELETRONICA                    ³
				//³57 - CONHECIMENTO DE TRANSPORTE ELETRONICO     ³
				//³67 - CONHECIMENTO DE TRANSPORTE ELETRONICO - OS³
				//³63 - BILHETE DE PASSAGEM ELETRÔNICO			  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !(cEspecie$"01#02#03#04#06#07#08#09#10#11#21#22#2D#55#57#1B#67#63")
					(cAliasSFT)->(DbSkip ())
					Loop
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Para as notas fiscais de transportes vindas do TMS sempre deverah      ³
				//³   haver um DT6 correspondente, caso nao haja, montar o arquivo de     ³
				//³   log e saltar para a proxima nota. Instrucoes passadas pela equipe do³
				//³   TMS.                                                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cEspecie$"#07#08#09#10#11#" .And. "S"$(cAliasSFT)->FT_TIPOMOV .And. IntTms()
					If !DT6->(DbSeek (xFilial ("DT6")+(cAliasSFT)->(FT_FILIAL+FT_NFISCAL+FT_SERIE)))			
						(cAliasSFT)->(DbSkip ())
						Loop
					EndIf
				EndIf

				//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Inicializacao de variaveis utilizadas no processamento ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Determina o Alias para as Tabelas SF1/SF2 e SD1/SD2.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cEntSai		:=	Iif ("E"$(cAliasSFT)->FT_TIPOMOV, "1", "2")
				cAlsSF			:=	"SF"+cEntSai	//Determina o Alias para as Tabelas SF1/SF2
				cAlsSD			:=	"SD"+cEntSai	//Determina o Alias para as Tabelas SD1/SD2
				cAlsSA			:=	"SA"+Iif ((cEntSai=="1" .And. !(cAliasSFT)->FT_TIPO$"BD") .Or. (cEntSai=="2" .And. (cAliasSFT)->FT_TIPO$"BD"), "2", "1")	//Determina o Alias para as Tabelas SA1/SA2
								//   1  2  3  4  5   6  7  8  9  10 11 12 13 14 15 16  17 18 19 20 21 22 23 24 25
				aTotaliza		:=	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
								//   1  2  3  4  5   6  7  8  9  10 11 12 13 14 15 16  17 18 19 20 21 22 23 24 25
				aTotalISS		:=	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
				nRelacDoc++		//Utilizado para relacionar os documentos fiscais aos seus elementos inferiores/dependentes		
				cObs			:=	""
				nItem			:=	0
				lAchouSE4		:=	.F.
				lCompIcm		:=	.F.
				lCompFre		:=  .F.
				aReg8540 		:= {}
				cSituaDoc		:=	RetSitDoc((cAliasSFT)->FT_TIPO,cAliasSFT,cCodSef)
				If cSituaDoc $ '80'
					(cAliasSFT)->(DbSkip ())
					Loop				
				EndIf
				
				nAcImport		+=	Iif (Left ((cAliasSFT)->FT_CFOP, 1)=="3", (cAliasSFT)->FT_VALICM, 0)  
				nAcCredTerc	+=	Iif ("E"$(cAliasSFT)->FT_TIPOMOV .And. Empty((cAliasSFT)->FT_FORMUL), (cAliasSFT)->FT_ICMSRET, 0)  		
				nAcCredProp	+=	Iif ("E"$(cAliasSFT)->FT_TIPOMOV .And. !Empty((cAliasSFT)->FT_FORMUL), (cAliasSFT)->FT_ICMSRET, 0)  		
				nAcRetEsta		+=	Iif (Left ((cAliasSFT)->FT_CFOP, 1)=="5", (cAliasSFT)->FT_ICMSRET, 0)		
				nAcRetInter	+=	Iif (Left ((cAliasSFT)->FT_CFOP, 1)=="6", (cAliasSFT)->FT_ICMSRET, 0)
				cCfps			:=	""
				aCmpAntSFT		:=	{(cAliasSFT)->FT_NFISCAL,;		//01
									(cAliasSFT)->FT_SERIE,;			//02
									(cAliasSFT)->FT_CLIEFOR,;		//03
									(cAliasSFT)->FT_LOJA,;			//04
									(cAliasSFT)->FT_ENTRADA,;		//05
									(cAliasSFT)->FT_EMISSAO,;		//06
									(cAliasSFT)->FT_DTCANC,;		//07
									(cAliasSFT)->FT_FORMUL,;		//08
									(cAliasSFT)->FT_CFOP,;			//09
									cLancam,;						//10	//(cAliasSFT)->FT_CONTA
									(cAliasSFT)->FT_ALIQICM,;		//11
									(cAliasSFT)->FT_PDV,;			//12
									(cAliasSFT)->FT_BASEICM,;		//13
									(cAliasSFT)->FT_CLASFIS,;		//14
									(cAliasSFT)->FT_VALICM,;		//15
									(cAliasSFT)->FT_ISENICM,;		//16
									(cAliasSFT)->FT_OUTRICM,;		//17
									(cAliasSFT)->FT_ICMSRET,;       //18
									(cAliasSFT)->FT_TIPO,;   		//19  TIPO 
									(cAliasSFT)->FT_CHVNFE,;		//20 Chave
									(cAliasSFT)->FT_OBSERV,; 		//21 OBSERV
									(cAliasSFT)->FT_FILIAL} 		//22 FILIAL

				cCmpCondP	:= cAlsSF+"->"+SubStr (cAlsSF, 2, 2)+"_COND" 
				cCmpFrete	:= cAlsSF+"->"+SubStr (cAlsSF, 2, 2)+"_FRETE"
				cCmpRecIss	:= cAlsSA+"->"+SubStr (cAlsSA, 2, 2)+"_RECISS"
				cCmpTes		:= cAlsSD+"->"+SubStr (cAlsSD, 2, 2)+"_TES"
				cCmpLocal	:= cAlsSD+"->"+SubStr (cAlsSD, 2, 2)+"_LOCAL"
				cCmpLtCtl	:= cAlsSD+"->"+SubStr (cAlsSD, 2, 2)+"_LOTECTL"
				cCmpNLote	:= cAlsSD+"->"+SubStr (cAlsSD, 2, 2)+"_NUMLOTE"
				cCmpVlAcr	:= cAlsSD+"->"+SubStr (cAlsSD, 2, 2)+"_VALACRS"
				cCmpRecSA	:= cAlsSA + "RECNO"

				lSm0		:= Iif( (cAliasSFT)->FT_FORMUL=="S" .And. cEntSai=="1",.T.,.F. )		
				cRecIss		:= ""

				//Quando a NF de Entrada for formulario proprio o validador exige que os dados do remente sejam os mesmos do declarante.
				If "E"$(cAliasSFT)->FT_TIPOMOV
					nFreteCIF += Iif(cAlsSF+"->"+SubStr (cAlsSF, 2, 2)+"_TPFRETE" == "C", cAlsSF+"->"+SubStr (cAlsSF, 2, 2)+"FRETE", 0)
					nFreteFOB += Iif(cAlsSF+"->"+SubStr (cAlsSF, 2, 2)+"_TPFRETE" == "F", cAlsSF+"->"+SubStr (cAlsSF, 2, 2)+"FRETE", 0)																								
				ElseIf "S"$(cAliasSFT)->FT_TIPOMOV .And. cAlsSF == "SF2"
					nFreteCIF += Iif((cAlsSF)->F2_TPFRETE == "C", (cAlsSF)->F2_FRETE, 0)
					nFreteFOB += Iif((cAlsSF)->F2_TPFRETE == "F", (cAlsSF)->F2_FRETE, 0)	
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Posicionando tabelas³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SEFIISeek(cAlsSA,,xFilial(cAlsSA)+(cAliasSFT)->(FT_CLIEFOR+FT_LOJA),Iif(lTop,(cAliasSFT)->&(cCmpRecSA),0))
				SEFIISeek(cAlsSF,,xFilial(cAlsSF)+(cAliasSFT)->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA),Iif(lTop,(cAliasSFT)->SFRECNO,0))
				lAchouSE4	:=	SEFIISeek("SE4",1,xFilial("SE4")+&(cCmpCondP),IIf(lTop,(cAliasSFT)->SE4RECNO,0))

				lCompIcm	:=	(&(cAlsSF + "->" + SubStr(cAlsSF, 2, 2) + "_TIPO") == "I") // Indica se NF de complemento de ICMS
				lCompFre	:=	(&(cAlsSF + "->" + SubStr(cAlsSF, 2, 2) + "_TIPO") == "C") // Indica se NF de complemento de Frete

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Processo todas as observacoes para o documento fiscal contidas na tabela SF3 (F3_OBSERV)³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !cEspecie$"02/2D" .Or. !aCmpAntSFT[19]$"F"	//O registro de observacao nao deve ser gerado para consumidor final, inclusive cupom fiscal
					aObs	:=	LivrObs (cAliasSFT, Val (cEntSai), 65536, @aLeis, cChaveF3,lCompFre)
					For nX := 1 To Len (aObs)
						cObs	+=	aObs[nX]+", "
					Next (nX)
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Retornando dados do participante em um array³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aPartDoc	:=	InfPartDoc (cAlsSA, Nil,cAliasSFT)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³SOMENTE MODELOS:                               ³
				//³01 - NOTA FISCAL NORMAL                        ³
				//³03 - NOTA FISCAL DE SERVICO                    ³
				//³04 - NOTA FISCAL PRODUTOR                      ³
				//³06 - NOTA FISCAL/CONTA DE ENERGIA ELETRICA     ³
				//³07 - NOTA FISCAL SERVICO DE TRANSPORTE         ³
				//³08 - CONHECIMENTO DE TRANSPORTE RODOVIARIO     ³
				//³09 - CONHECIMENTO DE TRANSPORTE AQUAVIARIO     ³
				//³10 - CONHECIMENTO DE TRANSPORTE AEREO          ³
				//³11 - CONHECIMENTO DE TRANSPORTE FERROVIARIO    ³
				//³21 - NOTA FISCAL DE SERVICO DE COMUNICACAO     ³
				//³22 - NOTA FISCAL DE SERVICO DE TELECOMUNICACAO ³
				//³55 - NOTA FISCAL ELETRONICA                    ³
				//³57 - CONHECIMENTO DE TRANSPORTE ELETRONICO     ³
				//³67 - CONHECIMENTO DE TRANSPORTE ELETRONICO - OS³
				//³63 - BILHETE DE PASSAGEM ELETRÔNICO			  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cEspecie$"01#03#04#06#07#08#09#10#11#21#22#55#57#1B#67#63"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³REGISTRO 0150 - TABELA DE CADASTRO DE PARTICIPANTES³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Reg0150 (aPartDoc,aWizard,cEspecie)
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Processando os itens do documento fiscal.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cChave	:=	(cAliasSFT)->FT_FILIAL+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA

				Do While !(cAliasSFT)->(Eof ()) .And.;
					cChave==(cAliasSFT)->FT_FILIAL+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA
					
					If Interrupcao(@lEnd)
						Exit
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Inicializacao de variaveis utilizadas no processamento do item³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					
					aBloco8 := {0,0,0,0,0,0,0,0,0,0,0,0,0,0}
					nItem += 1
					nItem8535 += 1	
					cCodCOP := ""
					lIss := ((cAliasSFT)->FT_TIPO == "S")
					cEspeNFS := AllTrim((cAliasSFT)->FT_ESPECIE )
					cCfps := Iif(Empty(cCfps), (cAliasSFT)->FT_CFPS, cCfps)
					lIssRet :=	 .F.
					
					SEFIISeek(cAlsSD,,xFilial(cAlsSD)+(cAliasSFT)->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_PRODUTO+FT_ITEM),IIf(lTop,(cAliasSFT)->SDRECNO,0))
					SEFIISeek("SB1",,xFilial("SB1")+(cAliasSFT)->FT_PRODUTO,IIf(lTop,(cAliasSFT)->SB1RECNO,0))

					If lTop
						cCodCOP := (cAliasSFT)->F4_COP
					Else
						If SEFIISeek("SF4",,xFilial("SF4") + &(cCmpTes))
							cCodCOP := SF4->F4_COP
						EndIf
					EndIf

					If Empty(cCodCOP)
						cCodCOP := RetCOP(@Alltrim((cAliasSFT)->FT_CFOP))
					EndIf
					
					cClasFis := RetCodCst(cAliasSFT, cAlsSA)
					
					Bloco8(cAlias, cAliasSFT,cSituaDoc)
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³verifica se este item da nota eh um servico ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								
					If lIss
						If !Empty ((cAliasSFT)->FT_RECISS)
							cRecIss		:=	(cAliasSFT)->FT_RECISS
						Else
							cRecIss		:=	&(cCmpRecIss)
						EndIf
						
						If (cEntSai=="1" .And. cRecIss$"2N") .Or. (cEntSai=="2" .And. cRecIss$"1S")
							lIssRet		:=	.T.
						EndIf
					Else
						lIcms := .T.
					EndIf
								
					If (cAliasSFT)->FT_TPPRODE $ " #0#1#2#3#4#5#6" .And. cEspecie $ "01#55" .And. !(cSituaDoc $ "90#81")
							
						nPosApLv := aScan(aRegSubAP, {|x| x[1] == (cAliasSFT)->FT_NRLIVRO})
						
						If nPosApLv > 0
													
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³GRAVACAO - REGISTRO 8545 - GIAF - APURAÇÃO INCENTIVADA
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If (cAliasSFT)->FT_TPPRODE$" #0#1#2#3#4#5#6"
								
								Reg8545(cAlias,aWizard,aRegSubAP[nPosApLv,2],@aReg8545)
																							
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³REGISTRO 8110 - AQUISIÇÃO DE BENS PARA USO/CONSUMO OU ATIVO FIXO ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If Substr(aWizard[6][2],1,1)$ "0"
									Reg8110 (cAlias, cAliasSFT, @aReg8110, lIssRet,cEspecie,aWizard)
								Endif
								
							Endif				
																
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³8505 - GIAF - BENEFÍCIOS FISCAIS³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If (cAliasSFT)->FT_TPPRODE$" #0#1#2#3#4#5#6"
								Reg8505 (cAlias, cAliasSFT, @aReg8505, cSituaDoc, aWizard, nRelacDoc, @aReg8510, @aReg8515, @aReg8525,aRegSubAP[nPosApLv,2],aMVPROPERC)
							Endif
								
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³REGISTRO 8530 GIAF - LANÇAMENTO COM ITEM INCENTIVADO     ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
							Reg8530 (cAlias, cEntSai, aCmpAntSFT, aPartDoc, cEspecie, cSituaDoc, aWizard, nRelacDoc, @aReg8535, @nItem8535, cAliasSFT, @aReg8540,@aReg8530,aRegSubAP[nPosApLv,2])															
													
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³REGISTRO 8550: GIAF - CONSOLIDAÇÃO POR CFOP DAS OPERAÇÕES INCENTIVADAS       ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If (cAliasSFT)->FT_TPPRODE$" #0#1#2#3#4#5#6"
								Reg8550 (cAliasSFT, cEntSai, @aReg8550, cSituaDoc, cEspecie, aWizard, aRegSubAP[nPosApLv,2])
							
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³REGISTRO 8555: GIAF - TOTALIZAÇÃO DAS OPERAÇÕES INCENTIVADAS ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								Reg8555 (cAlias,cAliasSFT, cEntSai, cSituaDoc, cEspecie, @aReg8555, aWizard,aRegSubAP[nPosApLv,2])
							Endif
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³GRAVACAO - 8560 - GIAF - SALDOS DA APURAÇÃO INCENTIVADA  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If (cAliasSFT)->FT_TPPRODE$" #0#1#2#3#4#5#6"
								Reg8560  (cAlias, dDataAte, cNrLivro,aWizard,aRegSubAP[nPosApLv,2],aRegSubAP[nPosApLv,1],@aReg8560,@aReg8565,aProAPFil,aProAPST)
							EndIf								
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ REGISTRO 8570 - GIAF 1 - PRODEPE INDÚSTRIA (CRÉDITO PRESUMIDO) - Apuração³				 
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If (cAliasSFT)->FT_TPPRODE$"#1#2#3"
								Reg8570 (cAlias, dDataDe, dDataAte,aReg8555,aWizard,aRegSubAP[nPosApLv,2],aRegSubAP[nPosApLv,1],@aReg8570,aProAPFil,cAliasSFT,cSituaDoc)
							Endif

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//REGISTRO 8580: GIAF 3 - PRODEPE IMPORTAÇÃO (DIFERIMENTO NA ENTRADA E CRÉDITO PRESUMIDO NA SAÍDA SUBSEQUENTE)¿
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							If (cAliasSFT)->FT_TPPRODE$"6"
								Reg85801 (cAlias,dDataDe, dDataAte,aWizard,aRegSubAP[nPosApLv,2],aRegSubAP[nPosApLv,1],@aReg8580,@aReg8585,cAliasSFT,aProAPFil,cSituaDoc)
							EndIf
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//REGISTRO 8590 - GIAF 4 - PRODEPE CENTRAL DE DISTRIBUIÇÃO (ENTRADAS/SAÍDAS) - Apuração ³
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							If (cAliasSFT)->FT_TPPRODE$"4#5"
								Reg8590 (cAlias, dDataDe, dDataAte,aWizard,aRegSubAP[nPosApLv,2],aRegSubAP[nPosApLv,1],@aReg8590,cAliasSFT)
							Endif
						Endif
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³SOMENTE MODELOS:                               ³
					//³01 - NOTA FISCAL NORMAL                        ³
					//³02 - NOTA FISCAL DE VENDA A CONSUMIDOR FINAL   ³
					//³03 - NOTA FISCAL DE SERVICO                    ³
					//³04 - NOTA FISCAL PRODUTOR                      ³
					//³06 - NOTA FISCAL/CONTA DE ENERGIA ELETRICA     ³
					//³07 - NOTA FISCAL SERVICO DE TRANSPORTE         ³
					//³08 - CONHECIMENTO DE TRANSPORTE RODOVIARIO     ³
					//³09 - CONHECIMENTO DE TRANSPORTE AQUAVIARIO     ³
					//³10 - CONHECIMENTO DE TRANSPORTE AEREO          ³
					//³11 - CONHECIMENTO DE TRANSPORTE FERROVIARIO
					//³21 - NOTA FISCAL DE SERVICO DE COMUNICACAO     ³
					//³22 - NOTA FISCAL DE SERVICO DE TELECOMUNICACAO ³
					//³55 - NOTA FISCAL ELETRONICA                    ³
					//³57 - CONHECIMENTO DE TRANSPORTE ELETRONICO     ³
					//³67 - CONHECIMENTO DE TRANSPORTE ELETRONICO - OS³
					//³63 - BILHETE DE PASSAGEM ELETRÔNICO			  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (cEspecie$"01#02#2D#04#06#07#08#09#10#11#21#22#55#57#1B#67#63")
						
						If lIss // Se eh servico
							aTotalISS[1]	+=	(cAliasSFT)->FT_VALCONT
							aTotalISS[3]	+=	(cAliasSFT)->FT_VALICM
							aTotalISS[5]	+=	(cAliasSFT)->FT_ICMSRET
							aTotalISS[20]	+=	(cAliasSFT)->FT_VALICM	//	Vlr ISS
						Else
							aTotaliza[1]	+=	(cAliasSFT)->FT_VALCONT
							aTotaliza[3]	+=	Round((cAliasSFT)->FT_VALICM,2)
							aTotaliza[5]	+=	(cAliasSFT)->FT_ICMSRET
							aTotaliza[20]	+=	(cAliasSFT)->FT_VALICM	//	Vlr ISS
						EndIf
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO G025 - DOCUMENTOS REGISTRADOS ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						RegG025 (cSituaDoc, cEspecie, cEntSai, cAliasSFT, lIss, lIssRet, aRegG025)
										
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO G030 - CUPONS REGISTRADOS³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If (cEspecie$"2D") .And. lIss
							RegG030(cAlias,aRegG030,aCmpAntSFT,cPdv,aTotaliza)
						EndIf	
									
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO G050 - MAPA-RESUMO DE OPERAÇÕES  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						RegG050 (cAliasSFT, cEntSai, aRegG050, cSituaDoc, aCmpAntSFT, lIss, aTotalISS,cCodCOP)
										
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO G400 - CONSOLIDAÇÃO POR CFOP  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						RegG400 (cAliasSFT, aRegG400, cSituaDoc, lIss,cEspecie)
										
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO G410 - TOTALIZACAO DAS OPERACOES³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						RegG410 (aRegG400,aRegG410)
										
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO G450 - TOTALIZACAO DAS OPERACOES INTERESTADUAIS³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						RegG450 (cAliasSFT, cEntSai, aRegG450, cSituaDoc, lIss,cEspecie)
										
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO G460 - SUB TOTAIS POR UF ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						RegG460 (cAliasSFT, cEntSai, aRegG460, cSituaDoc, lIss,cEspecie)
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO 8030 - QVA -DETALHAMENTO POR MUNICÍPIO DAS OPERAÇÕES E PRESTAÇÕES ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Reg8030 (cAlias, cAliasSFT, cAlsSD, @aReg8030, lIss, cEntSai, cSituaDoc,aWizard)
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³REGISTRO 8040 - AJUSTES DE VALORES POR CFOP  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Reg8040 (cAlias, cAliasSFT, @aReg8040, lIss, cEntSai, cSituaDoc,aWizard)
															
					EndIf
					
					(cAliasSFT)->(DbSkip ())
					
				EndDo	//ENDDO do item
				
				GrvRegSef (cAlias,nRelacDoc, aReg8540)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Este tratamento se dah devido a troca da especie quando for nota fiscal de servico ou nota fiscal conjugada.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cEspecie	:=	cEspAux
			
				If Interrupcao(lEnd)
					Exit
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³SOMENTE MODELOS:                              ³
				//³01 - NOTA FISCAL NORMAL                       ³
				//³02 - NOTA FISCAL PRODUTOR                     ³
				//³03 - NOTA FISCAL DE SERVICOS                  ³
				//³04 - NOTA FISCAL DE VENDA A CONSUMIDOR FINAL  ³
				//³06 - NOTA FISCAL/CONTA DE ENERGIA ELETRICA    ³
				//³21 - NOTA FISCAL DE SERVICO DE COMUNICACAO    ³
				//³22 - NOTA FISCAL DE SERVICO DE TELECOMUNICACAO³
				//³55 - NOTA FISCAL ELETRONICA                   ³
				//³67 - NOTA FISCAL ELETRONICA TRANSP - OS       ³
				//³63 - BILHETE DE PASSAGEM ELETRÔNICO			 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (cEspecie$"01#02#2D#04#06#07#08#09#10#11#21#22#55#57#1B#67#63")
					If aTotalISS[24]<>0 .And. Empty(cObs)
						cObs	:=	"ISS SUBEMPREITADA"
					EndIf				                     
					
					If (cEspecie$"01#04#55#1B") 	
					    // Eh necessário buscar o codigo do COP por Nota a partir do array (aCmpAntSFT).
						If !Empty(aCmpAntSFT[9])
							cCodCOP := RetCOP(@Alltrim(aCmpAntSFT[9]))
						EndIf					
					EndIf						
				EndIf
				   	     
				nContDoc++
			
			EndDo	//ENDDO da NF
			
		Next nTpMov
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTRO G020 - DOCUMENTOS REGISTRADOS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		RegG020 (aRegG020,cAlias, dDataDe, dDataAte, nRelacDoc, aCmpAntSFT) 	  		

		SM0->(DbSkip ())
		
	EndIf
	
Next (nForFilial)

RestArea (aAreaSM0)
cFilAnt := SM0->M0_CODFIL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO 8020 - INFORMACOES COMPLEMENTARES - QUADRO DE CALCULO VALOR ADICIONADO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Substr(aWizard[6][1],1,1)$ "0"
	Reg8020 (cAlias, dDataDe, dDataAte,aWizard,aReg8020)
	GrvRegSef (cAlias,, aReg8020)   
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO 8030 - QVA -DETALHAMENTO POR MUNICÍPIO DAS OPERAÇÕES E PRESTAÇÕES     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aReg8030)>0  .And.  Len(aReg8020)>0 	 
	GrvRegSef (cAlias,, aReg8030)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO 8040 - QVA - AJUSTES DE VALOR POR CFOP³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aReg8040)>0  .And. Len(aReg8020)>0 	
	GrvRegSef (cAlias,, aReg8040)                                                
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO 8100 - INFORMACOES COMPLEMENTARES - QUADRO DE AQUISICAO DE BENS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Reg8100 (cAlias,aReg8100, dDataDe, dDataAte, aWizard)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO 8110 - QAB - AQUISICAO DE BENS PARA USO/CONSUMO OU ATIVO FIXO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Substr(aWizard[6][2],1,1)$ "0" .AND. Len(aReg8110)>0 // Quadro aquisicao de bens 		
	GrvRegSef (cAlias,, aReg8110)  
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO 8160 - INFORMACOES COMPLEMENTARES QUADRO DE CONTROLE DO CREDITO ACUMULADO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Substr(aWizard[6][3],1,1)$ "0" //Quadro controle de credito acumulado
	Reg8160 (cAlias, dDataDe, dDataAte, aWizard)
Endif   
						
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO 8165 - QCA - CREDITO ACUMULADO NO PERIODO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Substr(aWizard[6][3],1,1)$ "0"  //Quadro controle de credito acumulado  
	Reg8165  (cAlias, dDataAte, aWizard, nAcImport, nAcRetInter, nDbCompIcm, nCrCompIcm, aLog,nAcRetEsta) 
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO 8300 - INFORMACOES COMPLEMENTARES - QUADRO DE VALORES POR TIPO DE CONSUMO|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Reg8300 (cAlias, dDataDe, dDataAte, aWizard)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO 8500 - GUIA DE APURAÇÃO DOS INCENTIVOS FISCAIS E FINANCEIROS
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Substr(aWizard[6][4],1,1)$ "0" 
	Reg8500(cAlias,dDataDe, dDataAte, aWizard)
Endif

//8525: 8525: GIAF - ITEM INCENTIVADO (PI) POR BENEFÍCIO
If Len(aReg8525) > 0
	nI := 0
	nJ := 0
	For nI := 1 To Len(aReg8525)
		cPosApLV := aReg8525[nI,1]
		cPosALiv := aReg8525[nI,2]
		aReg85 := {}
		aAdd(aReg85, {})
		nPos	:=	Len (aReg85)
		For nJ := 3 To Len(aReg8525[nI])
			aAdd(aReg85[nPos], aReg8525[nI,nJ])
		Next nJ
		
		GrvRegSef (cAlias,Val(cPosApLV),aReg85,,Val(cPosALiv))
	Next nI
EndIf

//LINHA 8530: LINHA 8530: GIAF - LANÇAMENTO COM ITEM INCENTIVADO
If Len(aReg8530) > 0
	nI := 0
	nJ := 0
	For nI := 1 To Len(aReg8530)
		cPosApLV := aReg8530[nI,1]
		aReg30 := {}
		aAdd(aReg30, {})
		nPos	:=	Len (aReg30)
		nRelac := aReg8530[nI,1]
		For nJ := 2 To Len(aReg8530[nI])
			aAdd(aReg30[nPos], aReg8530[nI,nJ])
		Next nJ
		GrvRegSef (cAlias,nRelac, aReg30)
	Next nI
EndIf

//³GRAVACAO - REGISTRO 8550 - GIAF - CONSOLIDAÇÃO POR CFOP DAS OPERAÇÕES INCENTIVADAS³
If Len(aReg8550) > 0
	nI := 0
	nJ := 0
	For nI := 1 To Len(aReg8550)
		cPosApLV := aReg8550[nI,1]
		aReg50 := {}
		aAdd(aReg50, {})
		nPos	:=	Len (aReg50)
		For nJ := 2 To Len(aReg8550[nI])
			aAdd(aReg50[nPos], aReg8550[nI,nJ])
		Next nJ
		GrvRegSef (cAlias,Val(cPosApLV), aReg50)
	Next nI
EndIf

//³GRAVACAO - 8555 GIAF - TOTALIZAÇÃO DAS OPERAÇÕES INCENTIVADAS  ³
If Len(aReg8555) > 0
	nI := 0
	nJ := 0
	For nI := 1 To Len(aReg8555)
		cPosApLV := aReg8555[nI,1]
		aReg55 := {}
		aAdd(aReg55, {})
		nPos	:=	Len (aReg55)
		For nJ := 2 To Len(aReg8555[nI])
			aAdd(aReg55[nPos], aReg8555[nI,nJ])
		Next nJ
		GrvRegSef (cAlias,Val(cPosApLV),aReg55)
	Next nI
EndIf

//LINHA 8560: GIAF - SALDOS DA APURAÇÃO INCENTIVADA
If Len(aReg8560) > 0
	nI := 0
	nJ := 0
	For nI := 1 To Len(aReg8560)
		cPosApLV := aReg8560[nI,1]
		aReg60 := {}
		aAdd(aReg60, {})
		nPos	:=	Len (aReg60)
		For nJ := 2 To Len(aReg8560[nI])
			aAdd(aReg60[nPos], aReg8560[nI,nJ])
		Next nJ
		GrvRegSef (cAlias,Val(cPosApLV), aReg60) 
	Next nI
EndIf

//LINHA 8565: GIAF - AJUSTES DA APURAÇÃO INCENTIVADA
If Len(aReg8565) > 0
	nI := 0
	nJ := 0
	For nI := 1 To Len(aReg8565)
		cPosApLV := aReg8565[nI,1]
		aReg65 := {}
		aAdd(aReg65, {})
		nPos	:=	Len (aReg65)
		For nJ := 2 To Len(aReg8565[nI])
			aAdd(aReg65[nPos], aReg8565[nI,nJ])
		Next nJ
		GrvRegSef (cAlias,Val(cPosApLV), aReg65 ) 
	Next nI
EndIf

//LINHA 8570: GIAF 1 - PRODEPE INDÚSTRIA (CRÉDITO PRESUMIDO)
If Len(aReg8570) > 0
	nI := 0
	nJ := 0
	For nI := 1 To Len(aReg8570)
		cPosApLV := aReg8570[nI,1]
		aReg70 := {}
		aAdd(aReg70, {})
		nPos	:=	Len (aReg70)
		For nJ := 2 To Len(aReg8570[nI])
			aAdd(aReg70[nPos], aReg8570[nI,nJ])
		Next nJ
		GrvRegSef (cAlias,Val(cPosApLV), aReg70)
	Next nI
EndIf

//LINHA 8580: GIAF 3 - PRODEPE IMPORTAÇÃO (DIFERIMENTO NA ENTRADA E CRÉDITO PRESUMIDO NA SAÍDA SUBSEQUENTE)
If Len(aReg8580) > 0
	nI := 0
	nJ := 0
	For nI := 1 To Len(aReg8580)
		cPosApLV := aReg8580[nI,1]
		aReg80 := {}
		aAdd(aReg80, {})
		nPos	:=	Len (aReg80)
		For nJ := 2 To Len(aReg8580[nI])
			aAdd(aReg80[nPos], aReg8580[nI,nJ])
		Next nJ
		GrvRegSef (cAlias,Val(cPosApLV), aReg80)
	Next nI
EndIf

//8585: GIAF 3 - PRODEPE IMPORTAÇÃO (SAÍDAS INTERNAS POR FAIXA DE ALÍQUOTA)
If Len(aReg8585) > 0
	nI := 0
	nJ := 0
	For nI := 1 To Len(aReg8585)
		cPosApLV := aReg8585[nI,1]
		aReg85 := {}
		aAdd(aReg85, {})
		nPos	:=	Len (aReg85)
		For nJ := 2 To Len(aReg8585[nI])
			aAdd(aReg85[nPos], aReg8585[nI,nJ])
		Next nJ
		GrvRegSef (cAlias,Val(cPosApLV), aReg85)
	Next nI
EndIf

//LINHA 8590: GIAF 4 - PRODEPE CENTRAL DE DISTRIBUIÇÃO (ENTRADAS/SAÍDAS)
If Len(aReg8590) > 0
	nI := 0
	nJ := 0
	For nI := 1 To Len(aReg8590)
		cPosApLV := aReg8590[nI,1]
		aReg90 := {}
		aAdd(aReg90, {})
		nPos	:=	Len (aReg90)
		For nJ := 2 To Len(aReg8590[nI])
			aAdd(aReg90[nPos], aReg8590[nI,nJ])
		Next nJ
		GrvRegSef (cAlias,Val(cPosApLV), aReg90)
	Next nI
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO 0150 - TABELA DE CADASTRO DE PARTICIPANTE ³
//|GRAVACAO - REGISTRO 0175 - ENDERECO DO PARTICIPANTE           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
R150R175 (cAlias)

If Len(aRegG020)>0 .And.  Len(aRegG025)>0     
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GRAVACAO - REGISTRO G020 - GUIA DE INFORMACOES ECONOMICO-FISCAIS³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GrvRegSef (cAlias,, aRegG020)                                                 	
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GRAVACAO - REGISTRO G025 - DOCUMENTOS REGISTRADOS ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	GrvRegSef (cAlias,, aRegG025)	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GRAVACAO - REGISTRO G030 - CUPONS REGISTRADOS³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GrvRegSef (cAlias,1, aRegG030)			
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GRAVACAO - REGISTRO G050 - MAPA-RESUMO DE OPERAÇÕES  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GrvRegSef (cAlias,, aRegG050)		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GRAVACAO - REGISTRO G400 - CONSOLIDAÇÃO POR CFOP  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	GrvRegSef (cAlias,, aRegG400)	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gravacao do REGISTRO G410 - TOTALIZACAO DAS OPERACOES³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GrvRegSef (cAlias,, aRegG410)    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GRAVACAO - REGISTRO G020 - GUIA DE INFORMACOES ECONOMICO FISCAL  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	G420G430 (cAlias, dDataAte, cNrLivro, nAcImport, nAcRetInter, nDbCompIcm, nCrCompIcm, aLog,nAcRetEsta,nAcCredTerc,nAcCredProp)	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³REGISTRO G440 - TOTALIZACOES DAS OBRIGACOES A RECOLHER³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
	RegG440 (aRegG440,cAlias,dDataDe,dDataAte,nRelacDoc)	    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GRAVACAO - REGISTRO G450 -TOTALIZAÇÃO DAS OPERAÇÕES INTERESTADUAIS³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GrvRegSef (cAlias,, aRegG450)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GRAVACAO - REGISTRO G460 - GUIA DE INFORMACOES ECONOMICO FISCAL  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aRegG450) > 0
		GrvRegSef (cAlias,, aRegG460)
	EndIf
EndIf	
 
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Inventario³ Autor ³Erick G. Dias          ³ Data ³ 10.10.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±	GERACAO DO LAYOUT RI (REGISTRO DE INVENTARIO)     					   ±±	
±±	BLOCOS QUE SERAO GERADOS: BLOCO 0, BLOCO H E BLOCO 9				   ±±	
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±   
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Inventario(aLisFil,aWizard,cAlias)  
Local	aAreaSM0		:=	SM0->(GetArea())
Local   aReg0200    	:=  {}      
Local	aRegH020    := {}
Local  aRegH040    := {}
Local  aRegH050    := {}
Local  aRegH060    := {}
Local	dDataDe			:=	SToD (aWizard[1][1])
Local	dDataAte		:=	SToD (aWizard[1][2])
Local   dDataInv        := IIf (!Empty(SToD(aWizard[1][13])),SToD(aWizard[1][13]),SuperGetMv ("MV_ULMES"))
Local 	nForFilial		:= 0

Local aReg0205	:=	{}
Local nI		:= 0
Local nJ		:= 0
Local nPos		:= 0
Local nPosApLV := 0
Local aReg  := {}

Default	aLisFil			:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO 0000 - ABERTURA DO ARQUIVO DIGITAL E IDENTIFICACAO DO CONTRIBUINTE³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Reg0000 (aWizard, cAlias, dDataDe, dDataAte)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO 0005 - DADOS COMPLEMENTARES DO CONTRIBUINTE³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Reg0005 (aWizard, cAlias)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³REGISTRO 0025 - BENEFICIO FISCAL³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Reg0025(cAlias)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO 0030 - PERFIL CONTRIBUINTE  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Reg0030 (aWizard, cAlias)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO 0100 - DADOS DO CONTABILISTA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Reg0100 (aWizard, cAlias)     
              
DbSelectArea ("SM0")

For nForFilial := 1 To Len( aLisFil ) 

	If  aLisFil [ nForFilial, 1 ]
  	   
  		cFilAnt := aLisFil[nForFilial][2]
  		SM0->(DbSeek (cEmpAnt+cFilAnt, .T.))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³GRAVACAO - REGISTRO H020 - REGISTRO DE INVENTARIO              ³
		//³GRAVACAO - REGISTRO H030 - ITENS DE INVENTARIO                 ³
		//³GRAVACAO - REGISTRO H040 - SUBTOTAIS POR POSSUIDOR/PROPRIETARIO³
		//³GRAVACAO - REGISTRO H050 - SUBTOTAIS POR TIPO DE ITEM          ³
		//³GRAVACAO - REGISTRO H060 - SUBTOTAIS POR NCM                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If dDataInv >=dDataDe .AND. dDataInv <=dDataAte
			RegistroH(cAlias, dDataInv, aWizard,@aReg0200,@aRegH020,@aRegH040,@aRegH050,@aRegH060,@aReg0205) 
		EndIf	
		SM0->(DbSkip ())
	EndIf
Next (nForFilial)

If Len(aReg0200) > 0
	nI := 0
	nJ := 0
	For nI := 1 To Len(aReg0200)
		nPosApLV := aReg0200[nI,1]
		aReg := {}
		aAdd(aReg, {})
		nPos	:=	Len (aReg)
		For nJ := 2 To Len(aReg0200[nI])
			aAdd(aReg[nPos], aReg0200[nI,nJ])
		Next nJ
		GrvRegSef (cAlias,nPosApLV, aReg)
	Next nI
	aReg0200 := {}
EndIf
//0205: CÓDIGO ANTERIOR DO ITEM
If Len(aReg0205) > 0
	nI := 0
	nJ := 0
	For nI := 1 To Len(aReg0205)
		nPosApLV := aReg0205[nI,1]
		aReg := {}
		aAdd(aReg, {})
		nPos	:=	Len (aReg)
		For nJ := 2 To Len(aReg0205[nI])
			aAdd(aReg[nPos], aReg0205[nI,nJ])
		Next nJ
		GrvRegSef (cAlias,nPosApLV, aReg)
	Next nI
EndIf

If Len(aRegH020) > 0
	GrvRegSef (cAlias, , aRegH020)
	aRegH020 := {}
EndIf

If Len(aRegH040) > 0
	GrvRegSef (cAlias, , aRegH040)
	aRegH040 := {}
EndIf
	
If Len(aRegH050) > 0
	GrvRegSef (cAlias, , aRegH050)
	aRegH050 := {}
EndIf
	
If Len(aRegH060) > 0
	GrvRegSef (cAlias, , aRegH060)
	aRegH060 := {}
EndIf

RestArea (aAreaSM0)
cFilAnt := SM0->M0_CODFIL
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - REGISTRO 0150 - TABELA DE CADASTRO DE PARTICIPANTE ³
//|GRAVACAO - REGISTRO 0175 - ENDERECO DO PARTICIPANTE           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
R150R175 (cAlias)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Reg0000   ³ Autor ³Sueli C. Santos        ³ Data ³10.05.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³ABERTURA DO ARQUIVO DIGITAL E IDENTIFICACAO DO CONTRIBUINTE ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao do Registro 0000 e gravacao do mesmo              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³0(1 por arquivo)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> informacoes preenchidas no Wizard                ³±±
±±³          ³cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³dDataDe -> Data incial do periodo de apuracao.              ³±±
±±³          ³dDataAte -> Data final do periodo de apuracao.              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Reg0000 (aWizard, cAlias, dDataDe, dDataAte)
Local	aReg	:=	{}
Local	lRet	:=	.T.
Local	nPos	:=	0
Local   cCodCTD := ""
Local   cFanta  := ""
               
If Substr(aWizard[1][8],1,1) == "1"     //-LA-ICMS
    cCodCTD := "20"
ElseIf Substr(aWizard[1][8],1,1) == "2" //eDoc
    cCodCTD := "91"
ElseIf Substr(aWizard[1][8],1,1) == "3" //RI
    cCodCTD := "21"
ElseIf Substr(aWizard[1][8],1,1) == "4" //Prodepe GI-ICMS
    cCodCTD := "30"
Else 
    cCodCTD := "07"
Endif    
                   
//o validador nao aceita no nome fantasia com menos que 8 posicoes, 
//por isso, nesse caso, será completado com espacos em branco. Ex: "NIKE    "
If Len(Alltrim(SM0->M0_NOME)) >= 8 
    cFanta := Alltrim(SM0->M0_NOME)
Else
    cFanta := Alltrim(SM0->M0_NOME) + Space(8-Len(Alltrim(SM0->M0_NOME)))
EndIf

aAdd(aReg, {})
nPos	:=	Len (aReg)
aAdd (aReg[nPos], "0000")													//01 - REG
aAdd (aReg[nPos], "LFPD")													//02 - LFPD
aAdd (aReg[nPos], dDataDe)										   			//03 - DT_INI
aAdd (aReg[nPos], dDataAte)										   			//04 - DT_FIM
aAdd (aReg[nPos], SM0->M0_NOMECOM)											//05 - NOME_EMPR
aAdd (aReg[nPos], Iif (RetPessoa(SM0->M0_CGC) == "J", SM0->M0_CGC, ""))  	//06 - CNPJ
aAdd (aReg[nPos], SM0->M0_ESTENT)											//07 - UF
aAdd (aReg[nPos], SM0->M0_INSC)											    //08 - IE
aAdd (aReg[nPos], SM0->M0_CODMUN)											//09 - COD_MUN
aAdd (aReg[nPos], SM0->M0_INSCM)											//10 - IM  
aAdd (aReg[nPos], "")										   				//11 - VAZIO
aAdd (aReg[nPos], SM0->M0_INS_SUF)											//12 - SUFRAMA
aAdd (aReg[nPos], "2000")													//13 - COD_VER 
aAdd (aReg[nPos], SubStr (aWizard[2][1], 1, 1))				    		//14 - COD_FIN
aAdd (aReg[nPos], cCodCTD)	                         					    //15 - COD_CTD   //SubStr (aWizard[2][2], 1, 2)
aAdd (aReg[nPos], "Brasil")													//16 - PAIS
aAdd (aReg[nPos], cFanta)	                                                //17 - FANTASIA
aAdd (aReg[nPos], Iif(cCodCTD == "91","",SM0->M0_NIRE))					//18 - NIRE
aAdd (aReg[nPos], Iif (RetPessoa(SM0->M0_CGC) == "F", SM0->M0_CGC, ""))   //19 - CPF
aAdd (aReg[nPos], "")										   				//20 - VAZIO

GrvRegSef (cAlias,, aReg)
Return (lRet)    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Reg0005   ³ Autor ³Sueli C. Santos        ³ Data ³10.05.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³             DADOS COMPLEMENTARES DO CONTRIBUINTE           ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao do Registro 0005 e gravacao do mesmo              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2(1 por arquivo)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> informacoes preenchidas no Wizard                ³±±
±±³          ³cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Reg0005 (aWizard, cAlias)
Local	aReg	:=	{}
Local	lRet	:=	.T.
Local	nPos	:=	0

aAdd(aReg, {})
nPos	:=	Len (aReg)
aAdd (aReg[nPos], "0005")																					//01 - REG
aAdd (aReg[nPos], SubStr (aWizard[2][4], 1, 60))														    //02 - NOME RESPONSAVEL
aAdd (aReg[nPos], SubStr (aWizard[2][3], 1, 3))														        //03 - COD_ASSIN
aAdd (aReg[nPos], SubStr (aWizard[2][5], 1, 11))														    //04 - CPF RESPONSAVEL
aAdd (aReg[nPos], SM0->M0_CEPENT)																			//05 - CEP             
aAdd (aReg[nPos], Substr (SM0->M0_ENDENT, 1, At(",", SM0->M0_ENDENT)-1))									//06 - END
aAdd (aReg[nPos], Substr (SM0->M0_ENDENT, At(",", SM0->M0_ENDENT)+1,6))	    					    		//07 - NUM
aAdd (aReg[nPos], SM0->M0_COMPENT)																			//08 - COMPL
aAdd (aReg[nPos], SM0->M0_BAIRENT)																			//09 - BAIRRO
aAdd (aReg[nPos], SM0->M0_CEPENT)																			//10 - CEP_CP
aAdd (aReg[nPos], SM0->M0_CAIXA)																			//11 - CP	
aAdd (aReg[nPos],  right(iif(!empty(SM0->M0_TEL),alltrim(str(FisGetTel(SM0->M0_TEL)[1])) + alltrim(str(FisGetTel(SM0->M0_TEL)[2])) + alltrim(str(FisGetTel(SM0->M0_TEL)[3])),""),11))        //12 - FONE
aAdd (aReg[nPos],  iif(!empty(SM0->M0_FAX),alltrim(str(FisGetTel(SM0->M0_FAX)[1])) + alltrim(str(FisGetTel(SM0->M0_FAX)[2])) + alltrim(str(FisGetTel(SM0->M0_FAX)[3])),""))        //13 - FAX
aAdd (aReg[nPos], SubStr (aWizard[2][6],1,60))																//14 - EMAIL

GrvRegSef (cAlias,, aReg)
Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Reg0025   ³ Autor ³Sueli C. Santos        ³ Data ³17.07.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³                  BENEFICIO FISCAL                          ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao do Registro 0020 e gravacao do mesmo              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2(um por arquivo)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Reg0025(cAlias)
Local	aReg		:=	{}
Local	lRet		:=	.T.
Local	nPos		:=	0

aAdd (aReg, {})
nPos	:=	Len (aReg)
aAdd (aReg[nPos], "0025")					//01 - REG
aAdd (aReg[nPos], "PE001")					//02 - COD_BF_ICMS
aAdd (aReg[nPos], "")						//03 - COD_BF_ISSQN

GrvRegSef (cAlias,, aReg)
Return(lRet)   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Reg0030   ³ Autor ³Sueli C. Santos        ³ Data ³02.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³                 PERFIL DO CONTRIBUINTE                     ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao do Registro 0030                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2(um por arquivo)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> informacoes preenchidas no Wizard                ³±±
±±³          ³cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Reg0030 (aWizard, cAlias)
Local	aReg		:=	{}
Local	lRet		:=	.T.
Local	nPos		:=	0

aAdd (aReg, {})
nPos	:=	Len (aReg)
aAdd (aReg[nPos], "0030")				        	//01 - REG
aAdd (aReg[nPos], SubStr (aWizard[3][1], 1, 1))	//02 - IND_ED   
aAdd (aReg[nPos], SubStr (aWizard[3][2], 1, 1))	//03 - IND_ARQ
aAdd (aReg[nPos], SubStr (aWizard[3][3], 1, 1))	//04 - PRF_ISS
aAdd (aReg[nPos], SubStr (aWizard[3][4], 1, 1))	//05 - PRF_ICMS
aAdd (aReg[nPos], Iif(Substr(aWizard[1][8],1,1) == "2","",SubStr (aWizard[3][5], 1, 1)))	//06 - PRF_RIDF
aAdd (aReg[nPos], Iif(Substr(aWizard[1][8],1,1) == "2","",SubStr (aWizard[3][6], 1, 1)))	//07 - PRF_RUDF
aAdd (aReg[nPos], Iif(Substr(aWizard[1][8],1,1) == "2","",SubStr (aWizard[3][7], 1, 1)))	//08 - PRF_LMC
aAdd (aReg[nPos], Iif(Substr(aWizard[1][8],1,1) == "2","",SubStr (aWizard[3][8], 1, 1)))	//09 - PRF_RV
aAdd (aReg[nPos], Iif(Substr(aWizard[1][8],1,1) == "2","",SubStr (aWizard[3][9], 1, 1)))	//10 - PRF_RI
aAdd (aReg[nPos], Iif(Substr(aWizard[1][8],1,1) == "2","",SubStr (aWizard[3][10], 1, 1)))//11 - IND_EC
aAdd (aReg[nPos], SubStr (aWizard[3][11], 1, 1))	//12 - IND_ISS
//aAdd (aReg[nPos], SubStr (aWizard[3][12], 1, 1))	//13 - IND_RT 
aAdd (aReg[nPos], "")	                            //13 - IND_RT //obs: se preencher, ocorre erro no validador
aAdd (aReg[nPos], SubStr (aWizard[3][13], 1, 1))	//14 - IND_ICMS
aAdd (aReg[nPos], SubStr (aWizard[3][14], 1, 1))	//15 - IND_ST
aAdd (aReg[nPos], SubStr (aWizard[3][15], 1, 1))	//16 - IND_AT
aAdd (aReg[nPos], SubStr (aWizard[3][16], 1, 1))	//17 - IND_IPI
aAdd (aReg[nPos], Iif(Substr(aWizard[1][8],1,1) == "2","",SubStr (aWizard[3][17], 1, 1)))	//18 - IND_RI
GrvRegSef (cAlias,, aReg)
Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Reg0100   ³ Autor ³Sueli C. Santos        ³ Data ³02.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³                 DADOS DO CONTABILISTA                      ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao do Registro 0100 e gravacao do mesmo              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2(um por arquivo)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> informacoes preenchidas no Wizard                ³±±
±±³          ³cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Reg0100 (aWizard, cAlias)
Local	aReg		:=	{}
Local	lRet		:=	.T.
Local	nPos		:=	0

aAdd (aReg, {})
nPos	:=	Len (aReg)
aAdd (aReg[nPos], "0100")				            	//01 - REG
aAdd (aReg[nPos], aWizard[4][1])						//02 - NOME 
aAdd (aReg[nPos], "900")	        	                //03 - COD_ASSIN   
aAdd (aReg[nPos], aWizard[4][2])						//04 - CNPJ
aAdd (aReg[nPos], aWizard[4][3])						//05 - CPF
aAdd (aReg[nPos], aWizard[4][4])						//06 - CRC           
aAdd (aReg[nPos], aWizard[4][6])						//07 - CEP
aAdd (aReg[nPos], aWizard[4][7])						//08 - END
aAdd (aReg[nPos], aWizard[4][8])						//09 - NUM
aAdd (aReg[nPos], aWizard[4][9])						//10 - COMPL
aAdd (aReg[nPos], aWizard[4][10])						//11 - BAIRRO
aAdd (aReg[nPos], aWizard[4][5])						//12 - UF
aAdd (aReg[nPos], aWizard[4][16])					   			      	//13 - COD_MUN
aAdd (aReg[nPos], iif( aWizard[4][11]="00000000","", aWizard[4][11])) 	//14 - CEP_CP
aAdd (aReg[nPos], iif( aWizard[4][12]="00000","", aWizard[4][12]))	  	//15 - CP                       
aAdd (aReg[nPos], aWizard[4][13])					   			      	//16 - FONE
aAdd (aReg[nPos], aWizard[4][14])										//17 - FAX
aAdd (aReg[nPos], aWizard[4][15])						//18 - EMAIL

GrvRegSef (cAlias,, aReg)
Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Reg0150   ³ Autor ³Sueli C. Santos        ³ Data ³02.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³        0150 - TABELA DE CADASTRO DE PARTICIPANTES          ³±±
±±³          ³             0175 - ENDERECO DO PARTICIPANTE                ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao dos Registro 150 e 175                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³0150 - 2(varios por arquivo) Relacionado com o Registro 0005³±±
±±³          ³0175 - 3(1:1) Relacionado com o Registro 0150               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aPartDoc -> Array com todas as informacoes do Cliente/Forne-³±±
±±³          ³ cedor.                                                     ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Reg0150 (aPartDoc,aWizard,cEspecie)
Local	lRet		:= .T.
Default cEspecie	:= ""

If !PAR->(DbSeek (aPartDoc[01]))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³TRB PAR = Registro 0150 - Tabela de cadastro de participantes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RecLock("PAR", .T.)
	PAR->PAR_REG		:=	"0150"          					//01    -   lin
	PAR->PAR_CODPAR		:=	aPartDoc[01]						//02	-	COD_PART
	PAR->PAR_NOME		:=	aPartDoc[02]						//03	-	NOME
	PAR->PAR_CODPAI		:=	aPartDoc[03]						//04	-	COD_PAIS
	PAR->PAR_CNPJ		:=	aPartDoc[04]						//05	-	CNPJ
	PAR->PAR_CPF		:=	aPartDoc[05]						//06	-	CPF  
	PAR->PAR_VAZIO		:=  ""             				   		//07    -   VAZIO
	PAR->PAR_UF			:=	aPartDoc[08]						//08	-	UF
	PAR->PAR_IE			:=	IIf("1B"$cEspecie,"",aPartDoc[09])	//09	-	IE
	PAR->PAR_IEST		:=	aPartDoc[10]						//10	-	IE_ST
	PAR->PAR_CODMUN		:=	aPartDoc[11]						//11	-	COD_MUN
	PAR->PAR_IM			:=	aPartDoc[12]						//12	-	IM
	PAR->PAR_SUFRAM		:=	aPartDoc[13]						//13	-	Inscricao SUFRAMA
	MsUnLock()
EndIf
Return (lRet)                    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³R150R175  ³ Autor ³Sueli C. Santos        ³ Data ³02.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³             TABELA DE IDENTIFICACAO DO ITEM                ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2(varios por arquivo)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R150R175 (cAlias)
Local	lRet		:=	.T.
Local	nPos		:=	1
Local	aReg		:=	{}

PAR->(DbGoTop ())
Do While !PAR->(Eof ())
	aReg	:=	{} 
                              
	aAdd( aReg, {PAR->PAR_REG, PAR->PAR_CODPAR, PAR->PAR_NOME, PAR->PAR_CODPAI, PAR->PAR_CNPJ,;
				 PAR->PAR_CPF, PAR->PAR_VAZIO,PAR->PAR_UF, PAR->PAR_IE, PAR->PAR_IEST,;
				 PAR->PAR_CODMUN, PAR->PAR_IM, PAR->PAR_SUFRAM})				 
				 
	GrvRegSef (cAlias,nPos,aReg)

	//sera gerado para o livro RV (Registro de Veiculos)
	//If (EDP->(DbSeek (PAR->PAR_CODPAR)))
	//	aReg	:=	{}
	//	aAdd( aReg, {EDP->EDP_REG, EDP->EDP_CEP, EDP->EDP_END, EDP->EDP_NUM, EDP->EDP_COMPL,;
	//		  		 EDP->EDP_BAIRRO, EDP->EDP_CEPCP, EDP->EDP_CP, EDP->EDP_FONE, EDP->EDP_FAX})
	//	GrvRegSef (cAlias,nPos,aReg)
	//EndIf
	
	PAR->(DbSkip ())
	nPos++
EndDo
Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³AdProd    ³ Autor ³Erick G. Dias          ³ Data ³08.11.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³             ADICIONA ITEM DO MERCADORIA UTILIZADO          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AdProd(cCodProd,aReg0200,aWizard,aReg0205)
Local nPos	  := 0 
Local cDescr  := ""
Local cCodGen := ""
Local cCodLst := ""		
Local cProd   := ""

Local aHist   		:= {}
Local nPos0205		:= 0
Local cCampData	 	:= ""
Local nX	   		:= ""
Local nY	  	 	:= ""
Local dDataDe		:=	CToD ("//")
Local dDataAte		:=	CToD ("//")
Local cCmpDTINCB1	:= ""
Local cB1CodAnt 	:= ""
Local cMVDTINCB1 	:= IIF(AllTrim(GetNewPar("MV_DTINCB1","B1_DATREF")) != "", AllTrim(GetNewPar("MV_DTINCB1","B1_DATREF")),"B1_DATREF")
Local cDescProd		:= ""
Local dDataFinal 	:= CToD("  /  /  ")
Local dDataInici 	:= CToD("  /  /  ")
Local aSef0205	 	:= {}
Local lHistor 		:= SuperGetMv("MV_HISTTAB",,.F.)
Local aAuxDesc 		:= {}
Local aArea			:= {}

Default aWizard := {}
Default aReg0205 := {}

cProd := AllTrim(cCodProd) + xFilial("SB1")

If (aScan (aReg0200, {|aX| AllTrim(aX[3])==AllTrim(cProd)})) =0
	//Tratamento para Registro 0205
	If Len(aWizard) > 0 .And. lHistor
		//Quando função for chamada pelo inventario data inicial e final do arquivo é a mesma. Conforme layout
		 //Para Processar periodo e gerar registro 0205 sera nescessario ajustar data inicio e fim
		dDataDe	 := FirstDate(SToD(aWizard[1][1]))		
		dDataAte := LastDate(SToD(aWizard[1][2]))

		aHist := MsConHist("SB1","","",dDataDe,dDataAte,Substr(cCodProd,1,TamSx3("B1_COD")[1]))
	Endif
	DbSelectArea ("SB1")	//Cadastro de Produtos
	SB1->(DbSetOrder (1))

	If SB1->(dbSeek (xFilial ("SB1")+AllTrim(cCodProd)))
		cDescr:=SB1->B1_DESC
		cCodGen:=	Iif ( Empty(SB1->B1_CODISS), Left (SB1->B1_POSIPI, 2), "00" )
		cCodLst:=SB1->B1_CODISS
		aAdd(aReg0200, {})
		nPos	:=	Len (aReg0200)
		aAdd (aReg0200[nPos], nPos)						//00-Relacionamento com o PAI
		aAdd (aReg0200[nPos], "0200")						//01 - LIN	
		aAdd (aReg0200[nPos], AllTrim(cProd)) 					//02 - COD_ITEM
		aAdd (aReg0200[nPos], SubStr(cDescr,1,80)) 		//03 - DESCR_ITEM
		aAdd (aReg0200[nPos], cCodGen) 					//04 - COD_GEN
		aAdd (aReg0200[nPos], cCodLst) 					//05 - COD_LST
		
		//0205 Inicio
		If len(aHist) > 0
			cCmpDTINCB1 := "SB1->" +cMVDTINCB1 //Campo configurado no parametro MV_DTINCB1
			//Exclui alteracoes que nao sejam de "B1_CODANT"
			For nX := 1 To Len(aHist)
				If Alltrim(aHist[nX][1]) $ "B1_CODANT"
					aAdd(aAuxDesc,aHist[nX])
				EndIf
			Next nX
		Endif
		//Ponto de entrada 
		IF ExistBlock("SEF0205")
			aSef0205 := Execblock("SEF0205", .F., .F., {dDataDe,dDataAte,Substr(cCodProd,1,TamSx3("B1_COD")[1])})
			//Ira verificar se o retorno do ponto de entrada tem todas as informacoes necessarias
			IF ValType(aSef0205) =="A" .And. Len(aSef0205) > 0
				If ValType(aSef0205[1]) <> "A"
					If Len(aSef0205) >= 4
						aAdd(aReg0205, {})
						nPos0205	:=	Len(aReg0205)
						aAdd(aReg0205[nPos0205], nPos)										//00-Relacionamento com o PAI
						aAdd(aReg0205[nPos0205], "0205")									//01 - REG
						aAdd(aReg0205[nPos0205], aSef0205[1])								//02 - Código anterior do item
						aAdd(aReg0205[nPos0205], aSef0205[2])								//03 - DESCR_ANT_ITEM
						aAdd(aReg0205[nPos0205], aSef0205[3])								//04 - Data inicial
						aAdd(aReg0205[nPos0205], aSef0205[4])								//05 - Data Final
					EndIf
				Else
					For nX := 1 To Len(aSef0205)
						If Len(aSef0205[nX]) >= 4
							aAdd(aReg0205, {})
							nPos0205	:=	Len(aReg0205)
							aAdd(aReg0205[nPos0205], nPos)									//00-Relacionamento com o PAI
							aAdd(aReg0205[nPos0205], "0205")								//01 - REG
							aAdd(aReg0205[nPos0205], aSef0205[nX][1])						//02 - Código anterior do item
							aAdd(aReg0205[nPos0205], aSef0205[nX][2])						//03 - DESCR_ANT_ITEM
							aAdd(aReg0205[nPos0205], aSef0205[nX][3])						//04 - Data inicial
							aAdd(aReg0205[nPos0205], aSef0205[nX][4])						//05 - Data Final
						EndIf
					Next nX
				EndIf
			EndIf
		EndIF		
		
		If len(aAuxDesc) >0
			//Ordenando descrescentemente o array aAuxDesc de acordo com DATA e HORA de alteração
			//Foi necessário colocar a condição da hora ser maior ou igual a dez, pois quando concatena os valor maiores que 10 eram ordenados de forma
			//incorreta caso houvesse outra hora com data próxima ou na mesma data.
			aAuxDesc := aSort(aAuxDesc,,,{|x,y| AllTrim(dTOs(x[3]))+IIf(HoraToInt(x[4])>=10,AllTrim(Str(HoraToInt(x[4]))),"0"+AllTrim(Str(HoraToInt(x[4])))) > AllTrim(dTOs(y[3]))+IIf(HoraToInt(y[4])>=10,AllTrim(Str(HoraToInt(y[4]))),"0"+AllTrim(Str(HoraToInt(y[4]))) ) })
			
			//Atribuindo a ultima data de alteração a variavel dDataFinal
			dDataFinal := IIf(Day(UltimoDia(aAuxDesc[1][3]))==Day(aAuxDesc[1][3]),aAuxDesc[1][3]-1,aAuxDesc[1][3])
			
			dDataInici := &(cCmpDTINCB1)
			If Empty(dDataInici)
				dDataInici := SB1->B1_DATREF
			Endif
	
			If Len(aAuxDesc)==1
				//Atribuindo a data da criação do produto a variavel dDataInici por ter efetuado uma alteração do produto				
				If Empty(dDataInici)
					dDataInici := aAuxDesc[1][3]
				Endif
			Else				
				If Empty(dDataInici)
					//Atribuindo a penultima data de alteração a variavel dDataInici independente se houve alteracao ou não no mesmo dia
					dDataInici := aAuxDesc[2][3]
				Endif
			Endif
			
			If Valtype(dDataInici) != Valtype(dDataFinal) .And. !Empty(dDataInici)
				dDataInici := IIF(Valtype(dDataInici) == "C" .And. Valtype(dDataFinal) == "D", cTod(dDataInici)  ,dDataInici )
			EndIf

			//Atribuindo a variavel cDescProd o valor da 'DESCRIçãO ANTERIOR DO PRODUTO' da ultima alteração
			cDescProd := cDescr
			cB1CodAnt := SB1->B1_CODANT

			//Caso não encontre produto anterior utiliza descrição do atual para não ocorrer erro na validaçao
			aArea	:= GetArea() 			
			If SB1->(dbSeek (xFilial ("SB1")+AllTrim(SB1->B1_CODANT)))
				cDescProd := SB1->B1_DESC
			Endif
			//Restaura area para produto do registro 0200, processamento de inventario esta posicionado no produto do registro 0200
			RestArea(aArea)

			//tratamento na geracao do registro 0205 - Alteracao do Item quando um item for alterado na data final do arquivo do Sped Fiscal
	   		If dDataInici < dDataFinal
				nPos0205 := (aScan (aReg0205, {|aX| AllTrim(aX[3])==AllTrim(SB1->B1_CODANT)}))
				If nPos0205 == 0
					aAdd(aReg0205, {})
					nPos0205	:=	Len(aReg0205)
					aAdd(aReg0205[nPos0205], nPos)						//00-Relacionamento com o PAI
					aAdd(aReg0205[nPos0205], "0205")					//01 - Texto fixo contendo "0205"
					aAdd(aReg0205[nPos0205], cB1CODANT)					//02 - Código anterior do item
					aAdd(aReg0205[nPos0205], cDescProd)					//03 - DESCR_ANT_ITEM
					aAdd(aReg0205[nPos0205], dDataInici)			    //04 - Data inicial
					aAdd(aReg0205[nPos0205], dDataFinal)				//05 - Data Final de utilização do código anterior do item
				EndIf
			EndIf
		EndIf
	EndIf	
EndIF

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |Reg0470   ³ Autor ³Erick G. Dias          ³ Data ³08.11.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³             CUPOM FISCAL/ICMS                              ³±±
±±³          ³- Geração do Registro Reg0470                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Reg0470(cAlias,cEspecie,aCmpAntSFT, aTotaliza, cPdv,nRelac)
	Local	nPos		:=	0	
	Local   cEcfFab     :=	""	
	Local   nCro        :=  0
	Local   nCrz        :=  0 
	Local   aReg0470    := {}
	
	//BUSCA NA TABELA SFI O CRO E CRZ PESQUISANDO PELO PDV E DATA DO DOCUMENTO
	If SFI->(dbSeek(xFilial("SFI")+cPdv + DTOS(aCmpAntSFT[6])))	
		nCro     := SFI->FI_CRO
		nCrz     := SFI->FI_NUMREDZ  
		cEcfFab  := SFI->FI_SERPDV
	EndIf
	
	aAdd(aReg0470, {})
	nPos	:=	Len (aReg0470)
	aAdd (aReg0470[nPos], "0470")		     //01-REG
	aAdd (aReg0470[nPos], cEspecie)			 //02-COD_MOD 
	aAdd (aReg0470[nPos], cPdv) 	         //03-ECF_CX 
	aAdd (aReg0470[nPos], cEcfFab)			 //04-ECF_FAB
	aAdd (aReg0470[nPos], nCro)	 			 //05-CRO
	aAdd (aReg0470[nPos], nCrz)     		 //06-CRZ
	aAdd (aReg0470[nPos], aCmpAntSFT[1])	 //07-NUM_DOC 
	aAdd (aReg0470[nPos], cvaltochar(strzero( day(aCmpAntSFT[6]),2))+ cvaltochar(strzero(Month(aCmpAntSFT[6]),2)) + cvaltochar(Year(aCmpAntSFT[6]))) //08-DT_DOC	
	aAdd (aReg0470[nPos], aTotaliza[1])		 //09-VL_DOC 
	aAdd (aReg0470[nPos], aTotaliza[20] )	 //10-VL_ISS 
	aAdd (aReg0470[nPos], aTotaliza[3] ) 	 //19-VL_ICMS
	
	GrvRegSef (cAlias, nRelac, aReg0470)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC020   ³ Autor ³Gustavo G. Rueda       ³ Data ³25.08.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³               NOTA FISCAL (MODELO 01, 04 e 55)             ³±±
±±³          ³                                                            ³±±
±±³          ³Geracao e gravacao do Registro C020                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrb com as informacoes de todos os docu-   ³±±
±±³          ³ mentos fiscais processados.                                ³±±
±±³          ³Somente sera gravado os documentos fiscais modelo 01 e 04   ³±±
±±³          ³ nos outros casos, sera utilizdo para gerar outros registros³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cEntSai -> Flag de indicacao do documento fiscal, 1=Entrada/³±±
±±³          ³ 2=Saida.                                                   ³±±
±±³          ³aPartDoc -> Array com todas as informacoes do Cliente/Forne-³±±
±±³          ³ cedor.                                                     ³±±
±±³          ³cEspecie -> Modelo do documento fiscal                      ³±±
±±³          ³cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³nRelac -> Flag de relacionamento com os sub-registros       ³±±
±±³          ³aCmpAntSFT -> Informacoes de cabecalho do documento fiscal  ³±±
±±³          ³aTotaliza -> Totalizacao de valores da tabela SFT do docu-  ³±±
±±³          ³ mento fiscal do processamento atual no while               ³±±
±±³          ³aRegC020 -> Informacoes sobre todos documentos fiscais pro- ³±±
±±³          ³ cessados no while da funcao principal.                     ³±±
±±³          ³cChave -> Chave para gravacao das observacoes do documento  ³±±
±±³          ³ fiscal referenciado(Registro 0450).                        ³±±
±±³          ³cSituaDoc -> Situacao do documento fiscal conforme funcao   ³±±
±±³          ³ RetSitDoc                                                  ³±±
±±³          ³lAchouSE4 -> Flag de posicionamento da tabela SE4 para a NF ³±±
±±³          ³ em processamento.                                          ³±±
±±³          ³ TARE para geracao do respectivo registro.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegC020(cEntSai, aPartDoc, cEspecie, cAlias, nRelac, aCmpAntSFT, aTotaliza, aRegC020, cChv0450, cSituaDoc, lAchouSE4, lGrava, aTotalIss, lGera)
	Local	nPos	:= 0     
	Local	lRet	:= .F.
	Local	cEmit	:= ""   
	
	Default lGera	:= .F.
	
	If (Empty (aCmpAntSFT[8])) .And. cEntSai=="1"
		cEmit := "1"							
	ElseIf (Empty (aCmpAntSFT[8])) .And. cEntSai=="2"
		cEmit := "0"							
	Else
		If ("S"$aCmpAntSFT[8])
			cEmit := "0" 						
		Else
			cEmit := "1"						
		EndIf
	EndIf            

	If lGera .OR. !(cEmit=="0" .And. cEntSai=="1" .And. Substr(Alltrim(aCmpAntSFT[9]),1,1)$"2")
		aAdd(aRegC020, {})
		nPos	:=	Len (aRegC020)
		aAdd (aRegC020[nPos], "C020")					   		//01 - REG
		aAdd (aRegC020[nPos], STR(Val (cEntSai)-1,1))			//02 - IND_OPER
		aAdd (aRegC020[nPos], cEmit)							//03 - IND_EMIT                 							
		aAdd (aRegC020[nPos], aPartDoc[1])						//04 - COD_PART   
		aAdd (aRegC020[nPos], IIf("1B"$cEspecie,"01",cEspecie))//05 - COD_MOD
		aAdd (aRegC020[nPos], cSituaDoc)				  		//06 - COD_SIT
		aAdd (aRegC020[nPos], aCmpAntSFT[2])  			  		//07 - SER
		aAdd (aRegC020[nPos], aCmpAntSFT[1])  			   		//08 - NUM_DOC               
		aAdd (aRegC020[nPos], aCmpAntSFT[20])  			   		//09 - CHV_NFE
		aAdd (aRegC020[nPos], Iif(cEntSai=="1",cvaltochar(strzero( day(aCmpAntSFT[6]),2)) + cvaltochar(strzero(Month(aCmpAntSFT[6]),2)) + cvaltochar(Year(aCmpAntSFT[6])),"")) //10 - DT_EMISS	
		aAdd (aRegC020[nPos], cvaltochar(strzero( day(aCmpAntSFT[5]),2)) + cvaltochar(strzero(Month(aCmpAntSFT[5]),2)) + cvaltochar(Year(aCmpAntSFT[5]))) //11 - DT_DOC	
		aAdd (aRegC020[nPos], aCmpAntSFT[9])   			   		//12 - COD_NAT
		//	Para ser a vista, a condicao de pagamento deve ser tipo 1 e somente 00 no campo E4_COND.
		//13 - IND_PAGTO
		If (lAchouSE4) .And. ("1"$SE4->E4_TIPO) .And. "00"==AllTrim (SE4->E4_COND)
			aAdd (aRegC020[nPos], "0")	   			  			
		Else	
			aAdd (aRegC020[nPos], "1")	  			  			
		EndIf
		
		aAdd (aRegC020[nPos], aTotaliza[1])															//14 - VL_DOC		-	FT_VALCONT
		aAdd (aRegC020[nPos], aTotaliza[9])					  										//15 - VL_DESC		-	
		aAdd (aRegC020[nPos], 0)         		    		   										//16 - VL_ACMO		-	
		aAdd (aRegC020[nPos], aTotaliza[10])				  										//17 - VL_MERC		-	FT_TOTAL
		aAdd (aRegC020[nPos], aTotaliza[11])				  										//18 - VL_FRT		-	FT_FRETE
		aAdd (aRegC020[nPos], aTotaliza[12])				   										//19 - VL_SEG		-	FT_SEGURO
		aAdd (aRegC020[nPos], aTotaliza[13])														//20 - VL_OUT_DA	-	FT_DESPESA
		aAdd (aRegC020[nPos], Iif(aTotalIss[19]>0,aTotalIss[19],aTotaliza[20]))					//21 - VL_PO_ISS
		aAdd (aRegC020[nPos], aTotaliza[2])					  										//22 - VL_BC_ICMS	-	FT_BASEICM
		aAdd (aRegC020[nPos], aTotaliza[3])					 										//23 - VL_ICMS		-	FT_VALICM
		aAdd (aRegC020[nPos], aTotaliza[4])					   										//24 - VL_BC_ST		-	FT_BASERET
		aAdd (aRegC020[nPos], aTotaliza[5])															//25 - VL_ST		-	FT_ICMSRET
		aAdd (aRegC020[nPos], 0)																		//26 - VL_AT
		aAdd (aRegC020[nPos], aTotaliza[6]) 				   										//27 - VL_IPI		-	FT_VALIPI
	    aAdd (aRegC020[nPos], cChv0450)						  										//28 - COD_INF_OBS		  				 	
          
		lRet := .T.
		If lGrava
		    GrvRegSef (cAlias,nRelac, aRegC020)
	    EndIf
    EndIf
Return (lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC040   ³ Autor ³Erick G. Dias          ³ Data ³29.10.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³             COMPLEMENTO DO DOCUMENTO ISS                   ³±±
±±³          ³                                                            ³±±
±±³          ³- Gravacao dos Registros C040                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3                                                           ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegC040 (cAlias,aTotaliza, aRegC040,nRelacDoc)
	Local	nPos		:=	0		                          
	
	aAdd(aRegC040, {})
	nPos	:=	Len (aRegC040)
	aAdd (aRegC040[nPos], "C040")					//01 - REG
	aAdd (aRegC040[nPos], SM0->M0_CODMUN) 			//02 - COD_MUN_SERV
	aAdd (aRegC040[nPos], aTotaliza[19]) 			//03 - VL_BC_ISS
	aAdd (aRegC040[nPos], aTotaliza[20]) 			//04 - VL_ISS
	aAdd (aRegC040[nPos], aTotaliza[21]) 			//05 - VL_BC_RT_ISS
	aAdd (aRegC040[nPos], aTotaliza[22]) 			//06 - VL_RT_ISS  
	
	GrvRegSef (cAlias,nRelacDoc, aRegC040)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC300   ³ Autor ³Erick G. Dias          ³ Data ³15.05.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³             ITENS DO DOCUMENTO                             ³±±
±±³          ³                                                            ³±±
±±³          ³- Geração do Registro C300                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegC300(cAliasSFT,aRegC300,aReg0200,nItemC300,cSitISS,cSitICM,cAlsSB1,aWizard,aReg0205)
Local nPos       := 0
Local nNcm       := 0
Local nUnidade   := 0
Local cItemC300  := ""

DEFAULT cAlsSB1 := "SB1"
Default aWizard := {}
Default aReg0205:= {}

nNcm := (cAlsSB1)->B1_POSIPI
nUnidade := (cAlsSB1)->B1_UM

cItemC300 := Alltrim(Strzero(nItemC300,4))

aAdd(aRegC300, {})
nPos	:=	Len (aRegC300)

aAdd (aRegC300[nPos], "C300")														//01 - REG
aAdd (aRegC300[nPos], cItemC300)													//02 - NUM_ITEM
aAdd (aRegC300[nPos], AllTrim((cAliasSFT)->FT_PRODUTO) + xFilial("SB1"))			//03 - COD_ITEM
aAdd (aRegC300[nPos], nUnidade)														//04 - UNID
aAdd (aRegC300[nPos], (cAliasSFT)->FT_TOTAL/(cAliasSFT)->FT_QUANT)					//05 - VL_UNIT
aAdd (aRegC300[nPos], iif((cAliasSFT)->FT_TIPO$"ICP",1,(cAliasSFT)->FT_QUANT))		//06 - QTD - (tratamento para nf de complemento de icms)
aAdd (aRegC300[nPos], (cAliasSFT)->FT_DESCONT)										//07 - VL_DESC_I
aAdd (aRegC300[nPos], 0)															//08 - VL_ACMO_I
aAdd (aRegC300[nPos], ((cAliasSFT)->FT_TOTAL - (cAliasSFT)->FT_DESCONT))			//09 - VL_ITEM - Valor Liquido do Item
aAdd (aRegC300[nPos], nNcm)															//10 - COD_NCM
aAdd (aRegC300[nPos], Iif((cAliasSFT)->FT_TIPO == "S",cSitISS,cSitICM))			//11 - CST
aAdd (aRegC300[nPos], (cAliasSFT)->FT_CFOP)											//12 - CFOP

If !(cAliasSFT)->FT_TIPO == "S"
	aAdd (aRegC300[nPos], (cAliasSFT)->FT_BASEICM)						//13 - VL_BC_ICMS_I
	aAdd (aRegC300[nPos], (cAliasSFT)->FT_ALIQICM)						//14 - ALIQ_IMCS
	aAdd (aRegC300[nPos], (cAliasSFT)->FT_VALICM)						//15 - VL_ICMS_I
	aAdd (aRegC300[nPos], 0)											//16 - VL_BC_ST_I
	aAdd (aRegC300[nPos], 0)											//17 - ALIQ_ST
	aAdd (aRegC300[nPos], 0)											//18 - VL_ICMS_ST_I
Else
	aAdd (aRegC300[nPos], 0)											//13 - VL_BC_ICMS_I
	aAdd (aRegC300[nPos], 0)											//14 - ALIQ_IMCS
	aAdd (aRegC300[nPos], 0)											//15 - VL_ICMS_I
	aAdd (aRegC300[nPos], (cAliasSFT)->FT_BASEICM)						//16 - VL_BC_ST_I
	aAdd (aRegC300[nPos], (cAliasSFT)->FT_ALIQICM)						//17 - ALIQ_ST
	aAdd (aRegC300[nPos], (cAliasSFT)->FT_VALICM)						//18 - VL_ICMS_ST_I
EndIf

If (cAliasSFT)->FT_BASERET > 0
	aRegC300[nPos][16] := (cAliasSFT)->FT_BASERET						//16 - VL_BC_ST_I
	aRegC300[nPos][17] := (cAliasSFT)->FT_ALIQSOL						//17 - ALIQ_ST
	aRegC300[nPos][18] := (cAliasSFT)->FT_ICMSRET						//18 - VL_ICMS_ST_I
EndIf

aAdd (aRegC300[nPos], (cAliasSFT)->FT_BASEIPI)							//19 - BL_BC_IPI
aAdd (aRegC300[nPos], (cAliasSFT)->FT_ALIQIPI)							//20 - ALIQ_IPI
aAdd (aRegC300[nPos], (cAliasSFT)->FT_VALIPI)							//21 -VL_IPI_I

//ADICIONA PRODUTO UTILIZADO NO REGISTRO 0200
AdProd((cAliasSFT)->FT_PRODUTO,@aReg0200,aWizard,@aReg0205)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC310   ³ Autor ³Erick G. Dias          ³ Data ³05.11.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³             COMPLEMENTO DO ITEM - ISS                      ³±±
±±³          ³                                                            ³±±
±±³          ³- Geração do Registro C310                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³4                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegC310(aTotaliza,aRegC310, nAlqIss, cSitISS)
	Local	nPos		:=	0	
	
	aAdd(aRegC310, {})
	nPos	:=	Len (aRegC310)
	aAdd (aRegC310[nPos], "C310")		     //01 - REG    
	aAdd (aRegC310[nPos], cSitISS)           //02 - CSTISS	
	aAdd (aRegC310[nPos], aTotaliza[19])    //03 - VL_BC_ISS_I
	aAdd (aRegC310[nPos], nAlqIss)          //04 - ALIQ_ISS
	aAdd (aRegC310[nPos], aTotaliza[20])    //05 - VL_ISS_I 
	//Inclusão do campo "CTISS - Código de Tributação do ISS"  	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RegC550   ³ Autor ³Erick G. Dias          ³ Data ³05.11.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³             DOCUMENTO - NF FISCAL VENDA CONSUMIDOR         ³±±
±±³          ³             CÓDIGO 02                                      ³±±
±±³          ³- Geração do Registro RegC550                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegC550 (cEspecie, cAlias, nRelac, aCmpAntSFT, aTotaliza, aRegC550, cSituaDoc, lAchouSE4,cCop, cChv0450,lGravac560)
	Local	nPos		:=	0	
	Local 	cPessoa		:=  0
	Local 	cCgc		:=  0
	Local   lRet        := .F.
	
	If SA1->(dbSeek(xFilial("SA1")+aCmpAntSFT[3]+aCmpAntSFT[4]))		
		cPessoa := SA1->A1_PESSOA
		cCgc    := SA1->A1_CGC	
	EndIf
		
	aAdd(aRegC550, {})
	nPos	:=	Len (aRegC550)
	aAdd (aRegC550[nPos], "C550")		     //01-REG
	
	If Alltrim(cPessoa) == "F"
		aAdd (aRegC550[nPos], cCgc)			 //02-CPF
		aAdd (aRegC550[nPos], "")			 //03-CNP
	Else
		aAdd (aRegC550[nPos], "")			 //02-CPF
		aAdd (aRegC550[nPos], cCgc)			 //03-CNP	
	EndIf	
	
	aAdd (aRegC550[nPos], cEspecie)			 //04-COD_MOD
	aAdd (aRegC550[nPos], cSituaDoc) 		 //05-COD_SIT
	aAdd (aRegC550[nPos], aCmpAntSFT[2]) 	 //06-SER	
	aAdd (aRegC550[nPos], IIF(cEspecie == "02" .AND. ALLTRIM(aCmpAntSFT[2]) == "D","1",""))				 //07-SUB
	aAdd (aRegC550[nPos], aCmpAntSFT[1])	 //08-NUM_DOC
	aAdd (aRegC550[nPos], cvaltochar(strzero( day(aCmpAntSFT[6]),2)) + cvaltochar(strzero(Month(aCmpAntSFT[6]),2)) +cvaltochar(Year(aCmpAntSFT[6])))     //09-DT_DOC 	
	aAdd (aRegC550[nPos], cCop)             //10-COP 
	aAdd (aRegC550[nPos], aTotaliza[1])		 //11-VL_DOC	
	aAdd (aRegC550[nPos], aTotaliza[9]) 	 //12-VL_DESC
	aAdd (aRegC550[nPos], 0) 	    		 //13-VL_ACMO
	aAdd (aRegC550[nPos], aTotaliza[10]) 	 //14-VL_MERC
	aAdd (aRegC550[nPos], aTotaliza[2]) 	 //15-VL_BC_ICMS
	aAdd (aRegC550[nPos], aTotaliza[3]) 	 //16-VL_ICMS
	aAdd (aRegC550[nPos], cChv0450 )			 	 //17-COD_INF_OBS
	
	lRet := .T.
	If lGravac560
		GrvRegSef (cAlias,nRelac, aRegC550)      
    EndIf
  
Return (lRet)
	

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC560   ³ Autor ³Erick G. Dias          ³ Data ³05.11.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³             ITENS DO DOCUMENTO (CÓDIGO 02)                 ³±±
±±³          ³                                                            ³±±
±±³          ³- Geração do Registro RegC560                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegC560(cAliasSFT,aRegC560,aReg0200,cSitICM,cAlsSB1,aWizard,aReg0205)

Local nPos := 0
Local nNcm := 0
Local nUnidade := 0
Local cProd := ""

DEFAULT cAlsSB1 := "SB1"
Default aWizard := {}
Default aReg0205:= {}

nNcm     := (cAlsSB1)->B1_POSIPI
nUnidade := (cAlsSB1)->B1_UM

cProd := ALLTRIM((cAliasSFT)->FT_PRODUTO)+xFilial("SB1")
	
aAdd(aRegC560, {})
nPos	:=	Len (aRegC560)
aAdd (aRegC560[nPos], "C560")					   		                //01 - REG
aAdd (aRegC560[nPos], (cAliasSFT)->FT_ITEM)					   	  	//02 - NUM_ITEM
aAdd (aRegC560[nPos], ALLTRIM(cProd))					   		//03 - COD_ITEM
aAdd (aRegC560[nPos], nUnidade)					   		      			//04 - UNID
aAdd (aRegC560[nPos], (cAliasSFT)->FT_TOTAL/(cAliasSFT)->FT_QUANT)    //05 - VL_UNIT
aAdd (aRegC560[nPos], (cAliasSFT)->FT_QUANT)					   		//06 - QTD
aAdd (aRegC560[nPos], (cAliasSFT)->FT_DESCONT)					   		//07 - VL_DESC_I
aAdd (aRegC560[nPos], 0)					   		        			//08 - VL_ACMO_I
aAdd (aRegC560[nPos], (cAliasSFT)->FT_VALCONT)					   		//09 - VL_ITEM	
aAdd (aRegC560[nPos], cSitICM)					   		       			//10 - CST
aAdd (aRegC560[nPos], (cAliasSFT)->FT_CFOP)					   	    //11 - CFOP	
aAdd (aRegC560[nPos], (cAliasSFT)->FT_BASEICM)					   		//12 - VL_BC_ICMS_I
aAdd (aRegC560[nPos], (cAliasSFT)->FT_ALIQICM)					   		//13 - ALIQ_IMCS
aAdd (aRegC560[nPos], (cAliasSFT)->FT_VALICM)					   		//14 - VL_ICMS_I	
	
//ADICIONA PRODUTO UTILIZADO NO REGISTRO 0200
AdProd((cAliasSFT)->FT_PRODUTO,@aReg0200,aWizard,@aReg0205)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RegC600   ³ Autor ³Erick G. Dias          ³ Data ³08.11.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³             CUPOM FISCAL/ICMS                              ³±±
±±³          ³- Geração do Registro RegC600                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegC600(cEspecie, cAlias, nRelac, aCmpAntSFT, aTotaliza, aRegC600, cPdv, cSituaDoc,cCop,cSitICM)
	
Local	nPos		:=	0	
Local   cEcfFab     :=	""	
Local   nCro        :=  0
Local   nCrz        :=  0 
Local   cPessoa     := ""
Local   cCgc        := ""
	
//BUSCA NA TABELA SFI O CRO E CRZ PESQUISANDO PELO PDV E DATA DO DOCUMENTO
If SFI->(dbSeek(xFilial("SFI")+cPdv + DTOS(aCmpAntSFT[6])))	
	nCro     := SFI->FI_CRO
	nCrz     := SFI->FI_NUMREDZ
	cEcfFab  := SFI->FI_SERPDV 
EndIf
	
If SA1->(dbSeek(xFilial("SA1")+aCmpAntSFT[3]+aCmpAntSFT[4]))		
	cPessoa := SA1->A1_PESSOA
	cCgc    := SA1->A1_CGC	
EndIf
	
aAdd(aRegC600, {})
nPos	:=	Len (aRegC600)
aAdd (aRegC600[nPos], "C600")		     //01-REG    

If AllTrim(cPessoa) == "F"
	aAdd (aRegC600[nPos], cCgc)			 //02-CPF
	aAdd (aRegC600[nPos], "")			 //03-CNPJ	
Else
	aAdd (aRegC600[nPos], "")			 //02-CPF
	aAdd (aRegC600[nPos], cCgc)			 //03-CNPJ
EndIf
	
aAdd (aRegC600[nPos], cEspecie)			 //04-COD_MOD
aAdd (aRegC600[nPos], cSituaDoc) 	     //05-COD_SIT	
aAdd (aRegC600[nPos], cPdv) 	         //06-ECF_CX 		
aAdd (aRegC600[nPos], cEcfFab)			 //07-ECF_FAB	
aAdd (aRegC600[nPos], nCro)	 			 //08-CRO
aAdd (aRegC600[nPos], nCrz)     		 //09-CRZ	
aAdd (aRegC600[nPos], aCmpAntSFT[1])	 //10-NUM_DOC
aAdd (aRegC600[nPos], cvaltochar(strzero( day(aCmpAntSFT[6]),2)) + cvaltochar(strzero(Month(aCmpAntSFT[6]),2)) + cvaltochar(Year(aCmpAntSFT[6])))	 //11-DT_DOC	
aAdd (aRegC600[nPos], IIf(Empty(aCmpAntSFT[7]),cCop,"OP00")) //12-COP
aAdd (aRegC600[nPos], aTotaliza[1])		 //13-VL_DOC
aAdd (aRegC600[nPos], 0) 	             //14-VL_CANC_ICMS
aAdd (aRegC600[nPos],  aTotaliza[9]) 	 //15-VL_DESC_ICMS
aAdd (aRegC600[nPos], 0) 	             //16-VL_ACMO_ICMS	
aAdd (aRegC600[nPos], aTotaliza[20] )	 //17-VL_OP_ISS	
aAdd (aRegC600[nPos], aTotaliza[2] ) 	 //18-VL_BC_ICMS
aAdd (aRegC600[nPos], aTotaliza[3] ) 	 //19-VL_ICMS
aAdd (aRegC600[nPos], aTotaliza[7] )	 //20-VL_ISN
aAdd (aRegC600[nPos], aTotaliza[23] )   //21-VL_NT
aAdd (aRegC600[nPos], aTotaliza[25] ) 	//22-VL_ICMS_ST 
   
GrvRegSef (cAlias,nRelac, aRegC600)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC605   ³ Autor ³Erick G. Dias          ³ Data ³08.11.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³             COMPLEMENTO DO DOCUMENTO ISS                   ³±±
±±³          ³                                                            ³±±
±±³          ³- Gravacao dos Registros C605                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3                                                           ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegC605 (cAlias,aTotaliza, aRegC605,nRelacDoc)
	Local	nPos		:=	0	
	//
	aAdd(aRegC605, {})
	nPos	:=	Len (aRegC605)
	aAdd (aRegC605[nPos], "C605")			   		//01 - LIN	
	aAdd (aRegC605[nPos], 0) 						//02 - VL_CANC_ISS
	aAdd (aRegC605[nPos], 0) 						//03 - VL_DESC_ISS
	aAdd (aRegC605[nPos], 0) 						//04 - VL_ACMO_ISS
	aAdd (aRegC605[nPos], aTotaliza[19]) 			//05 - VL_BC_ISS
	aAdd (aRegC605[nPos], aTotaliza[20]) 			//06 - VL_ISS	  
	aAdd (aRegC605[nPos], 0) 						//07 - VL_ISN_ISS
	aAdd (aRegC605[nPos], 0) 						//08 - VL_NT_ISS
	GrvRegSef (cAlias,nRelacDoc, aRegC605)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC610   ³ Autor ³Erick G. Dias          ³ Data ³08.11.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³             ITENS DO DOCUMENTO (ECF)                       ³±±
±±³          ³                                                            ³±±
±±³          ³- Geração do Registro RegC610                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   
Static Function RegC610(cAliasSFT,aRegC610,aReg0200,cSitICM,nItemNF,aWizard,aReg0205)
	Local	nPos		:=	0	
	Local   nNcm        :=  0
	Local   nUnidade    :=  0
    Local   cItemNF     :=  ""
    Local   cAuxCfop    :=  ""
    Local 	cProd		:=  ""
    
    cAuxCfop := IIf(Empty((cAliasSFT)->FT_DTCANC),(cAliasSFT)->FT_CFOP,"0000")
	
	If SB1->(dbSeek (xFilial ("SB1")+(cAliasSFT)->FT_PRODUTO))
		nNcm     := SB1->B1_POSIPI
		nUnidade := SB1->B1_UM
	EndIf  	
	cProd := Alltrim((cAliasSFT)->FT_PRODUTO) + xFilial("SB1")
	cItemNF := Alltrim(Strzero(nItemNF,4))
	aAdd(aRegC610, {})
	nPos	:=	Len (aRegC610)
	aAdd (aRegC610[nPos], "C610")					   		                //01 - REG     
	aAdd (aRegC610[nPos], cItemNF)                                          //02 - NUM_ITEM     					   	            
	aAdd (aRegC610[nPos], Alltrim(cProd))							   		//03 - COD_ITEM            
	aAdd (aRegC610[nPos], nUnidade)					   		      		   	//04 - UNID
	aAdd (aRegC610[nPos], (cAliasSFT)->FT_TOTAL/ (cAliasSFT)->FT_QUANT)	//05 - VL_UNIT --DEVE SER IGUAL AO VALOR BRUTO
	aAdd (aRegC610[nPos], (cAliasSFT)->FT_QUANT)					   	  	//06 - QTD
	aAdd (aRegC610[nPos], (cAliasSFT)->FT_DESCONT)					   		//07 - VL_DESC_I
	aAdd (aRegC610[nPos], 0)					   		        		    //08 - VL_ACMO_I
	aAdd (aRegC610[nPos], (cAliasSFT)->FT_VALCONT)                      	//09 - VL_ITEM	--DEVE SER IGUAL AO VALOR liquido
	aAdd (aRegC610[nPos], cSitICM)				   		        		  	//10 - CST
	aAdd (aRegC610[nPos], cAuxCfop)					   	   	              	//11 - CFOP	
	aAdd (aRegC610[nPos], (cAliasSFT)->FT_BASEICM)					   		//12 - VL_BC_ICMS_I
	aAdd (aRegC610[nPos], (cAliasSFT)->FT_ALIQICM)					   	   								//13 - ALIQ_IMCS
	aAdd (aRegC610[nPos], Round((cAliasSFT)->FT_VALICM,2))				   								//14 - VL_ICMS_I		
	aAdd (aRegC610[nPos], iif("40"$cSitICM,(cAliasSFT)->FT_ISENICM,0))	  								//15 - VL_ISN_I
	aAdd (aRegC610[nPos], If("5405"$(cAliasSFT)->FT_CFOP,0,IIf("41"$cSitICM,(cAliasSFT)->FT_OUTRICM,0)))   //16 - VL_NT_I
	aAdd (aRegC610[nPos], If("5405"$(cAliasSFT)->FT_CFOP,IIf("40"$cSitICM,(cAliasSFT)->FT_ISENICM+(cAliasSFT)->FT_ISENRET,(cAliasSFT)->FT_OUTRICM+(cAliasSFT)->FT_OUTRRET),0)) 	//17 - VL_ST_I	       				    
	
	//ADICIONA PRODUTO UTILIZADO NO REGISTRO 0200
	AdProd((cAliasSFT)->FT_PRODUTO,@aReg0200,aWizard,@aReg0205)	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegC615   ³ Autor ³Erick G. Dias          ³ Data ³08.11.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³             COMPLEMENTO DO ITEM - ISS                      ³±±
±±³          ³                                                            ³±±
±±³          ³- Geração do Registro C615                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³4                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegC615(aTotaliza,aRegC615, nAlqIss)
	Local	nPos		:=	0	      
	
	aAdd(aRegC615, {})
	nPos	:=	Len (aRegC615)
	aAdd (aRegC615[nPos], "C615")		     //01 - REG
	aAdd (aRegC615[nPos], aTotaliza[19])     //02 - VL_BC_ISS_I
	aAdd (aRegC615[nPos], nAlqIss)           //03 - ALIQ_ISS
	aAdd (aRegC615[nPos], aTotaliza[20])     //04 - VL_ISS_I  	
	aAdd (aRegC615[nPos], 0)                 //05 - VL_ISN_ISS_I
	aAdd (aRegC615[nPos], 0)                 //06 - VL_NT_ISS_I  	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Reg0400   ³ Autor ³Sueli C. Santos        ³ Data ³02.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³        TABELA DE NATUREZA DA OPERACAO/PRESTACAO            ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao do Registro 0400                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef com os CFOPs utilizados nos documentos.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2(varios por arquivo)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCfop -> Cfop do documento fiscal                           ³±±
±±³          ³aReg0400 -> Array com o conteudo do registro para posteior  ³±±
±±³          ³ gravacao.                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Reg0400 (cCfop, aReg0400,cCOP)
Local	lRet	:=	.T.
Local	nPos	:=	aScan (aReg0400, {|aX| aX[2]==cCfop})

If (nPos==0)
	aAdd (aReg0400, {})
	nPos	:=	Len (aReg0400)
	aAdd (aReg0400[nPos], "0400")							//01-REG
	aAdd (aReg0400[nPos], cCfop)							//02-COD_NAT
    //03-DESCR_NAT
	If (SX5->(DbSeek (xFilial ("SX5")+"13"+cCfop)))
		aAdd (aReg0400[nPos], AllTrim (X5Descri()))	
	Else
		aAdd (aReg0400[nPos], "")							
	EndIf 
	aAdd (aReg0400[nPos], cCOP)	                           //04-COP	
	
EndIf
Return (lRet)

/*/                                                                                                 	
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Reg0450   ³ Autor ³Sueli C. Santos        ³ Data ³02.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³        TABELA DE INFORMACAO COMPLEMENTAR/OBSERVACAO        ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro 0450                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef com as observacoes do documeto referen-³±±
±±³          ³ ciado                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2(varios por arquivo)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³nRelac -> Flag de relacionamento com os sub-registro        ³±±
±±³          ³cObs -> Observacao do documento fiscal referenciado         ³±±
±±³          ³cChave -> Codigo de referencia entre o documento fiscal e   ³±±
±±³          ³ este registro.                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Reg0450 (cAlias, nRelac, cObs, cChv0450)
Local	aReg0450	:=	{}
Local	lRet		:=	.T.
Local	nPos		:=	0
	
nPos := aScan(aReg0450, {|aX| aX[2]==cChv0450})     
    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gravacao do REGISTRO 0450³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nPos == 0
	cObs	:=  replicate(".", 10) + Left (cObs, Len (cObs)-2)

	aAdd(aReg0450, {})
	nPos	:=	Len (aReg0450)
	aAdd (aReg0450[nPos], "0450")    //01-LIN
	aAdd (aReg0450[nPos], cChv0450)  //02-COD_INF_OBS
	aAdd (aReg0450[nPos], cObs )     //03-TXT

	GrvRegSef (cAlias, nRelac, aReg0450)
EndIf

Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Reg0455   ³ Autor ³Gustavo G. Rueda       ³ Data ³25.08.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³                     NORMA REFERENCIADA                     ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro 0455                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef com o embasamento legal para tais      ³±±
±±³          ³ observacoes (nao e necessariamnte obrigatorio p/ cada 0450)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3(1:N) Para cada 0450                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³nRelac -> Flag de relacionamento com os sub-registros       ³±±
±±³          ³aLeis -> Array contemdo o embasamento legal para cada       ³±±
±±³          ³ observacao do documento fiscal.                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Reg0455 (cAlias, nRelac, aLeis,aReg0455)
Local	lRet		:=	.T.
Local	nPos		:=	0
Local	nX			:=	0
default aReg0455	:=	{}

For nX := 1 To Len (aLeis)
	IF ascan(areg0455,{|aX| aX[1]=="0455" .and. aX[2]==aLeis[nX]})==0
		aAdd(aReg0455, {})
		nPos	:=	Len (aReg0455)
		aAdd (aReg0455[nPos], "0455")
		aAdd (aReg0455[nPos], aLeis[nX])
	EndIF
Next (nX)

//GrvRegSef (cAlias, nRelac, aReg0455)

Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Reg0460   ³ Autor ³Gustavo G. Rueda       ³ Data ³25.08.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³           DOCUMENTO DE ARRECADACAO REFERENCIADO            ³±±
±±³          ³                                                            ³±±
±±³Descri‡…o ³Geracao e gravacao do Registro 0460                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef com todas as guias de recolhimento com ³±±
±±³          ³ a data de referencia no periodo apurado.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3(1:N) para cada Registro 450                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard -> Informacoes preenchidas no wizard da rotina      ³±±
±±³          ³cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³dDataDe -> Periodo inicial de apuracao                      ³±±
±±³          ³dDataAte -> Periodo final de apuracao                       ³±±
±±³          ³nRelac -> Flag de relacionamento com os sub-registro        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Reg0460 (aWizard,cAlias,dDataDe,dDataAte,nRelac,aCmpAntSFT,aPartDoc,lSm0,cTpMov)
Local	aReg0460	:=	{}
Local	lRet		:=	.T.
Local	nPos		:=	0
/*
Local	aSf6	:=	{"SF6", ""}

FsQuery (aSf6, 1, "F6_FILIAL='"+xFilial ("SF6")+"' AND F6_ANOREF="+StrZero(Year(dDataDe), 4)+" AND F6_MESREF="+StrZero (Month (dDataAte), 2)+" AND F6_TIPOIMP IN ('1', '3') AND F6_DOC='"+aCmpAntSFT[1]+"' AND F6_SERIE='"+aCmpAntSFT[2]+"'",;
			       "F6_FILIAL='"+xFilial ("SF6")+"' .AND. StrZero (F6_ANOREF, 4)=='"+StrZero (Year (dDataDe), 4)+"' .AND. StrZero (F6_MESREF, 2)=='"+StrZero (Month (dDataAte), 2)+"' .AND. F6_TIPOIMP$'13' .AND. F6_DOC=='"+aCmpAntSFT[1]+"' .AND. F6_SERIE=='"+aCmpAntSFT[2]+"'", "F6_TIPOIMP+F6_CODREC")

SF6->(DbGotop ())	
Do While !SF6->(Eof ())
             	
	aAdd(aReg0460, {})
	nPos	:=	Len (aReg0460)
	aAdd (aReg0460[nPos], "0460")						//01 - REG
	aAdd (aReg0460[nPos], "1")							//02 - COD_DA
	aAdd (aReg0460[nPos], "GUIA NAC RE")		        //03 - DESCR_DA
	aAdd (aReg0460[nPos], SF6->F6_EST)					//04 - UF
	if lSm0
		If(Len(SM0->M0_CODMUN)<=5)
			aAdd (aReg0460[nPos],RetCodEst(SM0->M0_ESTENT))//05- COD_MUN
		Else
			aAdd (aReg0460[nPos],SM0->M0_CODMUN)	 		//05- COD_MUN
		EndIf
	else
		aAdd (aReg0460[nPos], aPartDoc[11])				//05 - COD_MUN
	Endif
	aAdd (aReg0460[nPos], StrZero(SF6->F6_MESREF,2) + StrZero(SF6->F6_ANOREF,4))		//06 - PER_REF
	aAdd (aReg0460[nPos], SF6->F6_NUMERO)				//07 - NUM_DA
	aAdd (aReg0460[nPos], SF6->F6_VALOR)				//08 - VL_DA
	aAdd (aReg0460[nPos], cvaltochar(strzero( day(SF6->F6_DTVENC),2)) + cvaltochar(strzero(Month(SF6->F6_DTVENC),2)) +cvaltochar(Year(SF6->F6_DTVENC)) )	        //09 - DT_VCTO
	aAdd (aReg0460[nPos], 0)							//10 - VL_DESC
	aAdd (aReg0460[nPos], 0)							//11 - VL_MOR		
	aAdd (aReg0460[nPos], SF6->F6_JUROS)				//12 - VL_JUROS
	aAdd (aReg0460[nPos], SF6->F6_MULTA)				//13 - VL_MULTA				
	aAdd (aReg0460[nPos], SF6->F6_VALOR)				//14 - VL_PAGTO	
	aAdd (aReg0460[nPos], cvaltochar(strzero( day(SF6->F6_DTPAGTO2),2)) + cvaltochar(strzero(Month(SF6->F6_DTPAGTO2),2)) +cvaltochar(Year(SF6->F6_DTPAGTO2))  ) //15 - DT_PGTO 		
	aAdd (aReg0460[nPos], SF6->F6_AUTENT)				//16 - AUT_BCO						
	
	SF6->(DbSkip ())
EndDo	

FsQuery (aSf6, 2) */
								
If SF6->(MsSeek(xFilial("SF6")+cTpMov+aCmpAntSFT[19]+aCmpAntSFT[1]+aCmpAntSFT[2]+aCmpAntSFT[3]+aCmpAntSFT[4]))

	While !SF6->(Eof()) .And. xFilial("SF6") == aCmpAntSFT[22] .And. SF6->F6_OPERNF == cTpMov .And.;
		SF6->F6_TIPODOC == aCmpAntSFT[19] .And. SF6->F6_DOC == aCmpAntSFT[1] .And.;
		SF6->F6_SERIE == aCmpAntSFT[2] .And. SF6->F6_CLIFOR == aCmpAntSFT[3] .And.;
		SF6->F6_LOJA == aCmpAntSFT[4] .And. SF6->F6_ANOREF == Year(dDataDe)  .And.;
		SF6->F6_MESREF == Month(dDataAte) .And. SF6->F6_TIPOIMP $ "1|3"   
		            	
		aAdd(aReg0460, {})
		nPos	:=	Len (aReg0460)
		aAdd (aReg0460[nPos], "0460")						//01 - REG
		aAdd (aReg0460[nPos], "1")							//02 - COD_DA
		aAdd (aReg0460[nPos], "GUIA NAC RE")		        //03 - DESCR_DA
		aAdd (aReg0460[nPos], SF6->F6_EST)					//04 - UF
		if lSm0
			If(Len(SM0->M0_CODMUN)<=5)
				aAdd (aReg0460[nPos],RetCodEst(SM0->M0_ESTENT))//05- COD_MUN
			Else
				aAdd (aReg0460[nPos],SM0->M0_CODMUN)	 		//05- COD_MUN
			EndIf
		else
			aAdd (aReg0460[nPos], aPartDoc[11])				//05 - COD_MUN
		Endif
		aAdd (aReg0460[nPos], StrZero(SF6->F6_MESREF,2) + StrZero(SF6->F6_ANOREF,4))		//06 - PER_REF
		aAdd (aReg0460[nPos], SF6->F6_NUMERO)				//07 - NUM_DA
		aAdd (aReg0460[nPos], SF6->F6_VALOR)				//08 - VL_DA
		aAdd (aReg0460[nPos], cvaltochar(strzero( day(SF6->F6_DTVENC),2)) + cvaltochar(strzero(Month(SF6->F6_DTVENC),2)) +cvaltochar(Year(SF6->F6_DTVENC)) )	        //09 - DT_VCTO
		aAdd (aReg0460[nPos], 0)							//10 - VL_DESC
		aAdd (aReg0460[nPos], 0)							//11 - VL_MOR		
		aAdd (aReg0460[nPos], SF6->F6_JUROS)				//12 - VL_JUROS
		aAdd (aReg0460[nPos], SF6->F6_MULTA)				//13 - VL_MULTA				
		aAdd (aReg0460[nPos], SF6->F6_VALOR)				//14 - VL_PAGTO	
		aAdd (aReg0460[nPos], cvaltochar(strzero( day(SF6->F6_DTPAGTO2),2)) + cvaltochar(strzero(Month(SF6->F6_DTPAGTO2),2)) +cvaltochar(Year(SF6->F6_DTPAGTO2))  ) //15 - DT_PGTO 		
		aAdd (aReg0460[nPos], SF6->F6_AUTENT)				//16 - AUT_BCO						
		
		SF6->(DbSkip ())
	EndDo	

EndIf

GrvRegSef (cAlias, nRelac, aReg0460)

Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Reg0465   ³ Autor ³Gustavo G. Rueda       ³ Data ³25.08.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³               DOCUMENTO FISCAL REFERENCIADO                ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro 0465                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef com as informacoes de todos os docu-   ³±±
±±³          ³ mentos fiscais processados.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3(1:N) Para cada Registro 0450                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³nRelac -> Flag de relacionamento com os sub-registros       ³±±
±±³          ³aRegC020 -> Informacoes sobre todos documentos fiscais pro- ³±±
±±³          ³ cessados no while da funcao principal.                     ³±±
±±³          ³cEntSai -> Flag de indicacao do documento fiscal, 1=Entrada/³±±
±±³          ³ 2=Saida.                                                   ³±±
±±³          ³aPartDoc -> Array com todas as informacoes do Cliente/Forne-³±±
±±³          ³ cedor.                                                     ³±±
±±³          ³aTotalISS -> Totalizador do ISS por NF                      ³±±
±±³          ³lSm0 -> Verifica se devo utilizar as informacoes do sigamat,³±±
±±³          ³ este tratamento se dah para notas fiscais de entrada com   ³±±
±±³          ³ formulario proprio igual SIM                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Reg0465 (cAlias, nRelac, aRegC020, cEntSai, aPartDoc, aTotalISS, lSm0, aCmpAntSFT)
	Local	lRet   		:=	.T.
	Local	nPos		:=	0
	Local	aReg0465	:=	{}
	//
    If Len(aRegC020) > 0 .And. (lSm0 .Or. Len(aPartDoc) > 0)
		aAdd(aReg0465, {})
		nPos	:=	Len (aReg0465)
		aAdd (aReg0465[nPos], "0465")	 	   					//01 - REG
		aAdd (aReg0465[nPos], STR(Val (cEntSai)-1,1))			//02 - IND_OPER	
		aAdd (aReg0465[nPos], aRegC020[1][3])	 				//03 - IND_EMIT
	    If lSm0
	    	If Len(SM0->M0_CGC)==14
				aAdd (aReg0465[nPos], SM0->M0_CGC)				//04 - CNPJ
				aAdd (aReg0465[nPos], "")		 				//05 - CPF
			Else
				aAdd (aReg0465[nPos], "")						//04 - CNPJ
				aAdd (aReg0465[nPos], SM0->M0_CGC)	 			//05 - CPF
			EndIf
			aAdd (aReg0465[nPos], SM0->M0_ESTENT) 				//06 - UF
			aAdd (aReg0465[nPos], SM0->M0_INSC)			    	//07 - IE
	
			If(Len(SM0->M0_CODMUN)<=5)
				aAdd (aReg0465[nPos],RetCodEst(SM0->M0_ESTENT))//08 - COD_MUN
			Else
				aAdd (aReg0465[nPos],SM0->M0_CODMUN)	 		//08 - COD_MUN
			EndIf
			aAdd (aReg0465[nPos], SM0->M0_INSCM)				//09 - IM
	    Else
			aAdd (aReg0465[nPos], aPartDoc[4])	 				//04 - CNPJ
			aAdd (aReg0465[nPos], aPartDoc[5])	 				//05 - CPF
			aAdd (aReg0465[nPos], aPartDoc[8])	 				//06 - UF
			aAdd (aReg0465[nPos], aPartDoc[9])	 				//07 - IE
			aAdd (aReg0465[nPos], aPartDoc[11]) 		 		//08 - COD_MUN
			aAdd (aReg0465[nPos], aPartDoc[12])		 			//09 - IM
		EndIf
		aAdd (aReg0465[nPos], aRegC020[1][5])	 				//10 - COD_MOD
		aAdd (aReg0465[nPos], aRegC020[1][6])	 				//11 - COD_SIT
		aAdd (aReg0465[nPos], aRegC020[1][7])	 				//12 - SER
		aAdd (aReg0465[nPos], "")				            	//13 - SUB    
		aAdd (aReg0465[nPos], aCmpAntSFT[20])                  //14 - CHAVE NFE (MOD 55)
		aAdd (aReg0465[nPos], aRegC020[1][8])	 				//15 - NUM_DOC
		aAdd (aReg0465[nPos], aCmpAntSFT[6])                   //16 - DT_DOC
		aAdd (aReg0465[nPos], aRegC020[1][17])	 				//17 - VL_DOC
		aAdd (aReg0465[nPos], aTotalISS[20])	 				//18 - VL_ISS
		aAdd (aReg0465[nPos], aTotalISS[22])                   //19 - VL_RT
		aAdd (aReg0465[nPos], aRegC020[1][23])	 				//20 - VL_ICMS
		aAdd (aReg0465[nPos], aRegC020[1][25])	 				//21 - VL_ICMS_ST  
		aAdd (aReg0465[nPos], 0)	               				//22 - VL_AT
		aAdd (aReg0465[nPos], aRegC020[1][27])	 				//23 - VL_IPI        
		aAdd (aReg0465[nPos], 0)                			    //24 - VOL	
		GrvRegSef (cAlias, nRelac, aReg0465)
    EndIf
Return (lRet)
                       
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegE003   ³ Autor ³Cecilia Carvalho       ³ Data ³17.10.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³             CAMPOS ADICIONAIS                              ³±±
±±³          ³                                                            ³±±
±±³          ³- Geração do Registro E003                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegE003(cAlias, aRegE003)
	Local	nPos		:=	0	
	
	aAdd(aRegE003, {})
	nPos	:=	Len (aRegE003)
	aAdd (aRegE003[nPos], "E003")   //01 - REG
	aAdd (aRegE003[nPos], "PE")     //02 - UF
	aAdd (aRegE003[nPos], "E025")   //03 - LIN_NOM
	aAdd (aRegE003[nPos], "16")     //04 - CAMPO_INI
	aAdd (aRegE003[nPos], "2")      //05 - QTD_CAMPO  	

	aAdd(aRegE003, {})
	nPos	:=	Len (aRegE003)
	aAdd (aRegE003[nPos], "E003")   //01 - REG
	aAdd (aRegE003[nPos], "PE")     //02 - UF
	aAdd (aRegE003[nPos], "E055")   //03 - LIN_NOM
	aAdd (aRegE003[nPos], "09")     //04 - CAMPO_INI
	aAdd (aRegE003[nPos], "1")      //05 - QTD_CAMPO  	      
	
	aAdd(aRegE003, {})
	nPos	:=	Len (aRegE003)
	aAdd (aRegE003[nPos], "E003")   //01 - REG
	aAdd (aRegE003[nPos], "PE")     //02 - UF
	aAdd (aRegE003[nPos], "E065")   //03 - LIN_NOM
	aAdd (aRegE003[nPos], "06")     //04 - CAMPO_INI
	aAdd (aRegE003[nPos], "1")      //05 - QTD_CAMPO  	ADMIN
	                          
	aAdd(aRegE003, {})
	nPos	:=	Len (aRegE003)
	aAdd (aRegE003[nPos], "E003")   //01 - REG
	aAdd (aRegE003[nPos], "PE")     //02 - UF
	aAdd (aRegE003[nPos], "E085")   //03 - LIN_NOM
	aAdd (aRegE003[nPos], "10")     //04 - CAMPO_INI
	aAdd (aRegE003[nPos], "1")      //05 - QTD_CAMPO  	
	
	aAdd(aRegE003, {})
	nPos	:=	Len (aRegE003)
	aAdd (aRegE003[nPos], "E003")   //01 - REG
	aAdd (aRegE003[nPos], "PE")     //02 - UF
	aAdd (aRegE003[nPos], "E105")   //03 - LIN_NOM
	aAdd (aRegE003[nPos], "11")     //04 - CAMPO_INI
	aAdd (aRegE003[nPos], "1")      //05 - QTD_CAMPO  	
	                           
	aAdd(aRegE003, {})
	nPos	:=	Len (aRegE003)
	aAdd (aRegE003[nPos], "E003")   //01 - REG
	aAdd (aRegE003[nPos], "PE")     //02 - UF
	aAdd (aRegE003[nPos], "E310")   //03 - LIN_NOM
	aAdd (aRegE003[nPos], "10")     //04 - CAMPO_INI
	aAdd (aRegE003[nPos], "1")      //05 - QTD_CAMPO  	
	                          
	aAdd(aRegE003, {})
	nPos	:=	Len (aRegE003)
	aAdd (aRegE003[nPos], "E003")   //01 - REG
	aAdd (aRegE003[nPos], "PE")     //02 - UF
	aAdd (aRegE003[nPos], "E350")   //03 - LIN_NOM
	aAdd (aRegE003[nPos], "10")     //04 - CAMPO_INI
	aAdd (aRegE003[nPos], "1")      //05 - QTD_CAMPO  	
	GrvRegSef (cAlias,, aRegE003)	                           	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RegE020   ³ Autor ³Sueli C. Santos        ³ Data ³07.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³  E020 - REGISTRO MESTRE DE NOTA FISCAL (MODELO 01),  NOTA  ³±±
±±³          ³                FISCAL DE PRODUTOR (MODELO 04) E            ³±±
±±³          ³                NOTA FISCAL ELETRONICA (MODELO 55)          ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro E020 e E025                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef com as informacoe contidas no array    ³±±
±±³          ³ aTotaliza/aPartDoc/aCmpAntSFT para os modelos 01,04 E 55.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³E020 - 2(varios por arquivo)                                ³±±
±±³          ³E025 - 3(1:N) Para cada E020                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          |cEntSai -> Flag Entrada(1)/Saida(2).                        ³±±
±±³          |aCmpAntSFT -> Informacoes sobre o cabecalho dos documentos. ³±±
±±³          ³aPartDoc -> Array com informacoes sobre o participante do   ³±±
±±³          ³ documento fiscal, este array eh montado pela funcao princi-³±±
±±³          ³ pal.                                                       ³±±
±±³          |aTotaliza -> Totalizadores de valores para a tabela SFT.    ³±±
±±³          ³nRelac -> Flag de relacionamento.                           ³±±
±±³          ³cChave -> Codigo de referencia entre o documento fiscal e   ³±±
±±³          ³ este registro.                                             ³±±
±±³          ³cEspecie -> Modelo do documento fiscal                      ³±±
±±³          ³aRegE025 -> Array com informacoes analiticas do documento   ³±±
±±³          ³ fiscal processado na funcao principal para o documento.    ³±±
±±³          ³cSituaDoc -> Situacao do documento fiscal conforme funcao   ³±±
±±³          ³ RetSitDoc                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegE020 (cAlias, cEntSai, aCmpAntSFT, aPartDoc, aTotaliza, nRelac, cChv0450, cEspecie, aRegE025, cSituaDoc, lAchouSE4, aTotalISS, cCOP, aWizard, lIss, lConjugada )
	Local nPos   := 0
	Local nCol   := 0
	Local lRet   := .T.
	Local aReg   := {}
	Local nX     := 1
	Local lNFCE  := "65"$cEspecie
	Local cCFO020:= ""

If ("0"$aWizard[3][11] .And. lIss) .Or. !lIss
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GRAVACAO REGISTRO E020 - REGISTRO MESTRE DE NOTA FISCAL (MODELO 01), NOTA FISCAL DE PRODUTOR (MODELO 04) E NFE (MODELO 55)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd (aReg, {})
	nPos	:=	Len (aReg)
	aAdd (aReg[nPos], "E020")								//01 - REG
	aAdd (aReg[nPos], STR(Val (cEntSai)-1,1))				//02 - IND_OPER
	If (Empty (aCmpAntSFT[8])) .And. cEntSai=="1"
		aAdd (aReg[nPos], "1")								//03 - IND_EMIT
	ElseIf (Empty (aCmpAntSFT[8])) .And. cEntSai=="2"
		aAdd (aReg[nPos], "0")								//03 - IND_EMIT
	ElseIf ("S"$aCmpAntSFT[8])
		aAdd (aReg[nPos], "0")								//03 - IND_EMIT
	Else
		aAdd (aReg[nPos], "1")								//03 - IND_EMIT
	EndIf
	aAdd (aReg[nPos], aPartDoc[1])							//04 - COD_PART
	aAdd (aReg[nPos], IIf("1B"$cEspecie,"01",cEspecie))	//05 - COD_MOD
	aAdd (aReg[nPos], cSituaDoc)							//06 - COD_SIT
	aAdd (aReg[nPos], aCmpAntSFT[2])						//07 - SER
	aAdd (aReg[nPos], aCmpAntSFT[1])						//08 - NUM_DOC
	aAdd (aReg[nPos], aCmpAntSFT[20])						//09 - CHV_NFE
	aAdd (aReg[nPos], Iif(cEntSai=="1",aCmpAntSFT[6],""))	//10 - DT_EMIS
	aAdd (aReg[nPos], aCmpAntSFT[5])						//11 - DT_DOC
	aAdd (aReg[nPos], aCmpAntSFT[9])						//12 - COD_NAT
	If Len(aRegE025)>1 .And. Substr(aCmpAntSFT[9],2,3)$"910|911|920|921|949"
		For nX := 1 To Len(aRegE025)
			If !Substr(aRegE025[nX][4],2,3)$"910|911|920|921|949"
				// Para notas de Bonificação o CFOP deve ser trocado
				// conforme legislação da do Chamado: THZLZK
				cCFO020 := aRegE025[nx][4]
				cCOP := RetCOP(@Alltrim(cCFO020))
				aReg[nPos][12] := aRegE025[nx][4]			//12 - COD_NAT
				Exit
			EndIf
		Next (nX)
	EndIf
	aAdd (aReg[nPos], cCOP)									//13 - COP
	aAdd (aReg[nPos], aCmpAntSFT[10])						//14 - NUM_LCTO
	//Para ser a vista, a condicao de pagamento deve ser tipo 1 e somente 00 no campo E4_COND.
	//If (lAchouSE4) .And. ("1"$SE4->E4_TIPO) .And. "00"==AllTrim (SE4->E4_COND)
	//	aAdd (aReg[nPos], "0")								//15 - IND_PAGTO
	//Else
	//	aAdd (aReg[nPos], "1")								//15 - IND_PAGTO
	//EndIf
	aAdd (aReg[nPos], "")									//15 - IND_PAGTO obs: se preencher, ocorre erro no validador
	If cSituaDoc$"90#81#80"
		For nCol := 16 to 29
			aAdd (aReg[nPos], 0) //Adiciona valores zerados para documento cancelado
		Next
	Else
		// Verificando se trata-se de um complemento de ICMS-ST (aCmpAntSFT[19]=="I" e aTotaliza[5] > 0) pois neste caso
		// o valor contabil da NF original tambem seria alterado. Desta forma o registro da NF de complemento deve refletir a alteracao.
		aAdd (aReg[nPos], iif(aCmpAntSFT[19]=="I" ,aTotaliza[3]+aTotaliza[5],IIF(aCmpAntSFT[19] == "P" ,aTotaliza[6], Iif(lConjugada, aTotalISS[1]+aTotaliza[1],  IIF(lIss,aTotalISS[1],aTotaliza[1])  ) )))	//16 - VL_CONT
		aAdd (aReg[nPos], Iif(cEspecie=="04",0,aTotalISS[20]))							//17 - VL_OP_ISS
		aAdd (aReg[nPos], Iif(Substr(aCmpAntSFT[9],1,1)=="7",0,aTotaliza[2]))			//18 - VL_BC_ICMS
		aAdd (aReg[nPos], Iif(Substr(aCmpAntSFT[9],1,1)=="7",0,aTotaliza[3]))			//19 - VL_ICMS
		aAdd (aReg[nPos], Iif(Substr(aCmpAntSFT[9],1,1)=="7",0,aTotaliza[5]))			//20 - VL_ICMS_ST
		If cEntSai=="1"
			aAdd (aReg[nPos], Iif("0"$aWizard[6][5],aTotaliza[5],0))					//21 - VL_ST_E
			aAdd (aReg[nPos], 0)														//22 - VL_ST_S
			aAdd (aReg[nPos], aTotaliza[26])											//23 - VL_AT
		ElseIf cEntSai=="2"
			aAdd (aReg[nPos], 0)														//21 - VL_ST_E
			aAdd (aReg[nPos], aTotaliza[5])												//22 - VL_ST_S
			aAdd (aReg[nPos], 0)														//23 - VL_AT
		EndIf
		aAdd (aReg[nPos], aTotaliza[7])													//24 - VL_ISNT_ICMS
		//O campo ICMS outras tem por objetivo escriturar apenas o ICMS diferido ou suspenso, portaria 393/84, art.30.
		If (Substr(Alltrim(aCmpAntSFT[14]),2,2)$ "50|51")
			aAdd (aReg[nPos], aTotaliza[14])											//25 - VL_OUT_ICMS
		Else
			aAdd (aReg[nPos], 0)														//25 - VL_OUT_ICMS
		EndIf
		aAdd (aReg[nPos], aTotaliza[15])												//26 - VL_BC_IPI
		aAdd (aReg[nPos], aTotaliza[6])													//27 - VL_IPI
		aAdd (aReg[nPos], iif(SubStr(aWizard[3][16], 1, 1)=="0", aTotaliza[16],0))	//28 - VL_ISNT_IPI
		aAdd (aReg[nPos], aTotaliza[17])												//29 - VL_OUT_IPI
	EndIf
	If lNFCE
		aReg[nPos, 02] := "1"															//02 - IND_OPER
		aReg[nPos, 03] := "0"															//03 - IND_EMIT
		aReg[nPos, 04] := ""															//04 - COD_PART
		aReg[nPos, 20] := 0																//20 - VL_ICMS_ST
		aReg[nPos, 21] := 0																//21 - VL_ST_E
		aReg[nPos, 22] := 0																//22 - VL_ST_S
		aReg[nPos, 23] := 0																//23 - VL_AT
		aReg[nPos, 26] := 0																//26 - VL_BC_IPI
		aReg[nPos, 27] := 0																//27 - VL_IPI
		aReg[nPos, 28] := 0																//28 - VL_ISNT_IPI
		aReg[nPos, 29] := 0																//29 - VL_OUT_IPI
	EndIf
	aAdd (aReg[nPos], cChv0450)															//30 - COD_INF_OBS

	GrvRegSef (cAlias, nRelac, aReg)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GRAVACAO REGISTRO E025 - ANALITICO DO DOCUMENTO (MODELO 01, 04 E 55)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GrvRegSef (cAlias, nRelac, aRegE025)
EndIf

Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RegE025   ³ Autor ³Sueli C. Santos        ³ Data ³07.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³          ANALITICO DO DOCUMENTO (MODELO 01, 04 E 55)       ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao Registro E025                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef com as informacoes da tabela SFT.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³E025 - 3(1:N) Para cada E020                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAliasSFT -> Alias da tabela SFT aberta no momento.         ³±±
±±³          ³aRegE025 -> Array com informacoes analiticas do documento   ³±±
±±³          ³ fiscal processado na funcao principal para o documento.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegE025 (cAliasSFT, aRegE025, cSituaDoc, lIss, awizard, cEspecie)

Local nPos    := 0
Local lRet    := .T.
Local lNFCE   := "65"$cEspecie
Local cIndPetr:= "0"
Local nAliq   := (cAliasSFT)->FT_ALIQICM

IF SB5->(dbSeek (xFilial ("SB5")+(cAliasSFT)->FT_PRODUTO))
	cIndPetr := Iif(!Empty(Alltrim(SB5->B5_INDPETR)) ,SB5->B5_INDPETR, "0")
EndIf

If lIss
	nAliq	:= 0
EndIf

If ("0"$aWizard[3][11] .And. lIss) .Or. !lIss
	If ((nPos := aScan (aRegE025, {|aX| aX[4]==(cAliasSFT)->FT_CFOP .And. aX[6]== nAliq}))==0)
		aAdd(aRegE025, {})
		nPos	:=	Len (aRegE025)
		aAdd (aRegE025[nPos], "E025")					//01 - REG
		aAdd (aRegE025[nPos], 0)						//02 - VL_CONT_P
		aAdd (aRegE025[nPos], 0)						//03 - VL_OP_ISS_P
		aAdd (aRegE025[nPos], (cAliasSFT)->FT_CFOP)	//04 - CFOP
		aAdd (aRegE025[nPos], 0)						//05 - VL_BC_ICMS_P
		aAdd (aRegE025[nPos], IIf(lIss,0,(cAliasSFT)->FT_ALIQICM))	//06 - ALIQ_ICMS
		aAdd (aRegE025[nPos], 0)						//07 - VL_ICMS_P
		aAdd (aRegE025[nPos], 0)						//08 - VL_BC_ST_P
		aAdd (aRegE025[nPos], 0)						//09 - VL_ICMS_ST_P
		aAdd (aRegE025[nPos], 0)						//10 - VL_ISNT_ICMS_P
		aAdd (aRegE025[nPos], 0)						//11 - VL_OUT_ICMS_P
		aAdd (aRegE025[nPos], 0)						//12 - VL_BC_IPI_P
		aAdd (aRegE025[nPos], 0)						//13 - VL_IPI_P
		aAdd (aRegE025[nPos], 0)						//14 - VL_ISNT_IPI_P
		aAdd (aRegE025[nPos], 0)						//15 - VL_OUT_IPI_P
		aAdd (aRegE025[nPos], Alltrim(cIndPetr))		//16 - IND_PETR
		aAdd (aRegE025[nPos], "")						//17 - IND_IMUN
	EndIf
	If !(cSituaDoc$"90#81#80")
		aRegE025[nPos][2]	+=	iif((cAliasSFT)->FT_TIPO == "I",(cAliasSFT)->FT_ICMSRET+(cAliasSFT)->FT_VALICM,IIF((cAliasSFT)->FT_TIPO == "P" ,(cAliasSFT)->FT_VALIPI,iif(cSituaDoc	==	"20" .AND. ((cAliasSFT)->FT_TOTAL > (cAliasSFT)->FT_VALCONT),(cAliasSFT)->FT_TOTAL,(cAliasSFT)->FT_VALCONT)))	    //02 - VL_CONT_P
		If !lIss
			aRegE025[nPos][5]	+=	(cAliasSFT)->FT_BASEICM		//05 - VL_BC_ICMS_P
			aRegE025[nPos][7]	+=	(cAliasSFT)->FT_VALICM		//07 - VL_ICMS_P
			aRegE025[nPos][8]	+=	(cAliasSFT)->FT_BASERET		//08 - VL_BC_ST_P
			aRegE025[nPos][9]	+=	(cAliasSFT)->FT_ICMSRET		//09 - VL_ICMS_ST_P
			// Aplico a mesma regra utilizada no registro E020
			// ------------------------------------------------------
			//Quando configuro a TES para escriturar o Livro de ICMS/ST como ISENTO, na tabela SF3 o valor do campo 
			//  F3_ICMSRET eh transportado para o campo F3_ISENICM, ficando com os mesmos valores. Na tabela SFT, que
			//  possui o campo proprio FT_ISENRET, recebe este valor deixando o campo FT_ISENICM e FT_ICMSRET zerado.
			aRegE025[nPos][10] += (cAliasSFT)->FT_ISENICM+(cAliasSFT)->FT_ISENRET //10 - VL_ISNT_ICMS_P
			//O campo ICMS outras tem por objetivo escriturar apenas o ICMS diferido ou suspenso, portaria 393/84, art.30.
			If (Substr(Alltrim((cAliasSFT)->FT_CLASFIS),2,2)$ "50|51")
				aRegE025[nPos][11] += (cAliasSFT)->FT_OUTRICM+(cAliasSFT)->FT_OUTRRET //11 - VL_OUT_ICMS_P
			EndIf
		Else
			aRegE025[nPos][3]	+=	(cAliasSFT)->FT_VALICM		//03 - VL_OP_ISS_P
		EndIf
		aRegE025[nPos][12]	+=	(cAliasSFT)->FT_BASEIPI			//12 - VL_BC_IPI_P
		aRegE025[nPos][13]	+=	(cAliasSFT)->FT_VALIPI			//13 - VL_IPI_P
		aRegE025[nPos][14]	+=	(cAliasSFT)->FT_ISENIPI			//14 - VL_ISNT_IPI_P
		aRegE025[nPos][15]	+=	(cAliasSFT)->FT_OUTRIPI			//15 - VL_OUT_IPI_P
	EndIf
	If lNFCE
		aRegE025[nPos, 08] := 0									//08 - VL_BC_ST_P
		aRegE025[nPos, 09] := 0									//09 - VL_ICMS_ST_P
		aRegE025[nPos, 12] := 0									//12 - VL_BC_IPI_P
		aRegE025[nPos, 13] := 0									//13 - VL_IPI_P
		aRegE025[nPos, 14] := 0									//14 - VL_ISNT_IPI_P
		aRegE025[nPos, 15] := 0									//15 - VL_OUT_IPI_P
	EndIf
Endif
Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |E050E055  ³ Autor ³Sueli C. Santos        ³ Data ³07.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³E050 - REGISTRO MESTRE DE NOTA FISCAL DE VENDA A CONSUMIDOR ³±±
±±³          ³                         (MODELO 02)                        ³±±
±±³          ³                                                            ³±±
±±³          ³ E055 - REGISTRO ANALITICO DO DOCUMENTO FISCAL (MODELO 02)  ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao do Registro E050 e E055                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef com as informacoe contidas no array    ³±±
±±³          ³ aCmpAntSFT e na tabela SFT.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³E050 - 2(varios por arquivo)                                ³±±
±±³          ³E055 - 3(1:N) Para cada E050                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|aRegE050 -> Array contendo as informacoes processadas pela  ³±±
±±³          ³ funcao a ser retornado para gravacao pela funcao principal.³±±
±±³          |aRegE055 -> Array contendo as informacoes processadas pela  ³±±
±±³          ³ funcao a ser retornado para gravacao pela funcao principal.³±±
±±³          |aCmpAntSFT -> Informacoes sobre o cabecalho dos documentos. ³±±
±±³          ³cAliasSFT -> Alias da tabela SFT aberta no momento.         ³±±
±±³          ³cEspecie -> Modelo do documento fiscal                      ³±±
±±³          ³cSituaDoc -> Situacao do documento fiscal conforme funcao   ³±±
±±³          ³ RetSitDoc                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function E050E055 (aRegE050, aRegE055, aCmpAntSFT, cAliasSFT, cEspecie, cSituaDoc,cChv0450,cCOP)
Local	nPos	:=	0
Local	nPos2	:=	0
Local	lRet	:=	.T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³REGISTRO E050 - REGISTRO MESTRE DE NOTA FISCAL DE VENDA A CONSUMIDOR (MODELO 02)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Chave = COD_MOD+SER+DT_DOC+NUM_LCTO
	If ((nPos := aScan (aRegE050, {|aX| aX[2]==cEspecie .And. aX[4]==aCmpAntSFT[2] .And. aX[8]==aCmpAntSFT[6]}))==0)
		aAdd(aRegE050, {})
		nPos	:=	Len (aRegE050)
		aAdd (aRegE050[nPos], "E050")	 	   			//01 - REG
		aAdd (aRegE050[nPos], cEspecie)					//02 - COD_MOD
		aAdd (aRegE050[nPos], 0)						//03 - QTD_CANC
		aAdd (aRegE050[nPos], aCmpAntSFT[2])			//04 - SER
		aAdd (aRegE050[nPos], "")						//05 - SUB
		aAdd (aRegE050[nPos], aCmpAntSFT[1])			//06 - NUM_DOC_INI
		aAdd (aRegE050[nPos], aCmpAntSFT[1])			//07 - NUM_DOC_FIN
		aAdd (aRegE050[nPos], aCmpAntSFT[6])			//08 - DT_DOC
		aAdd (aRegE050[nPos], cCOP)                    //09 - COP		
		aAdd (aRegE050[nPos], aCmpAntSFT[10])			//10 - NUM_LCTO
		aAdd (aRegE050[nPos], 0)						//11 - VL_CONT
		aAdd (aRegE050[nPos], 0)						//12 - VL_BC_ICMS
		aAdd (aRegE050[nPos], 0)						//13 - VL_ICMS
		aAdd (aRegE050[nPos], 0)						//14 - VL_ISNT_ICMS
		aAdd (aRegE050[nPos], 0)						//15 - VL_OUT_ICMS
		aAdd (aRegE050[nPos], cChv0450)			        //16 - COD_INF_OBS
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Range de Numero de Documentos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (aCmpAntSFT[1]<aRegE050[nPos][5])
		aRegE050[nPos][5]	:=	aCmpAntSFT[1]
	EndIf
	//
	If (aCmpAntSFT[1]>aRegE050[nPos][6])
		aRegE050[nPos][6]	:=	aCmpAntSFT[1]
	EndIf
    //
	If ("90#81#" $ cSituaDoc)	                                                //02=Situacao de cancelada
		aRegE050[nPos][3]	:=	Alltrim (STR (Val (aRegE050[nPos][3]) + 1))		//03 - QTD_CANC
	Else
		aRegE050[nPos][11]	+=	(cAliasSFT)->FT_VALCONT		//11 - VL_CONT
		aRegE050[nPos][12]	+=	(cAliasSFT)->FT_BASEICM		//12 - VL_BC_ICMS
		aRegE050[nPos][13]	+=	(cAliasSFT)->FT_VALICM		//13 - VL_ICMS
		aRegE050[nPos][14]	+=	(cAliasSFT)->FT_ISENICM		//14 - VL_ISNT_ICMS
		aRegE050[nPos][15]	+=	(cAliasSFT)->FT_OUTRICM		//15 - VL_OUT_ICMS
	EndIf
	//
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³REGISTRO E055 - REGISTRO ANALITICO DO DOCUMENTO FISCAL (MODELO 02)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Chave = Reg.E050 + CFOP + ALIQICM
	nPos2 := aScan (aRegE055, {|aX|  aX[3]==(cAliasSFT)->FT_CFOP .And. aX[5]==(cAliasSFT)->FT_ALIQICM .And. aX[10]==nPos})
	
	If nPos2 == 0
		aAdd(aRegE055, {})
		nPos2	:=	Len (aRegE055)
		aAdd (aRegE055[nPos2], "E055")	 	   				    //01 - REG
		aAdd (aRegE055[nPos2], 0)							    //02 - VL_CONT_P
		aAdd (aRegE055[nPos2], (cAliasSFT)->FT_CFOP)		    //03 - CFOP
		aAdd (aRegE055[nPos2], 0)							    //04 - VL_BC_ICMS_P
		aAdd (aRegE055[nPos2], (cAliasSFT)->FT_ALIQICM) 	    //05 - ALIQ_ICMS
		aAdd (aRegE055[nPos2], 0)							    //06 - VL_ICMS_P
		aAdd (aRegE055[nPos2], 0)							    //07 - VL_ISNT_ICMS_P
		aAdd (aRegE055[nPos2], 0)							    //08 - VL_OUT_ICMS_P
		aAdd (aRegE055[nPos2], 0)						     	//09 - IND_IMUN
		aAdd (aRegE055[nPos2], nPos)					     	//10 - RELACIONA COM PAI
	EndIf
	If !("90#81#" $ cSituaDoc)
		aRegE055[nPos2][2]	+=	(cAliasSFT)->FT_VALCONT			//02 - VL_CONT_P
		aRegE055[nPos2][4]	+=	(cAliasSFT)->FT_BASEICM			//04 - VL_BC_ICMS_P
		aRegE055[nPos2][6]	+=	(cAliasSFT)->FT_VALICM			//06 - VL_ICMS_P
		aRegE055[nPos2][7]	+=	(cAliasSFT)->FT_ISENICM			//07 - VL_ISNT_ICMS_P
		aRegE055[nPos2][8]	+=	(cAliasSFT)->FT_OUTRICM			//08 - VL_OUT_ICMS_P
	EndIf	
Return (lRet)  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RegG030   ³ Autor ³Erick G. Dias          ³ Data ³26.10.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³RegG030 -  CUPONS REGISTRADOS                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegG030(cAlias,aRegG030,aCmpAntSFT,cPdv,aTotaliza)	
	Local nPos := 0
	Local cAliasSFI := "SFI"  
	Local nPosG030 :=0 
	Local nCro   :=0
	Local nCrz   := 0	
	
	//BUSCA NA TABELA SFI O CRO E CRZ PESQUISANDO PELO PDV E DATA DO DOCUMENTO
	If SFI->(dbSeek(xFilial("SFI")+cPdv + DTOS(aCmpAntSFT[6])))	
		nCro     := SFI->FI_CRO
		nCrz     := SFI->FI_NUMREDZ
	EndIf	

	nPosG030 :=aScan (aRegG030, {|aX| aX[3]== cPdv })
	if nPosG030 = 0 
		aAdd(aRegG030, {})
		nPos	:=	Len (aRegG030)	
		aAdd (aRegG030[nPos], "G030")           //01-LIN
		aAdd (aRegG030[nPos], "2D")             //02-COD_MOD
		aAdd (aRegG030[nPos], cPdv)             //03-ECF_CX
		aAdd (aRegG030[nPos], nCro)             //04-CRO
		aAdd (aRegG030[nPos], aCmpAntSFT[1])    //05-NUM_DOC_INI
		aAdd (aRegG030[nPos], aCmpAntSFT[1])    //06-NUM_DOC_FIN
		aAdd (aRegG030[nPos], "1")              //07-QTD_DOC
		aAdd (aRegG030[nPos], aTotaliza[1])     //08-VL_CONT
		aAdd (aRegG030[nPos], aTotaliza[20])    //09-VL_ISS
		aAdd (aRegG030[nPos], aTotaliza[3])     //10-VL_ICMS
		aAdd (aRegG030[nPos], aTotaliza[5])     //11-VL_ST			
	else
		aRegG030[nPosG030][6]:=aCmpAntSFT[1]    //06-NUM_DOC_FIN
		aRegG030[nPosG030][7] :=  CValToChar(val(aRegG030[nPosG030][7]) + 1) //07-QTD_DOC
		aRegG030[nPosG030][8] += aTotaliza[1]  //08-VL_CONT
		aRegG030[nPosG030][9] +=aTotaliza[20]  //09-VL_ISS
		aRegG030[nPosG030][10] += aTotaliza[3] //10-VL_ICMS
		aRegG030[nPosG030][11] += aTotaliza[5] //11-VL_ST						
	EndIf	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RegE360   ³ Autor ³Erick G. Dias          ³ Data ³26.10.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³E360 - OBRIGACOES DO ICMS A RECOLHER                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegE360(aRegE360,cAlias,dDtIni,dDtFim,cChv0450)
	Local nPos       := 0                                                
	Local cCodOr     := "" 
	Local cAliasSF6  :="SF6"     
	Local cDtVenc    := ""
	Local cMesIni    := substr(dtos(dDtIni),5,2)
	Local cMesFim    := substr(dtos(dDtFim),5,2)
	Local cAnoIni    := substr(dtos(dDtIni),1,4)
	Local cAnoFim    := substr(dtos(dDtFim),1,4)
 	Local lQuery 	 := .F. 
 	 
	dbSelectArea("SF6")                               					
	dbSetOrder(2)
	#IFDEF TOP
	    If TcSrvType()<>"AS/400" 
	    	lQuery := .T.		    
			cAliasSF6 :=GetNextAlias() 
			cQuery := "SELECT * "
			cQuery += "FROM "+RetSqlName("SF6")+" "
			cQuery += "WHERE F6_FILIAL='"+xFilial("SF6")+"' AND "
     		cQuery += "F6_MESREF>="+cMesIni+" AND "
	 		cQuery += "F6_MESREF<="+cMesFim+" AND "		 		
	 		cQuery += "F6_ANOREF>="+cAnoIni+" AND "
    		cQuery += "F6_ANOREF<="+cAnoFim+" AND "		 				 													
			cQuery += "D_E_L_E_T_ = ' ' "
			cQuery += "ORDER BY "+SqlOrder(SF6->(IndexKey()))
		
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF6,.T.,.T.)		
		
			dbSelectArea(cAliasSF6)
		Else
	#ENDIf
	    	(cAliasSF6)->( MsSeek(xFilial("SF6")))
	#IFDEF TOP
		EndIf
	#ENDIF
	While (cAliasSF6)->(!Eof()) .And. xFilial("SF6")== (cAliasSF6)->F6_FILIAL
        If (cAliasSF6)->F6_EST == "EX"
            cCodOr := "804"
        Else
	        If (cAliasSF6)->F6_TIPOIMP == "1"
	            cCodOr := "800"
	        ElseIf (cAliasSF6)->F6_TIPOIMP == "3"   
	            If (cAliasSF6)->F6_OPERNF == "1"
	                cCodOr := "801"
	            Else
		            If (cAliasSF6)->F6_EST == "PE"
		                cCodOr := "803" 
		            Else
		                cCodOr := "890"
		            EndIf                    
                EndIf
	        Else
	            cCodOr := "800"
	        EndIf
	    EndIf
		aAdd(aRegE360, {})
        
        cDtVenc := IIf( lQuery , (cAliasSF6)->F6_DTVENC , DtoS((cAliasSF6)->F6_DTVENC) )

		nPos	:=	Len (aRegE360)	
		aAdd (aRegE360[nPos], "E360") //1-LIN
		aAdd (aRegE360[nPos], (cAliasSF6)->F6_EST) //2-UF_OR
		aAdd (aRegE360[nPos], cCodOr) //3-COD_OR
		aAdd (aRegE360[nPos], strzero((cAliasSF6)->F6_MESREF,2)  +  str((cAliasSF6)->F6_ANOREF,4)) //4-PER_REF
		aAdd (aRegE360[nPos], PadL(Alltrim((cAliasSF6)->F6_CODREC),4)) //5-COD_REC
		aAdd (aRegE360[nPos], (cAliasSF6)->F6_VALOR) //6-VL_ICMS_REC
		aAdd (aRegE360[nPos],  IIf(Empty(cDtVenc),Replicate("0",8),substr(cDtVenc,7,2) + substr(cDtVenc,5,2) + substr(cDtVenc,1,4))) //7-DT_VCTO
		aAdd (aRegE360[nPos], "")   //8-NUM_PROC
		aAdd (aRegE360[nPos], "")   //9-IND_PROC
		aAdd (aRegE360[nPos], "")   //10-DESCR_PROC
		aAdd (aRegE360[nPos], "")   //11-COD_INF_OBS	
		dbskip()
	EndDo
	If len(aRegE360) > 0 
		GrvRegSef (cAlias, , aRegE360 ) 
	EndIf 
	
	#IFDEF TOP
		If (TcSrvType ()<>"AS/400")
			DbSelectArea (cAliasSF6)
			(cAliasSF6)->(DbCloseArea ())
		Else
	#ENDIF
		RetIndex("SF6")			
	#IFDEF TOP
		EndIf
	#ENDIF
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |E100E105  ³ Autor ³Sueli C. Santos        ³ Data ³07.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³         E100 - REGISTRO MESTRE DE NOTA FISCAL DE:          ³±±
±±³          ³              ENERGIA ELETRICA (MODELO 06)                  ³±±
±±³          ³            SERVICO DE COMUNICACAO (MODELO 21)              ³±±
±±³          ³          SERVICO DE TELECOMUNICACAO (MODELO 22)            ³±±
±±³          ³                                                            ³±±
±±³          ³     E105 - ANALITICO DO DOCUMENTO (MODELO 06, 21 E 22)     ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro E100 e E105                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef com as informacoe contidas no array    ³±±
±±³          ³ aTotaliza/aPartDoc/aCmpAntSFT para os modelos 06, 21 E 22. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³E100 - 2(varios por arquivo)                                ³±±
±±³          ³E105 - 3(1:N) Para cada E100                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          |cEntSai -> Flag Entrada(1)/Saida(2).                        ³±±
±±³          |aCmpAntSFT -> Informacoes sobre o cabecalho dos documentos. ³±±
±±³          ³aPartDoc -> Array com informacoes sobre o participante do   ³±±
±±³          ³ documento fiscal, este array eh montado pela funcao princi-³±±
±±³          ³ pal.                                                       ³±±
±±³          |aTotaliza -> Totalizadores de valores para a tabela SFT.    ³±±
±±³          ³nRelac -> Flag de relacionamento.                           ³±±
±±³          ³cChave -> Codigo de referencia entre o documento fiscal e   ³±±
±±³          ³ este registro.                                             ³±±
±±³          ³cEspecie -> Modelo do documento fiscal                      ³±±
±±³          ³aRegE105 -> Array com informacoes analiticas do documento   ³±±
±±³          ³ fiscal processado na funcao principal para o documento.    ³±±
±±³          ³cSituaDoc -> Situacao do documento fiscal conforme funcao   ³±±
±±³          ³ RetSitDoc                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function E100E105 (cAlias, cEntSai, aCmpAntSFT, aPartDoc, aTotaliza, nRelac, cChv0450, cEspecie, aRegE105, cSituaDoc, lAchouSFU, lAchouSFX, aTotalISS,cCOP)
Local	nPos		:=	0
Local	nPos2		:=	0
Local	lRet		:=	.T.
Local	aRegE100	:=	{}
Local	cCodCons	:=	""

If cEntSai == "2" //esse campo deve ser informado apenas para saida
	// Busco o codigo do consumo para NFCEE(modelo 6), para NTST/NTSC(modelo 21/22), para NFCG (modelo 28) e para NFAC (modelo 29) 
	If lAchouSFU
		cCodCons := SFU->FU_CLCOSEF
	ElseIf lAchouSFX
		cCodCons := SFX->FX_CLASCON
	EndIf
EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GRAVACAO REGISTRO E100 - REGISTRO MESTRE DE NOTA FISCAL ENERGIA ELETRICA (MODELO 06), COMUNICACAO (MODELO 21) E TELECOMUNICACAO (MODELO 22)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd (aRegE100, {})
nPos	:=	Len (aRegE100)
aAdd (aRegE100[nPos], "E100")								//01 - REG
aAdd (aRegE100[nPos], STR(Val (cEntSai)-1,1))				//02 - IND_OPER

//03 - IND_EMIT
If (Empty (aCmpAntSFT[8])) .And. cEntSai=="1"
	aAdd (aRegE100[nPos], "1")
ElseIf (Empty (aCmpAntSFT[8])) .And. cEntSai=="2"
	aAdd (aRegE100[nPos], "0")
Else
	If ("S"$aCmpAntSFT[8])
		aAdd (aRegE100[nPos], "0")
	Else
		aAdd (aRegE100[nPos], "1")
	EndIf
EndIf

aAdd (aRegE100[nPos], aPartDoc[1])							//04 - COD_PART
aAdd (aRegE100[nPos], aPartDoc[11])							//05 - COD_MUN_SERV
aAdd (aRegE100[nPos], cEspecie)								//06 - COD_MOD
aAdd (aRegE100[nPos], cSituaDoc)							//07 - COD_SIT
aAdd (aRegE100[nPos], IIf ("90#81#"$cSituaDoc, "1", ""))	//08 - QTD_CANC
aAdd (aRegE100[nPos], aCmpAntSFT[2])						//09 - SER
aAdd (aRegE100[nPos], "")									//10 - SUB
aAdd (aRegE100[nPos], cCodCons)								//11 - COD_CONS
aAdd (aRegE100[nPos], aCmpAntSFT[1])						//12 - NUM_DOC
aAdd (aRegE100[nPos], "1")									//13 - QTD_DOC	--	SEMPRE 1 (O MESMO), POIS COMO PODEMOS VER EH POR DOCUMENTO
aAdd (aRegE100[nPos], Iif(cEntSai=="1",aCmpAntSFT[6],""))	//14 - DT_EMIS
aAdd (aRegE100[nPos], aCmpAntSFT[5])						//15 - DT_DOC
aAdd (aRegE100[nPos], cCOP)									//16 - COP
aAdd (aRegE100[nPos], aCmpAntSFT[10])						//17 - NUM_LCTO
aAdd (aRegE100[nPos], aTotaliza[1])							//18 - VL_CONT
aAdd (aRegE100[nPos], aTotalISS[1])							//19 - VL_OP_ISS
aAdd (aRegE100[nPos], aTotaliza[2])							//20 - VL_BC_ICMS
aAdd (aRegE100[nPos], aTotaliza[3])							//21 - VL_ICMS
aAdd (aRegE100[nPos], aTotaliza[5])							//22 - VL_ICMS_ST
aAdd (aRegE100[nPos], aTotaliza[7])							//23 - VL_ISNT_ICMS
aAdd (aRegE100[nPos], aTotaliza[14])						//24 - VL_OUT_ICMS
aAdd (aRegE100[nPos], cChv0450)								//25 - COD_INF_OBS

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO REGISTRO E105 - ANALITICO DOS DOCUMENTOS (MODELO 06, 21 E 22)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !("90#81#"$cSituaDoc)
	aAdd (aRegE105, {})
	nPos2	:=	Len (aRegE105)
	aAdd (aRegE105[nPos2], "E105")							//01 - REG
	aAdd (aRegE105[nPos2], aTotaliza[1])					//02 - VL_CONT_P
	aAdd (aRegE105[nPos2], aTotalISS[1])					//03 - VL_OP_ISS_P
	aAdd (aRegE105[nPos2], aCmpAntSFT[9])					//04 - CFOP
	aAdd (aRegE105[nPos2], aTotaliza[2])					//05 - VL_BC_ICMS_P
	aAdd (aRegE105[nPos2], aCmpAntSFT[11])					//06 - ALIQ_ICMS
	aAdd (aRegE105[nPos2], aTotaliza[3])					//07 - VL_ICMS_P
	aAdd (aRegE105[nPos2], aTotaliza[5])					//08 - VL_ICMS_ST_P
	aAdd (aRegE105[nPos2], aTotaliza[7])					//09 - VL_ISNT_ICMS_P
	aAdd (aRegE105[nPos2], aTotaliza[14])					//10 - VL_OUT_ICMS_P
	aAdd (aRegE105[nPos2], " ")								//11 - IND_PETR
EndIf
	
GrvRegSef (cAlias, nRelac, aRegE100)

If !("90#81#"$cSituaDoc)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GRAVACAO REGISTRO E105 - ANALITICO DOS DOCUMENTOS (MODELO 06, 21 E 22)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GrvRegSef (cAlias, nRelac, aRegE105)
EndIf

Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RegE120   ³ Autor ³Sueli C. Santos        ³ Data ³07.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³  E120 - NOTA FISCAL DE SERVICO DE TRANSPORTE (MODELO 07)   ³±±
±±³          ³         CONHECIMENTO DE FRETE (MODELO 08)                  ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao do Registro E120                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef com as informacoe contidas no array    ³±±
±±³          ³ aPartDoc/aCmpAntSFT para os modelos 07, 08.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³E120 - 2(varios por arquivo)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³nRelac -> Flag de relacionamento.                           ³±±
±±³          ³aRegE120 -> Array passado por referencia para receber infor-³±±
±±³          ³ macoes a serem gravados posteriormente.                    ³±±
±±³          |cEntSai -> Flag Entrada(1)/Saida(2).                        ³±±
±±³          ³aPartDoc -> Array com informacoes sobre o participante do   ³±±
±±³          ³ documento fiscal, este array eh montado pela funcao princi-³±±
±±³          ³ pal.                                                       ³±±
±±³          ³cEspecie -> Modelo do documento fiscal                      ³±±
±±³          ³cSituaDoc -> Situacao do documento fiscal conforme funcao   ³±±
±±³          ³ RetSitDoc                                                  ³±±
±±³          |aCmpAntSFT -> Informacoes sobre o cabecalho dos documentos. ³±±
±±³          |cAliasSFT -> Alias da tabela SFT em processamento.          ³±±
±±³          ³cChave -> Codigo de referencia entre o documento fiscal e   ³±±
±±³          ³ este registro.                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegE120 (cAlias, nRelac, aRegE120, cEntSai, aPartDoc, cEspecie, cSituaDoc, aCmpAntSFT, cAliasSFT, cChv0450, lAchouSE4,cCOP,aWizard)
	Local	lRet	:=	.T.
	Local	nPos	:=	0
	
	nPos := aScan (aRegE120, {|aX| aX[10]==aCmpAntSFT[1] .And. aX[8]==aCmpAntSFT[2] .And. aX[4]==aPartDoc[1] })
	If nPos == 0
		aAdd (aRegE120, {})
		nPos	:=	Len (aRegE120)
		aAdd (aRegE120[nPos], "E120")							//01 - REG	
		aAdd (aRegE120[nPos], STR(Val (cEntSai)-1,1))	  		//02 - IND_OPER
		//03 - IND_EMIT
		If (Empty (aCmpAntSFT[8])) .And. cEntSai=="1"
			aAdd (aRegE120[nPos], "1")							
		ElseIf (Empty (aCmpAntSFT[8])) .And. cEntSai=="2"
			aAdd (aRegE120[nPos], "0")					  		
		Else
			If ("S"$aCmpAntSFT[8])
				aAdd (aRegE120[nPos], "0") 				   		
			Else
				aAdd (aRegE120[nPos], "1")						
			EndIf
		EndIf
		//
		If ( cEspecie=="63" )
			aAdd (aRegE120[nPos], "")	                                            //04 - COD_PART
		Else
			aAdd (aRegE120[nPos], aPartDoc[1])	                                            //04 - COD_PART
		EndIf
 		
		//valicação D- Na prestação informe um município existente no Brasil como local da prestação de serviço
		aAdd (aRegE120[nPos], Iif(cEntSai=="2".And. nFreteFOB == 0 ,Iif(aPartDoc[8]$"EX" .and. aPartDoc[11]$"0000000#9999999",SM0->M0_CODMUN,aPartDoc[11]),awizard[4][16])) //05 - COD_MUN_SERV 
		
		aAdd (aRegE120[nPos], cEspecie)  												//06 - COD_MOD
		aAdd (aRegE120[nPos], Iif(cSituaDoc=="06" .Or. cSituaDoc=="20","00",cSituaDoc)) //07 - COD_SIT
		aAdd (aRegE120[nPos], aCmpAntSFT[2])  											//08 - SER
		aAdd (aRegE120[nPos], Iif(Alltrim(aCmpAntSFT[2])$"B|C|F","1",""))             //09 - SUB		
		aAdd (aRegE120[nPos], aCmpAntSFT[1])  											//10 - NUM_DOC 
		aAdd (aRegE120[nPos], Iif(cEspecie=="57",aCmpAntSFT[20],"")) 				    //11 - CHV_CTE
		aAdd (aRegE120[nPos], Iif(cEntSai=="1",aCmpAntSFT[6],"")) 				        //12 - DT_EMIS 		
		aAdd (aRegE120[nPos], aCmpAntSFT[5])  				                         	//13 - DT_DOC
		aAdd (aRegE120[nPos], cCOP)                                                     //14 - COP
		aAdd (aRegE120[nPos], aCmpAntSFT[10])  				                         	//15 - NUM_LCTO 
		 
		//Para ser a vista, a condicao de pagamento deve ser tipo 1 e somente 00 no campo E4_COND.
		//If (lAchouSE4) .And. ("1"$SE4->E4_TIPO) .And. "00"==AllTrim (SE4->E4_COND)
		//	aAdd (aRegE120[nPos], "0")	   			  			//16 - IND_PAGTO
		//Else	
		//	aAdd (aRegE120[nPos], "1")	  			  			//16 - IND_PAGTO
		//EndIf
	    aAdd (aRegE120[nPos], "")	  			  		     	//16 - IND_PAGTO obs: se preencher, ocorre erro no validador 	  
		aAdd (aRegE120[nPos], 0)								//17 - VL_CONT		
		aAdd (aRegE120[nPos], (cAliasSFT)->FT_CFOP)			    //18 - CFOP
		aAdd (aRegE120[nPos], 0)								//19 - VL_BC_ICMS
		aAdd (aRegE120[nPos], (cAliasSFT)->FT_ALIQICM)			//20 - ALIQ_ICMS
		aAdd (aRegE120[nPos], 0)								//21 - VL_ICMS
		aAdd (aRegE120[nPos], 0)								//22 - VL_ICMS_ST
		aAdd (aRegE120[nPos], 0)								//23 - VL_ISNT_ICMS
		aAdd (aRegE120[nPos], 0)								//24 - VL_OUT_ICMS
		If ( cEspecie=="63" )
			aAdd (aRegE120[nPos], "")							    	//25 - COD_INF_OBS
		Else
			aAdd (aRegE120[nPos], cChv0450)							    //25 - COD_INF_OBS
		EndIf
	EndIf
	If !("90#81#"$cSituaDoc)
		aRegE120[nPos][17]	+=	(cAliasSFT)->FT_VALCONT			//17 - VL_CONT
		aRegE120[nPos][19]	+=	(cAliasSFT)->FT_BASEICM			//19 - VL_BC_ICMS
		aRegE120[nPos][21]	+=	(cAliasSFT)->FT_VALICM			//21 - VL_ICMS
		aRegE120[nPos][23]	+=	(cAliasSFT)->FT_ISENICM			//23 - VL_ISNT_ICMS
		aRegE120[nPos][24]	+=	(cAliasSFT)->FT_OUTRICM			//24 - VL_OUT_ICMS
	EndIf

Return (lRet)                                                  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RegE300   ³ Autor ³Sueli C. Santos        ³ Data ³07.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³               PERIODO DE APURACAO DO ICMS                  ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro E300                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2(um por periodo)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlias -> Alias do TRB que devera conter as informacoes do  ³±±
±±³          ³ meio-magnetico.                                            ³±±
±±³          ³dDataDe -> Data incial do periodo de apuracao.              ³±±
±±³          ³dDataAte -> Data final do periodo de apuracao.              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegE300 (cAlias, dDataDe, dDataAte)
	Local	aReg		:=	{}
	Local	lRet		:=	.T.
	Local	nPos		:=	0
	//
	aAdd (aReg, {})
	nPos	:=	Len (aReg)
	aAdd (aReg[nPos], "E300")								//01 - REG
	aAdd (aReg[nPos], dDataDe)								//02 - DT_INI
	aAdd (aReg[nPos], dDataAte)								//03 - DT_FIN
	//
	GrvRegSef (cAlias,, aReg)
Return (lRet)  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RegE305   ³ Autor ³Sueli C. Santos        ³ Data ³07.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³  E305 - MAPA RESUMO DE OPERACOES                           ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao do Registro E305                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef com as informacoe contidas no array    ³±±
±±³          ³ aPartDoc/aCmpAntSFT para os modelos 07, 08.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³E305 - 3(varios por arquivo)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³nRelac -> Flag de relacionamento.                           ³±±
±±³          ³aRegE120 -> Array passado por referencia para receber infor-³±±
±±³          ³ macoes a serem gravados posteriormente.                    ³±±
±±³          |cEntSai -> Flag Entrada(1)/Saida(2).                        ³±±
±±³          ³aPartDoc -> Array com informacoes sobre o participante do   ³±±
±±³          ³ documento fiscal, este array eh montado pela funcao princi-³±±
±±³          ³ pal.                                                       ³±±
±±³          ³cEspecie -> Modelo do documento fiscal                      ³±±
±±³          ³cSituaDoc -> Situacao do documento fiscal conforme funcao   ³±±
±±³          ³ RetSitDoc                                                  ³±±
±±³          |aCmpAntSFT -> Informacoes sobre o cabecalho dos documentos. ³±±
±±³          |cAliasSFT -> Alias da tabela SFT em processamento.          ³±±
±±³          ³cChave -> Codigo de referencia entre o documento fiscal e   ³±±
±±³          ³ este registro.                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegE305 (cAliasSFT, cEntSai, aRegE305, cEspecie, cSituaDoc, aCmpAntSFT, lIss, aTotalISS,cCOP, aWizard, lFinal)
Local	lRet    	:=	.T.
Local	nPos	    :=	0 
Local	dDataDe 	:=	CToD ("//")
Local	dDataAte	:=	CToD ("//")
Local   nCont       := 0
Local   nx          := 0
Local   dDataAnt    := CToD ("//")  
Local   aRegTemp    :=  {}
Local   cTipoMv		:= (cAliasSFT)->FT_TIPOMOV
Local	nPosEnt	    :=	0 
Local	nPosSai	    :=	0
Local 	nContador	:=  0 

IF cTipoMv == "E"
	cEntSai := "0"
ElseIf 	cTipoMv == "S"
	cEntSai := "1"
EndIf 
	
nPos := aScan (aRegE305, {|aX| aX[04]==(cAliasSFT)->FT_ENTRADA .And. aX[03]==cEntSai})       
dDataDe		:=	SToD (aWizard[1][1])
dDataAte	:=	SToD (aWizard[1][2])

//O registro E305 deve ser gerado para dias sem movimento.Antes da gravação do registro são alocados os dias sem movimento
//A base de geração do arquivo é SFT e não há linhas zeradas nela.
If !lFinal
	If nPos == 0
		aAdd (aRegE305, {})
		nPos	:=	Len (aRegE305)
		aAdd (aRegE305[nPos], "E305")							//01 - REG	
		aAdd (aRegE305[nPos], "2")								//02 - IND_MRO	
		aAdd (aRegE305[nPos], cEntSai)	  		//03 - IND_OPER	   
		aAdd (aRegE305[nPos], aCmpAntSFT[5])  					//04 - DT_DOC     
		aAdd (aRegE305[nPos], "")								//05 - COP   
		aAdd (aRegE305[nPos], aCmpAntSFT[10])  					//06 - NUM_LCTO
		aAdd (aRegE305[nPos], "1")			  					//07 - QTD_LCTO    
		aAdd (aRegE305[nPos], 0)				   				//08 - VL_CONT 
		aAdd (aRegE305[nPos], aTotalISS[1])						//09 - VL_OP_ISS
		aAdd (aRegE305[nPos], 0)						   		//10 - VL_BC_ICMS
		aAdd (aRegE305[nPos], 0)				   	   			//11 - VL_ICMS
		aAdd (aRegE305[nPos], 0)				   				//12 - VL_ICMS_ST
		aAdd (aRegE305[nPos], 0)				   				//13 - VL_ST_ENT		
		aAdd (aRegE305[nPos], 0)								//14 - VL_ST_FNT
		aAdd (aRegE305[nPos], 0)								//14 - VL_ST_UF		
		aAdd (aRegE305[nPos], 0)				   				//16 - VL_ST_OE
		aAdd (aRegE305[nPos], 0)				   				//17 - VL_AT
		aAdd (aRegE305[nPos], 0)						   		//18 - VL_ISNT_ICMS
		aAdd (aRegE305[nPos], 0)								//19 - VL_OUT_ICMS 
		aAdd (aRegE305[nPos], 0)		   						//20 - VL_BC_IPI
		aAdd (aRegE305[nPos], 0)		   						//21 - VL_IPI 
		aAdd (aRegE305[nPos], 0)								//22 - VL_ISNT_IPI
		aAdd (aRegE305[nPos], 0)				   				//23 - VL_OUT_IPI 
		  
		If !("90#81#"$cSituaDoc)  
			aRegE305[nPos][08]	+=	(cAliasSFT)->FT_VALCONT			//08 - VL_CONT
			If !lIss 
			  	aRegE305[nPos][10]	+=	(cAliasSFT)->FT_BASEICM		//10 - VL_BC_ICMS
				aRegE305[nPos][11]	+=	(cAliasSFT)->FT_VALICM		//11 - VL_ICMS 
				aRegE305[nPos][12]	+=	(cAliasSFT)->FT_ICMSRET		//12 - VL_ICMS_ST
				aRegE305[nPos][17]	+=	(cAliasSFT)->FT_VALANTI		//17 - VL_AT				
				aRegE305[nPos][18]	+=	(cAliasSFT)->FT_ISENICM		//18 - VL_ISNT_ICMS
				aRegE305[nPos][19]	+=	(cAliasSFT)->FT_OUTRICM		//19 - VL_OUT_ICMS
			
				If !Empty((cAliasSFT)->FT_FORMUL) .And. cEntSai=="1"     	//formulario Proprio igual a Sim na entrada
			   			aRegE305[nPos][14]	+=	(cAliasSFT)->FT_ICMSRET		//14 - VL_ST_FNT 			   			
			   	ElseIf	Empty((cAliasSFT)->FT_FORMUL) .And. cEntSai=="1"    //formulario Proprio igual a Nao na entrada  
			   			aRegE305[nPos][13]	+=	(cAliasSFT)->FT_ICMSRET		//13 - VL_ST_ENT			   			
			   	Elseif	SUBSTR((cAliasSFT)->FT_CFOP,1,1)=="5" .And. cEntSai=="2"
			   			aRegE305[nPos][15]	+=	(cAliasSFT)->FT_ICMSRET		//15 - VL_ST_UF				   			
				ElseIf SUBSTR((cAliasSFT)->FT_CFOP,1,1)>"5" .And. cEntSai=="2"
					aRegE305[nPos][16]	+=	(cAliasSFT)->FT_ICMSRET		    //16 - VL_ST_OE
				EndIF
				                                  		
			Else
				aRegE305[nPos][09]	+=	(cAliasSFT)->FT_VALCONT		//09 - VL_OP_ISS 
			EndIf 		
			aRegE305[nPos][20]	+=	(cAliasSFT)->FT_BASEIPI			//20 - VL_BC_IPI	
			aRegE305[nPos][21]	+=	(cAliasSFT)->FT_VALIPI			//21 - VL_IPI
			aRegE305[nPos][22]	+=	(cAliasSFT)->FT_ISENIPI			//22 - VL_ISNT_IPI
			aRegE305[nPos][23]	+=	(cAliasSFT)->FT_OUTRIPI			//23 - VL_OUT_IPI
		EndIf
	Else
			If !("90#81#"$cSituaDoc)  
			aRegE305[nPos][08]	+=	(cAliasSFT)->FT_VALCONT			//08 - VL_CONT
			If !lIss 
			  	aRegE305[nPos][10]	+=	(cAliasSFT)->FT_BASEICM		//10 - VL_BC_ICMS
				aRegE305[nPos][11]	+=	(cAliasSFT)->FT_VALICM		//11 - VL_ICMS 
				aRegE305[nPos][12]	+=	(cAliasSFT)->FT_ICMSRET		//12 - VL_ICMS_ST
				aRegE305[nPos][17]	+=	(cAliasSFT)->FT_VALANTI		//17 - VL_AT				
				aRegE305[nPos][18]	+=	(cAliasSFT)->FT_ISENICM		//18 - VL_ISNT_ICMS
				aRegE305[nPos][19]	+=	(cAliasSFT)->FT_OUTRICM		//19 - VL_OUT_ICMS
			
				If !Empty((cAliasSFT)->FT_FORMUL) .And. cEntSai=="1"     	//formulario Proprio igual a Sim na entrada
			   			aRegE305[nPos][14]	+=	(cAliasSFT)->FT_ICMSRET		//14 - VL_ST_FNT 			   			
			   	ElseIf	Empty((cAliasSFT)->FT_FORMUL) .And. cEntSai=="1"    //formulario Proprio igual a Nao na entrada  
			   			aRegE305[nPos][13]	+=	(cAliasSFT)->FT_ICMSRET		//13 - VL_ST_ENT			   			
			   	Elseif	SUBSTR((cAliasSFT)->FT_CFOP,1,1)=="5" .And. cEntSai=="2"
			   			aRegE305[nPos][15]	+=	(cAliasSFT)->FT_ICMSRET		//15 - VL_ST_UF				   			
				ElseIf SUBSTR((cAliasSFT)->FT_CFOP,1,1)>"5" .And. cEntSai=="2"
					aRegE305[nPos][16]	+=	(cAliasSFT)->FT_ICMSRET		    //16 - VL_ST_OE
				EndIF
				                                  		
			Else
				aRegE305[nPos][09]	+=	(cAliasSFT)->FT_VALCONT		//09 - VL_OP_ISS 
			EndIf 		
			aRegE305[nPos][20]	+=	(cAliasSFT)->FT_BASEIPI			//20 - VL_BC_IPI	
			aRegE305[nPos][21]	+=	(cAliasSFT)->FT_VALIPI			//21 - VL_IPI
			aRegE305[nPos][22]	+=	(cAliasSFT)->FT_ISENIPI			//22 - VL_ISNT_IPI
			aRegE305[nPos][23]	+=	(cAliasSFT)->FT_OUTRIPI			//23 - VL_OUT_IPI
		EndIf
	EndIF		 	 
Else
	 	dDataAnt := dDataDe 
		nCont:= (dDataAte - dDataDe) + 1 //Para considerar todos os dias	
		For nx:=1  to nCont
			nContador +=1
		   	nPosEnt := aScan (aRegE305, {|aX| aX[03]=="0" .And. aX[04] == dDataAnt}) 
		   	If nPosEnt > 0 	 
		 		aAdd (aRegTemp, {})		
				aAdd (aRegTemp[nX], "E305")											//01 - REG	
				aAdd (aRegTemp[nX], "2")											//02 - IND_MRO	
				aAdd (aRegTemp[nX], "0" )	  	  						//03 - IND_OPER	   
				aAdd (aRegTemp[nX], aRegE305[nPosEnt][4] )  		                		//04 - DT_DOC     
				aAdd (aRegTemp[nX], aRegE305[nPosEnt][5] )								//05 - COP   
				aAdd (aRegTemp[nX], aRegE305[nPosEnt][6] )             					//06 - NUM_LCTO
				aAdd (aRegTemp[nX], aRegE305[nPosEnt][7] )			  			  		//07 - QTD_LCTO    
				aAdd (aRegTemp[nX], aRegE305[nPosEnt][8] )				   				//08 - VL_CONT 
				aAdd (aRegTemp[nX], aRegE305[nPosEnt][9] )					         	//09 - VL_OP_ISS
				aAdd (aRegTemp[nX], aRegE305[nPosEnt][10] )						   		//10 - VL_BC_ICMS
				aAdd (aRegTemp[nX], aRegE305[nPosEnt][11] )				   	   			//11 - VL_ICMS
				aAdd (aRegTemp[nX], aRegE305[nPosEnt][12] )				   				//12 - VL_ICMS_ST
				aAdd (aRegTemp[nX], aRegE305[nPosEnt][13] )				   				//13 - VL_ST_ENT		
				aAdd (aRegTemp[nX], aRegE305[nPosEnt][14] )								//14 - VL_ST_FNT
				aAdd (aRegTemp[nX], aRegE305[nPosEnt][15] )								//14 - VL_ST_UF		
				aAdd (aRegTemp[nX], aRegE305[nPosEnt][16] )				   				//16 - VL_ST_OE
				aAdd (aRegTemp[nX], aRegE305[nPosEnt][17] )				   				//17 - VL_AT
				aAdd (aRegTemp[nX], aRegE305[nPosEnt][18] )						   		//18 - VL_ISNT_ICMS
				aAdd (aRegTemp[nX], aRegE305[nPosEnt][19] )								//19 - VL_OUT_ICMS 
				aAdd (aRegTemp[nX], aRegE305[nPosEnt][20] )		   						//20 - VL_BC_IPI
				aAdd (aRegTemp[nX], aRegE305[nPosEnt][21] )		   						//21 - VL_IPI 
				aAdd (aRegTemp[nX], aRegE305[nPosEnt][22] )								//22 - VL_ISNT_IPI
				aAdd (aRegTemp[nX], aRegE305[nPosEnt][23] )				   				//23 - VL_OUT_IPI
			Else
				aAdd (aRegTemp, {})		
				aAdd (aRegTemp[nX], "E305")							//01 - REG	
				aAdd (aRegTemp[nX], "2")							//02 - IND_MRO	
				aAdd (aRegTemp[nX], "0")	  	    //03 - IND_OPER	   
				aAdd (aRegTemp[nX], dDataAnt)  		                //04 - DT_DOC     
				aAdd (aRegTemp[nX], "")								//05 - COP   
				aAdd (aRegTemp[nX], 0)             					//06 - NUM_LCTO
				aAdd (aRegTemp[nX], "1")			  				//07 - QTD_LCTO    
				aAdd (aRegTemp[nX], 0)				   				//08 - VL_CONT 
				aAdd (aRegTemp[nX], 0)					         	//09 - VL_OP_ISS
				aAdd (aRegTemp[nX], 0)						   		//10 - VL_BC_ICMS
				aAdd (aRegTemp[nX], 0)				   	   			//11 - VL_ICMS
				aAdd (aRegTemp[nX], 0)				   				//12 - VL_ICMS_ST
				aAdd (aRegTemp[nX], 0)				   				//13 - VL_ST_ENT		
				aAdd (aRegTemp[nX], 0)								//14 - VL_ST_FNT
				aAdd (aRegTemp[nX], 0)								//14 - VL_ST_UF		
				aAdd (aRegTemp[nX], 0)				   				//16 - VL_ST_OE
				aAdd (aRegTemp[nX], 0)				   				//17 - VL_AT
				aAdd (aRegTemp[nX], 0)						   		//18 - VL_ISNT_ICMS
				aAdd (aRegTemp[nX], 0)								//19 - VL_OUT_ICMS 
				aAdd (aRegTemp[nX], 0)		   						//20 - VL_BC_IPI				
				aAdd (aRegTemp[nX], 0)		   						//21 - VL_IPI 
				aAdd (aRegTemp[nX], 0)								//22 - VL_ISNT_IPI
				aAdd (aRegTemp[nX], 0)				   				//23 - VL_OUT_IPI   		     		  		
	        EndIf
	    dDataAnt+= 1    
	    Next
	    dDataAnt := dDataDe 
		nCont:= (dDataAte - dDataDe) + 1 //Para considerar todos os dias
	    For nx:=nContador+1  to nCont+nContador
	        nPosSai := aScan (aRegE305, {|aX| aX[03]=="1" .And. aX[04] == dDataAnt}) 
		   	If nPosSai > 0 
		 		aAdd (aRegTemp, {})		
				aAdd (aRegTemp[nX], "E305")											//01 - REG	
				aAdd (aRegTemp[nX], "2")											//02 - IND_MRO	
				aAdd (aRegTemp[nX], "1" )	  	  					   				//03 - IND_OPER	   
				aAdd (aRegTemp[nX], aRegE305[nPosSai][4] )  		                		//04 - DT_DOC     
				aAdd (aRegTemp[nX], aRegE305[nPosSai][5] )								//05 - COP   
				aAdd (aRegTemp[nX], aRegE305[nPosSai][6] )             					//06 - NUM_LCTO
				aAdd (aRegTemp[nX], aRegE305[nPosSai][7] )			  			  		//07 - QTD_LCTO    
				aAdd (aRegTemp[nX], aRegE305[nPosSai][8] )				   				//08 - VL_CONT 
				aAdd (aRegTemp[nX], aRegE305[nPosSai][9] )					         	//09 - VL_OP_ISS
				aAdd (aRegTemp[nX], aRegE305[nPosSai][10] )						   		//10 - VL_BC_ICMS
				aAdd (aRegTemp[nX], aRegE305[nPosSai][11] )				   	   			//11 - VL_ICMS
				aAdd (aRegTemp[nX], aRegE305[nPosSai][12] )				   				//12 - VL_ICMS_ST
				aAdd (aRegTemp[nX], aRegE305[nPosSai][13] )				   				//13 - VL_ST_ENT		
				aAdd (aRegTemp[nX], aRegE305[nPosSai][14] )								//14 - VL_ST_FNT
				aAdd (aRegTemp[nX], aRegE305[nPosSai][15] )								//14 - VL_ST_UF		
				aAdd (aRegTemp[nX], aRegE305[nPosSai][16] )				   				//16 - VL_ST_OE
				aAdd (aRegTemp[nX], aRegE305[nPosSai][17] )				   				//17 - VL_AT
				aAdd (aRegTemp[nX], aRegE305[nPosSai][18] )						   		//18 - VL_ISNT_ICMS
				aAdd (aRegTemp[nX], aRegE305[nPosSai][19] )								//19 - VL_OUT_ICMS 
				aAdd (aRegTemp[nX], aRegE305[nPosSai][20] )		   						//20 - VL_BC_IPI
				aAdd (aRegTemp[nX], aRegE305[nPosSai][21] )		   						//21 - VL_IPI 
				aAdd (aRegTemp[nX], aRegE305[nPosSai][22] )								//22 - VL_ISNT_IPI
				aAdd (aRegTemp[nX], aRegE305[nPosSai][23] )				   				//23 - VL_OUT_IPI
			Else
				aAdd (aRegTemp, {})		
				aAdd (aRegTemp[nX], "E305")							//01 - REG	
				aAdd (aRegTemp[nX], "2")							//02 - IND_MRO	
				aAdd (aRegTemp[nX], "1")	  	    //03 - IND_OPER	   
				aAdd (aRegTemp[nX], dDataAnt)  		                //04 - DT_DOC     
				aAdd (aRegTemp[nX], "")								//05 - COP   
				aAdd (aRegTemp[nX], 0)             					//06 - NUM_LCTO
				aAdd (aRegTemp[nX], "1")			  				//07 - QTD_LCTO    
				aAdd (aRegTemp[nX], 0)				   				//08 - VL_CONT 
				aAdd (aRegTemp[nX], 0)					         	//09 - VL_OP_ISS
				aAdd (aRegTemp[nX], 0)						   		//10 - VL_BC_ICMS
				aAdd (aRegTemp[nX], 0)				   	   			//11 - VL_ICMS
				aAdd (aRegTemp[nX], 0)				   				//12 - VL_ICMS_ST
				aAdd (aRegTemp[nX], 0)				   				//13 - VL_ST_ENT		
				aAdd (aRegTemp[nX], 0)								//14 - VL_ST_FNT
				aAdd (aRegTemp[nX], 0)								//14 - VL_ST_UF		
				aAdd (aRegTemp[nX], 0)				   				//16 - VL_ST_OE
				aAdd (aRegTemp[nX], 0)				   				//17 - VL_AT
				aAdd (aRegTemp[nX], 0)						   		//18 - VL_ISNT_ICMS
				aAdd (aRegTemp[nX], 0)								//19 - VL_OUT_ICMS 
				aAdd (aRegTemp[nX], 0)		   						//20 - VL_BC_IPI
				aAdd (aRegTemp[nX], 0)		   						//21 - VL_IPI 
				aAdd (aRegTemp[nX], 0)								//22 - VL_ISNT_IPI
				aAdd (aRegTemp[nX], 0)				   				//23 - VL_OUT_IPI   		     		  		
	        EndIf
	    dDataAnt+= 1     	
		Next
		aRegE305 := ACLONE(aRegTemp)
EndIf 		 	   

Return (lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RegE310  	³ Autor ³Sueli C. Santos        ³ Data ³08.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³     E310 - CONSOLIDACAO DOS VALORES DE ICMS POR CFOP       ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao do Registros E310			                      |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef com as informacoe contidas no array    ³±±
±±³          ³ aCmpAntSFT e na tabela SFT.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³E310 - 3(varios por periodo)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAliasSFT -> Alias da tabela SFT aberta no momento.         ³±±
±±³          ³ funcao a ser retornado para gravacao pela funcao principal.³±±
±±³          |cEntSai -> Flag Entrada(1)/Saida(2).                        ³±±
±±³          |aRegE310 -> Array contendo as informacoes processadas pela  ³±±
±±³          ³ funcao a ser retornado para gravacao pela funcao principal.³±±
±±³          ³cSituaDoc -> Situacao do documento fiscal.                  ³±±
±±³          ³lIss -> Indicador de nota fiscal com incidencia do ISS      ³±±
±±³          ³cEspecie -> Especie do documento fiscal                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegE310 (cAliasSFT, cEntSai, aRegE310, cSituaDoc, lIss,cEspecie)
	Local	nPos	:=	0
	Local	lRet	:=	.T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³REGISTRO E310 - CONSOLIDACAO DOS VALORES DE ICMS POR CFOP ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ((nPos := aScan (aRegE310, {|aX| aX[4]==(cAliasSFT)->FT_CFOP}))==0)
		aAdd(aRegE310, {})
		nPos	:=	Len (aRegE310)
		aAdd (aRegE310[nPos], "E310")	 	   					//01 - REG
		aAdd (aRegE310[nPos], 0)								//02 - VL_CONT
		aAdd (aRegE310[nPos], 0)								//03 - VL_OP_ISS
		aAdd (aRegE310[nPos], (cAliasSFT)->FT_CFOP)			//04 - CFOP
		aAdd (aRegE310[nPos], 0)								//05 - VL_BC_ICMS
		aAdd (aRegE310[nPos], 0)								//06 - VL_ICMS
		aAdd (aRegE310[nPos], 0)								//07 - VL_ICMS_ST
		aAdd (aRegE310[nPos], 0)								//08 - VL_ISNT_ICMS
		aAdd (aRegE310[nPos], 0)								//09 - VL_OUT_ICMS
		aAdd (aRegE310[nPos], "")								//10 - IND_IMUN   		
		
	EndIf
	If !(cSituaDoc$"90#81#")
		If lIss
			aRegE310[nPos][3]	+=	(cAliasSFT)->FT_VALCONT		//03 - VL_OP_ISS
		Else
			aRegE310[nPos][2]	+=	(cAliasSFT)->FT_VALCONT		//02 - VL_CONT
			aRegE310[nPos][5]	+=	(cAliasSFT)->FT_BASEICM		//05 - VL_BC_ICMS
			aRegE310[nPos][6]	+=	(cAliasSFT)->FT_VALICM		//06 - VL_ICMS			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³* Para os modelos abaixo que tiverem DIFERENCIAL ALIQUOTA,   |
			//|  nao devo enviar neste campo, basta considerar nos ajustes. ³
			//³* Para os modelos abaixo que tiverem SUBSTITUICAO TRIBUTARIA,|
			//|  NAO devo enviar neste campo, pois o mesmo estah destinado  ³
			//|  aos registros C's(C020 - Campo 23 - modelo 01 e 04).       |
			//|                                                             |
			//³06 - NOTA FISCAL/CONTA DE ENERGIA ELETRICA                   ³
			//³21 - NOTA FISCAL DE SERVICO DE COMUNICACAO                   ³
			//³22 - NOTA FISCAL DE SERVICO DE TELECOMUNICACAO               ³
			//³07 - NOTA FISCAL SERVICO DE TRANSPORTE - SAIDA/ENTRADA       ³
			//³08 - CONHECIMENTO DE TRANSPORTE RODOVIARIO - SAIDA/ENTRADA   ³
			//³09 - CONHECIMENTO DE TRANSPORTE AQUAVIARIO - ENTRADA         ³
			//³10 - CONHECIMENTO DE TRANSPORTE AEREO - ENTRADA              ³
			//³11 - CONHECIMENTO DE TRANSPORTE FERROVIARIO - ENTRADA        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !(cEspecie$"06#07#08#09#10#11#21#22")
				aRegE310[nPos][7]	+=	(cAliasSFT)->FT_ICMSRET	    //07 - VL_ICMS_ST
			EndIf
			
			aRegE310[nPos][8]	+=	(cAliasSFT)->FT_ISENICM		//08 - VL_ISNT_ICMS
			//Quando configuro a TES para escriturar o Livro de ICMS/ST como ISENTO, na tabela SF3 o valor do campo 
			//  F3_ICMSRET eh transportado para o campo F3_ISENICM, ficando com os mesmos valores. Na tabela SFT, que
			//  possui o campo proprio FT_ISENRET, recebe este valor deixando o campo FT_ISENICM e FT_ICMSRET zerado.
			aRegE310[nPos][8]	+=	(cAliasSFT)->FT_ISENRET		//08 - VL_ISNT_ICMS
			
			If cEspecie<>"2D"
				aRegE310[nPos][9]	+=	(cAliasSFT)->FT_OUTRICM	//09 - VL_OUT_ICMS
			EndIf	
			//Quando configuro a TES para escriturar o Livro de ICMS/ST como OUTROS, na tabela SF3 o valor do campo 
			//  F3_ICMSRET eh transportado para o campo F3_OUTRICM, ficando com os mesmos valores. Na tabela SFT, que
			//  possui o campo proprio FT_OUTRRET, recebe este valor deixando o campo FT_OUTRICM e FT_ICMSRET zerado.
			aRegE310[nPos][9]	+=	(cAliasSFT)->FT_OUTRRET		//09 - VL_OUT_ICMS     
				
		EndIf
	EndIf
Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RegE330   ³ Autor ³Sueli C. Santos        ³ Data ³08.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³        TOTALIZACAO DAS OPERACOES                           ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro E330                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef com as informacoe contidas no array    ³±±
±±³          ³ aRegE310.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³E330 - 3(varios por periodo)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlias -> Alias do TRB para gravacao.                       ³±±
±±³          |aRegE310 -> Array contendo as informacoes por CFOP para     ³±±
±±³          ³ utilizacao.                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegE330 (cAlias,cAliasSFT, cEntSai, cSituaDoc, lIss,cEspecie, aRegE330)
	Local	lRet	:=	.T.
	Local	nPos	:=	0
	Local	nX		:=	0
	//
   
	cIndTot	:=	Left ((cAliasSFT)->FT_CFOP, 1)    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Consolidado CFOPs 1, 2, 3, 5, 6, 7.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ((nPos := aScan (aRegE330, {|aX| aX[2]==cIndTot}))==0)
		aAdd(aRegE330, {})
		nPos	:=	Len (aRegE330)
		aAdd (aRegE330[nPos], "E330")	   				//01 - REG
		aAdd (aRegE330[nPos], cIndTot)					//02 - IND_TOT
		aAdd (aRegE330[nPos], 0)						//03 - VL_CONT
		aAdd (aRegE330[nPos], 0)						//04 - VL_OP_ISS
		aAdd (aRegE330[nPos], 0)						//05 - VL_BC_ICMS
		aAdd (aRegE330[nPos], 0)						//06 - VL_ICMS
		aAdd (aRegE330[nPos], 0)						//07 - VL_ICMS_ST
		aAdd (aRegE330[nPos], 0)				    	//08 - VL_ST_ENT		
		aAdd (aRegE330[nPos], 0)				    	//09 - VL_ST_FNT
		aAdd (aRegE330[nPos], 0)				   		//10 - VL_ST_UF		
		aAdd (aRegE330[nPos], 0)				   		//11 - VL_ST_OE
		aAdd (aRegE330[nPos], 0)						//12 - VL_AT
		aAdd (aRegE330[nPos], 0)						//13 - VL_ISNT_ICMS
		aAdd (aRegE330[nPos], 0)						//14 - VL_OUT_ICMS
	EndIf
 
	If !(cSituaDoc$"90#81#")
		If lIss
			aRegE330[nPos][4]	+=	(cAliasSFT)->FT_VALCONT		//04 - VL_OP_ISS
		Else
			aRegE330[nPos][3]	+=	(cAliasSFT)->FT_VALCONT		//03 - VL_CONT
			aRegE330[nPos][5]	+=	(cAliasSFT)->FT_BASEICM		//05 - VL_BC_ICMS
			aRegE330[nPos][6]	+=	(cAliasSFT)->FT_VALICM		//06 - VL_ICMS			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³* Para os modelos abaixo que tiverem DIFERENCIAL ALIQUOTA,   |
			//|  nao devo enviar neste campo, basta considerar nos ajustes. ³
			//³* Para os modelos abaixo que tiverem SUBSTITUICAO TRIBUTARIA,|
			//|  NAO devo enviar neste campo, pois o mesmo estah destinado  ³
			//|  aos registros C's(C020 - Campo 23 - modelo 01 e 04).       |
			//|                                                             |
			//³06 - NOTA FISCAL/CONTA DE ENERGIA ELETRICA                   ³
			//³21 - NOTA FISCAL DE SERVICO DE COMUNICACAO                   ³
			//³22 - NOTA FISCAL DE SERVICO DE TELECOMUNICACAO               ³
			//³07 - NOTA FISCAL SERVICO DE TRANSPORTE - SAIDA/ENTRADA       ³
			//³08 - CONHECIMENTO DE TRANSPORTE RODOVIARIO - SAIDA/ENTRADA   ³
			//³09 - CONHECIMENTO DE TRANSPORTE AQUAVIARIO - ENTRADA         ³
			//³10 - CONHECIMENTO DE TRANSPORTE AEREO - ENTRADA              ³
			//³11 - CONHECIMENTO DE TRANSPORTE FERROVIARIO - ENTRADA        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !(cEspecie$"06#07#08#09#10#11#21#22")
				aRegE330[nPos][7]	+=	(cAliasSFT)->FT_ICMSRET	    //07 - VL_ICMS_ST
			EndIf
			
			aRegE330[nPos][13]	+=	(cAliasSFT)->FT_ISENICM		//13 - VL_ISNT_ICMS
			//Quando configuro a TES para escriturar o Livro de ICMS/ST como ISENTO, na tabela SF3 o valor do campo 
			//  F3_ICMSRET eh transportado para o campo F3_ISENICM, ficando com os mesmos valores. Na tabela SFT, que
			//  possui o campo proprio FT_ISENRET, recebe este valor deixando o campo FT_ISENICM e FT_ICMSRET zerado.
			aRegE330[nPos][13]	+=	(cAliasSFT)->FT_ISENRET		//13 - VL_ISNT_ICMS
			
			If cEspecie<>"2D"
				aRegE330[nPos][14]	+=	(cAliasSFT)->FT_OUTRICM	//14 - VL_OUT_ICMS
			EndIf	
			//Quando configuro a TES para escriturar o Livro de ICMS/ST como OUTROS, na tabela SF3 o valor do campo 
			//  F3_ICMSRET eh transportado para o campo F3_OUTRICM, ficando com os mesmos valores. Na tabela SFT, que
			//  possui o campo proprio FT_OUTRRET, recebe este valor deixando o campo FT_OUTRICM e FT_ICMSRET zerado.
			aRegE330[nPos][14]	+=	(cAliasSFT)->FT_OUTRRET		//14 - VL_OUT_ICMS     
			
			If !Empty((cAliasSFT)->FT_FORMUL) .And. cEntSai=="1"	//formulario Proprio igual a Sim na entrada
	   			aRegE330[nPos][9]	+=	(cAliasSFT)->FT_ICMSRET		//09 - VL_ST_FNT 
	   			
	   		ElseIf	Empty((cAliasSFT)->FT_FORMUL) .And. cEntSai=="1" //formulario Proprio igual a Nao na entrada  
	   			aRegE330[nPos][8]	+=	(cAliasSFT)->FT_ICMSRET		//08 - VL_ST_ENT
	   			
	   		Elseif	SUBSTR((cAliasSFT)->FT_CFOP,1,1)=="5" .And. cEntSai=="2"
	   			aRegE330[nPos][10]	+=	(cAliasSFT)->FT_ICMSRET		//10 - VL_ST_UF	
	   			
			ElseIf SUBSTR((cAliasSFT)->FT_CFOP,1,1)>"5" .And. cEntSai=="2"
				aRegE330[nPos][11]	+=	(cAliasSFT)->FT_ICMSRET		////11 - VL_ST_OE
			EndIF
			
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Totalizando 4, 8³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cIndTot	:=	Iif (Val(cIndTot)<4, "4", "8")
	If ((nPos := aScan (aRegE330, {|aX| aX[2]==cIndTot}))==0)
		aAdd(aRegE330, {})
		nPos	:=	Len (aRegE330)
		aAdd (aRegE330[nPos], "E330")	   				//01 - REG
		aAdd (aRegE330[nPos], cIndTot)					//02 - IND_TOT
		aAdd (aRegE330[nPos], 0)						//03 - VL_CONT
		aAdd (aRegE330[nPos], 0)						//04 - VL_OP_ISS
		aAdd (aRegE330[nPos], 0)						//05 - VL_BC_ICMS
		aAdd (aRegE330[nPos], 0)						//06 - VL_ICMS
		aAdd (aRegE330[nPos], 0)						//07 - VL_ICMS_ST
		aAdd (aRegE330[nPos], 0)				    	//08 - VL_ST_ENT		
		aAdd (aRegE330[nPos], 0)				    	//09 - VL_ST_FNT
		aAdd (aRegE330[nPos], 0)				   		//10 - VL_ST_UF		
		aAdd (aRegE330[nPos], 0)				   		//11 - VL_ST_OE
		aAdd (aRegE330[nPos], 0)						//12 - VL_AT
		aAdd (aRegE330[nPos], 0)						//13 - VL_ISNT_ICMS
		aAdd (aRegE330[nPos], 0)						//14 - VL_OUT_ICMS
	EndIf
	If !(cSituaDoc$"90#81#")
		If lIss
			aRegE330[nPos][4]	+=	(cAliasSFT)->FT_VALCONT		//04 - VL_OP_ISS
		Else
			aRegE330[nPos][3]	+=	(cAliasSFT)->FT_VALCONT		//03 - VL_CONT
			aRegE330[nPos][5]	+=	(cAliasSFT)->FT_BASEICM		//05 - VL_BC_ICMS
			aRegE330[nPos][6]	+=	(cAliasSFT)->FT_VALICM		//06 - VL_ICMS			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³* Para os modelos abaixo que tiverem DIFERENCIAL ALIQUOTA,   |
			//|  nao devo enviar neste campo, basta considerar nos ajustes. ³
			//³* Para os modelos abaixo que tiverem SUBSTITUICAO TRIBUTARIA,|
			//|  NAO devo enviar neste campo, pois o mesmo estah destinado  ³
			//|  aos registros C's(C020 - Campo 23 - modelo 01 e 04).       |
			//|                                                             |
			//³06 - NOTA FISCAL/CONTA DE ENERGIA ELETRICA                   ³
			//³21 - NOTA FISCAL DE SERVICO DE COMUNICACAO                   ³
			//³22 - NOTA FISCAL DE SERVICO DE TELECOMUNICACAO               ³
			//³07 - NOTA FISCAL SERVICO DE TRANSPORTE - SAIDA/ENTRADA       ³
			//³08 - CONHECIMENTO DE TRANSPORTE RODOVIARIO - SAIDA/ENTRADA   ³
			//³09 - CONHECIMENTO DE TRANSPORTE AQUAVIARIO - ENTRADA         ³
			//³10 - CONHECIMENTO DE TRANSPORTE AEREO - ENTRADA              ³
			//³11 - CONHECIMENTO DE TRANSPORTE FERROVIARIO - ENTRADA        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !(cEspecie$"06#07#08#09#10#11#21#22")
				aRegE330[nPos][7]	+=	(cAliasSFT)->FT_ICMSRET	    //07 - VL_ICMS_ST
			EndIf
			
			aRegE330[nPos][13]	+=	(cAliasSFT)->FT_ISENICM		//13 - VL_ISNT_ICMS
			//Quando configuro a TES para escriturar o Livro de ICMS/ST como ISENTO, na tabela SF3 o valor do campo 
			//  F3_ICMSRET eh transportado para o campo F3_ISENICM, ficando com os mesmos valores. Na tabela SFT, que
			//  possui o campo proprio FT_ISENRET, recebe este valor deixando o campo FT_ISENICM e FT_ICMSRET zerado.
			aRegE330[nPos][13]	+=	(cAliasSFT)->FT_ISENRET		//13 - VL_ISNT_ICMS
			
			If cEspecie<>"2D"
				aRegE330[nPos][14]	+=	(cAliasSFT)->FT_OUTRICM		//14 - VL_OUT_ICMS
			EndIf	
			//Quando configuro a TES para escriturar o Livro de ICMS/ST como OUTROS, na tabela SF3 o valor do campo 
			//  F3_ICMSRET eh transportado para o campo F3_OUTRICM, ficando com os mesmos valores. Na tabela SFT, que
			//  possui o campo proprio FT_OUTRRET, recebe este valor deixando o campo FT_OUTRICM e FT_ICMSRET zerado.
			aRegE330[nPos][14]	+=	(cAliasSFT)->FT_OUTRRET		    //14 - VL_OUT_ICMS     
			
			If !Empty((cAliasSFT)->FT_FORMUL) .And. cEntSai=="1"	//formulario Proprio igual a Sim na entrada
	   			aRegE330[nPos][9]	+=	(cAliasSFT)->FT_ICMSRET		//09 - VL_ST_FNT 
	   			
	   		ElseIf	Empty((cAliasSFT)->FT_FORMUL) .And. cEntSai=="1" //formulario Proprio igual a Nao na entrada  
	   			aRegE330[nPos][8]	+=	(cAliasSFT)->FT_ICMSRET		//08 - VL_ST_ENT
	   			
	   		Elseif	SUBSTR((cAliasSFT)->FT_CFOP,1,1)=="5" .And. cEntSai=="2"
	   			aRegE330[nPos][10]	+=	(cAliasSFT)->FT_ICMSRET		//10 - VL_ST_UF	
	   			
			ElseIf SUBSTR((cAliasSFT)->FT_CFOP,1,1)>"5" .And. cEntSai=="2"
				aRegE330[nPos][11]	+=	(cAliasSFT)->FT_ICMSRET		//11 - VL_ST_OE
			EndIF
			
		EndIf
	EndIf
Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |E340E360  ³ Autor ³Sueli C. Santos        ³ Data ³09.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³                   APURACAO DO ICMS                         ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro E360                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef com as informacoe contidas na apuracao ³±±
±±³          ³ de ICMS.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³E340 - 3(varios por periodo)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlias -> Alias do TRB para gravacao.                       ³±±
±±³          ³dDataAte -> Data final do periodo de apuracao.              ³±±
±±³          ³cNrLivro -> Numero do livro selecionado no wizard.          ³±±
±±³          ³nAcImport -> Valor de ICMS da Importacao.                   ³±±
±±³          ³nAcRetInter -> Valor Substituicao Tributaria nas operacoes  ³±±
±±³          ³ interestaduais.                                            ³±±
±±³          ³nDbCompIcm -> Total das NFs de complemento de ICMS - saidas ³±±
±±³          ³nCrCompIcm ->Total das NFs de complemento de ICMS - entradas³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function E340E360 (cAlias, dDataAte, cNrLivro, nAcImport, nAcRetInter, nDbCompIcm, nCrCompIcm, aLog,nAcRetEsta,nAcCredTerc,nAcCredProp,aPartDoc,cChv0450)
	Local	lRet		:=	.T.
	Local	nPos		:=	0
	Local	aReg		:=	{}
	Local	nX			:=	0
	Local	nApuracao	:=	GetSx1 (PadR("MTA951",10), "04", .T.)	//1-Decendial, 2-Quinzenal, 3-Mensal, 4-Semestral ou 5-Anual
	Local	nPeriodo	:=	1								//GetSx1 ("MTA951", "05", .T.)	//1-1., 2-2., 3-3.	
	Local	aApICM		:=	{}
	Local	aApST 		:=	{}
	Local	aApSIM 		:=	{}
	Local	nVL_01		:=	0
	Local	nVL_02		:=	0
	Local	nVL_03		:=	0
	Local	nVL_04		:=	0
	Local	nVL_05		:=	0
	Local	nVL_06		:=	0
	Local	nVL_07		:=	0
	Local	nVL_08		:=	0
	Local	nVL_09		:=	0
	Local	nVL_10		:=	0
	Local	nVL_11		:=	0
	Local	nVL_12		:=	0
	Local	nVL_13		:=	0
	Local	nVL_14		:=	0
	Local	nVL_15		:=	0
	Local	nVL_16		:=	0
	Local	nVL_17		:=	0
	Local	nVL_18		:=	0
	Local	nVL_19		:=	0
	Local	nVL_20		:=	0
	Local   nVL_21      :=  0
	Local   nVL_22      :=  0
	Local	nVL_99		:=	0
	Local 	nVlAj	    :=	0
	Local	aRegE340	:=	{}
	Local	aRegE350 	:= {} 	
	Local	cProc		:=	""
	Local   lAchou 		:= .F. 
	Local 	cDescAj     := ""
	Local   cCodAj 		:= ""
	Local   cDescri		:= ""
	Local   aE350		:={} 
	Local	nPosic		:= 0
   	Local   nPos2       := 0
   	Local   nTam        := 0
	Local 	aSubApRet	:= {}
	Local 	nPos350		:= 0
	Local 	cIndAp		:= ""
	Local cMvEstado	:= SuperGetMv("MV_ESTADO")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Fixo que o periodo de geracao podera ser somente Mensal ou Anual.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nApuracao==1) .Or. (nApuracao==2)
		nApuracao	:=	3
	ElseIf (nApuracao==4)
		nApuracao	:=	5
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Leio o arquivo de apuracao ICMS³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	aApICM	:=	FisApur ("IC", Year (dDataAte), Month (dDataAte), nApuracao, nPeriodo, cNrLivro, .F., {}, 1, .F., "")
	
	nVL_01	:=	Iif (aScan (aApICM, {|a| a[1]=="005"})<>0, aApICM[aScan (aApICM, {|a| a[1]=="005"})][3], 0)    
	nVL_02	:=  nAcCredTerc	
	nVL_03	:=	nAcCredProp
	nVL_04	:=  0
	nVL_05	:=	Iif (aScan (aApICM, {|a| a[4]=="006.00"})<>0, aApICM[aScan (aApICM, {|a| a[4]=="006.00"})][3], 0)
	nVL_06	:=	Iif (aScan (aApICM, {|a| a[4]=="007.00"})<>0, aApICM[aScan (aApICM, {|a| a[4]=="007.00"})][3], 0)		
	nVL_07	:=	Iif (aScan (aApICM, {|a| a[1]=="009"})<>0, aApICM[aScan (aApICM, {|a| a[1]=="009"})][3], 0)
	nVL_08	:=	Iif (aScan (aApICM, {|a| a[1]=="010"})<>0, aApICM[aScan (aApICM, {|a| a[1]=="010"})][3], 0)
	nVL_09	:=	Iif (aScan (aApICM, {|a| a[1]=="001"})<>0, aApICM[aScan (aApICM, {|a| a[1]=="001"})][3], 0)
	nVL_10	:=	Iif (aScan (aApICM, {|a| a[4]=="002.00"})<>0, aApICM[aScan (aApICM, {|a| a[4]=="002.00"})][3], 0)
	nVL_11	:=	Iif (aScan (aApICM, {|a| a[4]=="003.00"})<>0, aApICM[aScan (aApICM, {|a| a[4]=="003.00"})][3], 0)
	nVL_12	:=	Iif (aScan (aApICM, {|a| a[1]=="004"})<>0, aApICM[aScan (aApICM, {|a| a[1]=="004"})][3], 0)
	nVL_13	:=	Iif (aScan (aApICM, {|a| a[1]=="014"})<>0, aApICM[aScan (aApICM, {|a| a[1]=="014"})][3], 0)
	nVL_14	:=	Iif (aScan (aApICM, {|a| a[1]=="011"})<>0, aApICM[aScan (aApICM, {|a| a[1]=="011"})][3], 0)
	nVL_15	:=	Iif (aScan (aApICM, {|a| a[4]=="012.00"})<>0, aApICM[aScan (aApICM, {|a| a[4]=="012.00"})][3], 0)
	nVL_16	:=	Iif (aScan (aApICM, {|a| a[1]=="013"})<>0, aApICM[aScan (aApICM, {|a| a[1]=="013"})][3], 0)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Leio o arquivo de apuracao ICMS/ST³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aApST	:=	FisApur ("ST", Year (dDataAte), Month (dDataAte), nApuracao, nPeriodo, cNrLivro, .F., {}, 1, .F., "")
	nVL_17	:=	Iif (aScan (aApST, {|a| a[1]=="006"})<>0, aApST[aScan (aApST, {|a| a[1]=="006"})][3], 0)
	nVL_18	:=	0
	nVL_19	:=	nAcRetEsta  // ICMS substituto pelas saidas para o Estado.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Outros valores³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVL_20	:=	nAcImport
	nVL_21	:=	0
    nVL_22  :=  nVL_16 + nVL_17 + nVL_18 + nVL_19 + nVL_20 + nVL_21 
	nVL_99	:=	nAcRetInter

	aAdd(aReg, {})
	nPos	:=	Len (aReg)
	aAdd (aReg[nPos], "E340")	   				//01 - REG
	aAdd (aReg[nPos], nVL_01)					//02 - VL_01
	aAdd (aReg[nPos], nVL_02)					//03 - VL_02
	aAdd (aReg[nPos], nVL_03)					//04 - VL_03
	aAdd (aReg[nPos], nVL_04)					//05 - VL_04
	aAdd (aReg[nPos], nVL_05)					//06 - VL_05
	aAdd (aReg[nPos], nVL_06)					//07 - VL_06
	aAdd (aReg[nPos], nVL_07)					//08 - VL_07
	aAdd (aReg[nPos], nVL_08)					//09 - VL_08
	aAdd (aReg[nPos], nVL_09)					//10 - VL_09
	aAdd (aReg[nPos], nVL_10)					//11 - VL_10
	aAdd (aReg[nPos], nVL_11)					//12 - VL_11
	aAdd (aReg[nPos], nVL_12)					//13 - VL_12
	aAdd (aReg[nPos], nVL_13)					//14 - VL_13
	aAdd (aReg[nPos], nVL_14)					//15 - VL_14
	aAdd (aReg[nPos], nVL_15)					//16 - VL_15
	aAdd (aReg[nPos], nVL_16)					//17 - VL_16
	aAdd (aReg[nPos], nVL_17)					//18 - VL_17
	aAdd (aReg[nPos], nVL_18)					//19 - VL_18
	aAdd (aReg[nPos], nVL_19)					//20 - VL_19
	aAdd (aReg[nPos], nVL_20)					//21 - VL_20  
	aAdd (aReg[nPos], nVL_21)					//22 - VL_21
	aAdd (aReg[nPos], nVL_22)					//23 - VL_22    	
	aAdd (aReg[nPos], nVL_99)					//24 - VL_99
	//
	GrvRegSef (cAlias,, aReg)   
	//E350 AJUSTES DA APURAÇÃO DO ICMS
	
	For nX := 1 To Len (aApICM)
   		lAchou := .F. 
   		nPosic 	:= 0
   		nPos2 	:= 0
   		nTam 	:=0
    	If Ascan({"002","003","006","007","012"},{|a|a == aApICM[nX][1]})>0  .and. substr(aApICM[nX][4],1,3)<>aApICM[nX][1]
   		  lAchou := .T.   
   		  cCodAj := aApICM[nX][4]
   		  nVlAj  := aApICM[nX][3]
   		  cDescAj:= aApICM[nX][2]
   		  
   		  cDescri := aApICM[nX][2]
   		  cIndap	:= iif(substr(aApICM[nX][2],1,1) $ '1234567890',substr(aApICM[nX][2],1,1),'')
   		  nPosic:= At("/",cDescri)
   		  nPos2:= At("|",cDescri) 
   		  nTam := Len(cDescri)

   		  IF nPosic > 0 .And. nPos2 > 0 .And. SUBSTR(cDescri, 1,1)$"0,1,2,9"              
   		     aE350 := {{"IND_PROC", SUBSTR(cDescri, 1,1)},{"NUM_PROC", SUBSTR(cDescri, nPosic+1,nPos2-3)},{"DESCR_PROC", SUBSTR(cDescri, nPos2+1,nTam-nPos2)	}}
   		  Else
   		  	  aE350 := {{"IND_PROC", ""},{"NUM_PROC", ""},{"DESCR_PROC", ""}}   		  	  
   		  	  cChv0450 := StrZero(Val(cChv0450)+1,9)
   		  	  Reg0450 (cAlias, 0/*nRelac*/, cDescri+"  ", cChv0450)
   		  EndIf     
   		    
   		Endif
   		aSubApRet := SubAp() 
		nPos350	:=	aScan (aSubApRet, {|aX| aX[1]== Alltrim(cNrLivro)}) 
		If nPos350 > 0 .and. !Empty(cIndAp) 
			cIndAp	:= 	aSubApRet[nPos350][2]
		EndIf          
   		If lAchou 
			aAdd(aRegE350, {})
			nPos	:=	Len (aRegE350)
			aAdd (aRegE350[nPos], "E350")	   	   				//01 - REG
			aAdd (aRegE350[nPos], cMvEstado) 				//02 - UF_AJ 
			aAdd (aRegE350[nPos], substr(cCodAj,1,3))			           	//03 - COD_AJ 
			aAdd (aRegE350[nPos], nVlAj)			            //04 - VL_AJ  		
			aAdd (aRegE350[nPos], "") 							//05 - NUM_DA
			aAdd (aRegE350[nPos], aE350[2,2]) 					//06 - NUM_PROC 
			aAdd (aRegE350[nPos], aE350[1,2]) 					//07 - IND_PROC
	   		aAdd (aRegE350[nPos], aE350[3,2]) 			        //08 - DESCR_PROC 
	   		aAdd (aRegE350[nPos], cChv0450) 					//09 - COD_INF_OBS
	   		aAdd (aRegE350[nPos], cIndAp) 						//10 - IND_AP 
	   	Endif		
	Next nI
	If len(aRegE350) > 0 
		GrvRegSef (cAlias, , aRegE350 ) 
	EndIf            
Return (lRet)                   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RegE500   ³ Autor ³Sueli C. Santos        ³ Data ³09.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³               PERIODO DE APURACAO DO IPI                   ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro E500                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2(um por periodo)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlias -> Alias do TRB que devera conter as informacoes do  ³±±
±±³          ³ meio-magnetico.                                            ³±±
±±³          ³dDataDe -> Data incial do periodo de apuracao.              ³±±
±±³          ³dDataAte -> Data final do periodo de apuracao.              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegE500 (cAlias, dDataDe, dDataAte)	
	Local	aReg		:=	{}
	Local	lRet		:=	.T.
	Local	nPos		:=	0
	//
	aAdd (aReg, {})
	nPos	:=	Len (aReg)
	aAdd (aReg[nPos], "E500")							//01 - REG
	aAdd (aReg[nPos], dDataDe)							//02 - DT_INI
	aAdd (aReg[nPos], dDataAte)							//03 - DT_FIN
	//
	GrvRegSef (cAlias,, aReg)
Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RegE520   ³ Autor ³Sueli C. Santos        ³ Data ³07.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³    CONSOLIDACAO DOS VALORES DE IPI POR CFOP E CODIGO DE    ³±±
±±³          ³                   TRIBUTACAO DO IPI                        ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao do Registros E520                                 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef com as informacoe contidas na tabela   ³±±
±±³          ³ SFT somente para operacoes TRIBUTADAS                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3(varios por periodo)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAliasSFT -> Alias da tabela SFT aberta no momento.         ³±±
±±³          ³ funcao a ser retornado para gravacao pela funcao principal.³±±
±±³          |aRegE520 -> Array contendo as informacoes processadas pela  ³±±
±±³          ³ funcao a ser retornado para gravacao pela funcao principal.³±±
±±³          ³cSituaDoc -> Situação do documento.						  ³±±
±±³          ³cEntSai -> Flag de indicacao do documento fiscal, 1=Entrada/³±±
±±³          ³ 2=Saida.                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegE520 (cAliasSFT, aRegE520, cSituaDoc, cEntSai)
	Local	lRet		:=	.T.
	Local	nPos		:=	0

	If (nPos := aScan (aRegE520, {|aX| aX[3]==(cAliasSFT)->FT_CFOP }))==0
		aAdd(aRegE520, {})
		nPos	:=	Len (aRegE520)
		aAdd (aRegE520[nPos], "E520")	   				    //01 - REG  
		aAdd (aRegE520[nPos], 0)						    //02 - VL_CONT
		aAdd (aRegE520[nPos], (cAliasSFT)->FT_CFOP) 	    //03 - CFOP
		aAdd (aRegE520[nPos], 0)					     	//04 - VL_BC_IPI
		aAdd (aRegE520[nPos], 0)					     	//05 - VL_IPI
		aAdd (aRegE520[nPos], 0)					   	    //06 - VL_ISNT_IPI
		aAdd (aRegE520[nPos], 0)						    //07 - VL_OUT_IPI
		
	EndIf
	If !("90#81#"$cSituaDoc)
		aRegE520[nPos][2]	+=	(cAliasSFT)->FT_VALCONT		//02 - VL_CONT
		aRegE520[nPos][4]	+=	(cAliasSFT)->FT_BASEIPI		//04 - VL_BC_IPI	
		aRegE520[nPos][5]	+=	(cAliasSFT)->FT_VALIPI		//05 - VL_IPI
		aRegE520[nPos][6]	+=	(cAliasSFT)->FT_ISENIPI		//06 - VL_ISNT_IPI
		aRegE520[nPos][7]	+=	(cAliasSFT)->FT_OUTRIPI		//07 - VL_OUT_IPI
	EndIf
Return (lRet)  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RegE525   ³ Autor ³Sueli C. Santos        ³ Data ³08.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³        TOTALIZACAO DOS VALORES DE ENTRADAS E SAIDAS        ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro E330                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef com as informacoe contidas no array    ³±±
±±³          ³ aRegE310.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³E330 - 3(varios por periodo)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlias -> Alias do TRB para gravacao.                       ³±±
±±³          |aRegE310 -> Array contendo as informacoes por CFOP para     ³±±
±±³          ³ utilizacao.                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegE525 (cAlias, aRegE525, aRegE520)
	Local	lRet	:=	.T.
	Local	nPos	:=	0
	Local	nX		:=	0
	//
	For nX := 1 To Len (aRegE520)
		cIndTot	:=	Left (aRegE520[nX][3], 1)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Consolidado CFOPs 1, 2, 3, 5, 6, 7.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ((nPos := aScan (aRegE525, {|aX| aX[2]==cIndTot}))==0)
			aAdd(aRegE525, {})
			nPos	:=	Len (aRegE525)
			aAdd (aRegE525[nPos], "E525")	   				//01 - REG
			aAdd (aRegE525[nPos], cIndTot)					//02 - IND_TOT
			aAdd (aRegE525[nPos], 0)						//03 - VL_CONT
			aAdd (aRegE525[nPos], 0)						//04 - VL_BC_IPI
			aAdd (aRegE525[nPos], 0)						//05 - VL_IPI
			aAdd (aRegE525[nPos], 0)						//06 - VL_ISNT_IPI
			aAdd (aRegE525[nPos], 0)						//07 - VL_OUT_IPI
		EndIf
		aRegE525[nPos][3]	:=	aRegE520[nX][2]				//03 - VL_CONT		
		aRegE525[nPos][4]	:=	aRegE520[nX][4]				//04 - VL_BC_IPI
		aRegE525[nPos][5]	:=	aRegE520[nX][5]				//05 - VL_IPI
		aRegE525[nPos][6]	:=	aRegE520[nX][6]				//06 - VL_ISNT_IPI
		aRegE525[nPos][7]	:=	aRegE520[nX][7]				//07 - VL_OUT_IPI    
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Totalizando 4, 8³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cIndTot	:=	Iif (Val(cIndTot)<4, "4", "8")
		If ((nPos := aScan (aRegE525, {|aX| aX[2]==cIndTot}))==0)
			aAdd(aRegE525, {})
			nPos	:=	Len (aRegE525)
			aAdd (aRegE525[nPos], "E525")	   				//01 - REG
			aAdd (aRegE525[nPos], cIndTot)					//02 - IND_TOT
			aAdd (aRegE525[nPos], 0)						//03 - VL_CONT
			aAdd (aRegE525[nPos], 0)						//04 - VL_BC_IPI
			aAdd (aRegE525[nPos], 0)						//05 - VL_IPI
			aAdd (aRegE525[nPos], 0)						//06 - VL_ISNT_IPI
			aAdd (aRegE525[nPos], 0)						//07 - VL_OUT_IPI
		EndIf
		aRegE525[nPos][3]	:=	aRegE520[nX][2]				//03 - VL_CONT		
		aRegE525[nPos][4]	:=	aRegE520[nX][4]				//04 - VL_BC_IPI
		aRegE525[nPos][5]	:=	aRegE520[nX][5]				//05 - VL_IPI
		aRegE525[nPos][6]	:=	aRegE520[nX][6]				//06 - VL_ISNT_IPI
		aRegE525[nPos][7]	:=	aRegE520[nX][7]				//07 - VL_OUT_IPI   
		
	Next (nX)
Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RegE540   ³ Autor ³Sueli C. Santos        ³ Data ³08.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³                   APURACAO DO IPI                          ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro E550                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef com as informacoe contidas na apuracao ³±±
±±³          ³ de IPI.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³E540 - 3(varios por periodo)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlias -> Alias do TRB para gravacao.                       ³±±
±±³          ³dDataAte -> Data final do periodo de apuracao.              ³±±
±±³          ³cNrLivro -> Numero do livro selecionado no wizard.          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegE540 (cAlias, dDataAte, cNrLivro, dDataDe, cChv0450)
	Local	lRet		:= .T.
	Local	nPos		:= 0
	Local	nX			:= 0
	Local	nApuracao	:= GetSx1 (PadR("MTA951",10), "04", .T.)	//1-Decendial, 2-Quinzenal, 3-Mensal, 4-Semestral ou 5-Anual
	Local	nPeriodo	:= 1								//GetSx1 ("MTA951", "05", .T.)	//1-1., 2-2., 3-3.	
	Local	aReg		:= {}
	Local	aApIPI		:= {}
	Local 	nVL001 		:= 0
	Local 	nVL002		:= 0
	Local 	nVL003		:= 0	
	Local 	nVL004		:= 0	
	Local 	nVL005		:= 0	
	Local 	nVL006		:= 0	
	Local 	nVL007		:= 0	
	Local 	nVL008		:= 0	
	Local 	nVL009		:= 0	
	Local 	nVL010		:= 0
	Local 	nVL011		:= 0
	Local 	nVL012		:= 0
	Local 	nVL013		:= 0
	Local 	nVL014		:= 0
	Local 	nVL015		:= 0	
	Local   aRegE550    := {}
	Local   cChave      := ""
	Local	cAliasCDP	:= "CDP"
	Local	aParFil		:= {}
	Local	nRecnoCCK	:= Nil
	Local	lAchouCCK	:= .F.
	Local	cSequen		:= ""
	Local	cSomaSeq	:= "" 
	
	Default cChv0450	:= "" 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Fixo que o periodo de geracao podera ser somente Mensal ou Anual.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nApuracao==1) .Or. (nApuracao==2)
		nApuracao	:=	3
	ElseIf (nApuracao==4)
		nApuracao	:=	5
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Leio o arquivo de apuracao.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aApIPI	:=	FisApur ("IP", Year (dDataAte), Month (dDataAte), nApuracao, nPeriodo, cNrLivro, .F., {}, 1, .F., "")
    //
	nVL001	:=	Iif (aScan (aApIPI, {|a| a[1]=="001"})<>0, aApIPI[aScan (aApIPI, {|a| a[1]=="001"})][3], 0)  // 001- Valor dos créditos por entradas do mercado nacional
	nVL002	:=	Iif (aScan (aApIPI, {|a| a[1]=="002"})<>0, aApIPI[aScan (aApIPI, {|a| a[1]=="002"})][3], 0)	// 002- Valor dos créditos por entradas do mercado externo
	nVL003	:=	Iif (aScan (aApIPI, {|a| a[1]=="003"})<>0, aApIPI[aScan (aApIPI, {|a| a[1]=="003"})][3], 0)  // 003- Valor dos créditos por saídas para o mercado externo
	nVL004	:=	Iif (aScan (aApIPI, {|a| a[1]=="004"})<>0, aApIPI[aScan (aApIPI, {|a| a[1]=="004"})][3], 0)  // 004- Valor dos estornos de débitos
	nVL005	:=	Iif (aScan (aApIPI, {|a| a[1]=="005"})<>0, aApIPI[aScan (aApIPI, {|a| a[1]=="005"})][3], 0)	// 005- Valor dos outros créditos
	nVL006	:=	Iif (aScan (aApIPI, {|a| a[1]=="005"})<>0, aApIPI[aScan (aApIPI, {|a| a[1]=="005"})][3], 0)	// 006- Valor subtotal (001 + 002 + 003 + 004 + 005)	
	nVL007 	+= 	Iif (aScan (aApIPI, {|a| a[1]=="007"})<>0, aApIPI[aScan (aApIPI, {|a| a[1]=="007"})][3], 0)	// 007- Saldo credor do período anterior
	nVL008	:=	Iif (aScan (aApIPI, {|a| a[1]=="009"})<>0, aApIPI[aScan (aApIPI, {|a| a[1]=="009"})][3], 0)	// 009- Valor dos débitos por saídas para o mercado nacional
	nVL009	:=	Iif (aScan (aApIPI, {|a| a[1]=="010"})<>0, aApIPI[aScan (aApIPI, {|a| a[1]=="010"})][3], 0) // 010- Valor dos estornos de créditos
	nVL010 	+= 	Iif (aScan (aApIPI, {|a| a[1]=="011"})<>0, aApIPI[aScan (aApIPI, {|a| a[1]=="011"})][3], 0)	// 011- Valor dos ressarcimentos de créditos
	nVL011	:=	Iif (aScan (aApIPI, {|a| a[1]=="012"})<>0, aApIPI[aScan (aApIPI, {|a| a[1]=="012"})][3], 0)	// 012- Valor dos outros débitos
	nVL012	:=	Iif (aScan (aApIPI, {|a| a[1]=="014"})<>0, aApIPI[aScan (aApIPI, {|a| a[1]=="014"})][3], 0) // 014- Débito total (= 013), onde '013- Valor total dos débitos (009 + 010 + 011 + 012)'
	nVL013	:=	Iif (aScan (aApIPI, {|a| a[1]=="015"})<>0, aApIPI[aScan (aApIPI, {|a| a[1]=="015"})][3], 0)  //015- Crédito total (= 008), onde '008- Valor total dos créditos (006 + 007)'
    nVL014	:=	Iif (aScan (aApIPI, {|a| a[1]=="016"})<>0, aApIPI[aScan (aApIPI, {|a| a[1]=="016"})][3], 0) //016- Saldo devedor (014 - 015)
	nVL015	:=	Iif (aScan (aApIPI, {|a| a[1]=="017"})<>0, aApIPI[aScan (aApIPI, {|a| a[1]=="017"})][3], 0) //017- Saldo credor (015 - 014)
	//
	aAdd(aReg, {})
	nPos	:=	Len (aReg)
	aAdd (aReg[nPos], "E540")	   				//01 - REG  
	aAdd (aReg[nPos], nVL001)					//02 - VL001	
	aAdd (aReg[nPos], nVL002)					//03 - VL002	
	aAdd (aReg[nPos], nVL003)					//04 - VL003	
	aAdd (aReg[nPos], nVL004)					//05 - VL004	
	aAdd (aReg[nPos], nVL005)					//06 - VL005	
	aAdd (aReg[nPos], nVL006)					//07 - VL006	
	aAdd (aReg[nPos], nVL007)					//08 - VL007 	     
	aAdd (aReg[nPos], nVL008)					//09 - VL009	
	aAdd (aReg[nPos], nVL009)					//10 - VL010
	aAdd (aReg[nPos], nVL010)					//11 - VL011
	aAdd (aReg[nPos], nVL011)					//12 - VL012
	aAdd (aReg[nPos], nVL012)					//13 - VL013
	aAdd (aReg[nPos], nVL013)					//14 - VL008
	aAdd (aReg[nPos], nVL014)					//15 - VL016	
	aAdd (aReg[nPos], nVL015)					//16 - VL017
	
	GrvRegSef (cAlias,, aReg) 
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³O periodo de geracao podera ser somente 0 - Mensal ou 1 - Descendial ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nApuracao<>1)
		nApuracao	:=	3
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Para ambiente ADS/DBF, devo pegar a ultima sequencia para montar o indregua³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	
	If !lTop
		cChave	:=	STR(nApuracao,1)+STR(nPeriodo,1)+DTOS(dDataDe)+cNrLivro
		
		If CDP->(MsSeek(xFilial("CDP")+"IP"+cChave))
			cSomaSeq  		:= 	CDP->CDP_SEQUEN
	
			While CDP->(MsSeek(xFilial("CDP")+"IP"+cChave+cSomaSeq)) // Posiciona na ultima sequencia
				cSequen  	:= 	CDP->CDP_SEQUEN
			EndDo
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montando array de parametros para SPEDFFiltro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aParFil,"IP")
	aAdd(aParFil,STR(nApuracao,1))
	aAdd(aParFil,STR(nPeriodo,1))
	aAdd(aParFil,DTOS(dDataDe))
	aAdd(aParFil,cNrLivro)
	aAdd(aParFil,cSequen)
	             
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para quando existir a tabela de APuração de IP³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If AliasIndic("CDP") .And. AliasIndic("CCK") .And. SPEDFFiltro(1,"CDP",@cAliasCDP,aParFil)                                                     
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³A tabela de Apuracao jah estah filtrada neste momento ³
		//³  atraves da funcao SPEDFFiltro acima                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While !(cAliasCDP)->(Eof())
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Para ambiente TOP devo pegar o recno retornado na query, se nao for TOP,³
			//³ devo deixar como declarado, igual a Nil                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lTop
				nRecnoCCK	:=	(cAliasCDP)->CCKRECNO
			EndIf
			
			lAchouCCK	:=	SPEDSeek("CCK",,xFilial("CCK")+(cAliasCDP)->CDP_CODLAN,nRecnoCCK)
	
			If lAchouCCK
				aAdd(aRegE550, {})
				nPos	:=	Len (aRegE550)
				aAdd (aRegE550[nPos], "E550")	   	   							//01 - REG
				aAdd (aRegE550[nPos], (cAliasCDP)->CDP_CODLAN)					//02 - COD_AJ
				aAdd (aRegE550[nPos], (cAliasCDP)->CDP_VALOR)					//03 - VL_AJ  			
				aAdd (aRegE550[nPos], (cAliasCDP)->CDP_INDDOC)					//04 - IND_DOC
				aAdd (aRegE550[nPos], (cAliasCDP)->CDP_NUMDOC)					//05 - NUM_DOC
				aAdd (aRegE550[nPos], (cAliasCDP)->CDP_DESC)					//06 - DESCR_AJ			
				aAdd (aRegE550[nPos], cChv0450)				   					//07 - COD_INF_OBS
				
				GrvRegSef (cAlias,, aRegE550)
			EndIf
			
			(cAliasCDP)->(dbSkip())		
		EndDo

	EndIf
	
Return (lRet) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |E560   ³ Autor ³Erick G. Dias             ³ Data ³29.10.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³      OBRIGAÇÕES DO IPI A RECOLHER                          ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro E550                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegE560(cAlias,aRegE560,dDtIni,dDtFim,cChv0450)

	Local nPos:=0
	Local cNaturez := SuperGetMv("MV_IPI")
	Local cAliasSE2  :="SE2" 
    Local cDtEmis := ""
    Local lQuery := .F.
    Local cDtIni := ""
 
	//Busca da contas a pagar
	dbSelectArea("SE2")                               					
	dbSetOrder(2)
	#IFDEF TOP
	    If TcSrvType()<>"AS/400"
			lQuery := .T.
			cAliasSE2 :=GetNextAlias() 
			cQuery := "SELECT * "
			cQuery += "FROM "+RetSqlName("SE2")+" "
			cQuery += "WHERE E2_FILIAL='"+xFilial("SE2")+"' AND "
     		cQuery += "E2_EMISSAO>='"+Dtos(dDtIni)+"' AND "
	 		cQuery += "E2_EMISSAO<='"+Dtos(dDtFim)+"' AND "
	 		cQuery += "E2_NATUREZ='"+Alltrim(cNaturez)+"' AND "
	 		cQuery += "E2_FILORIG='"+cFilAnt+"' AND "
			cQuery += "D_E_L_E_T_ = ' ' "
			cQuery += "ORDER BY "+SqlOrder(SE2->(IndexKey()))
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE2,.T.,.T.)
			dbSelectArea(cAliasSE2)
		Else
	#ENDIf
	    	(cAliasSE2)->( MsSeek(xFilial("SE2")))
	#IFDEF TOP
		EndIf
	#ENDIF 
	
   	While (cAliasSE2)->(!Eof()) .And. xFilial("SE2")== (cAliasSE2)->E2_FILIAL		
		aAdd(aRegE560, {})
		
		cDtEmis := IIf( lQuery , (cAliasSE2)->E2_VENCREA , DtoS((cAliasSE2)->E2_VENCREA))
		cDtIni  := DtoS(dDtIni)  
		
		nPos	:=	Len (aRegE560)
		aAdd (aRegE560[nPos], "E560") // 01 - LIN
		aAdd (aRegE560[nPos], "")     // 02 - COD_OR_IPI
		aAdd (aRegE560[nPos], Substr(cDtIni,5,2)  +  substr(cDtIni,1,4) ) // 03 - PER_REF  
		aAdd (aRegE560[nPos],  (cAliasSE2)->E2_CODRET)     // 04 - COD_REC_IPI
		aAdd (aRegE560[nPos], (cAliasSE2)->E2_VALOR)       // 05 - VL_IPI_REC
		aAdd (aRegE560[nPos], Substr(cDtEmis,7,2) + Substr(cDtEmis,5,2) + Substr(cDtEmis,1,4))     // 06 - DT_VCTO  		     	
		aAdd (aRegE560[nPos], "")     // 07 - IND_DOC
		aAdd (aRegE560[nPos], "")     // 08 - NUM_DOC
		aAdd (aRegE560[nPos], "")     // 09 - DESCR_AJ
		aAdd (aRegE560[nPos], cChv0450)     // 10 - COD_INF_OBS
		DbSkip()
   	EndDo
	
	#IFDEF TOP
		If (TcSrvType ()<>"AS/400")
			DbSelectArea (cAliasSE2)
			(cAliasSE2)->(DbCloseArea ())
		Else
	#ENDIF
		RetIndex("SE2")			
	#IFDEF TOP
		EndIf
	#ENDIF	
Return

Static Function RegHP7(cArquivo,cTipo,cFiltro,cProdIni,cProdFim,cArmIni,cArmFim)

	Local aAreaAnt := GetArea()
	Local nh			:=	0
	Local cAlias		:=	''
	Local cIndTmp1	:=	''
	Local aRetInv		:=	{}
	Local aRet   		:=	{}
	Local lAglH010	:= 	SUPERGETMV('MV_AGLH010',,.F.)
	Local lArmazem	:=	.F.
	Local cProd		:=	''
	Local cAliBLH	:= {}
	Local cLoja			:= ""
	Local cClifor		:= ""
	Local nTotal		:= 0
	local ntamCli		:= TamSX3("A1_COD")[1]
	Local nTamLoj		:= TamSX3("A1_LOJA")[1]
	Local cTPCF     	:= ""
	Default cFiltro	:=	''
	Default cArquivo 	:=	''
	Default cArmIni	:=	''
	Default cArmFim	:=	''
	Default cProdFim	:=	''
	Default cProdIni	:= 	''
	Default cTipo 	:=	''

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Somente os tipos permitidos³
	//³                           ³
	//³1 - Saldo em Estoque       ³
	//³2 - Saldo em Processo      ³
	//³4 - Saldo De Terceiros     ³
	//³5 - Saldo Em Terceiros     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF Empty(SToD(cArquivo))
		Alert('Data de fechamento do inventário não preenchida')

	//Ponto de entrada
	ElseIf ExistBlock("SPEDALTH") 			

		cAliBLH := ExecBlock("SPEDALTH",.F.,.F.,{SToD(cArquivo),''})

		//Verifica se arquivo existe
		IF File(cAliBLH+GetDBExtension())
			
			dbSelectArea(cAliBLH) 
			(cAliBLH)->(dbGoTop())				
		Else
			Alert("Não foi encontrado arquivo do ponto de entrada SPEDALTH para compor Bloco H")		
		Endif
	Else
		SPDBlocH(@cAliBLH,'', SToD(cArquivo) )

		If Empty(cAliBLH)
			Alert("Nao foi encontrado dados no retorno da funçao SPDBlocH")
		Else
			dbSelectArea(cAliBLH)
			(cAliBLH)->(dbGoTop())
		Endif	
	Endif

	If !Empty(cAliBLH)
		While !(cAliBLH)->(Eof())
			cProd	 :=	PadR(Alltrim((cAliBLH)->COD_ITEM),TamSX3("B1_COD")[1])

			SB1->(DbSetOrder(1))
			SB1->(MsSeek(xFilial("SB1")+cProd))
			If (!Empty(cArmIni+cArmFim) .And. ;
			(cProd < cProdIni .Or. cProd > cProdFim) .Or. ;
			(!Empty(cArmIni+cArmFim)) .And. ;
			(SB1->B1_LOCPAD < cArmIni .Or. SB1->B1_LOCPAD > cArmFim))
				(cAlias)->(dbSkip())
				Loop
			EndIf

			cClifor	:= ''
			cLoja	:= ''
			cTPCF	:= ''		
			cClifor		:= SubsTring((cAliBLH)->COD_PART,4,ntamCli)
			cLoja		:= SubsTring((cAliBLH)->COD_PART,4+ntamCli,nTamLoj)

			IF (cAliBLH)->IND_PROP <> '0'			
				If SubsTring((cAliBLH)->COD_PART,1,3) == 'SA1'
					cTPCF		:= 'C'
				Else
					cTPCF		:= 'F'
				Endif
			Endif		

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Efetuo o processamento do arquivo solicitado conforme tipo passado³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If 	lAglH010 .And.;
				((cAliBLH)->IND_PROP == "4" .Or. (cAliBLH)->IND_PROP == "5") .And.;
				aScan(aRetInv,{|x|x[1] == cProd}) > 0
					nPos := Ascan(aRetInv,{|x|x[1] == (cAliBLH)->COD_ITEM})
					aRetInv[nPos][3] += (cAliBLH)->QTD
					aRetInv[nPos][4] += (cAliBLH)->VL_UNIT
					aRetInv[nPos][5] += (cAliBLH)->VL_ITEM
			Else
					aAdd(aRetInv,{cProd,;	// 01 - Produto.
					(cAliBLH)->UNID,;		// 02 - Unidade.
					(cAliBLH)->QTD,; 		// 03 - Quantidade.
					(cAliBLH)->VL_UNIT,; 	// 04 - Valor Unidade.
					(cAliBLH)->VL_ITEM,;    // 05 - Valor Total.
					cClifor,;     			// 06 - Codigo do Cliente/Fornecedor.
					cLoja,;       			// 07 - Codigo da loja Cliente/Fornecedor.
					(cAliBLH)->IND_PROP,;   // 08 - Situacao do estoque.
					cTPCF,;       			// 09 - Cliente/Fornecedor.
					(cAliBLH)->FILIAL})		// 10 - Filial.
			EndIF
			(cAliBLH)->(dbSkip())
		EndDo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Fecho o alias criado para o arquivo de trabalho³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !empty(cAliBLH) .and. Select(cAliBLH) > 0
			(cAliBLH)->(dbCloseArea())
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return aRetInv

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RegistroH ³ Autor ³Erick G. Dias          ³ Data ³11.11.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³                       INVENTARIO                           ³±±
±±³          ³                                                            ³±±
±±³ GERACAO DO BLOCO H                                                    |±±
±±³ IRA GERAR OS REGISTROS H020, H030, H040, H050 E H060                  |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef com as informacoes obtidas pela funcao ³±±
±±³          ³ FsEstInv.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//RegHP7(cArquivo,cTipo,cFiltro,cProdIni,cProdFim,cArmIni,cArmFim)
Static Function RegistroH (cAlias, dDataAte, aWizard,aReg0200,aRegH020,aRegH040,aRegH050,aRegH060,aReg0205)
  
	Local nPos		:= 0
	Local nPosH040  := 0
	Local nPosH050  := 0
	Local nPosH060  := 0
	Local nIND_ITEM	:= 0
	Local nAcVlrEst	:= 0
	Local nAcVIcmRc	:= 0
	Local nAcVIpiRc	:= 0
	Local nAcVPisRc	:= 0
	Local nAcVCofRc	:= 0
	Local nAcVTriRc	:= 0
	Local aPartDoc	:= {}
	Local cCodItem	:= ""
	Local cCodPart	:= ""
	Local cCodInv	:= GetNewPar("MV_CODINV","")
	Local aRet		:={}
	Local cTpProc	:= substr(awizard[1][16],1,1)
	Local cESTED	:= substr(awizard[1][15],1,1)
	Local cSalneg	:= substr(awizard[1][17],1,1)
	Local nI		:= 0
	Local nTamProd	:= TamSx3("B1_COD")[1] + Len(xFilial("SB1"))
	Local nTamParc	:= 3+len(cFilAnt)+TamSx3("A1_COD")[1]+TamSx3("A1_LOJA")[1]
	Local cAliBLH	:= ''
		
	Default aReg0205	:= {}
		
	IncProc(STR0052)	//"Filtrando base inventário..."
	//vai retornar toda a tabela emitida pelo P7
	aret:= RegHP7(alltrim(aWizard[1][14]),,,aWizard[1,3],aWizard[1,4])

	For nI:=1 to Len(aRet)
		IF cfilant == aRet[ni][10]
			if (cSalNeg == '1' .or. (cSalNeg == '0' .and. aret[nI][3] > 0));
					.and. (aret[nI][8]=='0' .or. (cTpProc == '1' .and. aret[nI][8]=='2');
					.or. (cESTED $ '1' .and. aret[nI][8]$ '4#5' ) .or. (cESTED $ '3' .and. aret[nI][8]$ '4' );
					.or. (cESTED $ '4' .and. aret[nI][8]$ '5'))
				IncProc(STR0053+AllTrim(aRet[nI,1] ))	//"Processando Inventário, Produto: "

				DbSelectArea ("SB1")
				SB1->(DbSetOrder (1))
				If (SB1->(DbSeek (xFilial("SB1")+PadR(Alltrim(aRet[nI,1]),TamSX3("B1_COD")[1]))))
			//Cadastro do Cliente/Fornecedor
					If Empty (aRet[nI,6])
						aPartDoc	:=	InfPartDoc ("SM0", .T.)
					Else
						DbSelectArea ("SA1")
						SA1->(DbSetOrder (1))
						If SA1->(dbSeek (xFilial ("SA1")+PadR(Alltrim(aRet[nI,6]),TamSX3("A1_COD")[1])+PadR(Alltrim(aRet[nI,7]),TamSX3("A1_LOJA")[1])))
							aPartDoc	:=	InfPartDoc ("SA1")
						Else
							DbSelectArea ("SA2")
							SA2->(DbSetOrder (1))
							If SA2->(dbSeek (xFilial ("SA2")+PadR(Alltrim(aRet[nI,6]),TamSX3("A2_COD")[1])+PadR(Alltrim(aRet[nI,7]),TamSX3("A2_LOJA")[1])))
								aPartDoc	:=	InfPartDoc ("SA2")
							EndIf
						EndIf
					EndIf
					If len(aPartDoc) > 0
						cCodPart	:=	aPartDoc[1]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³REGISTRO 0150 - TABELA DE CADASTRO DE PARTICIPANTES³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Reg0150 (aPartDoc,aWizard)
					EndIf
			
					cIND_POSSE	:=	aRet[nI,8]
					//TIPO 1 = EM ESTOQUE ; TIPO 2 = SALDO EM PROCESSO ; TIPO 3 = SEM SALDO ; TIPO 4 = SALDO DE TERCEIROS ;	TIPO 5 - SALDO EM TERCEIROS
				
						 			
					If At(SB1->B1_TIPO+"=",cCodInv) > 0
						nIND_ITEM :=	Val(Substr(cCodInv,At(SB1->B1_TIPO+"=",cCodInv)+3,1))
					//ElseIf aRet[nI,8]=="2" //Saldo em processo					
					//	nIND_ITEM	:=	3
					ElseIf ("ME"$SB1->B1_TIPO)
						nIND_ITEM	:=	0
					ElseIf ("MP"$SB1->B1_TIPO)
						nIND_ITEM	:=	1
					ElseIf ("PI"$SB1->B1_TIPO)
						nIND_ITEM	:=	2
					ElseIf ("PA"$SB1->B1_TIPO)
						nIND_ITEM	:=	4
					ElseIf ("EM"$SB1->B1_TIPO)
						nIND_ITEM	:=	5
					Else
						nIND_ITEM	:=	9
					EndIf
					
					/*Indicador do tipo de item inventariado:
					0- Mercadoria
					1- Matéria-prima (MP)
					2- Produto intermediário (PI)
					3- Produto em fabricação (PF)
					4- Produto acabado (PA)
					5- Embalagem (ME)
					8- Bens em almoxarifado
					9- Outros*/
										
					cCodItem := ALLTRIM(aRet[nI,1]) + xFilial("SB1")
			
			//	
					If !IVT->(DbSeek (cIND_POSSE+PadR(cCodPart,nTamParc)+STR(nIND_ITEM,1)+PadR(Alltrim(cCodItem),nTamProd)))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³REGISTRO 0200 PARA PRODUTOS DO INVENTARIO³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//if len(aReg0200) == 0  
				// O registro deve ser gerado por ítem conforme erro descrito no Validador
						AdProd(SB1->B1_COD,@aReg0200,aWizard,@aReg0205)
				//Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³REGISTRO H030 - ITENS INVENTARIO³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
						RecLock("IVT", .T.)
						IVT->IVT_REG	:=	"H030"						//01 - REG
						IVT->IVT_INDP	:=	cIND_POSSE					//02 - IND_POSSE
						IVT->IVT_CODPAR	:=	cCodPart					//03 - COD_PART
						IVT->IVT_INDINV	:=	STR(nIND_ITEM,1)			//04 - IND_ITEM
						IVT->IVT_NCM	:=	SB1->B1_POSIPI					//05 - COD_NCM
						IVT->IVT_CODITE	:=	AllTrim(cCodItem)			//06 - COD_ITEM
						IVT->IVT_UM	   	:=	SB1->B1_UM						//07 - UNID
						IVT->IVT_VICMRE := 0                  			//11 - VL_ICMS_REC_I
						IVT->IVT_VIPIRE := 0       	      	    		//12 - VL_IPI_REC_I
						IVT->IVT_VPISRE := 0                			//13 - VL_PIS_REC_I
						IVT->IVT_VCOFRE := 0                 			//14 - VL_COFINS_REC_I
						IVT->IVT_VTRIBN := 0                			//15 - VL_TRIB_NC_I
						IVT->IVT_OBS	:=	""							//16 - REF_INF_OBS
					Else
						RecLock("IVT", .F.)
					EndIf
					IVT->IVT_VLUNIT	+=	aRet[nI,4]				//08 - VL_UNIT
					IVT->IVT_QTD		+=	aRet[nI,3]				//09 - QTD
					IVT->IVT_VLITEM	+=	aRet[nI,5]				//10 - VL_ITEM
					MsUnLock()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³REGISTRO H040 - SUBTOTAIS POR TIPO DE ITEM ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nPosH040:=aScan (aRegH040, {|aX| aX[2]==AllTrim(cIND_POSSE)})
					If nPosH040 == 0
						aAdd(aRegH040, {})
						nPos	:=	Len (aRegH040)
						aAdd (aRegH040[nPos], "H040")			   	//01 - LIN
						aAdd (aRegH040[nPos], AllTrim(cIND_POSSE)) 	//02 - IND_POSSE
						aAdd (aRegH040[nPos], round(aRet[nI,5],2)) 			//03 - VL_SUB_POSSE
					Else
						aRegH040[nPosH040][3] += round(aRet[nI,5],2) 			//03 - VL_SUB_POSSE
					EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³REGISTRO H050 - SUBTOTAIS POR TIPO DE ITEM³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nPosH050:=aScan (aRegH050, {|aX| aX[2]==AllTrim(STR(nIND_ITEM,1))})
					If nPosH050 == 0
						aAdd(aRegH050, {})
						nPos	:=	Len (aRegH050)
						aAdd (aRegH050[nPos], "H050")			   		    //01 - LIN
						aAdd (aRegH050[nPos], AllTrim(STR(nIND_ITEM,1))) 	//02 - IND_ITEM
						aAdd (aRegH050[nPos], round(aRet[nI,5],2)) 				    //03 - VL_SUB_ITEM
					Else
						aRegH050[nPosH050][3] += round(aRet[nI,5],2) 				//03 - VL_SUB_ITEM
					EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³REGISTRO H060 - SUBTOTAIS POR NCM³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nPosH060:=aScan (aRegH060, {|aX| aX[2]==AllTrim(SB1->B1_POSIPI)})
					If nPosH060 == 0
						aAdd(aRegH060, {})
						nPos	:=	Len (aRegH060)
						aAdd (aRegH060[nPos], "H060")			   		//01 - LIN
						aAdd (aRegH060[nPos], AllTrim(SB1->B1_POSIPI)) 		//02 - COD_NCM
						aAdd (aRegH060[nPos], round(aRet[nI,5],2)) 				//03 - VL_SUB_NCM
					Else
						aRegH060[nPosH060][3] += round(aRet[nI,5],2) 			//03 - VL_SUB_NCM
					EndIf
				EndIf
			EndIf
		EndIf
	End
	
	IVT->(dbgotop())
	Do While !IVT->(Eof())
		aRegH030	:=	{IVT->IVT_REG, IVT->IVT_INDP, IVT->IVT_CODPAR, IVT->IVT_INDINV, IVT->IVT_NCM, ALLTRIM(IVT->IVT_CODITE),;
			IVT->IVT_UM,alltrim(TRANSFORM( IVT->IVT_VLUNIT, "@E 9999999999.999999")),alltrim(TRANSFORM( IVT->IVT_QTD, "@E 9999999999.999999")),alltrim(TRANSFORM(Round(IVT->IVT_VLITEM,2), "@E 9999999999.99")),IVT->IVT_VICMRE, IVT->IVT_VIPIRE,;
			IVT->IVT_VPISRE, IVT->IVT_VCOFRE, IVT->IVT_VTRIBN, IVT->IVT_OBS}
		nAcVlrEst	+=	round(IVT->IVT_VLITEM,2)
		nAcVIcmRc	+=	IVT->IVT_VICMRE
		nAcVIpiRc	+=	IVT->IVT_VIPIRE
		nAcVPisRc	+=	IVT->IVT_VPISRE
		nAcVCofRc	+=	IVT->IVT_VCOFRE
		nAcVTriRc	+=	IVT->IVT_VTRIBN
		GrvRegSef (cAlias,,{aRegH030})
		IVT->(DbSkip())
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³REGISTRO H020 - TOTAIS DO INVENTARIOS³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPos:=0
	If len(aRegH020) == 0
		aAdd(aRegH020, {})
		nPos	:=	Len (aRegH020)
		aAdd (aRegH020[nPos], "H020")	   			        //01 - REG	
		aAdd (aRegH020[nPos], Substr (aWizard[1][9],1,1)) //02 - IND_DT
		aAdd (aRegH020[nPos], cvaltochar(strzero( day(dDataAte),2))+ cvaltochar(strzero(Month(dDataAte),2)) + cvaltochar(Year(dDataAte))) //03 - DT_INV  //SuperGetMv ("MV_ULMES"))
		aAdd (aRegH020[nPos], nAcVlrEst)   			       //04 - VL_ESTQ
		aAdd (aRegH020[nPos], nAcVIcmRc)   		           //05 - VL_ICMS_REC
		aAdd (aRegH020[nPos], nAcVIpiRc)   			       //06 - VL_IPI_REC
		aAdd (aRegH020[nPos], nAcVPisRc)   			       //07 - VL_PIS_REC
		aAdd (aRegH020[nPos], nAcVCofRc)   			       //08 - VL_COFINS_REC
		aAdd (aRegH020[nPos], nAcVTriRc)   			       //09 - VL_TRIB_NC
		aAdd (aRegH020[nPos], nAcVlrEst - nAcVTriRc)       //10 - VL_ESTQ_NC
		aAdd (aRegH020[nPos], "")   		   		       //11 - NUM_LCTO
		aAdd (aRegH020[nPos], "")		   			       //12 - COD_INF_OBS
	Else
		npos:= aScan(aRegH020,{|x| x[2] == Substr (aWizard[1][9],1,1) .and. x[3]== (cvaltochar(strzero( day(dDataAte),2))+ cvaltochar(strzero(Month(dDataAte),2)) + cvaltochar(Year(dDataAte))) })
		aRegH020[nPos][04]+=nAcVlrEst
		aRegH020[nPos][05]+=nAcVIcmRc
		aRegH020[nPos][06]+=nAcVIpiRc
		aRegH020[nPos][07]+=nAcVPisRc
		aRegH020[nPos][08]+=nAcVCofRc
		aRegH020[nPos][09]+=nAcVTriRc
		aRegH020[nPos][10]+=(nAcVlrEst - nAcVTriRc)
	EndIf
    // limpando temporario do bloco H.  
	IVT->(DbGoTop ())
	Do While !IVT->(Eof())
		RecLock("IVT",.F.)
		IVT->(dbDelete())
		MsUnLock()
		IVT->(DbSkip())
	EndDo
Return  

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegG020   ³ Autor ³Sueli C. Santos                   ³ Data ³10.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³dDataDe -> Periodo inicial de apuracao                    			 ³±±
±±³          ³dDataAte -> Periodo final de apuracao                                  ³±±
±±³          ³nRelac -> Flag de relacionamento com os sub-registro                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegG020 (aRegG020,cAlias, dDataDe, dDataAte, nRelac, aCmpAntSFT)
Local	lRet := .T.
Local	nPos		:=	0
Local	aSf6	   :=	{"SF6", ""}
Local nPosG020  :=  0
Local nTpImp      :=  0
	
FsQuery (aSf6, 1, "F6_FILIAL='"+xFilial ("SF6")+"' AND F6_ANOREF="+StrZero (Year (dDataDe), 4)+" AND F6_MESREF="+StrZero (Month (dDataAte), 2)+" AND F6_TIPOIMP IN ('1', '2') ",;
					 "F6_FILIAL='"+xFilial ("SF6")+"' .AND. StrZero (F6_ANOREF, 4)=='"+StrZero (Year (dDataDe), 4)+"' .AND. StrZero (F6_MESREF, 2)=='"+StrZero (Month (dDataAte), 2)+"'", "F6_TIPOIMP+F6_CODREC")
SF6->(DbGotop ())	
	
Do While !SF6->(Eof ())
	  
	If SF6->F6_TIPOIMP $ "1,2,7"   //1 - ICMS; 2 - ISS; 7 - SIMPLES NACIONAL            	
	
		nTpImp := Iif(SF6->F6_TIPOIMP == "1","1",Iif(SF6->F6_TIPOIMP =="2","0","2"))
		nPosG020 := aScan (aRegG020, {|aX| aX[2]== nTpImp })
			
		If nPosG020 == 0
			aAdd(aRegG020, {})
			nPos	:=	Len (aRegG020)
			aAdd (aRegG020[nPos], "G020")	//01 - REG
			aAdd (aRegG020[nPos], nTpImp)	//02 - IND_GEF
			aAdd (aRegG020[nPos], dDataDe)	//03 - DT_INI
			aAdd (aRegG020[nPos], dDataAte)	//03 - DT_FIM
		EndIf
	              
	EndIf
		
	SF6->(DbSkip ())
	
EndDo	

FsQuery (aSf6, 2)
	
Return (lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  | RegG025  ³ Autor ³Sueli C. Santos                   ³ Data ³10.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegG025 (cSituaDoc, cEspecie, cEntSai, cAliasSFT, lIss, lIssRet, aRegG025)

Local	lRet		:=	.T.
Local	nPos        :=	0
Local nQtd        :=  0

If ((nPos := aScan (aRegG025, {|aX|aX[2]==STR(Val (cEntSai)-1,1) .And. aX[4]==cEspecie .And. aX[5]==(cAliasSFT)->FT_SERIE}))==0)
	aAdd (aRegG025, {})
	nPos	:=	Len (aRegG025)		
	nQtd    := 0 
	aAdd (aRegG025[nPos], "G025")	 	   		   		//01 - LIN
	aAdd (aRegG025[nPos], STR(Val (cEntSai)-1,1)) 		//02 - IND_OPER
                                    
    //03 - IND_EMIT
	If (Empty ((cAliasSFT)->FT_FORMUL)) .And. cEntSai=="1"
		aAdd (aRegG025[nPos], "1")				           
	ElseIf (Empty ((cAliasSFT)->FT_FORMUL)) .And. cEntSai=="2"
		aAdd (aRegG025[nPos], "0")	   
	Else
		If ("S"$(cAliasSFT)->FT_FORMUL)
			aAdd (aRegG025[nPos], "0") 					
		Else
			aAdd (aRegG025[nPos], "1")					
		EndIf	    
	EndIf	
	     		
	aAdd (aRegG025[nPos], cEspecie)		  				//04 - COD_MOD
	aAdd (aRegG025[nPos], (cAliasSFT)->FT_SERIE)		//05 - SER
	aAdd (aRegG025[nPos], "")							//06 - SUB
	aAdd (aRegG025[nPos], (cAliasSFT)->FT_NFISCAL)		//07 - NUM_DOC_INI
	aAdd (aRegG025[nPos], (cAliasSFT)->FT_NFISCAL)		//08 - NUM_DOC_FIN
	aAdd (aRegG025[nPos], "0")							//09 - QTD_DOC
	aAdd (aRegG025[nPos], "0")							//10 - QTD_CANC
	aAdd (aRegG025[nPos], 0)							//11 - VL_CONT
	aAdd (aRegG025[nPos], 0)							//12 - VL_ISS			
	aAdd (aRegG025[nPos], 0)							//13 - VL_RT_ISS		
	aAdd (aRegG025[nPos], 0)							//14 - VL_ICMS		
	aAdd (aRegG025[nPos], 0)							//15 - VL_ICMS_ST				
	aAdd (aRegG025[nPos], 0)							//16 - VL_AT
	aAdd (aRegG025[nPos], 0)							//17 - VL_IPI
else
	nQtd := val(aRegG025[nPos][9])
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Range de Numero de Documentos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ((cAliasSFT)->FT_NFISCAL<aRegG025[nPos][7])
	aRegG025[nPos][7]	:=	(cAliasSFT)->FT_NFISCAL		//07 - NUM_DOC_INI
EndIf
//
If ((cAliasSFT)->FT_NFISCAL>aRegG025[nPos][8])
	aRegG025[nPos][8]	:=	(cAliasSFT)->FT_NFISCAL		//08 - NUM_DOC_FIN
EndIf
// 

If ("90#81#" $ cSituaDoc)	//02=Situacao de cancelada
	aRegG025[nPos][10]	:=	Alltrim (STR (Val(aRegG025[nPos][10]) + 1))		//10 - QTD_CANC
Else    
	nQtd	:=	nQtd + 1 	                        	//09 - QTD_DOC
	aRegG025[nPos][11]	+=	(cAliasSFT)->FT_VALCONT		//11 - VL_CONT
	If lIss
		If lIssRet
			aRegG025[nPos][13]	+=	(cAliasSFT)->FT_ICMSRET		//13 - VL_RT_ISS
		Else
			aRegG025[nPos][12]	+=	(cAliasSFT)->FT_VALICM		//12 - VL_ISS  
		EndIf
	Else
		aRegG025[nPos][14]	+=	(cAliasSFT)->FT_VALICM	     	//14 - VL_ICMS
		aRegG025[nPos][15]	+=	(cAliasSFT)->FT_ICMSRET		    //15 - VL_ICMS_ST
	EndIf

	aRegG025[nPos][17]	+=	(cAliasSFT)->FT_VALIPI		        //17 - VL_IPI
EndIf

aRegG025[nPos][9] := alltrim(str(nQtd))

Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RegG050   ³ Autor ³Sueli C. Santos        ³ Data ³07.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³  G050 - MAPA RESUMO DE OPERACOES                           ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao do Registro G050                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef com as informacoe contidas no array    ³±±
±±³          ³ aPartDoc/aCmpAntSFT para os modelos 07, 08.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³G050 - 3(varios por arquivo)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³nRelac -> Flag de relacionamento.                           ³±±
±±³          ³aRegE120 -> Array passado por referencia para receber infor-³±±
±±³          ³ macoes a serem gravados posteriormente.                    ³±±
±±³          |cEntSai -> Flag Entrada(1)/Saida(2).                        ³±±
±±³          ³aPartDoc -> Array com informacoes sobre o participante do   ³±±
±±³          ³ documento fiscal, este array eh montado pela funcao princi-³±±
±±³          ³ pal.                                                       ³±±
±±³          ³cEspecie -> Modelo do documento fiscal                      ³±±
±±³          ³cSituaDoc -> Situacao do documento fiscal conforme funcao   ³±±
±±³          ³ RetSitDoc                                                  ³±±
±±³          |aCmpAntSFT -> Informacoes sobre o cabecalho dos documentos. ³±±
±±³          |cAliasSFT -> Alias da tabela SFT em processamento.          ³±±
±±³          ³cChave -> Codigo de referencia entre o documento fiscal e   ³±±
±±³          ³ este registro.                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegG050 (cAliasSFT, cEntSai, aRegG050, cSituaDoc, aCmpAntSFT, lIss, aTotalISS,cCOP)

Local	lRet	:=	.T.
Local	nPos	:=	0
	
nPos := aScan (aRegG050, {|aX| aX[04]==(cAliasSFT)->FT_ENTRADA })

If nPos == 0
	aAdd (aRegG050, {})
	nPos	:=	Len (aRegG050)
	aAdd (aRegG050[nPos], "G050")							//01 - REG	
	aAdd (aRegG050[nPos], "2")								//02 - IND_MRO	
	aAdd (aRegG050[nPos], STR(Val (cEntSai)-1,1))	  		//03 - IND_OPER
	aAdd (aRegG050[nPos], aCmpAntSFT[5])  					//04 - DT_DOC     
	aAdd (aRegG050[nPos], "")                            //05 - COP   
	aAdd (aRegG050[nPos], "1")			  					//06 - QTD_LCTO    
	aAdd (aRegG050[nPos], 0)				   				//07 - VL_CONT 
	aAdd (aRegG050[nPos], 0)								//08 - VL_CONT_PRP
	aAdd (aRegG050[nPos], 0)								//09 - VL_CONT_OUT
	aAdd (aRegG050[nPos], 0)								//10 - VL_ISS
	aAdd (aRegG050[nPos], 0)						   		//11 - VL_RT_ISS
	aAdd (aRegG050[nPos], 0)				   	   			//12 - VL_ICMS
	aAdd (aRegG050[nPos], 0)				   				//13 - VL_ICMS_ST		
	aAdd (aRegG050[nPos], 0)				   				//14 - VL_ST_ENT		
	aAdd (aRegG050[nPos], 0)								//15 - VL_ST_FNT
	aAdd (aRegG050[nPos], 0)								//16 - VL_ST_UF		
	aAdd (aRegG050[nPos], 0)				   				//17 - VL_ST_OE
	aAdd (aRegG050[nPos], 0)				   				//18 - VL_AT
	aAdd (aRegG050[nPos], 0)		   						//19 - VL_IPI 		
EndIf 

If !("90#81#"$cSituaDoc)  
	If !lIss 
  		aRegG050[nPos][07]	+=	(cAliasSFT)->FT_VALCONT		//07 - VL_CONT
		aRegG050[nPos][12]	+=	(cAliasSFT)->FT_VALICM		//12 - VL_ICMS 
		aRegG050[nPos][13]	+=	(cAliasSFT)->FT_ICMSRET		//13 - VL_ICMS_ST  
		aRegG050[nPos][19]	+=	(cAliasSFT)->FT_VALIPI		//19 - VL_IPI

		If !Empty((cAliasSFT)->FT_FORMUL) .And. cEntSai=="1"	//formulario Proprio igual a Sim na entrada
   			aRegG050[nPos][15]	+=	(cAliasSFT)->FT_ICMSRET		//15 - VL_ST_FNT 
   			
   		ElseIf	Empty((cAliasSFT)->FT_FORMUL) .And. cEntSai=="1" //formulario Proprio igual a Nao na entrada  
   			aRegG050[nPos][14]	+=	(cAliasSFT)->FT_ICMSRET		//14 - VL_ST_ENT
   			
   		Elseif	SUBSTR((cAliasSFT)->FT_CFOP,1,1)=="5" .And. cEntSai=="2"
   			aRegG050[nPos][16]	+=	(cAliasSFT)->FT_ICMSRET		//16 - VL_ST_UF	
   			
		ElseIf SUBSTR((cAliasSFT)->FT_CFOP,1,1)>"5" .And. cEntSai=="2"
			aRegG050[nPos][17]	+=	(cAliasSFT)->FT_ICMSRET		////17 - VL_ST_OE
		EndIF			
	Else 			
		If	SUBSTR((cAliasSFT)->FT_CFOP,1,1)$"15" 
			aRegG050[nPos][08]	+=	(cAliasSFT)->FT_VALCONT		//08 - VL_CONT_PRP 
		Else
			aRegG050[nPos][09]	+=	(cAliasSFT)->FT_VALCONT		//09 - VL_CONT_OUT 
		EndIf  
		aRegG050[nPos][10]	+=	(cAliasSFT)->FT_VALICM		//11 - VL_ISS 
		aRegG050[nPos][11]	+=	(cAliasSFT)->FT_ICMSRET		//12 - VL_ISS_ST
	EndIf 		    
EndIf

Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  | RegG400 	³ Autor ³Sueli C. Santos        ³ Data ³08.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³    G400: ICMS - CONSOLIDAÇÃO POR CFOP                      ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao do Registros E310			                      |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef com as informacoe contidas no array    ³±±
±±³          ³ aCmpAntSFT e na tabela SFT.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³G400 - 3(varios por periodo)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAliasSFT -> Alias da tabela SFT aberta no momento.         ³±±
±±³          ³ funcao a ser retornado para gravacao pela funcao principal.³±±
±±³          |cEntSai -> Flag Entrada(1)/Saida(2).                        ³±±
±±³          |aRegE310 -> Array contendo as informacoes processadas pela  ³±±
±±³          ³ funcao a ser retornado para gravacao pela funcao principal.³±±
±±³          ³cSituaDoc -> Situacao do documento fiscal.                  ³±±
±±³          ³lIss -> Indicador de nota fiscal com incidencia do ISS      ³±±
±±³          ³cEspecie -> Especie do documento fiscal                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegG400 (cAliasSFT, aRegG400, cSituaDoc, lIss,cEspecie)
	Local	nPos	:=	0
	Local	lRet	:=	.T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³REGISTRO E310 - CONSOLIDACAO DOS VALORES DE ICMS POR CFOP ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ((nPos := aScan (aRegG400, {|aX| aX[4]==(cAliasSFT)->FT_CFOP}))==0)
		aAdd(aRegG400, {})
		nPos	:=	Len (aRegG400)
		aAdd (aRegG400[nPos], "G400")	 	   					//01 - REG
		aAdd (aRegG400[nPos], 0)								//02 - VL_CONT
		aAdd (aRegG400[nPos], 0)								//03 - VL_OP_ISS
		aAdd (aRegG400[nPos], (cAliasSFT)->FT_CFOP)		    //04 - CFOP
		aAdd (aRegG400[nPos], 0)								//05 - VL_BC_ICMS
		aAdd (aRegG400[nPos], 0)								//06 - VL_ICMS     
		aAdd (aRegG400[nPos], 0)								//07 - VL_BC_ST		
		aAdd (aRegG400[nPos], 0)								//08 - VL_ICMS_ST
		aAdd (aRegG400[nPos], 0)								//09 - VL_ISNT_ICMS
		aAdd (aRegG400[nPos], 0)								//10 - VL_OUT_ICMS
	EndIf
	If !(cSituaDoc$"90#81#")
		If lIss
			aRegG400[nPos][3]	+=	(cAliasSFT)->FT_VALCONT		//03 - VL_OP_ISS
		Else
			aRegG400[nPos][2]	+=	(cAliasSFT)->FT_VALCONT		//02 - VL_CONT
			aRegG400[nPos][5]	+=	(cAliasSFT)->FT_BASEICM		//05 - VL_BC_ICMS
			aRegG400[nPos][6]	+=	(cAliasSFT)->FT_VALICM		//06 - VL_ICMS						
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³* Para os modelos abaixo que tiverem DIFERENCIAL ALIQUOTA,   |
			//|  nao devo enviar neste campo, basta considerar nos ajustes. ³
			//³* Para os modelos abaixo que tiverem SUBSTITUICAO TRIBUTARIA,|
			//|  NAO devo enviar neste campo, pois o mesmo estah destinado  ³
			//|  aos registros C's(C020 - Campo 23 - modelo 01 e 04).       |
			//|                                                             |
			//³06 - NOTA FISCAL/CONTA DE ENERGIA ELETRICA                   ³
			//³21 - NOTA FISCAL DE SERVICO DE COMUNICACAO                   ³
			//³22 - NOTA FISCAL DE SERVICO DE TELECOMUNICACAO               ³
			//³07 - NOTA FISCAL SERVICO DE TRANSPORTE - SAIDA/ENTRADA       ³
			//³08 - CONHECIMENTO DE TRANSPORTE RODOVIARIO - SAIDA/ENTRADA   ³
			//³09 - CONHECIMENTO DE TRANSPORTE AQUAVIARIO - ENTRADA         ³
			//³10 - CONHECIMENTO DE TRANSPORTE AEREO - ENTRADA              ³
			//³11 - CONHECIMENTO DE TRANSPORTE FERROVIARIO - ENTRADA        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !(cEspecie$"06#07#08#09#10#11#21#22")                          
				aRegG400[nPos][7]	+=	(cAliasSFT)->FT_BASERET	//07 - VL_BC_ST			
				aRegG400[nPos][8]	+=	(cAliasSFT)->FT_ICMSRET	//08 - VL_ICMS_ST
			EndIf
			
			aRegG400[nPos][9]	+=	(cAliasSFT)->FT_ISENICM		//09 - VL_ISNT_ICMS
			//Quando configuro a TES para escriturar o Livro de ICMS/ST como ISENTO, na tabela SF3 o valor do campo 
			//F3_ICMSRET eh transportado para o campo F3_ISENICM, ficando com os mesmos valores. Na tabela SFT, que
			//possui o campo proprio FT_ISENRET, recebe este valor deixando o campo FT_ISENICM e FT_ICMSRET zerado.
			aRegG400[nPos][9]	+=	(cAliasSFT)->FT_ISENRET		//09 - VL_ISNT_ICMS
			
			If cEspecie<>"2D"
				aRegG400[nPos][10]	+=	(cAliasSFT)->FT_OUTRICM		//10 - VL_OUT_ICMS
			EndIf
				
			//Quando configuro a TES para escriturar o Livro de ICMS/ST como OUTROS, na tabela SF3 o valor do campo 
			//  F3_ICMSRET eh transportado para o campo F3_OUTRICM, ficando com os mesmos valores. Na tabela SFT, que
			//  possui o campo proprio FT_OUTRRET, recebe este valor deixando o campo FT_OUTRICM e FT_ICMSRET zerado.
			aRegG400[nPos][10]	+=	(cAliasSFT)->FT_OUTRRET		//10 - VL_OUT_ICMS     
			
		EndIf
	EndIf
Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  | RegG410 	³ Autor ³Erick G. Dias          ³ Data ³29.10.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³    RegG410: ICMS - TOTALIZAÇÃO DAS OPERAÇÕES               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao do Registros RegG410   		                      |±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegG410 (aRegG400, aRegG410)
	
	Local nPos    :=0
	Local nPos400 :=0 
	Local nCont   :=0
	
	If len(aRegG400) > 0 
		For nCont :=1 To Len (aRegG400)
			nPos400 := aScan (aRegG410, {|aX| aX[2]== Substr(aRegG400[nCont][4],1,1) })
			If nPos400 = 0
				aAdd(aRegG410, {})
				nPos	:=	Len (aRegG410)
				aAdd (aRegG410[nPos], "G410")                          // 01 - LIN		
				aAdd (aRegG410[nPos], Substr(aRegG400[nCont][4],1,1)) // 02 - IND_TOT		
				aAdd (aRegG410[nPos], aRegG400[nCont][2]) // 03 - VL_CONT		
				aAdd (aRegG410[nPos], aRegG400[nCont][3]) // 04 - VL_OP_ISS		
				aAdd (aRegG410[nPos], aRegG400[nCont][5]) // 05 - VL_BC_ICMS					
				aAdd (aRegG410[nPos], aRegG400[nCont][6]) // 06 - VL_ICMS		
				aAdd (aRegG410[nPos], aRegG400[nCont][8]) // 07 - VL_ICMS_ST		
				aAdd (aRegG410[nPos], 0) // 08 - VL_ST_ENT		
				aAdd (aRegG410[nPos], 0) // 09 - VL_ST_FNT		
				aAdd (aRegG410[nPos], 0) // 10 - VL_ST_UF		
				aAdd (aRegG410[nPos], 0) // 11 - VL_ST_OE		
				aAdd (aRegG410[nPos], 0) // 12 - VL_AT		
				aAdd (aRegG410[nPos], aRegG400[nCont][9]) // 13 - VL_ISNT_ICMS		
				aAdd (aRegG410[nPos], aRegG400[nCont][10]) // 14 - VL_OUT_ICMS					
			Else				
				aRegG410[nPos400][3] += aRegG400[nCont][2] // 03 - VL_CONT		
				aRegG410[nPos400][4] += aRegG400[nCont][3] // 04 - VL_OP_ISS		
				aRegG410[nPos400][5] += aRegG400[nCont][5] // 05 - VL_BC_ICMS					
				aRegG410[nPos400][6] += aRegG400[nCont][6] // 06 - VL_ICMS		
				aRegG410[nPos400][7] += aRegG400[nCont][8] // 07 - VL_ICMS_ST						
				aRegG410[nPos400][13] += aRegG400[nCont][9] // 13 - VL_ISNT_ICMS		
				aRegG410[nPos400][14] += aRegG400[nCont][10] // 14 - VL_OUT_ICMS					
			EndIf
			
		Next (nCont)
	
	EndIf	
Return	

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RegG440   ³ Autor ³Erick G. Dias          ³ Data ³26.10.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³G440 -                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegG440(aRegG440,cAlias,dDtIni,dDtFim,nRelac)
	Local nPos := 0
	Local nPosG440 :=0
	Local cAliasSF6  :="SF6" 
	Local cDtVenc := ""   
	Local lQuery := .F.
	
	dbSelectArea("SF6")                               					
	dbSetOrder(2)
	#IFDEF TOP
	    If TcSrvType()<>"AS/400" 
	    	lQuery := .T.		    
			cAliasSF6 :=GetNextAlias() 
			cQuery := "SELECT * "
			cQuery += "FROM "+RetSqlName("SF6")+" "
			cQuery += "WHERE F6_FILIAL='"+xFilial("SF6")+"' AND "
     		cQuery += "F6_MESREF>="+substr(dtos(dDtIni),5,2)+" AND "
	 		cQuery += "F6_MESREF<="+substr(dtos(dDtFim),5,2)+" AND "		 		
	 		cQuery += "F6_ANOREF>="+substr(dtos(dDtIni),1,4)+" AND "
    		cQuery += "F6_ANOREF<="+substr(dtos(dDtFim),1,4)+" AND "		 				 													
			cQuery += "D_E_L_E_T_ = ' ' "
			cQuery += "ORDER BY "+SqlOrder(SF6->(IndexKey()))
		
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF6,.T.,.T.)		
		
			dbSelectArea(cAliasSF6)
		Else
	#ENDIf
	    	(cAliasSF6)->( MsSeek(xFilial("SF6")))
	#IFDEF TOP
		EndIf
	#ENDIF
	While (cAliasSF6)->(!Eof()) .And. xFilial("SF6")== (cAliasSF6)->F6_FILIAL
		nPosG440:=aScan (aRegG440, {|aX| aX[5]==PadL(Alltrim((cAliasSF6)->F6_CODREC),4)})
		If nPosG440 == 0		
			aAdd(aRegG440, {})
			cDtVenc := IIf( lQuery , (cAliasSF6)->F6_DTVENC , DtoS((cAliasSF6)->F6_DTVENC) )
			
			nPos	:=	Len (aRegG440)	
			aAdd (aRegG440[nPos], "G440") //1-LIN
			aAdd (aRegG440[nPos], "PE")  //2-UF_OR
			aAdd (aRegG440[nPos], "800")  //3-COD_OR
			aAdd (aRegG440[nPos], strzero((cAliasSF6)->F6_MESREF,2)  +  str((cAliasSF6)->F6_ANOREF,4)) //4-PER_REF
			aAdd (aRegG440[nPos], PadL(Alltrim((cAliasSF6)->F6_CODREC),4)) //5-COD_REC
			aAdd (aRegG440[nPos], (cAliasSF6)->F6_VALOR)                   //6-VL_ICMS_REC
			aAdd (aRegG440[nPos],  IIf(Empty(cDtVenc),Replicate("0",8),substr(cDtVenc,7,2) + substr(cDtVenc,5,2) + substr(cDtVenc,1,4))) //7-DT_VCTO		
		else
			aRegG440[nPosG440][6]+=(cAliasSF6)->F6_VALOR
		EndIf
		dbskip()
	EndDo
	If len(aRegG440) > 0 
		GrvRegSef (cAlias, nRelac, aRegG440 ) 
	EndIf
	
	#IFDEF TOP
		If (TcSrvType ()<>"AS/400")
			DbSelectArea (cAliasSF6)
			(cAliasSF6)->(DbCloseArea ())
		Else
	#ENDIF
		RetIndex("SF6")			
	#IFDEF TOP
		EndIf
	#ENDIF
Return
		
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |G420G430  ³ Autor ³Sueli C. Santos        ³ Data ³09.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³      G420: ICMS - SALDOS APURADOS                          ³±±
±±³          ³     G430: ICMS - TOTALIZAÇÃO DOS AJUSTES DA APURAÇÃO       ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro E360                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef com as informacoe contidas na apuracao ³±±
±±³          ³ de ICMS.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³G420 - 3(1/Periodo)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlias -> Alias do TRB para gravacao.                       ³±±
±±³          ³dDataAte -> Data final do periodo de apuracao.              ³±±
±±³          ³cNrLivro -> Numero do livro selecionado no wizard.          ³±±
±±³          ³nAcImport -> Valor de ICMS da Importacao.                   ³±±
±±³          ³nAcRetInter -> Valor Substituicao Tributaria nas operacoes  ³±±
±±³          ³ interestaduais.                                            ³±±
±±³          ³nDbCompIcm -> Total das NFs de complemento de ICMS - saidas ³±±
±±³          ³nCrCompIcm ->Total das NFs de complemento de ICMS - entradas³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function G420G430 (cAlias, dDataAte, cNrLivro, nAcImport, nAcRetInter, nDbCompIcm, nCrCompIcm, aLog,nAcRetEsta,nAcCredTerc,nAcCredProp)
	Local	lRet		:=	.T.
	Local	nPos		:=	0
	Local	aReg		:=	{}
	Local	nX			:=	0
	Local	nApuracao	:=	GetSx1 (PadR("MTA951",10), "04", .T.)	//1-Decendial, 2-Quinzenal, 3-Mensal, 4-Semestral ou 5-Anual
	Local	nPeriodo	:=	1								//GetSx1 ("MTA951", "05", .T.)	//1-1., 2-2., 3-3.	
	Local	aApICM		:=	{}
	Local	aApST 		:=	{}
	Local	aApSIM 		:=	{}
	Local	nVL_01		:=	0
	Local	nVL_02		:=	0
	Local	nVL_03		:=	0
	Local	nVL_04		:=	0
	Local	nVL_05		:=	0
	Local	nVL_06		:=	0
	Local	nVL_07		:=	0
	Local	nVL_08		:=	0
	Local	nVL_09		:=	0
	Local	nVL_10		:=	0
	Local	nVL_11		:=	0
	Local	nVL_12		:=	0
	Local	nVL_13		:=	0
	Local	nVL_14		:=	0
	Local	nVL_15		:=	0
	Local	nVL_16		:=	0
	Local	nVL_17		:=	0
	Local	nVL_18		:=	0
	Local	nVL_19		:=	0
	Local	nVL_20		:=	0
	Local	nVL_21		:=	0
	Local	nVL_22		:=	0
	Local	nVL_99		:=	0
	Local	aRegG430	:=	{}
	Local	cProc		:=	""
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Fixo que o periodo de geracao podera ser somente Mensal ou Anual.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nApuracao==1) .Or. (nApuracao==2)
		nApuracao	:=	3
	ElseIf (nApuracao==4)
		nApuracao	:=	5
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Leio o arquivo de apuracao ICMS³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aApICM	:=	FisApur ("IC", Year (dDataAte), Month (dDataAte), nApuracao, nPeriodo, cNrLivro, .F., {}, 1, .F., "")
	
	nVL_01	:=	Iif (aScan (aApICM, {|a| a[1]=="005"})<>0, aApICM[aScan (aApICM, {|a| a[1]=="005"})][3], 0)    
	nVL_02	:=  nAcCredTerc	
	nVL_03	:=	nAcCredProp
    nVL_04  :=  0	
	nVL_05	:=	Iif (aScan (aApICM, {|a| a[4]=="006.00"})<>0, aApICM[aScan (aApICM, {|a| a[4]=="006.00"})][3], 0)
	nVL_06	:=	Iif (aScan (aApICM, {|a| a[4]=="007.00"})<>0, aApICM[aScan (aApICM, {|a| a[4]=="007.00"})][3], 0)		
	nVL_07	:=	Iif (aScan (aApICM, {|a| a[1]=="009"})<>0, aApICM[aScan (aApICM, {|a| a[1]=="009"})][3], 0)
	nVL_08	:=	Iif (aScan (aApICM, {|a| a[1]=="010"})<>0, aApICM[aScan (aApICM, {|a| a[1]=="010"})][3], 0)
	nVL_09	:=	Iif (aScan (aApICM, {|a| a[1]=="001"})<>0, aApICM[aScan (aApICM, {|a| a[1]=="001"})][3], 0)
	nVL_10	:=	Iif (aScan (aApICM, {|a| a[4]=="002.00"})<>0, aApICM[aScan (aApICM, {|a| a[4]=="002.00"})][3], 0)
	nVL_11	:=	Iif (aScan (aApICM, {|a| a	[4]=="003.00"})<>0, aApICM[aScan (aApICM, {|a| a[4]=="003.00"})][3], 0)
	nVL_12	:=	Iif (aScan (aApICM, {|a| a[1]=="004"})<>0, aApICM[aScan (aApICM, {|a| a[1]=="004"})][3], 0)
	nVL_13	:=	Iif (aScan (aApICM, {|a| a[1]=="014"})<>0, aApICM[aScan (aApICM, {|a| a[1]=="014"})][3], 0)
	nVL_14	:=	Iif (aScan (aApICM, {|a| a[1]=="011"})<>0, aApICM[aScan (aApICM, {|a| a[1]=="011"})][3], 0)
	nVL_15	:=	Iif (aScan (aApICM, {|a| a[4]=="012.00"})<>0, aApICM[aScan (aApICM, {|a| a[4]=="012.00"})][3], 0)
	nVL_16	:=	Iif (aScan (aApICM, {|a| a[1]=="013"})<>0, aApICM[aScan (aApICM, {|a| a[1]=="013"})][3], 0)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Leio o arquivo de apuracao ICMS/ST³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aApST	:=	FisApur ("ST", Year (dDataAte), Month (dDataAte), nApuracao, nPeriodo, cNrLivro, .F., {}, 1, .F., "")
	nVL_17	:=	Iif (aScan (aApST, {|a| a[1]=="006"})<>0, aApST[aScan (aApST, {|a| a[1]=="006"})][3], 0)
    nVL_18	:=  0
	nVL_19	:=	nAcRetEsta  // ICMS substituto pelas saidas para o Estado.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Outros valores³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVL_20	:=	nAcImport
	nVL_21	:=	0
	nVL_22	:=	nVL_16 + nVL_17 + nVL_18 + nVL_19 + nVL_20 + nVL_21
	nVL_99	:=	nAcRetInter

	aAdd(aReg, {})
	nPos	:=	Len (aReg)
	aAdd (aReg[nPos], "G420")	   				//01 - REG
	aAdd (aReg[nPos], nVL_01)					//02 - VL_01
	aAdd (aReg[nPos], nVL_02)					//03 - VL_02
	aAdd (aReg[nPos], nVL_03)					//04 - VL_03
	aAdd (aReg[nPos], nVL_04)					//05 - VL_04
	aAdd (aReg[nPos], nVL_05)					//06 - VL_05
	aAdd (aReg[nPos], nVL_06)					//07 - VL_06
	aAdd (aReg[nPos], nVL_07)					//08 - VL_07
	aAdd (aReg[nPos], nVL_08)					//09 - VL_08
	aAdd (aReg[nPos], nVL_09)					//10 - VL_09
	aAdd (aReg[nPos], nVL_10)					//11 - VL_10
	aAdd (aReg[nPos], nVL_11)					//12 - VL_11
	aAdd (aReg[nPos], nVL_12)					//13 - VL_12
	aAdd (aReg[nPos], nVL_13)					//14 - VL_13
	aAdd (aReg[nPos], nVL_14)					//15 - VL_14
	aAdd (aReg[nPos], nVL_15)					//16 - VL_15
	aAdd (aReg[nPos], nVL_16)					//17 - VL_16
	aAdd (aReg[nPos], nVL_17)					//18 - VL_17
	aAdd (aReg[nPos], nVL_18)					//19 - VL_18
	aAdd (aReg[nPos], nVL_19)					//20 - VL_19
	aAdd (aReg[nPos], nVL_20)					//21 - VL_20
	aAdd (aReg[nPos], nVL_21)					//22 - VL_21	
	aAdd (aReg[nPos], nVL_22)                  //23 - VL_22
	aAdd (aReg[nPos], nVL_99)					//24 - VL_99
	
	GrvRegSef (cAlias,, aReg)    
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Este FOR verifica todos os ajustes lancados na Apuracao de ICMS³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//	For nX := 1 To Len (aApICM)
//		If ("002"$aApICM[nX][1] .And. !"002.00"$aApICM[nX][4]) .Or.;
//			("003"$aApICM[nX][1] .And. !"003.00"$aApICM[nX][4]) .Or.;
//			("006"$aApICM[nX][1] .And. !"006.00"$aApICM[nX][4]) .Or.;
//			("007"$aApICM[nX][1] .And. !"007.00"$aApICM[nX][4]) .Or.;
//			("012"$aApICM[nX][1] .And. !"012.00"$aApICM[nX][4])
//			
//			aAdd(aRegG430, {})
//			nPos	:=	Len (aRegG430)
//			aAdd (aRegG430[nPos], "G430")	   	   				//01 - REG
//			aAdd (aRegG430[nPos], SUBSTR(aApICM[nX][4],1,3))	//02 - COD_AJ
//			aAdd (aRegG430[nPos], aApICM[nX][3])				//03 - VL_AJ
//		EndIf
//	Next nI
//	
//	GrvRegSef (cAlias,, aRegG430) 	
Return (lRet)                                                                

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RegG450  	³ Autor ³Sueli C. Santos        ³ Data ³08.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³     G450 - CONSOLIDACAO DOS VALORES DE ICMS POR CFOP       ³±±
±±³          ³             INTERESTADUAL                                  ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao do Registros G450			                      |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef com as informacoe contidas no array    ³±±
±±³          ³ aCmpAntSFT e na tabela SFT.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³G450 - 3(varios por periodo)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAliasSFT -> Alias da tabela SFT aberta no momento.         ³±±
±±³          ³ funcao a ser retornado para gravacao pela funcao principal.³±±
±±³          |cEntSai -> Flag Entrada(1)/Saida(2).                        ³±±
±±³          |aRegG450 -> Array contendo as informacoes processadas pela  ³±±
±±³          ³ funcao a ser retornado para gravacao pela funcao principal.³±±
±±³          ³cSituaDoc -> Situacao do documento fiscal.                  ³±±
±±³          ³lIss -> Indicador de nota fiscal com incidencia do ISS      ³±±
±±³          ³cEspecie -> Especie do documento fiscal                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegG450 (cAliasSFT, cEntSai, aRegG450, cSituaDoc, lIss,cEspecie)
	Local	nPos	:=	0
	Local	lRet	:=	.T.
	Local 	cCfopPE			:= GetNewPar("MV_CFOPRE","")  // cfop utilizados para identificar operacoes com petroleo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³REGISTRO G450 - CONSOLIDACAO DOS VALORES DE ICMS POR CFOP INTERESTADUAIS ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ          
	If Substr((cAliasSFT)->FT_CFOP,1,1)$"26" 
		If ((nPos := aScan (aRegG450, {|aX| aX[2]==STR(Val (cEntSai)-1,1)}))==0  )
			aAdd(aRegG450, {})
			nPos	:=	Len (aRegG450)
			aAdd (aRegG450[nPos], "G450")	 	   					//01 - REG    
			aAdd (aRegG450[nPos], STR(Val (cEntSai)-1,1)) 			//02 - IND_OPER
			aAdd (aRegG450[nPos], 0)								//03 - VL_CONT_NC
			aAdd (aRegG450[nPos], 0)								//04 - VL_CONT_C
			aAdd (aRegG450[nPos], 0)								//05 - VL_OP_ISS
			aAdd (aRegG450[nPos], 0)								//06 - VL_BC_ICMS_NC
			aAdd (aRegG450[nPos], 0)								//07 - VL_BC_ICMS_C
			aAdd (aRegG450[nPos], 0)								//08 - VL_ICMS
			aAdd (aRegG450[nPos], 0)								//09 - VL_ICMS_ST
			aAdd (aRegG450[nPos], 0)								//10 - VL_ICMS_PETR			
			aAdd (aRegG450[nPos], 0)								//11 - VL_ICMS_EEL
			aAdd (aRegG450[nPos], 0)								//12 - VL_ICMS_ST_OUT
			aAdd (aRegG450[nPos], 0)				   				//13 - VL_AT			
			aAdd (aRegG450[nPos], 0)								//14 - VL_ISNT_ICMS
			aAdd (aRegG450[nPos], 0)								//15 - VL_OUT_ICMS

		EndIf
		If !(cSituaDoc$"90#81#")     
		
			cAlsSA	:=	"SA"+Iif ((cEntSai=="1" .And. !(cAliasSFT)->FT_TIPO$"BD") .or.  (cEntSai=="2" .And. (cAliasSFT)->FT_TIPO$"BD"), "2", "1")	//Determina o Alias para as Tabelas SA1/SA2
			(cAlsSA)->(dbSeek (xFilial (cAlsSA)+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA))
							
			lInscrito := IIf(Empty((cAlsSA)+"->"+SubStr (cAlsSA, 2, 2)+"_INSCR").Or."ISENT"$((cAlsSA)+"->"+SubStr (cAlsSA, 2, 2)+"_INSCR").Or."RG"$((cAlsSA)+"->"+SubStr(cAlsSA, 2, 2)+"_INSCR").Or.((cAlsSA)->(FieldPos(SubStr(cAlsSA,2,2)+"_CONTRIB")) > 0 .And. ((cAlsSA)+"->"+SubStr (cAlsSA, 2, 2)+"_CONTRIB") == "2"),.T.,.F.)
			
			If lIss
				aRegG450[nPos][5]	+=	(cAliasSFT)->FT_VALCONT		    //05 - VL_OP_ISS
			Else 
			    If lInscrito
					aRegG450[nPos][4]	+=	(cAliasSFT)->FT_VALCONT		//04 - VL_CONT_C 
					aRegG450[nPos][7]	+=	(cAliasSFT)->FT_BASEICM		//07 - VL_BC_ICMS_C
				Else
					aRegG450[nPos][3]	+=	(cAliasSFT)->FT_VALCONT		//03 - VL_CONT_NC
					aRegG450[nPos][6]	+=	(cAliasSFT)->FT_BASEICM		//06 - VL_BC_ICMS_NC
				EndIf 
			
				aRegG450[nPos][8]	+=	(cAliasSFT)->FT_VALICM		    //08 - VL_ICMS			
				//¿
				//³* Para os modeloÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄs abaixo que tiverem DIFERENCIAL ALIQUOTA,   |
				//|  nao devo enviar neste campo, basta considerar nos ajustes. ³
				//³* Para os modelos abaixo que tiverem SUBSTITUICAO TRIBUTARIA,|
				//|  NAO devo enviar neste campo, pois o mesmo estah destinado  ³
				//|  aos registros C's(C020 - Campo 23 - modelo 01 e 04).       |
				//|                                                             |
				//³06 - NOTA FISCAL/CONTA DE ENERGIA ELETRICA                   ³
				//³21 - NOTA FISCAL DE SERVICO DE COMUNICACAO                   ³
				//³22 - NOTA FISCAL DE SERVICO DE TELECOMUNICACAO               ³
				//³07 - NOTA FISCAL SERVICO DE TRANSPORTE - SAIDA/ENTRADA       ³
				//³08 - CONHECIMENTO DE TRANSPORTE RODOVIARIO - SAIDA/ENTRADA   ³
				//³09 - CONHECIMENTO DE TRANSPORTE AQUAVIARIO - ENTRADA         ³
				//³10 - CONHECIMENTO DE TRANSPORTE AEREO - ENTRADA              ³
				//³11 - CONHECIMENTO DE TRANSPORTE FERROVIARIO - ENTRADA        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !(cEspecie$"06#07#08#09#10#11#21#22")
					aRegG450[nPos][9]	+=	(cAliasSFT)->FT_ICMSRET	    //09 - VL_ICMS_ST
				EndIf
				      
				 If (cAliasSFT)->FT_CFOP$cCfopPE
				 	 aRegG450[nPos][10]	+=	(cAliasSFT)->FT_VALICM		//10 - VL_ICMS_PETR		
				 EndIf
				      
				 If (cEspecie$"06")
				 	 aRegG450[nPos][11]	+=	(cAliasSFT)->FT_VALICM		//11 - VL_ICMS_EE		
				 EndIf
				 
				aRegG450[nPos][14]	+=	(cAliasSFT)->FT_ISENICM		    //14 - VL_ISNT_ICMS
				//Quando configuro a TES para escriturar o Livro de ICMS/ST como ISENTO, na tabela SF3 o valor do campo 
				//  F3_ICMSRET eh transportado para o campo F3_ISENICM, ficando com os mesmos valores. Na tabela SFT, que
				//  possui o campo proprio FT_ISENRET, recebe este valor deixando o campo FT_ISENICM e FT_ICMSRET zerado.
				aRegG450[nPos][14]	+=	(cAliasSFT)->FT_ISENRET		   //14 - VL_ISNT_ICMS
				
				If cEspecie<>"2D"
					aRegG450[nPos][15]	+=	(cAliasSFT)->FT_OUTRICM	   //15 - VL_OUT_ICMS
				EndIf	
				//Quando configuro a TES para escriturar o Livro de ICMS/ST como OUTROS, na tabela SF3 o valor do campo 
				//  F3_ICMSRET eh transportado para o campo F3_OUTRICM, ficando com os mesmos valores. Na tabela SFT, que
				//  possui o campo proprio FT_OUTRRET, recebe este valor deixando o campo FT_OUTRICM e FT_ICMSRET zerado.
				aRegG450[nPos][15]	+=	(cAliasSFT)->FT_OUTRRET		  //15 - VL_OUT_ICMS     
				
			EndIf
		EndIf
	EndIf
Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RegG460  	³ Autor ³Sueli C. Santos        ³ Data ³08.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³     G460 - CONSOLIDACAO DOS VALORES DE ICMS POR CFOP       ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao do Registros E310			                      |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef com as informacoe contidas no array    ³±±
±±³          ³ aCmpAntSFT e na tabela SFT.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³G460 - 3(varios por periodo)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAliasSFT -> Alias da tabela SFT aberta no momento.         ³±±
±±³          ³ funcao a ser retornado para gravacao pela funcao principal.³±±
±±³          |cEntSai -> Flag Entrada(1)/Saida(2).                        ³±±
±±³          |aRegE310 -> Array contendo as informacoes processadas pela  ³±±
±±³          ³ funcao a ser retornado para gravacao pela funcao principal.³±±
±±³          ³cSituaDoc -> Situacao do documento fiscal.                  ³±±
±±³          ³lIss -> Indicador de nota fiscal com incidencia do ISS      ³±±
±±³          ³cEspecie -> Especie do documento fiscal                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegG460 (cAliasSFT, cEntSai, aRegG460, cSituaDoc, lIss,cEspecie)
	Local	nPos	:=	0
	Local	lRet	:=	.T.  
	Local 	cCfopPE			:= GetNewPar("MV_CFOPRE","")    

	If Substr((cAliasSFT)->FT_CFOP,1,1)$"26" 
		If ((nPos := aScan (aRegG460, {|aX| aX[2]==(cAliasSFT)->FT_ESTADO}))==0  )
			aAdd(aRegG460, {})
			nPos	:=	Len (aRegG460)
			aAdd (aRegG460[nPos], "G460")	 	   					//01 - REG    
			aAdd (aRegG460[nPos],(cAliasSFT)->FT_ESTADO ) 			//02 - UF
			aAdd (aRegG460[nPos], 0)								//03 - VL_CONT_NC_UF
			aAdd (aRegG460[nPos], 0)								//04 - VL_CONT_C_UF
			aAdd (aRegG460[nPos], 0)								//05 - VL_OP_ISS_UF
			aAdd (aRegG460[nPos], 0)								//06 - VL_BC_ICMS_NC_UF
			aAdd (aRegG460[nPos], 0)								//07 - VL_BC_ICMS_C_UF
			aAdd (aRegG460[nPos], 0)								//08 - VL_ICMS_UF
			aAdd (aRegG460[nPos], 0)								//09 - VL_ICMS_ST_UF
			aAdd (aRegG460[nPos], 0)								//10 - VL_ICMS_PETR_UF			
			aAdd (aRegG460[nPos], 0)								//11 - VL_ICMS_EEL_UF
			aAdd (aRegG460[nPos], 0)								//12 - VL_ICMS_ST_OUT_UF
			aAdd (aRegG460[nPos], 0)				   				//13 - VL_AT_UF			
			aAdd (aRegG460[nPos], 0)								//14 - VL_ISNT_ICMS_UF
			aAdd (aRegG460[nPos], 0)								//15 - VL_OUT_ICMS_UF
	
		EndIf
		If !(cSituaDoc$"90#81#")     
		
			cAlsSA	:=	"SA"+Iif ((cEntSai=="1" .And. !(cAliasSFT)->FT_TIPO$"BD") .or.  (cEntSai=="2" .And. (cAliasSFT)->FT_TIPO$"BD"), "2", "1")	//Determina o Alias para as Tabelas SA1/SA2
			(cAlsSA)->(dbSeek (xFilial (cAlsSA)+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA))
							
			lInscrito := IIf(Empty((cAlsSA)+"->"+SubStr (cAlsSA, 2, 2)+"_INSCR") .Or. "ISENT"$((cAlsSA)+"->"+SubStr (cAlsSA, 2, 2)+"_INSCR") .Or. "RG"$((cAlsSA)+"->"+SubStr(cAlsSA, 2, 2)+"_INSCR") .Or. ((cAlsSA)->(FieldPos(SubStr(cAlsSA,2,2)+"_CONTRIB"))  > 0 .And. ((cAlsSA)+"->"+SubStr (cAlsSA, 2, 2)+"_CONTRIB") == "2"),.T.,.F.)
			
			If lIss
				aRegG460[nPos][5]	+=	(cAliasSFT)->FT_VALCONT		    //05 - VL_OP_ISS_UF
			Else 
			    If lInscrito
					aRegG460[nPos][4]	+=	(cAliasSFT)->FT_VALCONT		//04 - VL_CONT_C_UF 
					aRegG460[nPos][7]	+=	(cAliasSFT)->FT_BASEICM		//07 - VL_BC_ICMS_C_UF
				Else
					aRegG460[nPos][3]	+=	(cAliasSFT)->FT_VALCONT		//03 - VL_CONT_NC_UF
					aRegG460[nPos][6]	+=	(cAliasSFT)->FT_BASEICM		//06 - VL_BC_ICMS_NC_UF
				EndIf 
				
				aRegG460[nPos][8]	+=	(cAliasSFT)->FT_VALICM		    //08 - VL_ICMS_UF			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³* Para os modelos abaixo que tiverem DIFERENCIAL ALIQUOTA,   |
				//|  nao devo enviar neste campo, basta considerar nos ajustes. ³
				//³* Para os modelos abaixo que tiverem SUBSTITUICAO TRIBUTARIA,|
				//|  NAO devo enviar neste campo, pois o mesmo estah destinado  ³
				//|  aos registros C's(C020 - Campo 23 - modelo 01 e 04).       |
				//|                                                             |
				//³06 - NOTA FISCAL/CONTA DE ENERGIA ELETRICA                   ³
				//³21 - NOTA FISCAL DE SERVICO DE COMUNICACAO                   ³
				//³22 - NOTA FISCAL DE SERVICO DE TELECOMUNICACAO               ³
				//³07 - NOTA FISCAL SERVICO DE TRANSPORTE - SAIDA/ENTRADA       ³
				//³08 - CONHECIMENTO DE TRANSPORTE RODOVIARIO - SAIDA/ENTRADA   ³
				//³09 - CONHECIMENTO DE TRANSPORTE AQUAVIARIO - ENTRADA         ³
				//³10 - CONHECIMENTO DE TRANSPORTE AEREO - ENTRADA              ³
				//³11 - CONHECIMENTO DE TRANSPORTE FERROVIARIO - ENTRADA        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !(cEspecie$"06#07#08#09#10#11#21#22")
					aRegG460[nPos][9]	+=	(cAliasSFT)->FT_ICMSRET	    //09 - VL_ICMS_ST_UF
				EndIf
				      
				 If (cAliasSFT)->FT_CFOP$cCfopPE
				 	 aRegG460[nPos][10]	+=	(cAliasSFT)->FT_VALICM		//10 - VL_ICMS_PETR_UF		
				 EndIf
				      
				 If (cEspecie$"06")
				 	 aRegG460[nPos][11]	+=	(cAliasSFT)->FT_VALICM		//11 - VL_ICMS_EE_UF		
				 EndIf
				 
				aRegG460[nPos][14]	+=	(cAliasSFT)->FT_ISENICM		    //14 - VL_ISNT_ICMS_UF
				//Quando configuro a TES para escriturar o Livro de ICMS/ST como ISENTO, na tabela SF3 o valor do campo 
				//  F3_ICMSRET eh transportado para o campo F3_ISENICM, ficando com os mesmos valores. Na tabela SFT, que
				//  possui o campo proprio FT_ISENRET, recebe este valor deixando o campo FT_ISENICM e FT_ICMSRET zerado.
				aRegG460[nPos][14]	+=	(cAliasSFT)->FT_ISENRET		    //14 - VL_ISNT_ICMS_UF
				
				If cEspecie<>"2D"
					aRegG460[nPos][15]	+=	(cAliasSFT)->FT_OUTRICM		//15 - VL_OUT_ICMS_UF
				EndIf	
				//Quando configuro a TES para escriturar o Livro de ICMS/ST como OUTROS, na tabela SF3 o valor do campo 
				//  F3_ICMSRET eh transportado para o campo F3_OUTRICM, ficando com os mesmos valores. Na tabela SFT, que
				//  possui o campo proprio FT_OUTRRET, recebe este valor deixando o campo FT_OUTRICM e FT_ICMSRET zerado.
				aRegG460[nPos][15]	+=	(cAliasSFT)->FT_OUTRRET		    //15 - VL_OUT_ICMS_UF     
				
			EndIf
		EndIf
	Endif	
Return (lRet)     
  
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Reg8020   ³ Autor ³Sueli C. Santos        ³ Data ³16.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³            INFORMACOES COMPLEMENTARES                      ³±±
±±³          ³         QUADRO DE CALCULO DO VALOR ADICIONADO              ³±±
±±³          ³                                                            ³±±
±±³          ³- Gravacao dos Registros 8020 e 8030                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2(varios por arquivo)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Reg8020 (cAlias, dDataDe, dDataAte,aWizard,aReg8020)
	Local	lRet		:=	.T.
	Local	nPos		:=	0    
//	Local   aReg8020    := {}
	//
	
		aAdd (aReg8020, {})
		nPos	:=	Len (aReg8020)
		aAdd (aReg8020[nPos], "8020")							 //01 - REG
		aAdd (aReg8020[nPos], Substr(aWizard[6][1],1,1))       //02 - IND_QVA 
		aAdd (aReg8020[nPos], dDataDe)							 //03 - DT_INI
		aAdd (aReg8020[nPos], dDataAte)							 //04 - DT_FIN
	
	//

Return (lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Reg8030   ³ Autor ³Osmar Haruo Kanehisa   ³ Data ³11.06.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³            INFORMACOES COMPLEMENTARES                      ³±±
±±³          ³         QUADRO DE CALCULO DO VALOR ADICIONADO              ³±±
±±³          ³                                                            ³±±
±±³          ³- Gravacao dos Registros 8030                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2(varios por arquivo)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Reg8030 (cAlias, cAliasSFT, cAlsSD, aReg8030, lIss, cEntSai, cSituaDoc, aWizard)

Local nPos    := 0
Local lRet    := .T.
Local cMun    := ""
Local cInd    := ""
Local cIndDet := ""
Local cCfop   := ""
Local cCfopT  := ""
Local cCfopC  := ""
	
cCfop := "1111/1113/1406/1551/1552/1553/1554/1601/1602/1603/1604/1919/1922/1923/1924/1922/1923/1924/1933/"
cCfop += "2111/2113/2406/2551/2553/2554/2555/2603/2919/2922/2923/2924/3551/3553/5111/5112/5113/5114/5412/"
cCfop += "5551/5552/5553/5554/5555/5601/5602/5603/5919/5922/5923/5924/5929/5932/5933/6111/6112/6113/6114/"
cCfop += "6412/6551/6552/6553/6554/6555/6603/6919/6922/6923/6924/6929/6932/7551/7553"

cCfopT := "5351/5352/5353/5354/5355/5356/5357/5359/5360/6351/6352/6353/6354/6355/6356/6357/6359/6360/7358"
cCfopC := "5301/5302/5303/5304/5305/5306/5307/6301/6302/6303/6404/6305/6306/6307/7301"

If cEntSai == "1"
	If (cAliasSFT)->FT_TIPO$"BD"
		SA1->(DbSetOrder (1))
		If SA1->(DbSeek (xFilial ("SA1")+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA))
			If SA1->A1_EST $ "EX"
				cMun := "9999999"
			Else
				cMun := UfCodIBGE(SA1->A1_EST) + SA1->A1_COD_MUN
			Endif
		EndIf
	Else
		SA2->(DbSetOrder (1))
		If SA2->(DbSeek (xFilial ("SA2")+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA))
			If SA2->A2_EST $ "EX"
				cMun := "9999999"
			Else
				cMun := UfCodIBGE(SA2->A2_EST) + SA2->A2_COD_MUN
			Endif
		EndIf
	EndIf
Else
	If (cAliasSFT)->FT_TIPO$"BD"
		SA2->(DbSetOrder (1))
		If SA2->(DbSeek (xFilial ("SA2")+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA))
			If SA2->A2_EST $ "EX"
				cMun := "9999999"
			Else
				cMun := UfCodIBGE(SA2->A2_EST) + SA2->A2_COD_MUN
			Endif
		EndIf
	Else
		SA1->(DbSetOrder (1))
		If SA1->(DbSeek (xFilial ("SA1")+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA))
			If SA1->A1_EST $ "EX"
				cMun := "9999999"
			Else
				cMun := UfCodIBGE(SA1->A1_EST) + SA1->A1_COD_MUN
			Endif
		EndIf
	EndIf
EndIf

If !(AllTrim((cAliasSFT)->FT_CFOP)) $ cCfop

	If !( cSituaDoc $ "90#81#" )

		If (cAlsSD)->(dbSeek (xFilial (cAlsSD)+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA+(cAliasSFT)->FT_PRODUTO+(cAliasSFT)->FT_ITEM))
			SF4->(DbSetOrder (1))
			If SF4->(dbSeek (xFilial ("SF4")+&(cCmpTes)))
				cIndDet := SF4->F4_INDDET
			EndIf
		EndIf

		cInd := cIndDet

		If cIndDet $ "01"
			If cIndDet = "0" .AND.(AllTrim((cAliasSFT)->FT_CFOP)) $ cCfopT   //0 - Prestação de serviços de tranp intermunicipal ou interestadual.
				cInd := "0"
			ELSE
				If cIndDet = "1" .AND.(AllTrim((cAliasSFT)->FT_CFOP)) $ cCfopC   //1 - Prestação de serviços oneroso de comunicação.
					cInd := "1"
				ELSE
					cInd := ""
				EndIf
			EndIf
		EndIf
			
		If cInd <> "9" .And. cMun >= '2600054' .And. cMun <= '2616506'
			If ( nPos := aScan (aReg8030, {|aX| aX[5]== cMun .AND. aX[3]== STR(Val (cEntSai)-1,1) .AND. Alltrim(aX[4])== Alltrim(cInd)} ) ) = 0
				aAdd(aReg8030, {})
				nPos :=	Len (aReg8030)
				aAdd (aReg8030[nPos], "8030")                   //01 - REG
				aAdd (aReg8030[nPos], 0)                        //02 - IND_TOT POR MUNICÍPIO 
				aAdd (aReg8030[nPos], STR(Val (cEntSai)-1,1))  //03 - IND_OPER
				aAdd (aReg8030[nPos], cInd)                     //04 - IND_DET
				aAdd (aReg8030[nPos], cMun)                     //05 - COD_MUN
				aAdd (aReg8030[nPos], 0)                        //06 - VL_CONT_MUN
				aAdd (aReg8030[nPos], 0)                        //07 - VL_OP_ISS_MUN
				aAdd (aReg8030[nPos], 0)                        //08 - VL_ICMS_ST_MUN
				aAdd (aReg8030[nPos], 0)                        //09 - VL_TE_MUN
				aAdd (aReg8030[nPos], 0)                        //10 - VL_TS_MUN
				aAdd (aReg8030[nPos], 0)                        //11 - VL_AD_MUN
			EndIf

			aReg8030[nPos][6] += (cAliasSFT)->FT_VALCONT						//06 - VL_CONT_MUN

			If lIss
				aReg8030[nPos][7] += (cAliasSFT)->FT_VALCONT					//07 - VL_OP_ISS_MUN
			Else
				aReg8030[nPos][8] += (cAliasSFT)->FT_ICMSRET					//08 - VL_ICMS_ST_MUN
				
				If  cEntSai=="1"
					aReg8030[nPos][9 ] += (cAliasSFT)->FT_VALCONT				//09 - VL_TE_CFOP_MUN
				Else
					aReg8030[nPos][10] += (cAliasSFT)->FT_VALCONT				//10 - VL_TS_CFOP_MUN
				EndIF

				aReg8030[nPos][11] := aReg8030[nPos][10] - aReg8030[nPos][9]	//11 - VL_AD_MUN

				If aReg8030[nPos][11] < 0
					aReg8030[nPos][11] := 0
				EndIf

			EndIf
		EndIf
	EndIf
EndIf

Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |Reg8040   ³ Autor ³Sueli C. Santos        ³ Data ³16.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³    8040 - AJUSTES DE VALORES POR CFOP                      ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao do Registro 8040                                  |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrb com as informacoe contidas no array    ³±±
±±³          ³ aCmpAntSFT e na tabela SFT.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³8040 - 3(varios por periodo)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAliasSFT -> Alias da tabela SFT aberta no momento.         ³±±
±±³          ³ funcao a ser retornado para gravacao pela funcao principal.³±±
±±³          |aRegB420 -> Array contendo as informacoes processadas pela  ³±±
±±³          ³ funcao a ser retornado para gravacao pela funcao principal.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Reg8040 (cAlias, cAliasSFT, aReg8040, lIss, cEntSai, cSituaDoc,aWizard)
	Local	nPos	:=	0
	Local	lRet	:=	.T.

	If ((nPos := aScan (aReg8040, {|aX| aX[5]==(cAliasSFT)->FT_CFOP}))=0)
		aAdd(aReg8040, {})
		nPos	:=	Len (aReg8040)
		aAdd (aReg8040[nPos], "8040")	 	   			//01 - REG 
		aAdd (aReg8040[nPos], "1")	 	   			    //02 - IND_CFOP		
		aAdd (aReg8040[nPos], 0)						//03 - VL_CONT
		aAdd (aReg8040[nPos], 0)						//04 - VL_OP_ISS
		aAdd (aReg8040[nPos], (cAliasSFT)->FT_CFOP)	//05 - CFOP
		aAdd (aReg8040[nPos], 0)						//06 - VL_ICMS_ST
		aAdd (aReg8040[nPos], 0)						//07 - VL_TE_CFOP
		aAdd (aReg8040[nPos], 0)						//08 - VL_TS_CFOP
	EndIf
	//
	If !(cSituaDoc$"90#81#")
		aReg8040[nPos][3]	+= (cAliasSFT)->FT_VALCONT		        //02 - VL_CONT

		If lIss
			aReg8040[nPos][4]	+=	(cAliasSFT)->FT_VALCONT		    //03 - VL_OP_ISS
		Else
	
			aReg8040[nPos][6]	+=	(cAliasSFT)->FT_ICMSRET	       //06 - VL_ICMS_ST
		
			If  cEntSai=="1"
				aReg8040[nPos][7]	+=	(cAliasSFT)->FT_VALCONT		//07 -VL_TE_CFOP	   			
	   		Else
	   			aReg8040[nPos][8]	+=	(cAliasSFT)->FT_VALCONT		//08 - VL_Ts_CFOP
			EndIF
			
		EndIf 
	EndIf

Return (lRet)   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Reg8100   ³ Autor ³Sueli C. Santos        ³ Data ³16.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³            INFORMACOES COMPLEMENTARES                      ³±±
±±³          ³            QUADRO DE AQUISIÇÃO DE BENS                     ³±±
±±³          ³                                                            ³±±
±±³          ³- Gravacao dos Registros 8100                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2(varios por arquivo)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Reg8100 (cAlias,aReg8100, dDataDe, dDataAte, aWizard)

Local	lRet		:=	.T.
Local	nPos		:=	0

aAdd (aReg8100, {})
nPos	:=	Len (aReg8100)
aAdd (aReg8100[nPos], "8100")							  //01 - REG
aAdd (aReg8100[nPos], Substr(aWizard[6][2],1,1))        //02 - IND_QAB 
aAdd (aReg8100[nPos], dDataDe)							  //03 - DT_INI
aAdd (aReg8100[nPos], dDataAte)							  //04 - DT_FIN

GrvRegSef (cAlias,, aReg8100)

Return (lRet)     

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |Reg8110   ³ Autor ³Sueli C. Santos        ³ Data ³16.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³    8110 - AJUSTES DE VALORES POR CFOP                      ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao do Registro 8040                                  |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegTrb com as informacoe contidas no array    ³±±
±±³          ³ aCmpAntSFT e na tabela SFT.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³8040 - 3(varios por periodo)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAliasSFT -> Alias da tabela SFT aberta no momento.         ³±±
±±³          ³ funcao a ser retornado para gravacao pela funcao principal.³±±
±±³          |aRegB420 -> Array contendo as informacoes processadas pela  ³±±
±±³          ³ funcao a ser retornado para gravacao pela funcao principal.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Reg8110 (cAlias, cAliasSFT, aReg8110, lIssRet,cEspecie,aWizard)
	
Local	nPos	:=	0
Local	lRet	:=	.T.   
Local cOrigem  := ""

If (cAliasSFT)->FT_CFOP <"5" .And. cEspecie$"06#21" .Or. AllTrim((cAliasSFT)->FT_CFOP)$"1551/1553/2551/2553/3551/3553" 
		 
	If Left(AllTrim((cAliasSFT)->FT_CFOP),1)=="1" .And. (cAliasSFT)->FT_ESTADO==SM0->M0_ESTENT //Internas
		cOrigem	:= "0"
	ElseIf Left(AllTrim((cAliasSFT)->FT_CFOP),1)=="2" .And. Upper((cAliasSFT)->FT_ESTADO)$"SP/RJ/MG/PR/SC/RS" //Sul/Sudeste exceto ES
	 	cOrigem	:= "1"	
	ElseIf Left(AllTrim((cAliasSFT)->FT_CFOP),1)=="3"
		cOrigem	:= "3"	
	ElseIf Left(AllTrim((cAliasSFT)->FT_CFOP),1)=="2"
		cOrigem	:= "2"	
	Else
		cOrigem	:= "0"	
	Endif			    

   	If ((nPos := aScan (aReg8110, {|aX| aX[2]==cOrigem}))=0)
		aAdd(aReg8110, {})
		nPos	:=	Len (aReg8110)
		aAdd (aReg8110[nPos], "8110")	 	   			//01 - REG 
		aAdd (aReg8110[nPos], cOrigem)	 	   		    //02 - IND_ORIG
		aAdd (aReg8110[nPos], 0)						//03 - VL_EEL
		aAdd (aReg8110[nPos], 0)						//04 - VL_COM
		aAdd (aReg8110[nPos], 0)  						//05 - VL_ATV
		aAdd (aReg8110[nPos], 0)						//06 - VL_OUT
	EndIf
	//
	If (cEspecie$"06")
		aReg8110[nPos][3]	+= (cAliasSFT)->FT_VALICM		//03 - VL_EEL
     
   	ElseIf (cEspecie$"21")
		aReg8110[nPos][4]	+=	(cAliasSFT)->FT_VALICM+(cAliasSFT)->FT_ICMSCOM		//04 - VL_COM
	
	ElseIf AllTrim((cAliasSFT)->FT_CFOP)$"1551/1553/2551/2553/3551/3553"
		aReg8110[nPos][5]	+=	(cAliasSFT)->FT_VALICM+(cAliasSFT)->FT_ICMSCOM	 //05 - VL_ATV
	Else
		aReg8110[nPos][6]	+=	(cAliasSFT)->FT_VALICM		//06 -VL_OUT	   			
	EndIf
	
EndIf

Return (lRet)   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Reg8160   ³ Autor ³Sueli C. Santos        ³ Data ³16.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³            INFORMACOES COMPLEMENTARES                      ³±±
±±³          ³            QUADRO DE AQUISIÇÃO DE BENS                     ³±±
±±³          ³                                                            ³±±
±±³          ³- Gravacao dos Registros 8160                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2(varios por arquivo)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Reg8160 (cAlias, dDataDe, dDataAte, aWizard)

Local	lRet		:=	.T.
Local	nPos		:=	0
Local  aReg8160    := {}

aAdd (aReg8160, {})
nPos	:=	Len (aReg8160)
aAdd (aReg8160[nPos], "8160")								//01 - REG
aAdd (aReg8160[nPos], Substr(aWizard[6][3],1,1))          //02 - IND_QCA
aAdd (aReg8160[nPos], dDataDe)							    //03 - DT_INI
aAdd (aReg8160[nPos], dDataAte)							    //04 - DT_FIN

GrvRegSef (cAlias,, aReg8160)

Return (lRet)   
 
 /*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |Reg8165   ³ Autor ³Sueli C. Santos        ³ Data ³09.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³                   APURACAO DO ICMS                         ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro E360                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef com as informacoe contidas na apuracao ³±±
±±³          ³ de ICMS.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³8165 - 3(varios por periodo)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlias -> Alias do TRB para gravacao.                       ³±±
±±³          ³dDataAte -> Data final do periodo de apuracao.              ³±±
±±³          ³cNrLivro -> Numero do livro selecionado no wizard.          ³±±
±±³          ³nAcImport -> Valor de ICMS da Importacao.                   ³±±
±±³          ³nAcRetInter -> Valor Substituicao Tributaria nas operacoes  ³±±
±±³          ³ interestaduais.                                            ³±±
±±³          ³nDbCompIcm -> Total das NFs de complemento de ICMS - saidas ³±±
±±³          ³nCrCompIcm ->Total das NFs de complemento de ICMS - entradas³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Reg8165  (cAlias, dDataAte, aWizard, nAcImport, nAcRetInter, nDbCompIcm, nCrCompIcm, aLog,nAcRetEsta)
	Local	lRet		:=	.T.
	Local	nPos		:=	0
	Local	aReg		:=	{}
	Local	nX			:=	0
	Local	nApuracao	:=	GetSx1 (PadR("MTA951",10), "04", .T.)	//1-Decendial, 2-Quinzenal, 3-Mensal, 4-Semestral ou 5-Anual
	Local	nPeriodo	:=	1								//GetSx1 ("MTA951", "05", .T.)	//1-1., 2-2., 3-3.	
	Local	aApICM		:=	{}
	Local	aReg8160	:=	{}   
	Local	nVL_REM		:=	0
	Local   nVL_PU  	:=	0
	Local   nVL_C1C2	:=	0
	Local   nVL_TUT		:=	0
	Local   nVL_SLD		:=  0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Fixo que o periodo de geracao podera ser somente Mensal ou Anual.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nApuracao==1) .Or. (nApuracao==2)
		nApuracao	:=	3
	ElseIf (nApuracao==4)
		nApuracao	:=	5
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Leio o arquivo de apuracao ICMS³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aApICM	:=	FisApur ("IC", Year (dDataAte), Month (dDataAte), nApuracao, nPeriodo, cNrLivro, .F., {}, 1, .F., "")
	
	nVL_REM	:=	Iif (aScan (aApICM, {|a| a[1]=="009"})<>0, aApICM[aScan (aApICM, {|a| a[1]=="009"})][3], 0)
	nVL_PU  :=	Iif (aScan (aApICM, {|a| a[1]=="010"})<>0, aApICM[aScan (aApICM, {|a| a[1]=="010"})][3], 0)
	nVL_C1C2:=	Iif (aScan (aApICM, {|a| a[1]=="008"})<>0, aApICM[aScan (aApICM, {|a| a[1]=="008"})][3], 0)
	nVL_TUT	:=	Iif (aScan (aApICM, {|a| a[1]=="004"})<>0, aApICM[aScan (aApICM, {|a| a[1]=="004"})][3], 0)
	nVL_SLD	:=	Iif (aScan (aApICM, {|a| a[1]=="014"})<>0, aApICM[aScan (aApICM, {|a| a[1]=="014"})][3], 0)
	

	
	aAdd(aReg, {})
	nPos	:=	Len (aReg)
	aAdd (aReg[nPos], "8165")	   				//01 - REG
	aAdd (aReg[nPos], nVL_REM)					//02 - VL_REM
	aAdd (aReg[nPos], nVL_C1C2)					//03 - VL_ACUM
	aAdd (aReg[nPos], nVL_PU)					//04 - VL_PU
	aAdd (aReg[nPos], nVL_TUT)					//05 - VL_TUT
	aAdd (aReg[nPos], nVL_SLD)					//06 - VL_SLD  
	//
	GrvRegSef (cAlias,, aReg)    
	//   
Return (lRet) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |Reg8255   ³ Autor ³Sueli C. Santos        ³ Data ³08.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³        8255 - PRODEPE IMPORTACAO (CREDITO PRESUMIDO)       ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef com as informacoe contidas no array    ³±±
±±³          ³ aRegE310.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³8250 - 4(varios por periodo)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlias -> Alias do TRB para gravacao.                       ³±±
±±³          |aRegE310 -> Array contendo as informacoes por CFOP para     ³±±
±±³          ³ utilizacao.                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
Static Function Reg8255 (cAlias, cAliasSFT, aReg8255)
	Local	lRet	:=	.T.
	Local	nPos	:=	0
	Local	nX		:=	0   
	Local   aProdep := {}
		
	Local cTabApu	:= Left(AllTrim(SuperGetMv("MV_SEF02")),2)		//Tabela de Apuracao PRODEPE cadastrada pelo Cliente no SX5
	
	aProdep := Prodep((cAliasSFT)->FT_PRODUTO,cAliasSFT)

	aAdd(aReg8255, {})
	nPos	:=	Len (aReg8255)
	aAdd (aReg8255[nPos], "8255")	   									//01 - REG
	aAdd (aReg8255[nPos], 0)   											//02 - Importações não-incentivadas de itens incentivados 
	aAdd (aReg8255[nPos], 0)											//03 - Importações incentivadas de itens incentivados  
	aAdd (aReg8255[nPos], 0)											//04 - ICMS - importações não-incentivadas de itens incentivados 
	aAdd (aReg8255[nPos], 0)                                           //05 - ICMS - importações incentivadas de itens incentivados 
	aAdd (aReg8255[nPos], 0)                                           //06 - Crédito presumido
	aAdd (aReg8255[nPos], 0)                                           //07 - ICMS a recolher relativo ás importações incentivadas de itens incentivados 

Return (lRet)                   

*/
                     
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |Reg8270   ³ Autor ³Sueli C. Santos        ³ Data ³08.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³        TOTALIZACAO DOS VALORES DE ENTRADAS E SAIDAS        ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef com as informacoe contidas no array    ³±±
±±³          ³ aRegE310.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³8270 - 3(varios por periodo)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlias -> Alias do TRB para gravacao.                       ³±±
±±³          |aRegE310 -> Array contendo as informacoes por CFOP para     ³±±
±±³          ³ utilizacao.                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   

/*
Static Function Reg8270 (cAlias, aReg8270)
	Local	lRet	:=	.T.
	Local	nPos	:=	0
	Local	aReg	:=	{}
	Local	nX		:=	0
	//

	aAdd(aReg8270, {})
	nPos	:=	Len (aReg8270)
	aAdd (aReg8270[nPos], "8270")	   				//01 - REG
	aAdd (aReg8270[nPos], 0)						//02 - Entradas (percentual de incentivo)
	aAdd (aReg8270[nPos], 0)						//03 - Entradas não-incentivadas de itens incentivados
	aAdd (aReg8270[nPos], 0)						//04 - Entradas incentivadas de itens incentivados 
	aAdd (aReg8270[nPos], 0)	   					//05 - Saídas (percentual de incentivo)		
	aAdd (aReg8270[nPos], 0)						//06 - Saídas não-incentivadas de itens incentivados 
	aAdd (aReg8270[nPos], 0)						//07 - Saídas incentivadas de itens incentivados 
	aAdd (aReg8270[nPos], 0)						//08 - Saldo devedor do ICMS antes das deduções do Prodepe - produtos com e sem incentivo
	aAdd (aReg8270[nPos], 0)						//09 - Crédito presumido nas entradas incentivadas de itens incentivados 
	aAdd (aReg8270[nPos], 0)						//10 - Crédito presumido nas saídas incentivadas de itens incentivados 
	aAdd (aReg8270[nPos], 0)						//11 - Total de incentivos Prodepe
	aAdd (aReg8270[nPos], 0)						//12 - Saldo devedor do ICMS após deduções do Prodepe
	aAdd (aReg8270[nPos], 0)						//13 - Indice
	aAdd (aReg8270[nPos], 0)						//14 - Valor do frete CIF		
	aAdd (aReg8270[nPos], 0)						//15 - Valor do frete FOB	

	GrvRegSef (cAlias,, aReg8270)
Return (lRet)

*/                     

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Reg8300   ³ Autor ³Sueli C. Santos        ³ Data ³16.06.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³            INFORMACOES COMPLEMENTARES                      ³±±
±±³          ³            QUADRO DE AQUISIÇÃO DE BENS                     ³±±
±±³          ³                                                            ³±±
±±³          ³- Gravacao dos Registros 8200                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2(varios por arquivo)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias -> Alias do TRB que recebera as informacoes          ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*Static Function Reg8300 (cAlias, dDataDe, dDataAte, aWizard)
	Local	lRet		:=	.T.
	Local	nPos		:=	0
	Local   aReg        := {}
	//
	
		aAdd (aReg, {})
		nPos	:=	Len (aReg)
		aAdd (aReg[nPos], "8300")								//01 - REG
		aAdd (aReg[nPos], "1")                                 //02 - IND_QCC
		aAdd (aReg[nPos], dDataDe)								//02 - DT_INI
		aAdd (aReg[nPos], dDataAte)								//03 - DT_FIN
	
	//
	GrvRegSef (cAlias,, aReg)
Return (lRet)*/        

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Reg8500   ³ Autor ³Beatriz Scarpa Vilar   ³ Data ³11.07.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³  GUIA DE APURACAO DOS INCENTIVOS FISCAIS E FINANCEIROS     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2(1/Periodo)                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Reg8500(cAlias,dDataDe, dDataAte, aWizard)

	Local	aReg		:=	{}
	

		aAdd(aReg, {})
		nPos	:=	Len (aReg)
		aAdd (aReg[nPos], "8500")									//01 - LIN
		aAdd (aReg[nPos], SubStr(aWizard[6][4],1,1))				//02 - IND_GIAF
		aAdd (aReg[nPos], dDataDe)								   	//03 - DT_INI
		aAdd (aReg[nPos], dDataAte)								   	//04 - DT_FIN


GrvRegSef (cAlias,, aReg)

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Reg8545   ³ Autor ³Beatriz Scarpa Vilar   ³ Data ³11.07.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³               APURACAO INCENTIVADA                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3(1/sub-apuracao)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Reg8545(cAlias,aWizard,cPosApLV,aReg8545)
Local aReg := {}
	If aScan(aReg8545, {|x| x[3]==cPosApLV})==0
		aAdd(aReg, {})
		nPos	:=	Len (aReg)
		aAdd (aReg[nPos], "8545")									//01 - LIN
		aAdd (aReg[nPos], "PE001")									//02 - COD_BF_ICMS
		aAdd (aReg[nPos], cPosApLV)									//03 - IND_AP
		aAdd (aReg[nPos], "")										//04 - IND_ESP
	
		GrvRegSef (cAlias,Val(cPosApLV), aReg)
		
		aAdd( aReg8545, aClone(aReg[nPos]))
	EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Reg8570   ³ Autor ³Beatriz Scarpa Vilar   ³ Data ³11.07.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³            PRODEPE INDUSTRIA (CREDITO PRESUMIDO)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³4(1/sub-apuração)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Reg8570 (cAlias,dDataDe, dDataAte,aReg8555,aWizard,cPosApLV,cNrLvSub, aReg8570,aProAPFil,cAliasSFT,cSituaDoc)
	
	Static nVlUlAl 	:= 0
	Local	aReg		:=	{}
	Local	nPos		:=	0 
	Local	nApuracao	:=	GetSx1 (PadR("MTA951",10), "04", .T.)
	Local	nPeriodo	:=	1
	Local	nVL_02		:=	0
	Local	nVL_03		:=	0
	Local	nVL_04		:=	0
	Local	nVL_05		:=	0
	Local	nVL_06		:=	0
	Local	nVL_07		:=	0
	Local	nVL_08		:=	0
	Local	nVL_09		:=	0
	Local	nVL_10		:=	0
	Local	nVL_11		:=	0
		
	Default aProAPFil := {}
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Fixo que o periodo de geracao podera ser somente Mensal ou Anual.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nApuracao==1) .Or. (nApuracao==2)
		nApuracao	:=	3
	ElseIf (nApuracao==4)
		nApuracao	:=	5
	EndIf
	
	If aBloco8[6] > 0
		nVlUlAl := aBloco8[6]
	Endif 
	
	If (cAliasSFT)->FT_TIPOMOV == "S" .And. Val(Substr((cAliasSFT)->FT_CFOP,1,1)) >= 5	
    	If (cAliasSFT)->FT_TPPRODE $ '0# ' 
    		If !(cSituaDoc$"90#81#")	
				nVL_02	 := (cAliasSFT)->FT_VALCONT //Saidas nao incentivadas de PI
			Endif
		Endif
	Endif
	
	nVL_03	:=	aBloco8[3]
	nVL_04	:=	aBloco8[2]
	
	If (nPos := aScan(aProAPFil, {|x| x[1]==cNrLvSub}))>0
		
		nVL_05	:=	Iif (aScan (aProAPFil[nPos][2], {|a| a[1]=="011"})<>0, aProAPFil[nPos][2][aScan (aProAPFil[nPos][2], {|a| a[1]=="011"})][3], 0) - nVL_02
		nVL_06	:=	nVL_05		
		nVL_07	:=	Iif (aScan (aProAPFil[nPos][2], {|a| a[4]=="012.03"})<>0, aProAPFil[nPos][2][aScan (aProAPFil[nPos][2], {|a| a[4]=="012.03"})][3], 0)
		nVL_08	:=	nVL_06 - nVL_07 
		nVL_09	:=	Iif (aScan (aProAPFil[nPos][2], {|a| a[4]=="012.01"})<>0, aProAPFil[nPos][2][aScan (aProAPFil[nPos][2], {|a| a[4]=="012.01"})][3], 0)
		nVL_10	:=	nVL_07 + nVL_09
		If nVL_05 > nVL_10 					// Verifico este valor pois se não tiver valor suficiente de saldo devedor contém 0 Zero	
			nVL_11	:=	nVL_05 - nVL_10
		Endif

	Endif 
	
	If (nPos := aScan(aReg8570, {|x| x[1]==cPosApLV}))==0
		aAdd(aReg8570, {})
		nPos	:=	Len (aReg8570)
		aAdd (aReg8570[nPos], cPosApLV)
		aAdd (aReg8570[nPos], "8570")									//01 - LIN
		aAdd (aReg8570[nPos], nVlUlAl)			//02 - G1_01
		aAdd (aReg8570[nPos], nVL_02)								   	//03 - G1_02
		aAdd (aReg8570[nPos], nVL_03)								   	//04 - G1_03
		aAdd (aReg8570[nPos], nVL_04)									//05 - G1_04
		aAdd (aReg8570[nPos], nVL_05)   								//06 - G1_05                    
		aAdd (aReg8570[nPos], nVL_06)									//07 - G1_06
		aAdd (aReg8570[nPos], nVL_07)									//08 - G1_07
		aAdd (aReg8570[nPos], nVL_08)									//09 - G1_08
		aAdd (aReg8570[nPos], nVL_09)									//10 - G1_09	
		aAdd (aReg8570[nPos], nVL_10)			            			//11 - G1_10	
		aAdd (aReg8570[nPos], nVL_11)									//12 - G1_11
	Else
		aReg8570[nPos][3] := nVlUlAl		//02 - G1_01
		aReg8570[nPos][4] += nVL_02								   	//03 - G1_02
		aReg8570[nPos][5] += nVL_03								   	//04 - G1_03
		aReg8570[nPos][6] += nVL_04									//05 - G1_04	
	Endif
	
Return .T. 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Reg8590   ³ Autor ³Beatriz Scarpa Vilar   ³ Data ³11.07.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³   PRODEPE CENTRAL DE DISTRIBUICAO (ENTRADAS/SAIDAS)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³4(1/sub-apuração)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³														      ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Reg8590 (cAlias,dDataDe, dDataAte,aWizard, cPosApLV,cNrLvSub, aReg8590,cAliasSFT)
	
	Local	aReg		:=	{}
	Local	nPos		:=	0
	Local	nApuracao	:=	GetSx1 (PadR("MTA951",10), "04", .T.)
	Local	nPeriodo	:=	1
	Local	nVL_01		:=	3
	Local	nVL_02		:=	0
	Local	nVL_03		:=	0
	Local	nVL_04		:=	3
	Local	nVL_05		:=	0
	Local	nVL_06		:=	0
	Local	nVL_07		:=	0
	Local	nVL_08		:=	0
	Local	nVL_09		:=	0
	Local	nVL_10		:=	0
	Local	nVL_11		:=	0 
	Local	nVL_12		:=	0
	Local	nVL_13		:=	0//nFreteCIF - Este tipo de benefício foi revogado. Este campo não deve ser preenchido.
	Local	nVL_14		:=	0//nFreteFOB - Este tipo de benefício foi revogado. Este campo não deve ser preenchido.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Fixo que o periodo de geracao podera ser somente Mensal ou Anual.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nApuracao==1) .Or. (nApuracao==2)
		nApuracao	:=	3
	ElseIf (nApuracao==4)
		nApuracao	:=	5
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Leio o arquivo de apuracao ICMS³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aApICM	:=	FisApur ("IC", Year (dDataAte), Month (dDataAte), nApuracao, nPeriodo, cNrLvSub, .F., {}, 1, .F., "")
	
	//validação:D- Este campo deve ser igual a 3% (no caso de a legislação permitir incremento de até '1%', o percentual não pode ultrapassar 4%).
	IF (cAliasSFT)->FT_TPPRODE == '4' // 4=Dist-Crd.Pres Entrada
		nVL_01	:=  Iif(aBloco8[6] <= 3,3,aBloco8[6]) // Percentual do incentivo		
	Else
		nVL_04 	:=	Iif(aBloco8[6] <= 3,3,aBloco8[6]) // Percentual do incentivo
	Endif
	
	nVL_02	:=  aBloco8[4]
	nVL_03	:=	aBloco8[5]	
	nVL_05	:= 	aBloco8[1]
	nVL_06	:=	aBloco8[3]		
	nVL_07	:=	Iif (aScan (aApICM, {|a| a[1]=="011"})<>0, aApICM[aScan (aApICM, {|a| a[1]=="011"})][3], 0)
	nVL_08	:=	Iif (aScan (aApICM, {|a| a[4]=="012.04"})<>0, aApICM[aScan (aApICM, {|a| a[4]=="012.04"})][3], 0)
	nVL_09	:=	Iif (aScan (aApICM, {|a| a[4]=="012.05"})<>0, aApICM[aScan (aApICM, {|a| a[4]=="012.05"})][3], 0)
	nVL_10	:=	Iif(nVL_07-(nVL_08 + nVL_09) < 0, 0,nVL_08 + nVL_09)
	nVL_11	:=	Iif((nVL_07 - nVL_10) < 0, 0, nVL_07 - nVL_10)
	
	If (nPos := aScan(aReg8590, {|x| x[1]==cPosApLV}))==0
		aAdd(aReg8590, {})
		nPos	:=	Len (aReg8590)
		aAdd (aReg8590[nPos], cPosApLV)
		aAdd (aReg8590[nPos], "8590")	//01 - LIN
		aAdd (aReg8590[nPos], nVL_01)	//02 - G4_01 - Entradas (percentual de incentivo) 
		aAdd (aReg8590[nPos], nVL_02)	//03 - G4_02 - Entradas não incentivadas de PI
		aAdd (aReg8590[nPos], nVL_03)	//04 - G4_03 - Entradas incentivadas de PI 
		aAdd (aReg8590[nPos], nVL_04)	//05 - G4_04 - Saídas (percentual de incentivo)
		aAdd (aReg8590[nPos], nVL_05)   //06 - G4_05 - Saídas não incentivadas de PI 
		aAdd (aReg8590[nPos], nVL_06)	//07 - G4_06 - Saídas incentivadas de PI 
		aAdd (aReg8590[nPos], nVL_07)	//08 - G4_07 - Saldo devedor do ICMS antes das deduções do Prodepe (PI e itens não incentivados) 
		aAdd (aReg8590[nPos], nVL_08)	//09 - G4_08 - Crédito presumido nas entradas incentivadas de PI 
		aAdd (aReg8590[nPos], nVL_09)	//10 - G4_09 - Crédito presumido nas saídas incentivadas de PI
		aAdd (aReg8590[nPos], nVL_10)	//11 - G4_10 - Dedução de incentivo do Prodepe Central de Distribuição (entradas/saídas)(nVL_08+nVL_09)
		aAdd (aReg8590[nPos], nVL_11)	//12 - G4_11 - Saldo devedor do ICMS após deduções do Prodepe
		aAdd (aReg8590[nPos], nVL_12)	//13 - G4_12 - Índice de recolhimento da central de distribuição 
		aAdd (aReg8590[nPos], nVL_13)	//14 - G4_13 - Valor do frete CIF
		aAdd (aReg8590[nPos], nVL_14)	//15 - G4_14 - Valor do frete FOB 
	Else
		//Atualiza percentual incentivo para entrada ou saída
		IF aBloco8[6] > 0
			IF (cAliasSFT)->FT_TPPRODE == '4' // 4=Dist-Crd.Pres Entrada
				aReg8590[nPos][3] := nVL_01 //02 - G4_01 - Entradas (percentual de incentivo)
			Else
				aReg8590[nPos][6] := nVL_04 //05 - G4_04 - Saídas (percentual de incentivo)
			Endif			
		Endif
		aReg8590[nPos][4] += nVL_02	//03 - G4_02 - Entradas não incentivadas de PI
		aReg8590[nPos][5] += nVL_03	//04 - G4_03 - Entradas incentivadas de PI
		aReg8590[nPos][7] += nVL_05	//06 - G4_05 - Saídas não incentivadas de PI
		aReg8590[nPos][8] += nVL_06	//07 - G4_06 - Saídas incentivadas de PI 		
	Endif
Return .T.   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Reg9900   ³ Autor ³Liber de Esteban       ³ Data ³20.08.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³                  REGISTROS DO ARQUIVO                      ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro 9900                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2(varios por arquivo)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias   -> Alias do TRB que recebera as informacoes        ³±±
±±³          ³aReg9900 -> Array com informacoes que serao gravadas no TRB ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Reg9900 (cAlias, aReg9900)
	Local	lRet	:=	.T.
	//
	GrvRegSef (cAlias,,aReg9900,)
Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Reg9999   ³ Autor ³Liber de Esteban       ³ Data ³20.08.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³              ENCERRAMENTO DO ARQUIVO DIGITAL               ³±±
±±³          ³                                                            ³±±
±±³          ³- Geracao e gravacao do Registro 9999                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao GrvRegSef.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³0(um por arquivo)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias   -> Alias do TRB que recebera as informacoes        ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Reg9999 (cAlias)
	Local	lRet	:=	.T.
	Local	nPos	:=	0
	Local	aReg	:= {}
	//
	aAdd(aReg, {})
	nPos	:=	Len (aReg)
	nTotLin := (cAlias)->(RecCount()) + 1
	aAdd (aReg[nPos], "9999")					//01 - REG
	aAdd (aReg[nPos], Alltrim(STR(nTotLin)))	//02 - QTD_LIN
	GrvRegSef (cAlias,,aReg,)
	//
Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |BlAbEnc   ³ Autor ³Gustavo G. Rueda       ³ Data ³25.08.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³       GRAVACAO DO INDICADOR DE BLOCO COM MOVIMENTO         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Funcao de gravacao do indicador de bloco com movimento(0) ou³±±
±±³          ³ sem movimento(1) conforme passagem de parametros. Utilizado³±±
±±³          ³ na funcao GrvIndMov.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAbEnt -> Indicador de Bloco de Abertura (A) ou Encerramento³±±
±±³          ³ (E).                                                       ³±±
±±³          ³cAlias -> Alias do TRB onde sera gravado as informacoes.    ³±±
±±³          ³cReg -> Codigo do registro                                  ³±±
±±³          ³cIndMov -> Indicador de movimento (0=Sim, 1=Nao)            ³±±
±±³          ³nQtdLin -> Quantidade de linha do registro                  ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static function BlAbEnc (cAbEnc, cAlias, cReg, cIndMov, nQtdLin)
	Local	lRet		:=	.T.
	Local	aBlAbEnc	:=	{}
	//
	aAdd(aBlAbEnc, {})
	nPos	:=	Len (aBlAbEnc)
	//
	If ("A"$cAbEnc)
		aAdd (aBlAbEnc[nPos], cReg)
		aAdd (aBlAbEnc[nPos], cIndMov)
		//
		If (Left (cReg, 1)$"A#B")
			aAdd (aBlAbEnc[nPos], AllTrim (SM0->M0_CODMUN))
		ElseIf (Left (cReg, 1)$"8")
			aAdd (aBlAbEnc[nPos], AllTrim (SM0->M0_ESTENT))
		EndIf
	Else
		aAdd (aBlAbEnc[nPos], cReg)
		aAdd (aBlAbEnc[nPos], Alltrim(STR(nQtdLin+2)))	// O +2 eh para somar o registro de abertura mais o registro de encerramento
	EndIf
	//
	GrvRegSef (cAlias,,aBlAbEnc,)
Return (lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |InfPartDoc³ Autor ³Gustavo G. Rueda       ³ Data ³25.08.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³       ATRIBUICAO DOS DADOS DO PARTICIPANTE NO ARRAY        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Funcao que retorna um array com as informacoes necessarias  ³±±
±±³          ³ do participante do documento fiscal.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aA1A2 -> Array com as informacoes do participante da docto  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlsSA -> Alias da tabela SA1 ou SA2.                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function InfPartDoc (cAlsSA, lSm0,cAliasSFT)
	Local	aA1A2		:=	{}
	Local	cA1A2		:=	SubStr (cAlsSA, 3, 1)
	Local	cCodMun		:=	""
	Local	cCmpCod		:=	cAlsSA+"->A"+cA1A2+"_COD"
	Local	cCmpLoja	:=	cAlsSA+"->A"+cA1A2+"_LOJA"
	Local	cCmpNome	:=	cAlsSA+"->A"+cA1A2+"_NOME"
	Local	cCmpTipo	:=	cAlsSA+"->A"+cA1A2+Iif ("2"$cA1A2, "_TIPO", "_PESSOA")
	Local	cCmpCgc		:=	cAlsSA+"->A"+cA1A2+"_CGC"
	Local	cCmpEst		:=	cAlsSA+"->A"+cA1A2+"_EST"
	Local	cCmpInsc	:=	cAlsSA+"->A"+cA1A2+"_INSCR"
	Local	cCmpCodM	:=	cAlsSA+"->A"+cA1A2+"_COD_MUN"
	Local	cCmpInscM	:=	cAlsSA+"->A"+cA1A2+"_INSCRM"
	Local	cCmpCep		:=	cAlsSA+"->A"+cA1A2+"_CEP"
	Local	cCmpEnd		:=	cAlsSA+"->A"+cA1A2+"_END"
	Local	cCmpBairro	:=	cAlsSA+"->A"+cA1A2+"_BAIRRO"
	Local	cCmpCxPost	:=	cAlsSA+"->A"+cA1A2+Iif ("2"$cA1A2, "_CX_POST", "_CXPOSTA")
	Local	cCmpTel		:=	cAlsSA+"->A"+cA1A2+"_TEL"
	Local	cCmpFax		:=	cAlsSA+"->A"+cA1A2+"_FAX" 
    Local	cCmpCdPais	:=	cAlsSA+"->A"+cA1A2+"_CODPAIS"
	Local   aArea       :=  {}
	Local   aEnd        :=  {}                             
	
	//
	Default	lSm0	  := .F.    
	Default cAliasSFT := ""
	//
	If lSm0
		aAdd (aA1A2, "SM0"+SM0->(M0_CODIGO+M0_CODFIL))			 							//01	-	COD_PART
		aAdd (aA1A2, SM0->M0_NOME)															//02	-	NOME
		aAdd (aA1A2, "01058")	 															//03	-	COD_PAIS
		//Se pessoa Juridica armazeno o CNPJ no sua devida posicao
		If Len (AllTrim (SM0->M0_CGC))>=14
			aAdd (aA1A2, AllTrim (SM0->M0_CGC))										 		//04	-	CNPJ
			aAdd (aA1A2, "")																//05	-	CPF
		//Se pessoa Fisica armazeno o CPF no sua devida posicao
		ElseIf Len (AllTrim (SM0->M0_CGC))<14
			aAdd (aA1A2, "")																//04	-	CNPJ
			aAdd (aA1A2, AllTrim (SM0->M0_CGC))										 		//05	-	CPF
		Else
			aAdd (aA1A2, "")																//04	-	CNPJ
			aAdd (aA1A2, "")																//05	-	CPF
		EndIf
		aAdd (aA1A2, "")					 												//06	-	CEI
		aAdd (aA1A2, "")																	//07	-	NIT
		aAdd (aA1A2, SM0->M0_ESTENT)														//08	-	UF
		aAdd (aA1A2, SM0->M0_INSC)															//09	-	IE
		aAdd (aA1A2, "")																	//10	-	IE_ST
		aAdd (aA1A2, IIF( Len(SM0->M0_CODMUN) <= 5 , RetCodEst(SM0->M0_ESTENT),"") + SM0->M0_CODMUN )	//11	-	COD_MUN
		aAdd (aA1A2, SM0->M0_INSCM)															//12	-	IM
		aAdd (aA1A2, "")																	//13	-	Inscricao SUFRAMA
		//ÚÄÄÄÄÄÄÄÄ¿
		//³ENDERECO³
		//ÀÄÄÄÄÄÄÄÄÙ
		aAdd (aA1A2, SM0->M0_CEPENT)														//14	-	CEP
		aAdd (aA1A2, Substr (SM0->M0_ENDENT, 1, At(",", SM0->M0_ENDENT)-1))				//15	-	END
		aAdd (aA1A2, Substr (SM0->M0_ENDENT, At(",", SM0->M0_ENDENT)+1, Len (AllTrim (SM0->M0_ENDENT))))		//16	-	NUM
		aAdd (aA1A2, SM0->M0_COMPENT)														//17	-	COMPL
		aAdd (aA1A2, SM0->M0_BAIRENT)														//18	-	BAIRRO
		aAdd (aA1A2, "")																	//19	-	CEP_CP
		aAdd (aA1A2, "")																	//20	-	CP
		aAdd (aA1A2, SM0->M0_TEL)															//21	-	TEL
		aAdd (aA1A2, SM0->M0_FAX)															//22	-	FAX
	Else  
	    If !Empty(cAliasSFT) .AND. !Empty((cAliasSFT)-> FT_PDV )
	        aArea :=  GetArea()
			DbSelectArea("SA1")	    	                      	
			DbSetOrder(1)
			DbSeek(xFilial("SA1")+ (cAliasSFT)->FT_CLIEFOR + (cAliasSFT)->FT_LOJA)  
			RestArea(aArea)
	    EndIf
		aAdd (aA1A2, cAlsSA+cFilAnt+&(cCmpCod)+&(cCmpLoja)) 							//01	-	COD_PART
		aAdd (aA1A2, &(cCmpNome))														//02	-	NOME
		
		//se estrangeiro
        If &cCmpEst == "EX"		
			aAdd (aA1A2, &(cCmpCdPais))												    	//03	-	COD_PAIS
			aAdd (aA1A2, "")														     	//04	-	CNPJ
			aAdd (aA1A2, "")															    //05	-	CPF
			aAdd (aA1A2, "")		 												        //06	-	CEI
			aAdd (aA1A2, "")														        //07	-	NIT
			aAdd (aA1A2, "EX")				    									    	//08	-	UF
			aAdd (aA1A2, "")    										                    //09	-	IE
			aAdd (aA1A2, "")															    //10	-	IE_ST
			cCodMun := "9999999"                                                           //11	-	COD_MUN
		Else   		
    		aAdd (aA1A2, "01058")	 					    							    //03	-	COD_PAIS
			//Se pessoa Juridica armazeno o CNPJ no sua devida posicao
			If (!Empty(&(cCmpCgc)) .and. RetPessoa(&(cCmpCgc)) == "J") .OR. ("J"$(&(cCmpTipo)))
				aAdd (aA1A2, aRetDig(&(cCmpCgc),.F.))										    //04	-	CNPJ
				aAdd (aA1A2, "")															    //05	-	CPF
			//Se pessoa Fisica armazeno o CPF no sua devida posicao
			ElseIf (!Empty(&(cCmpCgc)) .and. RetPessoa(&(cCmpCgc)) == "F") .OR. ("F"$(&(cCmpTipo)))
				aAdd (aA1A2, "")															    //04	-	CNPJ
				aAdd (aA1A2, aRetDig(&(cCmpCgc),.F.))										    //05	-	CPF
			Else
				aAdd (aA1A2, "")														     	//04	-	CNPJ
				aAdd (aA1A2, "")															    //05	-	CPF
			EndIf
			aAdd (aA1A2, "")		 												        	//06	-	CEI
			aAdd (aA1A2, "")														        	//07	-	NIT
			aAdd (aA1A2, &(cCmpEst))													    	//08	-	UF
			aAdd (aA1A2, aRetDig(&(cCmpInsc),.F.))										    	//09	-	IE
			aAdd (aA1A2, "")															    	//10	-	IE_ST
			//
			IF aA1A2[03] == "01058"		// Se for Brasil
				IF Len(Alltrim(&(cCmpCodM))) <= 5		// Se nao tiver com o codigo do estado junto
					cCodMun := RetCodEst(&(cCmpEst)) + &(cCmpCodM)
				Else
					cCodMun := &(cCmpCodM)
				EndIf
			Else
				cCodMun := "0000000"
			EndIf
       EndIf
		//
		aAdd (aA1A2, cCodMun )															//11	-	COD_MUN
		aAdd (aA1A2, aRetDig(&(cCmpInscM),.F.))										//12	-	IM
		aAdd (aA1A2, "")															    //13	-	Inscricao SUFRAMA
		//ÚÄÄÄÄÄÄÄÄ¿
		//³ENDERECO³
		//ÀÄÄÄÄÄÄÄÄÙ
    	aEnd	:=	SEFGetEnd(&cCmpEnd,cAlsSA,"")		
		aAdd (aA1A2, &(cCmpCep))														//14	-	CEP
		aAdd (aA1A2, aEnd[1])		                                        			//15	-	END
		aAdd (aA1A2, Iif (!Empty(aEnd[2]),aEnd[3],"SN"))	                        	//16	-	NUM
		aAdd (aA1A2, aEnd[4])															//17	-	COMPL
		aAdd (aA1A2, &(cCmpBairro))														//18	-	BAIRRO
		aAdd (aA1A2, &(cCmpCep))														//19	-	CEP_CP
		aAdd (aA1A2, &(cCmpCxPost))														//20	-	CP
		aAdd (aA1A2, &(cCmpTel))														//21	-	TEL
		aAdd (aA1A2, &(cCmpfAX))														//22	-	FAX
	EndIf	
Return (aA1A2)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³SEFGetEnd ³ Autor ³Cecilia Carvalho              ³ Data ³23.10.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o participante e do DF, ou se tem um tipo de endereco ³±±
±±³          ³ que nao se enquadra na regra padrao de preenchimento de endereco  ³±±
±±³          ³ por exemplo: Enderecos de Area Rural (essa verificção e feita     ³±±
±±³          ³ atraves do campo ENDNOT).                                         ³±±
±±³          ³ Caso seja do DF, ou ENDNOT = 'S', somente ira retornar o campo    ³±±
±±³          ³ Endereco (sem numero ou complemento). Caso contrario ira retornar ³±±
±±³          ³ o padrao do FisGetEnd                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Obs.     ³ Esta funcao so pode ser usada quando ha um posicionamento de      ³±±
±±³          ³ registro, pois será verificado o ENDNOT do registro corrente      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS                                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SEFGetEnd(cEndereco,cAlias,cAlsQry)

Local cCmpEndN	:= SubStr(cAlias,2,2)+"_ENDNOT"
Local cCmpEst	:= SubStr(cAlias,2,2)+"_EST"
Local aRet		:= {"",0,"",""}

Default	cAlsQry	:=	""

//Tratamento para quando os campos base estiverem no select
If Empty(cAlsQry)
	cAlsQry	:=	cAlias
EndIf

//Campo ENDNOT indica que endereco participante mao esta no formato <logradouro>, <numero> <complemento>
//Se tiver com 'S' somente o campo de logradouro sera atualizado (numero sera SN)
If (&(cAlsQry+"->"+cCmpEst) == "DF") .Or. ((cAlias)->(FieldPos(cCmpEndN)) > 0 .And. &(cAlsQry+"->"+cCmpEndN) == "1")
	aRet[1] := cEndereco
	aRet[3] := "SN"
Else
	aRet := FisGetEnd(cEndereco,&(cAlsQry+"->"+cCmpEst))
EndIf
Return aRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |MontWiz   ³ Autor ³Sueli C. Santos        ³ Data ³25.08.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³                    MONTAGEM DO WIZARD                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Funcao que monta o Wizard em tela para processamento.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T. se o wizard foi finalizado com sucesso ou .F. se³±±
±±³          ³ foi cancelado.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MontWiz (cNomWiz)
	Local	aTxtApre	:=	{}
	Local	aPaineis	:=	{}
	Local	aItens1		:=	{}
	Local	aItens2		:=	{}
	Local	cTitObj1	:=	""
	Local	cTitObj2	:=	""
	Local	lRet		:=	.T.
	Local   nTamLoc		:= TamSx3("B1_LOCPAD")[1]

	//
	aAdd (aTxtApre, STR0004) //"Parametros necessarios."
	aAdd (aTxtApre, "")	
	aAdd (aTxtApre, STR0005) //"Preencha corretamente as informacoes solicitadas."
	aAdd (aTxtApre, STR0006) //"Informacoes necessarias para a geração do meio-magnético que trata o ATO COTEPE N. 35/05, DE 17 DE JUNHO DE 2005."
	//ÚÄÄÄÄÄÄÄÄ¿
	//³Painel 0³
	//ÀÄÄÄÄÄÄÄÄÙ	
	aAdd (aPaineis, {})
	nPos	:=	Len (aPaineis)
	aAdd (aPaineis[nPos], STR0005) //"Preencha corretamente as informacoes solicitadas."
	aAdd (aPaineis[nPos], STR0007) //"Parametros para Geração"
	aAdd (aPaineis[nPos], {})	
	//
	cTitObj1	:=	STR0008;								   			cTitObj2	:=	STR0009 //"Data de"###"Data até"		
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
	aAdd (aPaineis[nPos][3], {2,,,3,,,,});							aAdd (aPaineis[nPos][3], {2,,,3,,,,}) 
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
    //
	cTitObj1	:=	STR0130;                                             cTitObj2	:=	STR0131 //"Armazem De"##"Armazem Até"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd(aPaineis[nPos][3], {1, cTitObj2,,,,,,})	
	cTitObj1	:=	Replicate ("X", nTamLoc);							cTitObj2	:=	Replicate ("X", nTamLoc)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,nTamLoc});			aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,nTamLoc})	
	aAdd(aPaineis[nPos][3], {0,"",,,,,,});							aAdd(aPaineis[nPos][3], {0,"",,,,,,})  
	//
	cTitObj1	:=	STR0010;                                             cTitObj2	:=	STR0011 //"Livro"##Diretorio
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})	
	cTitObj1	:=	Replicate ("X", 50);							cTitObj2	:=	Replicate ("X", 20)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});				aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,20})	
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})  
    //
    aItens1	:=	{}
	aAdd (aItens1, STR0100)//LA-ICMS / GIAM-GIA-ICMS	
    aAdd (aItens1, STR0101)//e-Doc - Extrato
	aAdd (aItens1, STR0102)//RI - Registro de Inventário    
	aAdd (aItens1, STR0132)//PRODEPE      
    
    cTitObj1	:=	STR0012;  										cTitObj2	:=	STR0099	  //""###"Nome do Arquivo Destino"###Escolha arquivo a ser gerado
    aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
    cTitObj1	:=	Replicate ("X", 50);							cTitObj2	:=	Replicate ("X", 50)    
    aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});                aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,}) 
    aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})  
    //
    aItens1	:=	{}
   	aItens2 	:=	{}
	aAdd (aItens1, STR0083);/*0- Levantado...coincidente com a data do balanço*/ 	aAdd (aItens2, STR0117) //"0-Sim"
	aAdd (aItens1, STR0084);/*1- Levantado...divergente da data do balanço*/			aAdd (aItens2, STR0118) //"1-Não" 
	aAdd (aItens1, STR0085)/*2- Levantado...divergente do último dia do ano civil*/
	aAdd (aItens1, STR0086)/*3- Levantado...ultimo dia do ano civil*/
   
	cTitObj1 :=	STR0056;/*"Simples Nacional"##Opçoes para inventário*/		cTitObj2 :=	STR0126 	/*Seleciona Filiais*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});							aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,});							aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});									aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	cTitObj1	:=	STR0128; /*"Gera o registro C020?(Entr de Devolução)"*/	cTitObj2 :=	STR0129;/*"Aglutina Seleção por CNPJ + I.E. ?*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});			   				aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
	aItens1	:=	{};															aItens2	:= {}
	aAdd (aItens1, STR0118);												aAdd (aItens2, STR0118)
	aAdd (aItens1, STR0117);												aAdd (aItens2, STR0117)
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,}); 						aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})	;							aAdd (aPaineis[nPos][3], {0,"",,,,,,})	
		//"Indicador da data do Inventário" 	    
	cTitObj1	:=	"Data Inventário"	;								cTitObj2	:=	"Nome arq. Gerado no Reg. Inv. Mod.P7"	
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})	;				aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})				
	aAdd (aPaineis[nPos][3], {2,,,3,,,,}) ;						aAdd (aPaineis[nPos][3], {2,,'',1,,,,20})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})	;						aAdd (aPaineis[nPos][3], {0,"",,,,,,})				

	aItens1	:=	{}
   	aItens2 	:=	{}
	aAdd (aItens1, '1-Sim');											aAdd (aItens2, '0-Não')
	aAdd (aItens1, '2-Não');											aAdd (aItens2, '1-Sim')								 
	aAdd (aItens1, '3-De Terc.')
	aAdd (aItens1, '4-Em Terc.')

	cTitObj1	:=	"Considera o Saldo de Estoque";	cTitObj2	:=	"Considera Saldo em Processo ? "
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});				aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {1,"De / Em Terceiros ?",,,,,,});	aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,});					aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	cTitObj1	:=	"Considera o Saldo Negativo?";					cTitObj2	:=""
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});				aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {1, "",,,,,,});						aAdd (aPaineis[nPos][3], {1,"",,,,,,})

	//ÚÄÄÄÄÄÄÄÄ¿
	//³Painel 1³
	//ÀÄÄÄÄÄÄÄÄÙ	
	aAdd (aPaineis, {})
	nPos	:=	Len (aPaineis)
	aAdd (aPaineis[nPos], STR0005) //"Preencha corretamente as informacoes solicitadas."
	aAdd (aPaineis[nPos], STR0013) //"Identificação do Contribuinte"
	aAdd (aPaineis[nPos], {})
	//
	cTitObj1	:=	STR0014;		   									cTitObj2	:=	STR0015 //"Codigo da Finalidade do Arquivo"###"Código do Conteudo do Arquivo"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
	
	aItens1	:=	{}
	aItens2	:=	{}
	aAdd (aItens1, STR0016);											aAdd (aItens2, STR0019) //"00-Remessa regularde arquivo"###"20-Livros fiscais de apuração"
	aAdd (aItens1, STR0017);											aAdd (aItens2, STR0020) //"01-Remessa de arquivo substituto"###"21-Livros fiscais, mapas e documentos de controle"
	aAdd (aItens1, STR0018);											aAdd (aItens2, STR0021) //"02-Rem. de arquivo com dados adicionais"###"30-Guias de informações econômico-fiscais e declarações"
																		aAdd (aItens2, STR0103)
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,});						aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	cTitObj1	:=	STR0022 //"Código de Qualificacao do Assinante"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
    aItens1	:=	{}
	aAdd (aItens1, "203-Diretor")	
    aAdd (aItens1, "204-Conselheiro administrativo")
	aAdd (aItens1, "205-Administrador")
	aAdd (aItens1, "206- Administrador de grupo")
	aAdd (aItens1, "207- Administrador de sociedade filiada	")
	aAdd (aItens1, "220- Administrador judicial – pessoa física")
	aAdd (aItens1, "222- Administrador judicial – pessoa jurídica")
	aAdd (aItens1, "223- Administrador judicial/gestor")
	aAdd (aItens1, "226-Gestor judicial")
	aAdd (aItens1, "309-Procurador")
	aAdd (aItens1, "312-Inventariante")
	aAdd (aItens1, "313-Liquidante")
	aAdd (aItens1, "315-Interventor")
	aAdd (aItens1, "801-Empresário")
	aAdd (aItens1, "900-Contador")
	aAdd (aItens1, "999-Outros")
   
	//cTitObj1	:=	Replicate ("X", 3)
	//aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,3});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
    aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,});                      aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	cTitObj1	:=	STR0032 //"INFORMAÇÕES CADASTRAIS"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	
	cTitObj1	:=	STR0081; 											cTitObj2	:=	STR0082  //Nome Responsavel###"Código do Conteudo do Arquivo"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
	
	cTitObj1	:=	Replicate ("X", 50) ; 								cTitObj2	:=	Replicate ("X", 11) 
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});					aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,50}) 
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	cTitObj1	:=	STR0033 //"E-Mail"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	cTitObj1	:=	Replicate ("X", 50)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});					aAdd (aPaineis[nPos][3], {1,"",,,,,,})
	aAdd (aPaineis[nPos][3], {1,"",,,,,,});							aAdd (aPaineis[nPos][3], {1,"",,,,,,})

	//ÚÄÄÄÄÄÄÄÄ¿
	//³Painel 2³
	//ÀÄÄÄÄÄÄÄÄÙ	
	aAdd (aPaineis, {})
	nPos	:=	Len (aPaineis)
	aAdd (aPaineis[nPos], STR0005) //"Preencha corretamente as informacoes solicitadas."
	aAdd (aPaineis[nPos], STR0080) //"Perfil do Contribuinte"
	aAdd (aPaineis[nPos], {})
	//
	cTitObj1	:=	STR0023;		   								cTitObj2	:=	STR0024 //"Indicador de Entrada de Dados"###"Indicador de conteudo do Arquivo"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})	
	aItens1	:=	{}
	aItens2	:=	{}
	aAdd (aItens1, STR0061);										aAdd (aItens2, STR0064) 
	aAdd (aItens1, STR0062);										aAdd (aItens2, STR0065) 
	aAdd (aItens1, STR0063);										aAdd (aItens2, STR0066) 
 																	aAdd (aItens2, STR0067)
																	aAdd (aItens2, STR0068)
																	aAdd (aItens2, STR0069)
																	aAdd (aItens2, STR0070)		
																	aAdd (aItens2, STR0114)
																	aAdd (aItens2, STR0115)
																	aAdd (aItens2, STR0116)											
	
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,});					aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
    //
     
	//
	cTitObj1	:=	STR0025;		   								cTitObj2	:=	STR0026//Ind.Exigibilidade da escrituração do ISS###Ind.Exigibilidade da escrituração do ICMS 
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})    
	aItens1	:=	{}
	aItens2	:=	{}
	aAdd (aItens1, STR0105);										aAdd (aItens2, STR0105) //"0-Sim, c/ regime simplificado"
	aAdd (aItens1, STR0107);										aAdd (aItens2, STR0106) //"1-Sim, c/ regime intermediario"    
    aAdd (aItens1, STR0108);                                        aAdd (aItens2, STR0107) //"2-Sim, c/ regime integral"
                                                                    aAdd (aItens2, STR0108) //"9-Nao obrigado a escriturar"
 	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,});					aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//
    
    //
	cTitObj1	:=	STR0057;		   								cTitObj2	:=	STR0058  //ind de exigibilidade do reg de impr de doc fiscais###ind de exigib do reg de utiliz de doc fiscais
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})    
	aItens1	:=	{}
	aItens2	:=	{}
	aAdd (aItens1, STR0117);										aAdd (aItens2, STR0117) //"0-Sim "
	aAdd (aItens1, STR0118);										aAdd (aItens2, STR0118) //"1-Não"    
 	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,});					aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
    //

	//
	cTitObj1	:=	STR0059;		   					   			cTitObj2	:=	STR0060  //ind de exig. livro de movim. de combustiveis###ind de exigib do registro de veiculos
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})    
	aItens1	:=	{}
	aItens2	:=	{}
	aAdd (aItens1, STR0117);										aAdd (aItens2, STR0117) //"0-Sim "
	aAdd (aItens1, STR0118);										aAdd (aItens2, STR0118) //"1-Não"    
 	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,});					aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
    //
      
	//
	cTitObj1	:=	STR0031;		   								cTitObj2	:=	STR0030  //ind de exigibilidade do registro de inventario###indicador da escrituração contábil
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})    
	aItens1	:=	{}
	aItens2	:=	{}
	aAdd (aItens1, STR0117);										aAdd (aItens2, STR0073) //"0"
	aAdd (aItens1, STR0118);										aAdd (aItens2, STR0074) //"1"
	                                                                aAdd (aItens2, STR0075) //"2"
	                                                                aAdd (aItens2, STR0076) //"3"
	                                                                aAdd (aItens2, STR0077) //"4"
	                                                                aAdd (aItens2, STR0078) //"5"
	                                                                aAdd (aItens2, STR0079) //"9"
 	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,});					aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
    // 
   
	//
	cTitObj1	:=	STR0109;		   								cTitObj2	:=	STR0110 // Ind.oper.sujeita ao ISS###Ind. Oper suj a retencao substituicao tributaria ISS
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})    
	aItens1	:=	{}
	aItens2	:=	{}
	aAdd (aItens1, STR0117);										aAdd (aItens2, STR0117) //"0-Sim "
	aAdd (aItens1, STR0118);										aAdd (aItens2, STR0118) //"1-Não"    
 	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,});					aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
    // 


    //
	cTitObj1	:=	STR0027;		   								cTitObj2	:=	STR0028 //Ind. Operacoes sujeitas ao ICMS### Ind. Oper suj a retencao/substituicao tributaria
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})    
	aItens1	:=	{}
	aItens2	:=	{}
	aAdd (aItens1, STR0117);										aAdd (aItens2, STR0117) //"0-Sim "
	aAdd (aItens1, STR0118);										aAdd (aItens2, STR0118) //"1-Não"    
 	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,});					aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
    // 
   
	//
	cTitObj1	:=	STR0029;		   								cTitObj2	:=	STR0111 //Ind.Oper.sujeita a antecipacao tributaria ICMS###Ind.Oper.sujeitao ao IPI
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})    
	aItens1	:=	{}
	aItens2	:=	{}
	aAdd (aItens1, STR0117);										aAdd (aItens2, STR0117) //"0-Sim "
	aAdd (aItens1, STR0118);										aAdd (aItens2, STR0118) //"1-Não"
 	
 	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,});					aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
    //

	//
	cTitObj1	:=	STR0112;										cTitObj2	:=""  //ind apresentacao avulsa reg.inventario
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
	aItens1	:=	{}
	aItens2	:=	{}
	aAdd (aItens1, STR0117) //"0-Sim "
	aAdd (aItens1, STR0118) //"1-Não"
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {1,"",,,,,,});						aAdd (aPaineis[nPos][3], {1,"",,,,,,})
	//

	//ÚÄÄÄÄÄÄÄÄ¿
	//³Painel 3³
	//ÀÄÄÄÄÄÄÄÄÙ
	aAdd (aPaineis, {})
	nPos	:=	Len (aPaineis)
	aAdd (aPaineis[nPos], STR0005) //"Preencha corretamente as informacoes solicitadas."
	aAdd (aPaineis[nPos], STR0034) //"Dados do contabilista"
	aAdd (aPaineis[nPos], {})
	//
	cTitObj1	:=	STR0035;                                        cTitObj2	:=	STR0036 //"Nome"### CNPJ
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                  aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})							
	cTitObj1	:=	Replicate ("X", 40);                            cTitObj2	:=	Replicate ("X", 14)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,40});		        aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,14})				
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//
	
	//
	cTitObj1	:=	STR0037;                                        cTitObj2	:=	STR0038 //CPF###CRC
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                  aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})							
	cTitObj1	:=	Replicate ("X", 11);                            cTitObj2	:=	Replicate ("X", 11)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,11});		        aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,11})				
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//
		
	//
	cTitObj1	:=	STR0039;                                        cTitObj2	:=	STR0040 //UF###CEP
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                  aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})							
	cTitObj1	:=	Replicate ("X", 2);                            	cTitObj2	:=	Replicate ("X", 8)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,2});		            aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,8})				
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//
	cTitObj1	:=	STR0041;										cTitObj2	:=	STR0042 //"Endereço"###"Número"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})	
	cTitObj1	:=	Replicate ("X", 50);							cTitObj2	:=	Replicate ("X", 5)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});				aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,5})	
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//
	
	//
	cTitObj1	:=	STR0043;										cTitObj2	:=	STR0044 //"Complemento"###"Bairro"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
	cTitObj1	:=	Replicate ("X", 20);							cTitObj1	:=	Replicate ("X", 15)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,20});				aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,15})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//
	
	//
	cTitObj1	:=	STR0045;										cTitObj2	:=	STR0046 //"CEP Caixa Postal"###"Caixa Postal"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})	
	cTitObj1	:=	"@E 99999999";									cTitObj2	:=	"@E 99999"
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,2,0,,,8});				aAdd (aPaineis[nPos][3], {2,,cTitObj2,2,0,,,5})	
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//
	
	//
	cTitObj1	:=	STR0047;										cTitObj2	:=	STR0048 //"Fone"###"Fax"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})	
	cTitObj1	:=	Replicate ("X", 15);							cTitObj2	:=	Replicate ("X", 15)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,15});				aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,15})	
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
    //

	//
	cTitObj1	:=	STR0033;										cTitObj2	:=	STR0113 //"E-Mail##codigo municipio"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});				aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
	cTitObj1	:=	Replicate ("X", 50);							cTitObj2	:=	"@E 9999999"
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});				aAdd (aPaineis[nPos][3], {2,,cTitObj2,2,0,,,7})
	aAdd (aPaineis[nPos][3], {1,"",,,,,,});						aAdd (aPaineis[nPos][3], {1,"",,,,,,})
	//

	//ÚÄÄÄÄÄÄÄÄ¿
	//³Painel 4³
	//ÀÄÄÄÄÄÄÄÄÙ
	aAdd (aPaineis, {})
	nPos	:=	Len (aPaineis)
	aAdd (aPaineis[nPos], STR0005) //"Preencha corretamente as informacoes solicitadas."
	aAdd (aPaineis[nPos], STR0049) //"Dados do técnico/empresa"
	aAdd (aPaineis[nPos], {})
	//
	cTitObj1	:=	STR0035;                                        cTitObj2	:=	STR0036 //"Nome"###CNPJ
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                  aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})							
	cTitObj1	:=	Replicate ("X", 40);                            cTitObj2	:=	Replicate ("X", 14)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,40});		        aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,14})				
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//
	
	//                             		
	cTitObj1	:=	STR0037;                                        cTitObj2	:=	STR0047 //CPF###FONE
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                  aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})							
	cTitObj1	:=	Replicate ("X", 11);                            cTitObj2	:=	Replicate ("X", 15)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,11});		        aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,15})				
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//
	
	//
	cTitObj1	:=	STR0048;                                        cTitObj2	:=	STR0033 //FAX###EMAIL
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                  aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})							
	cTitObj1	:=	Replicate ("X", 15);                            cTitObj2	:=	Replicate ("X", 50)
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,15});		        aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,50})				
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	//		
	
	//ÚÄÄÄÄÄÄÄÄ¿
	//³Painel 5³
	//ÀÄÄÄÄÄÄÄÄÙ
	aAdd (aPaineis, {})
	nPos	:=	Len (aPaineis)
	aAdd (aPaineis[nPos], STR0005) //"Preencha corretamente as informacoes solicitadas."
	aAdd (aPaineis[nPos], STR0087 ) //"Dados do Bloco 8"
	aAdd (aPaineis[nPos], {})
	//
	cTitObj1	:=	STR0090;										cTitObj2	:=	STR0091 //Quadro Aquisicao de Bens //"Quadro de Calculo do Valor Adicionado"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})	
	aItens1	:=	{};                                                 aItens2	:=	{}	
	aAdd (aItens1, STR0088); 										aAdd (aItens2, STR0088) //"0 - Quadro com dados Informados" //"0 - Quadro com dados Informados"
	aAdd (aItens1, STR0089); 									   	aAdd (aItens2, STR0089) //"1 - Quadro sem dados Informados" //"1 - Quadro sem dados Informados"                                       		
 	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,});					aAdd (aPaineis[nPos][3],  {3,,,,,aItens2,,}) 
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})   
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
    //
		
	//
	cTitObj1	:=	STR0092;										    cTitObj2	:=	STR0119 //"Quadro Controle de Credito Acumulado" //"Indicador de conteudo"
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})	
	aItens1	:=	{}; 													aItens2	:=	{}
	aAdd (aItens1, STR0088);                                            aAdd (aItens2, STR0120) //"0- Guia com conteúdo"
	aAdd (aItens1, STR0089); 											aAdd (aItens2, STR0121) //"0 - Quadro com dados Informados"  //"1- Guia sem conteúdo"
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,}); 						aAdd (aPaineis[nPos][3],  {3,,,,,aItens2,,})//"1 - Quadro sem dados Informados" 
 	aAdd (aPaineis[nPos][3], {0,"",,,,,,});					   		aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})		
    //
    
    //
    cTitObj1	:=	"Imprime Credito ST"										 	    
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})
	aItens1	:=	{}					 		
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})					
	aAdd (aItens1, STR0117)
	aAdd (aItens1, STR0118)			
	aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})						
			 	                                              	                                              
 	
	lRet	:=	xMagWizard (aTxtApre, aPaineis, cNomWiz)
Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RetStr    ³ Autor ³Gustavo G. Rueda       ³ Data ³25.08.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³  RECEBE, TRANSFORMA E RETORNA A STRING NO FORMATO EXIGIDO  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Transforma a string ou valor passado para o padrao exigido  ³±±
±±³          ³ pelo leyout.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³xRet -> A string ou valor no padrao do layout               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|xValor -> Conteudo a ser padronizado                        ³±±
±±³          ³cEspecial -> Clausula para tratamentos especiais quando o   ³±±
±±³          ³ conteudo for do tipo string.                               ³±±
±±³          ³nDecimal -> numero de casas decimais.                       ³±±
±±³          ³lLimpa -> verifica se executa Alltrim.                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetStr (xValor, cEspecial, nDecimal,lLimpa)
	Local	xRet
	//
	Default	cEspecial	:=	""
	Default nDecimal    := 0
	Default lLimpa      := .T.
	//
	If (ValType (xValor)=="N")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Todas as variaveis numericas que nao tiverem formatacao especifica ("VLR3")  |
		//³serao convertidas para apresentarem 2 decimais. Portanto, se houver um campo |
		//|que tenha outra formatacao e o seu tipo seja numerico, deve-se converter     |
		//|para string antes da gravacao do mesmo, ou usar o "VLR3".                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (xValor==0) .And. nDecimal<>2 .And. nDecimal<>6 
			xRet	:=	"0"

		ElseIf ("VLR3"$cEspecial)
			xRet	:=	AllTrim (StrTran (Str (xValor,,3), ".", ","))
		ElseIf nDecimal==2
			xRet	:=	AllTrim (StrTran (Str (xValor,,2), ".", ","))
		ElseIf nDecimal==6
			xRet	:=	AllTrim (StrTran (Str (xValor,,6), ".", ","))
		EndIf
		
	ElseIf (ValType (xValor)=="C")
		If ("COD"$cEspecial)
			xRet	:=	ARetDig (AllTrim (xValor), .F.)
		Else
			xRet	:=	Iif(lLimpa, AllTrim (xValor), xValor)
		EndIf
	
	ElseIf (ValType (xValor)=="D")
		xRet	:=	StrZero (Day (xValor), 2)+StrZero (Month (xValor), 2)+StrZero (Year (xValor), 4)
	
	EndIf
Return (xRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |GrvRegSef ³ Autor ³Gustavo G. Rueda       ³ Data ³25.08.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³              GRAVACAO DO REGISTRO NO TRB                   ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Gravacao do registro passado como parametro (aReg) no TRB   ³±±
±±³          ³ que sera posteiormente lido e gerado o TXT.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlias -> Alias do TRB gerado na funcao principal           ³±±
±±³          ³nRelac -> Codigo de indicacao de relacionamento com outros  ³±±
±±³          ³ registros.                                                 ³±±
±±³          ³aReg -> Registro a ser gravado no TRB.                      ³±±
±±³          ³nItem -> Identificador de itens para um mesmo relacionamento³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GrvRegSef (cAlias, nRelac, aReg, nItem, nPai)
	Local nX		:= 0
	Local lRet		:= .T.
	Local cDelimit	:= "|"
	Local nZ		:= 0
	Local nDec		:= 0
	Local cLinha	:= ""
	Local cRegDec2	:= ""
	Local cRegDec6	:= ""
	//
	Default nRelac	:= 0
	//relacao dos registros/campo que deve ser gravado com 2 casas decimais
	//as 4 primeiras posicoes correspondem ao tipo do registro e os dois ultimos ao numero do campo
	cRegDec2 += "046008/046010/046011/046012/046013/046014/"
	cRegDec2 += "046517/046518/046519/046520/046521/046522/046523/046524/"
	cRegDec2 += "047009/047010/047011/"
	cRegDec2 += "C02014/C02015/C02016/C02017/C02018/C02019/C02020/C02021/C02022/C02023/C02024/C02025/C02026/C02027/"
	cRegDec2 += "C04003/C04004/C04005/C04006/"
	cRegDec2 += "C30007/C30008/C30009/C30013/C30014/C30015/C30016/C30017/C30018/C30019/C30020/C30021/"
	cRegDec2 += "C31003/C31004/C31005/"
	cRegDec2 += "C55011/C55012/C55013/C55014/C55015/C55016/"
	cRegDec2 += "C56007/C56008/C56009/C56012/C56013/C56014/"
	cRegDec2 += "C60013/C60014/C60015/C60016/C60017/C60018/C60019/C60020/C60021/C60022/C60023/"
	cRegDec2 += "C60502/C60503/C60504/C60505/C60506/C60507/C60508/"
	cRegDec2 += "C61007/C61008/C61009/C61012/C61013/C61014/C61015/C61016/C61017/"
	cRegDec2 += "C61502/C61503/C61504/C61505/C61506/"
	cRegDec2 += "E02016/E02017/E02018/E02019/E02020/E02021/E02022/E02023/E02024/E02025/E02026/E02027/E02028/E02029/"
	cRegDec2 += "E02502/E02503/E02505/E02506/E02507/E02508/E02509/E02510/E02511/E02512/E02513/E02514/E02515/"
	cRegDec2 += "E05011/E05012/E05013/E05014/E05015/"
	cRegDec2 += "E05502/E05504/E05505/E05506/E05507/E05507/E05508/"
	cRegDec2 += "E06010/E06011/E06012/E06013/E06014/E06015/E06016/E06017/E06018/E06019/E06020/E06021/E06022/"       
	cRegDec2 += "E06503/E06504/E06505/"       
	cRegDec2 += "E08006/E08007/E08008/E08009/E08010/E08013/E08014/E08015/E08016/E08017/"       
	cRegDec2 += "E08502/E08503/E08505/E08506/E08507/E08508/E08509/"       
	cRegDec2 += "E10018/E10019/E10020/E10021/E10022/E10023/E10024/"       
	cRegDec2 += "E10502/E10503/E10505/E10506/E10507/E10508/E10509/E10510/"       
	cRegDec2 += "E12017/E12019/E12020/E12021/E12022/E12023/E12024/"       
	cRegDec2 += "E30508/E30509/E30510/E30511/E30512/E30513/E30514/E30515/E30516/E30517/E30518/E30519/E30520/E30521/E30522/E30523/"       
	cRegDec2 += "E31002/E31003/E31005/E31006/E31007/E31008/E31009/"       
	cRegDec2 += "E33003/E33004/E33005/E33006/E33007/E33008/E33009/E33010/E33011/E33012/E33013/E33014/"      
	cRegDec2 += "E34002/E34003/E34004/E34005/E34006/E34007/E34008/E34009/E34010/E34011/E34012/E34013/E34014/E34015/E34016/E34017/E34018/E34019/E34020/E34021/E34022/E34023/E34024/"      
	cRegDec2 += "E35004/" 
	cRegDec2 += "E36006/"       
	cRegDec2 += "E52002/E52004/E52005/E52006/E52007/"
	cRegDec2 += "E52503/E52504/E52505/E52506/E52507/"
	cRegDec2 += "E54002/E54003/E54004/E54005/E54006/E54007/E54008/E54009/E54010/E54011/E54012/E54013/E54014/E54015/E54016/"
	cRegDec2 += "E55003/"       	
	cRegDec2 += "E56005/"       
	cRegDec2 += "G02511/G02512/G02513/G02514/G02515/G02516/G02517/"       
	cRegDec2 += "G03008/G03009/G03010/G03011/"       
	cRegDec2 += "G05007/G05008/G05009/G05010/G05011/G05012/G05013/G05014/G05015/G05016/G05017/G05018/G05019/"       
	cRegDec2 += "G40002/G40003/G40005/G40006/G40007/G40008/G40009/G40010/"
	cRegDec2 += "G41003/G41004/G41005/G41006/G41007/G41008/G41009/G41010/G41011/G41012/G41013/G41014/"
	cRegDec2 += "G42002/G42003/G42004/G42005/G42006/G42007/G42008/G42009/G42010/G42011/G42012/G42013/G42014/G42015/G42016/G42017/G42018/G42019/G42020/G42021/G42022/G42023/G42024/"
	cRegDec2 += "G43003/"       
	cRegDec2 += "G44006/"       
	cRegDec2 += "G45003/G45004/G45005/G45006/G45007/G45008/G45009/G45010/G45011/G45012/G45013/G45014/G45015/"
	cRegDec2 += "G46003/G46004/G46005/G46006/G46007/G46008/G46009/G46010/G46011/G46012/G46013/G46014/G46015/"
	cRegDec2 += "H02004/H02005/H02006/H02007/H02008/H02009/H02010/"       
	cRegDec2 += "H03011/H03012/H03013/H03014/H03015/"       
	cRegDec2 += "H04003/"       
	cRegDec2 += "H05003/"       
	cRegDec2 += "H06003/"       
	cRegDec2 += "803006/803007/803008/803009/803010/803011/"        
	cRegDec2 += "804003/804004/804006/804007/804008/"       
	cRegDec2 += "811003/811004/811005/811006/"       
	cRegDec2 += "816502/816503/816504/816505/816506/"       
	cRegDec2 += "857002/857003/857004/857005/857006/857007/857008/857009/857010/857011/857012/"
	cRegDec2 += "859002/859003/859004/859005/859006/859007/859008/859009/859010/859011/859012/859013/859014/859015/"
	cRegDec2 += "853009/853010/853011/"
	cRegDec2 += "853505/853506/853507/"
	cRegDec2 += "854002/854004/854005/854006/"
	cRegDec2 += "855002/855004/"
	cRegDec2 += "855503/855504/"                  
	cRegDec2 += "856002/856003/856004/856005/856006/856007/856008/856009/856010/856011/856012/"
	cRegDec2 += "856503/"
	cRegDec2 += "852506/"
	cRegDec2 += "858002/8580038580/858004/858005/858006/858007/858008/858009/858010/"
	cRegDec2 += "858503/858504/858505/"

	//relacao dos registros/campo que deve ser gravado com 6 casas decimais
	cRegDec6 += "C30005/C30006/C56005/C56006/C61005/C61006/H02008/"

	For nZ := 1 To Len (aReg)
		cLinha	:=	cDelimit
		//
		//Monto cLinha para gravar no TRB
		For nX := 1 To Len (aReg[nZ])
			If (ValType (aReg[nZ][nX])="A")
				cLinha	+=	RetStr (aReg[nZ][nX][1], aReg[nZ][nX][2])+cDelimit
			Else
				If Alltrim(aReg[nZ][1])+Strzero(nX,2)$cRegDec2
					nDec := 2
					If aReg[nZ][nX]==0 .And. !(Alltrim(aReg[nZ][1])$"C600/C605/C610/E060/E065/E080/E085/8165/G030")
						If nX==17 .And. (Alltrim(aReg[nZ][1])$"0465")
							cLinha	+=	"0,00"+cDelimit
						Else
							cLinha	+=	""+cDelimit
						EndIf
					Else
						If aReg[nZ][nX]==0 .And.Alltrim(aReg[nZ][1])+Strzero(nX,2)=="C60017" 
							cLinha	+=	""+cDelimit
						Else
							cLinha	+=	RetStr (aReg[nZ][nX],"",nDec,.T.)+cDelimit
						EndIf
					EndIf
				ElseIf Alltrim(aReg[nZ][1])+Strzero(nX,2)$cRegDec6
					nDec := 6
					If aReg[nZ][nX]==0 
						cLinha	+=	""+cDelimit
					Else
						cLinha	+=	RetStr (aReg[nZ][nX],"",nDec,.T.)+cDelimit
					EndIf
				Else
					nDec := 0
					cLinha	+=	RetStr (aReg[nZ][nX],"",nDec,Iif(Alltrim(aReg[nZ][1])+Strzero(nX,2)$"000017",.F.,.T.))+cDelimit
				EndIf
			EndIf
		Next (nX)
		
		//Tratamento para nao permitir gerar uma string maior que o tamanho do campo TRB_CONT. Se acontecer, somente serah no registro 0450.
		If Len(cLinha)>Len((cAlias)->TRB_CONT)
			cLinha	:=	AllTrim(Left(cLinha,Len((cAlias)->TRB_CONT)-1))+cDelimit
		EndIf
		//
		//Monto TRB
		RecLock (cAlias, .T.)
			(cAlias)->TRB_TPREG	:=	SubStr (cLinha, 2, 4)
			(cAlias)->TRB_RELAC	:=	StrZero (nRelac, 9, 0)
			(cAlias)->TRB_CONT	:=	cLinha
			(cAlias)->TRB_ITEM	:=	nItem
			(cAlias)->TRB_PAI	:=  nPai
		MsUnLock ()
	Next (nZ)
Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |GeraTrb   ³ Autor ³Gustavo G. Rueda       ³ Data ³25.08.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³              GERACAO DA ESTRUTURA DO TRB                   ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Geracao da estrutura do TRB utilizado em todo processamento ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|nTipo -> 1=Gerar o TRB, 2=Fechar o TRB                      ³±±
±±³          ³cArq -> Nome fisico do TRB criado                           ³±±
±±³          ³cAlias -> Alias do TRB criado                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraTrb (nTipo, aArq, cAlias)
	Local	lRet	:=	.T.
	Local	aCmp	:=	{}
	Local	cArq	:=	""
	Local	nI		:=	0
	//
	If (nTipo==1)
		//ÚÄÄÄÄÄÄÄÄÄ¿
		//³TRB Geral³
		//ÀÄÄÄÄÄÄÄÄÄÙ
		cAlias	:=	"TRB"
		aAdd (aCmp, {"TRB_TPREG",	"C", 	004,		0})
		aAdd (aCmp, {"TRB_RELAC",	"C", 	009,		0})
		aAdd (aCmp, {"TRB_FLAG",	"C", 	001,		0})
		aAdd (aCmp, {"TRB_CONT",	"C", 	999,		0})
		aAdd (aCmp, {"TRB_ITEM",	"N", 	005,		0})
		aAdd (aCmp, {"TRB_PAI",		"N", 	005,		0})
		cArq	:=	CriaTrab (aCmp)
		DbUseArea (.T., __LocalDriver, cArq, cAlias)
		IndRegua (cAlias, cArq, "TRB_TPREG+TRB_RELAC+StrZero (TRB_ITEM, 5, 0)")
    	aAdd (aArq, {cAlias, cArq})
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³TRB PRD = Registro 0200 - Tabela de identificacao do item³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCmp	:=	{}
		cAlias	:=	"PRD"
		aAdd (aCmp, {"PRD_CODITE",	"C", 	TamSx3("B1_COD")[1],		0})
		aAdd (aCmp, {"PRD_DESC",	"C", 	TamSx3("B1_DESC")[1],		0})
		aAdd (aCmp, {"PRD_CODGEN",	"C", 	2,							0})
		aAdd (aCmp, {"PRD_CODLST",	"C", 	TamSx3("B1_CODISS")[1],		0})
		//
		cArq	:=	CriaTrab (aCmp)
		DbUseArea (.T., __LocalDriver, cArq, cAlias)
		IndRegua (cAlias, cArq, "PRD_CODITE")
		aAdd (aArq, {cAlias, cArq})
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³TRB PAR = Registro 0150 - Tabela de cadastro de participantes³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCmp	:=	{}
		cAlias	:=	"PAR"
		aAdd (aCmp, {"PAR_REG",		"C", 	4,					0})
		nTam	:=	3+len(cFilAnt)+TamSx3("A1_COD")[1]+TamSx3("A1_LOJA")[1]
		aAdd (aCmp, {"PAR_CODPAR",	"C", 	nTam,				0})
		nTam	:=	TamSx3("A1_NOME")[1]
		aAdd (aCmp, {"PAR_NOME",	"C", 	60,				0})
		aAdd (aCmp, {"PAR_CODPAI",	"C", 	5,					0})
		aAdd (aCmp, {"PAR_CNPJ",	"C", 	14,					0})
		aAdd (aCmp, {"PAR_CPF",		"C", 	11,					0})
		aAdd (aCmp, {"PAR_VAZIO",	"C", 	01,					0})
		aAdd (aCmp, {"PAR_UF",		"C", 	02,					0})
		nTam	:=	TamSx3("A1_INSCR")[1]
		aAdd (aCmp, {"PAR_IE",		"C", 	nTam,				0})		
		aAdd (aCmp, {"PAR_IEST",	"C", 	nTam,				0})	//NAO UTILIZADO
		aAdd (aCmp, {"PAR_CODMUN",	"C", 	7,					0})
		nTam	:=	TamSx3("A1_INSCRM")[1]
		aAdd (aCmp, {"PAR_IM",		"C", 	nTam,				0})
		aAdd (aCmp, {"PAR_SUFRAM",	"C", 	9,					0})

		//
		cArq	:=	CriaTrab (aCmp)
		DbUseArea (.T., __LocalDriver, cArq, cAlias)
		IndRegua (cAlias, cArq, "PAR_CODPAR")
		aAdd (aArq, {cAlias, cArq})		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³TRB END = Registro 0175 - Endereco do participante³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCmp	:=	{}
		cAlias	:=	"EDP"
		aAdd (aCmp, {"EDP_REG",		"C", 	04,					0})
		nTam	:=	5+TamSx3("A1_COD")[1]+TamSx3("A1_LOJA")[1]
		aAdd (aCmp, {"EDP_CODPAR",	"C", 	nTam,				0})
		aAdd (aCmp, {"EDP_CEP",		"C", 	08,					0})
		nTam	:=	TamSx3("A1_END")[1]
		aAdd (aCmp, {"EDP_END",		"C", 	nTam,				0})
		aAdd (aCmp, {"EDP_NUM",		"C", 	10,					0})
		aAdd (aCmp, {"EDP_COMPL",	"C", 	30,					0})	//NAO UTILIZADO
		nTam	:=	TamSx3("A1_BAIRRO")[1]
		aAdd (aCmp, {"EDP_BAIRRO",	"C", 	nTam,				0})
		aAdd (aCmp, {"EDP_CEPCP",	"C", 	08,					0})
		nTam	:=	TamSx3("A1_CXPOSTA")[1]
		aAdd (aCmp, {"EDP_CP",		"C", 	nTam,				0})
		nTam	:=	TamSx3("A1_DDD")[1]+TamSx3("A1_TEL")[1]
		aAdd (aCmp, {"EDP_FONE",	"C", 	nTam,				0})		
		aAdd (aCmp, {"EDP_FAX",		"C", 	nTam,				0})
		//
		cArq	:=	CriaTrab (aCmp)
		DbUseArea (.T., __LocalDriver, cArq, cAlias)
		IndRegua (cAlias, cArq, "EDP_CODPAR")
		aAdd (aArq, {cAlias, cArq})
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³IVT = Registro H030 - ITENS IVENTARIO         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCmp	:=	{}
		cAlias	:=	"IVT"
		aAdd (aCmp, {"IVT_REG",		"C", 	04,					0})
		aAdd (aCmp, {"IVT_INDP",	"C", 	01,					0})
		nTam	:=	3+len(cFilAnt)+TamSx3("A1_COD")[1]+TamSx3("A1_LOJA")[1]
		aAdd (aCmp, {"IVT_CODPAR",	"C", 	nTam,				0})
		aAdd (aCmp, {"IVT_INDINV",	"C", 	01,					0})
		aAdd (aCmp, {"IVT_NCM",		"C", 	08,					0})
		nTam	:=	TamSx3("B1_COD")[1] + Len(xFilial("SB1"))
		aAdd (aCmp, {"IVT_CODITE",	"C", 	nTam,				0})
		nTam	:=	TamSx3("B1_UM")[1]
		aAdd (aCmp, {"IVT_UM",		"C", 	nTam,				0})
		aAdd (aCmp, {"IVT_VLUNIT",	"N", 	16,					4})
		aAdd (aCmp, {"IVT_QTD",		"N", 	16,					3})
		aAdd (aCmp, {"IVT_VLITEM",	"N", 	16,					3})
		aAdd (aCmp, {"IVT_VICMRE",	"N", 	16,					3})
		aAdd (aCmp, {"IVT_VIPIRE",	"N", 	16,					3})
		aAdd (aCmp, {"IVT_VPISRE",	"N", 	16,					3})
		aAdd (aCmp, {"IVT_VCOFRE",	"N", 	16,					3})
		aAdd (aCmp, {"IVT_VTRIBN",	"N", 	16,					3})
		aAdd (aCmp, {"IVT_OBS",		"C", 	20,					0}) 
		
		cArq	:=	CriaTrab (aCmp)
		DbUseArea (.T., __LocalDriver, cArq, cAlias)
		IndRegua (cAlias, cArq, "IVT_INDP+IVT_CODPAR+IVT_INDINV+IVT_CODITE")
		aAdd (aArq, {cAlias, cArq})
	Else
		For nI := 1 To Len (aArq)
			DbSelectArea (aArq[nI][1])
				(aArq[nI][1])->(DbCloseArea ())
			Ferase (aArq[nI][2]+GetDBExtension ())
			Ferase (aArq[nI][2]+OrdBagExt ())	
		Next nI
	EndIf
	
	cAlias	:=	"TRB"	//Devo sempre retornar para os casos que nao tiverem TRB proprio.
Return (lRet)         

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RetSitDoc ³ Autor ³Gustavo G. Rueda       ³ Data ³25.08.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³              SITUACAO DO DOCUMENTO FISCAL                  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Retorna a situacao do documento fiscal em processamento,    ³±±
±±³          ³ onde:                                                      ³±±
±±³          ³ 5=Devolucao                                                ³±±
±±³          ³ 6=Complemento                                              ³±±
±±³          ³ 2=Cancelado                                                ³±±
±±³          ³ 3=Cupom Cancelado                                          ³±±
±±³          ³ o=Normal                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cSituaDoc -> Situacao do documento                          ³±±
±±³          ³ onde:                                                      ³±±
±±³          ³ 5=Devolucao                                                ³±±
±±³          ³ 6=Complemento                                              ³±±
±±³          ³ 2=Cancelado                                                ³±±
±±³          ³ 3=Cupom Cancelado                                          ³±±
±±³          ³ o=Normal                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cTipo -> F3_TIPO                                            ³±±
±±³          ³cAliasSFT -> Alias  tabela SFT filtrada na funcao principal ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetSitDoc (cTipo,cAliasSFT,cCodSef)
	Local	cSituaDoc	:=	"00"
	Local  cRepFiscal := GetNewPar("MV_REPFIS","")

	//Situacao da NF           
	//00-Documetno normal (00)              
	//01-Documento extemporaneo (??)
	//02-Documento cancelado (90)
	//03-Documento cupom cancelado (90)      
	//04-NFe uso denegado (80)
	//05-Nfe numeração inutilizada (81)
	//06-Complemento (20)                          
	//10-NF Avulsa
	//99-Sem repercursão fiscal
	
	If (cTipo$"ICP")
		cSituaDoc	:=	"20"	//Complemento de IPI, Complemento de ICMS, Complemento de Preco e Beneficiamento (?)			
	EndIf     
	
	If "NFA"$(cAliasSFT)->FT_ESPECIE
		cSituaDoc	:=	"10"	//NF Avulsa
	EndIf     

	If !(Empty ((cAliasSFT)->FT_DTCANC))
		If (Empty ((cAliasSFT)->FT_PDV))
			If Month((cAliasSFT)->FT_EMISSAO)<>Month((cAliasSFT)->FT_ENTRADA)
				cSituaDoc	:=	"90"	//Documento Extemporaneo Cancelado
			Else
				cSituaDoc	:=	"90"	//Documento Cancelado
			EndIf
		Else
			cSituaDoc	:=	"90"	    //Documento Cupom Cancelado
		EndIf
	EndIf                                          
	If !Empty(cCodSef)
		//NFe - Uso denegado
		If cCodSef $ "110/204/205/301/302/303/304/305/306/999"
			cSituaDoc := "80"
		//NFe - Numeracao Inutilizada
		ElseIf cCodSef $ "102"
			cSituaDoc := "81"	
		EndIf
	EndIf
	
	// Sem repercussão fiscal.Conforme a tabela 4.1.3
	IF Alltrim((cAliasSFT)->FT_CFOP)$cRepFiscal .And. !cSituaDoc$"#90#80#102#81"
		cSituaDoc := "99"	
	EndIf
Return (cSituaDoc)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |ProcEstru ³ Autor ³Gustavo G. Rueda       ³ Data ³25.08.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³            PROCESSAMENTO DA ESTRUTURA PRODUTO              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Funcao recursiva para processamento da estrutura do produto.³±±
±±³          ³ Copiado da DCRE                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cProd -> Codigo do produto a ser estruturado                ³±±
±±³          ³cAlias -> Alias do TRB para gravacao pela funcao GrvRegSef  ³±±
±±³          ³nRelac -> codigo de relacionamento de registros             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
Static Function ProcEstru (cProd, cAlias, nRelac, cUm, lIcms)
	Local	lRet	:=	.T.
	Local 	aArea 	:= 	GetArea ()
	
	Default lIcms	:= .F.
	//
	If (SG1->(DbSeek (xFilial ("SG1")+cProd)))
		Do While !SG1->(Eof ()) .And. (SG1->G1_FILIAL+SG1->G1_COD==xFilial("SG1")+cProd)
			ProcReg (cAlias, nRelac, cUm, lIcms)
			ProcEstru (SG1->G1_COMP,cAlias,,cUm, lIcms)
			//
			SG1->(DbSkip ())
		Enddo
	Endif
	//
	RestArea (aArea)
Return (lRet)
*/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |ProcReg   ³ Autor ³Gustavo G. Rueda       ³ Data ³25.08.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³              GRAVACAO DA ESTRUTURA PRODUTO                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Funcao para gravacao da estrutura do produto montada no TRB.³±±
±±³          ³ Copiado da DCRE                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlias -> Alias do TRB para gravacao pela funcao GrvRegSef  ³±±
±±³          ³nRelac -> codigo de relacionamento de registros             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
Static Function ProcReg (cAlias, nRelac, cUm, lIcms)
	Local	lRet		:=	.T.
	Local 	aArea 		:= 	GetArea ()
	Local	aReg0210	:=	{} 
	Local	cCodEstr	:=	SG1->G1_COMP
	Local	nQtdEstr	:=	SG1->G1_QUANT
	Local	cDtIni		:= 	SG1->G1_INI
	Local 	cDtFim		:=	SG1->G1_FIM 
	
	Default lIcms		:= .F.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida o Componente da Estrutura                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (CheckComp (cCodEstr)) .AND. lIcms
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processa Cadastro de Produtos                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea ("SB1")
		SB1->(DbSetOrder (1))
		If SB1->(DbSeek (xFilial ("SB1")+cCodEstr))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava Componentes do Produtos                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aReg0210	:=	{}
			aAdd (aReg0210, {})
			nPos	:=	Len (aReg0210)
			aAdd (aReg0210[nPos], "0210")				//01 - REG
			aAdd (aReg0210[nPos], ALLTRIM(cCodEstr))				//02 - COD_ITEM_COMP
			aAdd (aReg0210[nPos], cUm)					//03 - UNID_ITEM
			aAdd (aReg0210[nPos], Alltrim(StrTran(STR(nQtdEstr,,3),".",",")))	//04 - QTD_COMP
			aAdd (aReg0210[nPos], SB1->B1_UM)			//05 - UNID_COMP
			aAdd (aReg0210[nPos], cDtIni)	  			//06 - DT_INI_COMP
			aAdd (aReg0210[nPos], cDtFim)	  	   		//07 - DT_FIM_COMP
			aAdd (aReg0210[nPos], "0")	    			//08 - IND_ALT 
			aAdd (aReg0210[nPos], cTxAlt)				//09 - TX_ALT 
			//
			GrvRegSef (cAlias, nRelac, aReg0210)
		Endif
	Endif
	RestArea(aArea)
Return (lRet)
*/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |CheckComp ³ Autor ³Gustavo G. Rueda       ³ Data ³25.08.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³          VERIFICACAO DO COMPONENTE DA ESTRUTURA            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Verificacao do componente da estrutura, pois ocorre casos de³±±
±±³          ³ ser componente e possuir outros componentes na estrutura tb³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cComps -> Codigo do componente.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
Static Function CheckComp (cComp)
	Local aArea		:= GetArea()
	Local lRet		:= .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o componente e produzido ou comprado                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea ("SG1")
		SG1->(DbSetOrder (1))
	If (SG1->(DbSeek (xFilial ("SG1")+cComp)))
		lRet := .F.
	Endif
	//
	RestArea(aArea)
Return (lRet)
*/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |LivrObs   ³ Autor ³Gustavo G. Rueda       ³ Data ³25.08.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³          OBSERVACAO PARA OS DOCUMENTOS FISCAIS             ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Montagem das observacoes dos documentos fiscais com seus    ³±±
±±³          ³ embasamentos legais. Rotina copiada o MATR930              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aColObs -> Observacoes escrituradas no Livro Fiscal para o  ³±±
±±³          ³ documento fiscal processado no momento.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAliasSFT -> Alias da tabela SFT aberta no momento.         ³±±
±±³          ³ funcao a ser retornado para gravacao pela funcao principal.³±±
±±³          ³nEntSai -> Flag indicador de entrada(1)/saida(2).           ³±±
±±³          ³nTamObs -> Len de quebra para o campo de Observacao         ³±±
±±³          ³aLeis -> Embasamento legal para tal observacao.             ³±±
±±³          ³lCompFre -> Indica se é complemento de Frete.               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LivrObs (cAliasSFT, nEntSai, nTamObs, aLeis, cChaveF3,lCompFre)
	Local	xx			:=	0
	Local	aColObs		:=	{}
	Local	cMensagem	:=	""
	Local	lNfDivers	:=	.F.
	Local	nMlCt		:=	0
	//
	aLeis		:=	{}
	
	If SF3->(dbSeek (cChaveF3))
		Do While !SF3->(Eof ()) .And.;
			cChaveF3==SF3->F3_FILIAL+DToS (SF3->F3_ENTRADA)+SF3->(F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA)
			//
		   	If !Empty (SF3->F3_OBSERV)
		   		If (nEntSai==1)
			   	   	If ("N.F.ORIG.: DIVERSAS"$SF3->F3_OBSERV)
				   		cMensagem := SubStr (SF3->F3_OBSERV, 1, At (":", SF3->F3_OBSERV)+1)
			   		    //
						SD1->(dbSeek (xFilial ("SD1")+SF3->(F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA)))
						//
		   		   		Do While !SD1->(Eof ()) .And.;
		   		   			xFilial ("SD1")+SF3->(F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA)==SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
		   		   			//
		   	   				If !(AllTrim (SD1->D1_NFORI+"/"+SD1->D1_SERIORI)$cMensagem)
			   	   				cMensagem += AllTrim (SD1->D1_NFORI+"/"+SD1->D1_SERIORI)+", "
			   	   			EndIf
			   	   			SD1->(DbSkip ())
		   		   		EndDo
		   		   		//
				   		cMensagem 	:= SubStr (cMensagem, 1, Len (cMensagem)-2)
				   		lNfDivers	:=	.T.
				   	Else
						cMensagem := Trim (SF3->F3_OBSERV)
				    EndIf
		   	  	Else
			   	   	If (("Dev. terc. N.F.ORIG.: DIVERSAS"$SF3->F3_OBSERV) .Or. ("N.F.ORIG.: DIVERSAS"$SF3->F3_OBSERV))
				   		cMensagem := SubStr (SF3->F3_OBSERV, 1, At(":", SF3->F3_OBSERV)+1)
			   		    //
						SD2->(dbSeek (xFilial ("SD2")+SF3->(F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA)))
			   		    //
		   		   		Do While !SD2->(Eof ()) .And.;
			   		   		xFilial ("SD2")+SF3->(F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA)==SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)
		   		   			//
		   	   				If !(AllTrim (SD2->D2_NFORI+"/"+SD2->D2_SERIORI)$cMensagem)
			   	   				cMensagem += AllTrim (SD2->D2_NFORI+"/"+SD2->D2_SERIORI)+", "
			   	   			EndIf
			   	   			SD2->(DbSkip ())
		   		   		EndDo
		   		   		//
				   		cMensagem 	:= SubStr (cMensagem, 1, Len (cMensagem)-2)
				   		lNfDivers	:=	.T.
				   	Else
						cMensagem := Trim (SF3->F3_OBSERV)
				    EndIf
		   	  	EndIf
		  		//O artigo abaixo 454 é do RICMS de São Paulo e não de Pernambuco, gerando registro 0455 com artigo incorreto.
		  		//Porém em Pernanbuco não tem o artigo equivalente para eu substituir, então por este motivo o registro 0455 não será gerado 
		  		//para as devoluções.   
				/*If (lNfDivers)
				   	aAdd (aLeis, "Art. 454 do RICMS")
				EndIf*/
				//
				If !Empty(cMensagem)
					nMlCt	:=	MlCount (cMensagem, nTamObs)
					If nMlCt==0
						aAdd (aColObs, cMensagem)
					Else
						For xx:=1 to nMlCt
							aAdd (aColObs, MemoLine (cMensagem, nTamObs, xx))
						Next xx
					EndIf
			   	EndIf
			Endif
		 	If !Empty (SF3->F3_FORMULA) .And. !(OemToAnsi ("CANCELADA")$SF3->F3_OBSERV)
		 		dbSelectArea("SF3")
				If (cMensagem	:=	Formula (SF3->F3_FORMULA))<>Nil
					nMlCt	:=	MlCount (cMensagem, nTamObs)
					If nMlCt==0
						aAdd (aColObs, cMensagem)
					Else
						For xx:=1 to nMlCt
							aAdd (aColObs, MemoLine (cMensagem, nTamObs, xx))
						Next xx
					EndIf
				EndIf
			Endif
			If (SF3->F3_VALOBSE>0)
				cMensagem	:=	"DESCONTO..."+Alltrim (TransForm (SF3->F3_VALOBSE, PesqPict ("SF3","F3_VALOBSE")))
				nMlCt	:=	MlCount (cMensagem, nTamObs)
				If nMlCt==0
					aAdd (aColObs, cMensagem)
				Else
					For xx:=1 to nMlCt
						aAdd (aColObs, MemoLine (cMensagem, nTamObs, xx))
					Next xx
				EndIf
			Endif
			If (SF3->F3_IPIOBS>0)
				cMensagem	:=	"IPI....."+Alltrim (TransForm (SF3->F3_IPIOBS, PesqPict ("SF3","F3_IPIOBS")))
				nMlCt	:=	MlCount (cMensagem, nTamObs)
				If nMlCt==0
					aAdd (aColObs, cMensagem)
				Else
					For xx:=1 to nMlCt
						aAdd (aColObs, MemoLine (cMensagem, nTamObs, xx))
					Next xx
				EndIf
			Endif
			If (SF3->F3_ICMSRET-SF3->F3_OBSSOL)>0 .And. lCompFre
					cMensagem	:= "ICMS sobre frete retido por substituição tributária: " +Alltrim (TransForm (SF3->F3_BASERET, PesqPict ("SF3","F3_BASERET")))+" "+Alltrim (TransForm (SF3->F3_ICMSRET-SF3->F3_OBSSOL, PesqPict ("SF3","F3_ICMSRET")))
			   		aAdd (aLeis, "Decreto nº 18.955, de 22 de dezembro de 1997, Anexo IV, Caderno IV, item 1. (AC)")
			   		nMlCt	:=	MlCount (cMensagem, nTamObs)
					If nMlCt==0
						aAdd (aColObs, cMensagem)
					Else
						For xx:=1 to nMlCt
							aAdd (aColObs, MemoLine (cMensagem, nTamObs, xx))
						Next xx
					EndIf
			Else
				If (SF3->F3_ICMSRET-SF3->F3_OBSSOL)>0
					cMensagem	:=	"ICMS RETIDO..: "+Alltrim (TransForm (SF3->F3_ICMSRET-SF3->F3_OBSSOL, PesqPict ("SF3","F3_ICMSRET")))
					nMlCt	:=	MlCount (cMensagem, nTamObs)
					If nMlCt==0
						aAdd (aColObs, cMensagem)
					Else
						For xx:=1 to nMlCt
							aAdd (aColObs, MemoLine (cMensagem, nTamObs, xx))
						Next xx
					EndIf
				Endif
			EndIf	
			If (SF3->F3_ICMSCOM>0)
				cMensagem	:=	"ICMS DIF.ALIQ: "+Alltrim (TransForm (SF3->F3_ICMSCOM, PesqPict ("SF3", "F3_ICMSCOM")))
				nMlCt	:=	MlCount (cMensagem, nTamObs)
				If nMlCt==0
					aAdd (aColObs, cMensagem)
				Else
					For xx:=1 to nMlCt
						aAdd (aColObs, MemoLine (cMensagem, nTamObs, xx))
					Next xx
				EndIf
			Endif
			If (SF3->F3_VALTST>0)
				cMensagem	:=	"ICMSST FRET.AUT: "+Alltrim (TransForm (SF3->F3_VALTST, PesqPict ("SF3", "F3_VALTST")))
				nMlCt	:=	MlCount (cMensagem, nTamObs)
				If nMlCt==0
					aAdd (aColObs, cMensagem)
				Else
					For xx:=1 to nMlCt
						aAdd (aColObs, MemoLine (cMensagem, nTamObs, xx))
					Next xx
				EndIf
			EndIf
			If (SF3->F3_ICMAUTO>0)
				cMensagem	:=	"ICMS FRET.AUT: "+Alltrim (TransForm (SF3->F3_ICMAUTO, PesqPict ("SF3", "F3_ICMAUTO")))
				nMlCt	:=	MlCount (cMensagem, nTamObs)
				If nMlCt==0
					aAdd (aColObs, cMensagem)
				Else
					For xx:=1 to nMlCt
						aAdd (aColObs, MemoLine (cMensagem, nTamObs, xx))
					Next xx
				EndIf
			Endif
			If (SF3->F3_OBSICM>0)
				cMensagem	:=	"ICMS NORMAL: "+Alltrim (TransForm (SF3->F3_OBSICM, PesqPict("SF3", "F3_OBSICM")))
				nMlCt	:=	MlCount (cMensagem, nTamObs)
				If nMlCt==0
					aAdd (aColObs, cMensagem)
				Else
					For xx:=1 to nMlCt
						aAdd (aColObs, MemoLine (cMensagem, nTamObs, xx))
					Next xx
				EndIf
			Endif
			If SF3->F3_OBSSOL>0
				cMensagem	:=	"ICMS ST. INT.: "+Alltrim (TransForm (SF3->F3_OBSSOL, PesqPict("SF3", "F3_OBSSOL")))
				nMlCt	:=	MlCount (cMensagem, nTamObs)
				If nMlCt==0
					aAdd (aColObs, cMensagem)
				Else
					For xx:=1 to nMlCt
						aAdd (aColObs, MemoLine (cMensagem, nTamObs, xx))
					Next xx
				EndIf
			Endif
			
			//
			SF3->(DbSkip ())
		EndDo
	EndIf
Return (aColObs)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |OrgTxt    ³ Autor ³Gustavo G. Rueda       ³ Data ³25.08.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³             GRAVACAO DO TRB EM MEIO-MAGNETICO              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Funcao de gravacao do meio-magnetico de acordo com o TRB.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlias -> Alias do TRB gerado na funcao principal.          ³±±
±±³          |cFile -> Nome do meio-magnetico a ser gerado.               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function OrgTxt (cAlias, cFile)
	Local	lRet		:=	.T.
	Local	lGravaReg8	:=	.F.
	Local	lGravaReg9	:=	.F.
	Local	nHandle	:=	-1
	Local	cRelac		:=	""
	Local	cChave		:=	""
	Local  cChave2	:= ""
	Local  aArea2 	:={}		
	Local  aRegAux	:= {}
	Local 	nX			:= 0
	Local 	nY			:= 0	
	//
	If (File (cFile))		
		FErase (cFile)
	Endif
	nHandle	:=	MsFCreate (cFile)
	//
	DbSelectArea (cAlias)  
		(cAlias)->(DbSetOrder (1))
	ProcRegua ((cAlias)->(RecCount ()))
	(cAlias)->(DbGoTop ())
	//
	Do While !(cAlias)->(Eof ())
	
		IncProc(STR0051)	//"Gerando arquivo texto"
	
		If (Empty ((cAlias)->TRB_FLAG))
				//
			cRelac	:=	(cAlias)->TRB_RELAC
			aArea	:=	(cAlias)->(GetArea ())
			//
			If ("0150"$(cAlias)->TRB_TPREG)
				cChave	:=	"0150"+cRelac
				If ((cAlias)->(DbSeek (cChave)))
					Do While !(cAlias)->(Eof ()) .And. cChave==(cAlias)->TRB_TPREG+(cAlias)->TRB_RELAC
						GravaLinha (nHandle, cAlias)
						//
						RegPorNf (nHandle, cAlias, "0175", cRelac, (cAlias)->TRB_ITEM)
						//
						(cAlias)->(DbSkip ())
					EndDo
				EndIf
				
			ElseIf ("0200"$(cAlias)->TRB_TPREG)
				cChave	:=	"0200"+cRelac
				If ((cAlias)->(DbSeek (cChave)))
					Do While !(cAlias)->(Eof ()) .And. cChave==(cAlias)->TRB_TPREG+(cAlias)->TRB_RELAC
						GravaLinha (nHandle, cAlias)
						//
						RegPorNf (nHandle, cAlias, "0205", cRelac, (cAlias)->TRB_ITEM)
						RegPorNf (nHandle, cAlias, "0210", cRelac, (cAlias)->TRB_ITEM)
						//
						(cAlias)->(DbSkip ())
					EndDo
				EndIf

			ElseIf ("0450"$(cAlias)->TRB_TPREG)
					cChave	:=	"0450"+cRelac
					If ((cAlias)->(DbSeek (cChave)))
						Do While !(cAlias)->(Eof ()) .And. cChave==(cAlias)->TRB_TPREG+(cAlias)->TRB_RELAC
							GravaLinha (nHandle, cAlias)
							//
							RegPorNf (nHandle, cAlias, "0455", cRelac, (cAlias)->TRB_ITEM)
							//
							RegPorNf (nHandle, cAlias, "0460", cRelac, (cAlias)->TRB_ITEM)
							//
							RegPorNf (nHandle, cAlias, "0465", cRelac, (cAlias)->TRB_ITEM)
							//
							(cAlias)->(DbSkip ())
						EndDo
					EndIf
			
			ElseIf ("C020"$(cAlias)->TRB_TPREG)
				GravaLinha (nHandle, cAlias)
				
				RegPorNf (nHandle, cAlias, "C040", cRelac,)				
				
				RegPorNf (nHandle, cAlias, "C300", cRelac,)				
				
				RegPorNf (nHandle, cAlias, "C310", cRelac,)	
		   
			ElseIf ("C550"$(cAlias)->TRB_TPREG)
				GravaLinha (nHandle, cAlias)				
				
				RegPorNf (nHandle, cAlias, "C560", cRelac,)										
				
			ElseIf ("C600"$(cAlias)->TRB_TPREG)
				GravaLinha (nHandle, cAlias)
				
				RegPorNf (nHandle, cAlias, "C605", cRelac,)				
				
				RegPorNf (nHandle, cAlias, "C610", cRelac,)				
				
				RegPorNf (nHandle, cAlias, "C615", cRelac,)								

			ElseIf ("E003"$(cAlias)->TRB_TPREG)
				GravaLinha (nHandle, cAlias)

			ElseIf ("E020"$(cAlias)->TRB_TPREG)
				GravaLinha (nHandle, cAlias)
				
				RegPorNf (nHandle, cAlias, "E025", cRelac,)
				
			ElseIf ("E050"$(cAlias)->TRB_TPREG)
				GravaLinha (nHandle, cAlias)
				
				RegPorNf (nHandle, cAlias, "E055", cRelac,)
				
			ElseIf ("E060"$(cAlias)->TRB_TPREG)
				GravaLinha (nHandle, cAlias)
				
				RegPorNf (nHandle, cAlias, "E065", cRelac,)
			
			ElseIf ("E080"$(cAlias)->TRB_TPREG)
				GravaLinha (nHandle, cAlias)
				
				RegPorNf (nHandle, cAlias, "E085", cRelac,)
				
			ElseIf ("E100"$(cAlias)->TRB_TPREG)
				GravaLinha (nHandle, cAlias)
				
				RegPorNf (nHandle, cAlias, "E105", cRelac,)				
			
			ElseIf ( "8" $ Substr((cAlias)->TRB_TPREG,1,1))
				lGravaReg8 := .T.
				
			ElseIf ( "9" $ Substr((cAlias)->TRB_TPREG,1,1))
				lGravaReg9 := .T.  
			Else
				GravaLinha (nHandle, cAlias)
					
			EndIf
			RestArea (aArea)
		EndIf
		//
		(cAlias)->(DbSkip ())
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pela ordem definida no layout, os registros comecando com "8" e "9" devem ser  ³
	//³impressos no final do arquivo magnetico                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If lGravaReg8
 		(cAlias)->(DbSeek("8"))
		Do While !(cAlias)->(Eof ()) .And. Substr((cAlias)->TRB_TPREG,1,1) == "8"
		
			If (Empty ((cAlias)->TRB_FLAG))

				cRelac	:=	(cAlias)->TRB_RELAC

				If ("8505"$(cAlias)->TRB_TPREG)
					aArea2  := (cAlias)->(GetArea ())
				
					cChave2 := "8515"
					If (cAlias)->(msSeek (cChave2)) .And. Empty((cAlias)->TRB_FLAG)
						Do While !(cAlias)->(Eof()) .And. cChave2==(cAlias)->TRB_TPREG
								
						aAdd(aRegAux, {})
						nPos	:=	Len (aRegAux)
						aAdd (aRegAux[nPos], (cAlias)->TRB_TPREG)
						aAdd (aRegAux[nPos], (cAlias)->TRB_RELAC)
						aAdd (aRegAux[nPos], SubStr((cAlias)->TRB_CONT, 7, 1))
						aAdd (aRegAux[nPos], cValToChar((cAlias)->TRB_PAI))
					
						(cAlias)->(DbSkip ())
						EndDo
						aSort(aRegAux,,,{|x,y|val(x[3]) < val(y[3])})	
					EndIf				
					
					For nX := 1 To Len (aRegAux)
						cChave2 := "8505"+aRegAux[nX][2] 				
						
						If (cAlias)->(msSeek (cChave2)) .And. Empty((cAlias)->TRB_FLAG)
							Do While !(cAlias)->(Eof()) .And. cChave2==(cAlias)->TRB_TPREG+(cAlias)->TRB_RELAC
								GravaLinha (nHandle, cAlias)
								(cAlias)->(DbSkip ())
							EndDo
						EndIf			
							
						cChave2 := "8510"+aRegAux[nX][2]						
						If (cAlias)->(msSeek (cChave2)) .And. Empty((cAlias)->TRB_FLAG)
							Do While !(cAlias)->(Eof()) .And. cChave2==(cAlias)->TRB_TPREG+(cAlias)->TRB_RELAC
									GravaLinha (nHandle, cAlias)								
								(cAlias)->(DbSkip ())
							EndDo
						EndIf
						
						
						cChave2 := "8515"+aRegAux[nX][2]
						If (cAlias)->(msSeek (cChave2)) //.And. Empty((cAlias)->TRB_FLAG)
							Do While !(cAlias)->(Eof()) .And. cChave2==(cAlias)->TRB_TPREG+(cAlias)->TRB_RELAC
								IF aRegAux[nX][4] == cValToChar((cAlias)->TRB_PAI) .And. Empty((cAlias)->TRB_FLAG)
									GravaLinha (nHandle, cAlias)
								Endif
								(cAlias)->(DbSkip ())
							EndDo
						EndIf
						
						cChave2 := "8525"+aRegAux[nX][2]
						If (cAlias)->(msSeek (cChave2)) //.And. Empty((cAlias)->TRB_FLAG)
							Do While !(cAlias)->(Eof()) .And. cChave2==(cAlias)->TRB_TPREG+(cAlias)->TRB_RELAC
								IF aRegAux[nX][4] == cValToChar((cAlias)->TRB_PAI) .And. Empty((cAlias)->TRB_FLAG)
									GravaLinha (nHandle, cAlias)
								Endif
								(cAlias)->(DbSkip ())
							EndDo
						EndIf
											
					Next nX
				
					RestArea (aArea2)
					
				ElseIf ("8530"$(cAlias)->TRB_TPREG)
					GravaLinha (nHandle, cAlias)
			
					RegPorNf (nHandle, cAlias, "8535", cRelac,)
					
					RegPorNf (nHandle, cAlias, "8540", cRelac,)
					
				ElseIf ("8545"$(cAlias)->TRB_TPREG)
					GravaLinha (nHandle, cAlias)
			
					RegPorNf (nHandle, cAlias, "8550", cRelac,)
					
					RegPorNf (nHandle, cAlias, "8555", cRelac,)

					RegPorNf (nHandle, cAlias, "8560", cRelac,)

					RegPorNf (nHandle, cAlias, "8565", cRelac,)

					RegPorNf (nHandle, cAlias, "8570", cRelac,)

					RegPorNf (nHandle, cAlias, "8580", cRelac,)
					
					RegPorNf (nHandle, cAlias, "8585", cRelac,)

					RegPorNf (nHandle, cAlias, "8590", cRelac,)
					
				Elseif !((cAlias)->TRB_TPREG$"8505/8510/8515/8525/8530/8535/8540/8510/8515/8525/8550/8555/8560/8565/8570/8580/8585/8590")
					GravaLinha (nHandle, cAlias)
				EndIf
			
			EndIf
		
			(cAlias)->(DbSkip ())
		EndDo
	EndIf
	If lGravaReg9
		(cAlias)->(DbSeek("9"))
		Do While !(cAlias)->(Eof ()) .And. Substr((cAlias)->TRB_TPREG,1,1) == "9"
			GravaLinha (nHandle, cAlias)
			(cAlias)->(DbSkip ())
		EndDo
	EndIf
	//
	If (nHandle>=0)
		FClose (nHandle)
	Endif
Return (lRet)   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RegPorNf  ³ Autor ³Gustavo G. Rueda       ³ Data ³25.08.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³   GRAVACAO DE UM REGISTRO RELACIONADO COM SEU SUPERIOR     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Posiciono no registro com a chave passada como parametro e  ³±±
±±³          ³ gero o TXT na funcao Gravalinha                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|nHandle -> Handle do arquivo txt aberto.                    ³±±
±±³          |cAlias -> Alias do TRB criado atraves da funcao principal.  ³±±
±±³          |cTpReg -> Tipo de registro que compoe a chave de pesquisa.  ³±±
±±³          |cRelac -> Relacionamento do registro que compoe a chave de  ³±±
±±³          | pesquisa                                                   ³±±
±±³          |nItem -> Item por relacionamento.                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegPorNf (nHandle, cAlias, cTpReg, cRelac, nItem)
	Local	lRet	:=	.T.
	Local	cChave	:=	cTpReg+cRelac
	Local	aArea	:=	(cAlias)->(GetArea ())
	//
	If (nItem<>Nil .And. nItem>0)
		cChave	+=	StrZero (nItem, 5, 0)
	EndIf
	//
	If ((cAlias)->(DbSeek (cChave)))
		Do While !(cAlias)->(Eof ()) .And. cChave==(cAlias)->TRB_TPREG+(cAlias)->TRB_RELAC+Iif (nItem<>Nil .And. nItem>0, StrZero ((cAlias)->TRB_ITEM, 5, 0),"")
			GravaLinha (nHandle, cAlias)
			//
			(cAlias)->(DbSkip ())
		EndDo
	EndIf
	//
	RestArea (aArea)
Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |GravaLinha³ Autor ³Gustavo G. Rueda       ³ Data ³25.08.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³      GRAVACAO DE UM REGISTRO E MARCA COMO GRAVADO          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Gravo o registro posicionado do TRB e marco ele como ja gra-³±±
±±³          ³ vado evitanto duplicidade.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|nHandle -> Handle do arquivo txt aberto.                    ³±±
±±³          |cAlias -> Alias do TRB criado atraves da funcao principal.  ³±±
±±³          |cTpReg -> Tipo de registro que compoe a chave de pesquisa.  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GravaLinha (nHandle, cAlias)	
	Local	cConteudo := AllTrim ((cAlias)->TRB_CONT)+Chr (13)+Chr (10)	//+"**"+(cAlias)->TRB_RELAC+"**"
	//
	FWrite (nHandle, cConteudo, Len (cConteudo))
	//
	RecLock (cAlias, .F.)
		(cAlias)->TRB_FLAG	:=	"*"
	MsUnLock ()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |GrRegDep  ³ Autor ³Gustavo G. Rueda       ³ Data ³25.08.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³              GRAVO REGISTROS DEPENDENTES                   ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Suponhamos o cabecalho e os itens do documento fiscal, onde ³±±
±±³          ³ o cabecalho eh o pai e os itens eh o filho, portanto tenho ³±±
±±³          ³ varios itens para um pai. Para que esta funcao interprete  ³±±
±±³          ³ este caso, a primeira posicao do registro filho indica a   ³±±
±±³          ³ posicao do registro pai, ou seja, leio a primeira posicao  ³±±
±±³          ³ do array pai e procuro todos os registros itens que possuem³±±
±±³          ³ na primeira posicao a posicao lida do registro pai.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlias -> Alias do TRB criado atraves da funcao principal.  ³±±
±±³          |aRegPai -> Registro Pai.                                    ³±±
±±³          |aRegFilho -> Registro tipo filho (1:N) Varios para cada Pai.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GrRegDep (cAlias, aRegPai, aRegFilho)
	Local	lRet	:=	.T.
	Local	aReg	:=	{}
	Local	nCtd	:=	0
	Local	nZ		:=	0
	Local	nCod	:=	0
	Local	nX		:=	0
	
	For nZ := 1 To Len (aRegPai)
		GrvRegSef (cAlias, nZ, {aRegPai[nZ]})
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³nCod e a posicao lida do E050(pai) que se relaciona com o conteudo da posicao 1 do array E055(detalhe)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aRegFilho) >= 1
    		nCtd := aScan (aRegFilho, {|aX|  aX[10]==nZ})
            If nCtd > 0
			    Do While nCtd <= Len(aRegFilho)
			     	If  (aRegFilho[nCtd][10]==nZ) 
					    aReg	:=	{}
					    For nX := 1 To Len (aRegFilho[nCtd])-1
						    aAdd (aReg, aRegFilho[nCtd][nX])
					    Next (nX)
					    GrvRegSef (cAlias, nZ, {aReg}, nCtd)
				    EndIf
				  	nCtd++
			    EndDo
		    EndIf
		EndIf
	Next (nZ)
Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |GrvIndMov ³ Autor ³Gustavo G. Rueda       ³ Data ³25.08.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³          GRAVACAO DOS INDICADORES DE MOVIMENTO             ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Gravo os indicadores de movimento para todos os registros   ³±±
±±³          ³ a serem gerados.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlias -> Alias do TRB criado atraves da funcao principal.  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GrvIndMov (cAlias,nDocumento)
	Local	lRet		:= .T.
	Local	nQtd0990	:= 0
	Local	nQtdC990	:= 0
	Local	nQtdE990	:= 0
	Local	nQtdH990	:= 0
	Local	nQtd8990	:= 0
	Local	nQtd9990	:= 0
	Local	nQtdG990	:= 0
	Local	nPos		:= 0
	Local	aReg9900	:=	{}
	//
	DbSelectArea (cAlias) 
		(cAlias)->(DbSetOrder (1))
	(cAlias)->(DbGoTop ())
	//
	Do While !(cAlias)->(Eof ())

		If (nPos := aScan (aReg9900, {|aX| aX[2]==(cAlias)->TRB_TPREG}))==0
			aAdd (aReg9900, {"9900",(cAlias)->TRB_TPREG,"1"})
		Else
			aReg9900[nPos][3] := Alltrim(STR( Val( aReg9900[nPos][3] )+1))
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTROS - 0³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (Left ((cAlias)->TRB_TPREG, 1)$"0")
			nQtd0990++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTROS - E³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf (Left ((cAlias)->TRB_TPREG, 1)$"E")
			nQtdE990++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTROS - H³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf (Left ((cAlias)->TRB_TPREG, 1)$"H")
			nQtdH990++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTROS - G³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf (Left ((cAlias)->TRB_TPREG, 1)$"G")
			nQtdG990++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTROS - 8³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf (Left ((cAlias)->TRB_TPREG, 1)$"8")
			nQtd8990++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REGISTROS - C³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf (Left ((cAlias)->TRB_TPREG, 1)$"C")
			nQtdC990++
		EndIf
		//
		(cAlias)->(DbSkip ())
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gravacao do indicador de movimento do bloco 0.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BlAbEnc ("A", cAlias, "0001", Iif (nQtd0990>4, "0", "1"),)
	BlAbEnc ("E", cAlias, "0990",, nQtd0990)
	aAdd (aReg9900, {"9900","0001","1"})
	aAdd (aReg9900, {"9900","0990","1"})
	if nDocumento == 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gravacao do indicador de movimento do bloco E.   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BlAbEnc ("A", cAlias, "E001", Iif (nQtdE990>0, "0", "1"),)
		BlAbEnc ("E", cAlias, "E990",, nQtdE990)
		aAdd (aReg9900, {"9900","E001","1"})
		aAdd (aReg9900, {"9900","E990","1"})
	EndIf
	
	If nDocumento ==4
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gravacao do indicador de movimento do bloco G.   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BlAbEnc ("A", cAlias, "G001", Iif (nQtdG990>0, "0", "1"),)
		BlAbEnc ("E", cAlias, "G990",, nQtdG990)
		aAdd (aReg9900, {"9900","G001","1"})
		aAdd (aReg9900, {"9900","G990","1"})
	EndIf
	
	If nDocumento ==3
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gravacao do indicador de movimento do bloco H.   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BlAbEnc ("A", cAlias, "H001", Iif (nQtdH990>0, "0", "1"),)
		BlAbEnc ("E", cAlias, "H990",, nQtdH990)
		aAdd (aReg9900, {"9900","H001","1"})
		aAdd (aReg9900, {"9900","H990","1"})
	EndIf
	
	If nDocumento ==4
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gravacao do indicador de movimento do bloco 8.   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BlAbEnc ("A", cAlias, "8001", Iif (nQtd8990>0, "0", "1"),"PE",)
		BlAbEnc ("E", cAlias, "8990",, nQtd8990)
		aAdd (aReg9900, {"9900","8001","1"})
		aAdd (aReg9900, {"9900","8990","1"})
	EndIf
	
	If nDocumento ==2
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gravacao do indicador de movimento do bloco C.   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		BlAbEnc ("A", cAlias, "C001", Iif (nQtdC990>0, "0", "1"),"PE",)
		BlAbEnc ("E", cAlias, "C990",, nQtdC990)
		aAdd (aReg9900, {"9900","C001","1"})
		aAdd (aReg9900, {"9900","C990","1"})
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gravacao do bloco 9 (Totalizacao dos registros)  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd (aReg9900, {"9900","9001","1"})
	aAdd (aReg9900, {"9900","9990","1"})
	aAdd (aReg9900, {"9900","9999","1"})
	aAdd (aReg9900, {"9900","9900",Alltrim(Str(Len(aReg9900)+1))})
	Reg9900 (cAlias, aReg9900)
	nQtd9990 := len(aReg9900) + 1
	BlAbEnc ("A", cAlias, "9001", Iif (nQtd0990>4, "0", "1"),)
	BlAbEnc ("E", cAlias, "9990",, nQtd9990)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gravacao do registro 9999 (Encerramento do arquivo) ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Reg9999 (cAlias)

Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |GetSx1    ³ Autor ³Gustavo G. Rueda       ³ Data ³25.08.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³       RETORNO O CONTEUDO DE UMA DETERMINADA PERGUNTA       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Gravo os indicadores de movimento para todos os registros   ³±±
±±³          ³ a serem gerados.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet -> .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cGrupo -> Grupo de perguntas a pesquisar.                   ³±±
±±³          |cGrupo -> ordem da pergunta a pesquisar.                    ³±±
±±³          |lPreSel -> .T. para retornar o conteudo do X1_PRESEL(NUMER) ³±±
±±³          | ou .T. para retornar do X1_CONTEUD.                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GetSx1 (cGrupo, cOrdem, lPreSel)
	Local	xRet	:=	Iif (lPreSel, 0, "")
	//
	DbSelectArea ("SX1")
		SX1->(DbSetOrder (1))
	If (SX1->(DbSeek (cGrupo+cOrdem)))
		If lPreSel
			xRet	:=	SX1->X1_PRESEL
		Else
			xRet	:=	SX1->X1_CNT01
		EndIf
	EndIf
Return (xRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RetCodEst ³ Autor ³ Liber de Esteban      ³ Data ³20.08.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que retorna o codigo da UF do participante, de acordo³±±
±±³          ³com a tabela disponibilizada pelo IBGE.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cCod -> Codigo da UF                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cUf  -> Sigla da UF do cliente/fornecedor                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetCodEst (cUf)
	Local cCod := ""
	//
	Do Case
	Case cUf == "RO" ; cCod := "11" // Rondonia
	Case cUf == "AC" ; cCod := "12" // Acre
	Case cUf == "AM" ; cCod := "13" // Amazonas
	Case cUf == "RR" ; cCod := "14" // Roraima
	Case cUf == "PA" ; cCod := "15" // Para
	Case cUf == "AP" ; cCod := "16" // Amapa
	Case cUf == "TO" ; cCod := "17" // Tocantins
	Case cUf == "MA" ; cCod := "21" // Maranhao
	Case cUf == "PI" ; cCod := "22" // Piaui
	Case cUf == "CE" ; cCod := "23" // Ceara
	Case cUf == "RN" ; cCod := "24" // Rio Gde Norte
	Case cUf == "PB" ; cCod := "25" // Paraiba
	Case cUf == "PE" ; cCod := "26" // Pernambuco
	Case cUf == "AL" ; cCod := "27" // Alagoas
	Case cUf == "SE" ; cCod := "28" // Sergipe
	Case cUf == "BA" ; cCod := "29" // Bahia
	Case cUf == "MG" ; cCod := "31" // Minas Gerais
	Case cUf == "ES" ; cCod := "32" // Espitiro Santo
	Case cUf == "RJ" ; cCod := "33" // Rio de Janeiro
	Case cUf == "SP" ; cCod := "35" // Sao Paulo
	Case cUf == "PR" ; cCod := "41" // Parana
	Case cUf == "SC" ; cCod := "42" // Sta Catarina
	Case cUf == "RS" ; cCod := "43" // Rio Gde Sul
	Case cUf == "MS" ; cCod := "50" // Mato Grosso do Sul
	Case cUf == "MT" ; cCod := "51" // Mato Grosso
	Case cUf == "GO" ; cCod := "52" // Goias
	Case cUf == "DF" ; cCod := "53" // Distrito Federal
	EndCase
	//
Return(cCod)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RetCodCst ³ Autor ³ Liber de Esteban      ³ Data ³20.08.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que retorna a origem da mercadoria(importacao direta,³±±
±±³          ³indireta ou de origem nacinal) para preenchimento do codigo ³±±
±±³          ³da situação tributaria, quando esta nao vem preenchida      ³±±
±±³          ³corretamente.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cRet -> Codigo da origem da mercadoria                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cProd   -> Codigo do produto                                ³±±
±±³          |cFornec -> Codigo do fornecedor                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetCodCst (cAliasSFT,cAlsSA)
	Local	cRet	:= ""
	Local	cA1A2	:=	SubStr (cAlsSA, 3, 1)
	Local	cCmpEst	:=	cAlsSA+"->A"+cA1A2+"_EST"

	If Empty((cAliasSFT)->FT_CLASFIS) .Or. Len(Alltrim((cAliasSFT)->FT_CLASFIS))<>3
		If Empty(SB1->B1_ORIGEM)
			If Empty(SB1->B1_IMPORT) .Or. SB1->B1_IMPORT=="N" 
				cRet := "0"
			Else
				If &(cCmpEst)=="EX"
					cRet := "1"
				Else
					cRet := "2"
				EndIf
			EndIf
		Else
			cRet := SB1->B1_ORIGEM
		EndIf
		//Situacao Tributaria
		cRet += SF4->F4_SITTRIB
	Else
		cRet := (cAliasSFT)->FT_CLASFIS
	EndIf

Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RetCOP    ³ Autor ³ Cecilia Carvalho      ³ Data ³06.11.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que retorna o codigo COP (Classe de Opercao ou       ³±±
±±³          ³servico) de acordo com o CFOP passado.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cCodCOP -> codigo COP                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cCFOP   -> CFOP                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetCOP (cCFOP)
	Local cEA10   := "1101/1102/1111/1113/1116/1117/1118/1120/1121/1122/1126/1128/1251/1252/1253/1254/1255/1256/1257/1401/1403/1406/1407/1551/1556/1651/1652/1653/1933/2101/2102/2111/2113/2116/2117/2118/2120/2121/2122/2126/2128/2251/2252/2253/2254/2255/2256/2257/2401/2403/2406/2407/2551/2556/2651/2652/2653/2933/3101/3102/3126/3127/3128/3251/3551/3556/3651/3652/3653"
	Local cEA20   := "1201/1202/1203/1204/1410/1411/1553/1660/1661/1662/2201/2202/2203/2204/2410/2411/2553/2660/2661/2662/3201/3202/3211/3553"
	Local cEA30   := "1124/1125/1414/1415/1451/1452/1554/1664/1902/1903/1904/1906/1907/1909/1913/1914/1916/1918/1919/1921/1925/2124/2125/2414/2415/2554/2664/2902/2903/2904/2906/2907/2909/2913/2914/2916/2919/2921/2925"
	Local cEA40   := "1503/1504/1505/1506/2503/2504/2505/2506/2918/3503"
	Local cEA50   := "1501/1555/1663/1901/1905/1908/1910/1911/1912/1915/1917/1920/1923/1924/1934/2501/2555/2663/2901/2905/2908/2910/2911/2912/2915/2917/2920/2923/2924/2934/3930"
	Local cEA60   := "1151/1152/1153/1154/1208/1209/1408/1409/1552/1557/1658/1659/2151/2152/2153/2154/2208/2209/2408/2409/2552/2557/2658/2659"
	Local cEA65   := "1926"
	Local cEA70   := "1301/1302/1303/1304/1305/1306/1351/1352/1353/1354/1355/1356/1360/1932/2301/2302/2303/2304/2305/2306/2351/2352/2353/2354/2355/2356/2932/3301/3351/3352/3353/3354/3355/3356"
	Local cEA80   := "1205/1206/1207/2205/2206/2207/3205/3206/3207"
	Local cEA90   := "1601/1602/1604/1605/1922/1931/2922/2931"
	Local cEA91   := "1603/2603"
	Local cEA99   := "1949/2949/3949"
	Local cSP10   := "5101/5102/5103/5104/5105/5106/5109/5110/5111/5112/5113/5114/5115/5116/5117/5118/5119/5120/5122/5123/5251/5252/5253/5254/5255/5256/5257/5258/5401/5402/5403/5405/5551/5651/5652/5653/5654/5655/5656/5667/5933/6101/6102/6103/6104/6105/6106/6107/6108/6109/6110/6111/6112/6113/6114/6115/6116/6117/6118/6119/6120/6122/6123/6251/6252/6253/6254/6255/6256/6257/6258/6401/6402/6403/6404/6551/6651/6652/6653/6654/6655/6656/6667/6933/7101/7102/7105/7106/7127/7251/7501/7551/7651/7654/7667"
	Local cSP20   := "5201/5202/5210/5410/5411/5412/5413/5553/5556/5660/5661/5662/6201/6202/6210/6410/6411/6412/6413/6553/6556/6660/6661/6662/7201/7202/7210/7211/7553/7556/7930"
	Local cSP30   := "5414/5415/5451/5501/5502/5504/5505/5554/5657/5663/5666/5901/5904/5905/5908/5910/5911/5912/5914/5915/5917/5920/5923/5924/5934/6414/6415/6501/6502/6504/6505/6554/6657/6663/6666/6901/6904/6905/6908/6910/6911/6912/6914/6915/6917/6920/6923/6924/6934"
	Local cSP50   := "5124/5125/5503/5555/5664/5665/5902/5903/5906/5907/5909/5913/5916/5918/5919/5921/5925/6124/6125/6208/6209/6503/6555/6664/6665/6902/6903/6906/6907/6909/6913/6916/6918/6919/6921/6925"
	Local cSP60   := "5151/5152/5153/5155/5156/5208/5209/5408/5409/5552/5557/5658/5659/6151/6152/6153/6155/6156/6408/6409/6552/6557/6658/6659"   
	Local cSP65   := "5926/5927/5928"
	Local cSP70   := "5301/5302/5303/5304/5305/5306/5307/5351/5352/5353/5354/5355/5356/5357/5359/5360/5932/6301/6302/6303/6304/6305/6306/6307/6351/6352/6353/6354/6355/6356/6357/6359/6360/6932/7301/7358"
	Local cSP80   := "5205/5206/5207/6205/6206/6207/7205/7206/7207"
	Local cSP90   := "5601/5602/5605/5606/5922/5929/5931/6922/6929/6931"
	Local cSP91   := "5603/6603"
	Local cSP99   := "5949/6949/7949"
	Local cCodCOP := ""
	
	Default cCFOP   := ""
	
    If Val(Substr(cCFOP,1,1)) < 5
        If cCFOP$cEA10
            cCodCOP := "EA10"
        ElseIf cCFOP$cEA20
            cCodCOP := "EA20"
        ElseIf cCFOP$cEA30
            cCodCOP := "EA30"
        ElseIf cCFOP$cEA40
            cCodCOP := "EA40"
        ElseIf cCFOP$cEA50
            cCodCOP := "EA50"
        ElseIf cCFOP$cEA60
            cCodCOP := "EA60"
        ElseIf cCFOP$cEA65
            cCodCOP := "EA65"
        ElseIf cCFOP$cEA70
            cCodCOP := "EA70"
        ElseIf cCFOP$cEA80
            cCodCOP := "EA80"
        ElseIf cCFOP$cEA90
            cCodCOP := "EA90"
        ElseIf cCFOP$cEA91
            cCodCOP := "EA91"
        ElseIf cCFOP$cEA99
            cCodCOP := "EA99"
        Else
            cCodCOP := cCFOP
        EndIf
    Else
        If cCFOP$cSP10
            cCodCOP := "SP10"
        ElseIf cCFOP$cSP20
            cCodCOP := "SP20"
        ElseIf cCFOP$cSP30
            cCodCOP := "SP30"
        ElseIf cCFOP$cSP50
            cCodCOP := "SP50"
        ElseIf cCFOP$cSP60
            cCodCOP := "SP60"
        ElseIf cCFOP$cSP65
            cCodCOP := "SP65"
        ElseIf cCFOP$cSP70
            cCodCOP := "SP70"
        ElseIf cCFOP$cSP80
            cCodCOP := "SP80"
        ElseIf cCFOP$cSP90
            cCodCOP := "SP90"
        ElseIf cCFOP$cSP91
            cCodCOP := "SP91"
        ElseIf cCFOP$cSP99
            cCodCOP := "SP99"
        Else
            cCodCOP := cCFOP
        EndIf
    EndIf   
Return(cCodCOP)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  | Bloco8   ³ Autor ³ Beatriz Scarpa Vilar  ³ Data ³06.11.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna array com os valores acumulados SFT                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aRet                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Bloco8(cAlias, cAliasSFT,cSituaDoc)
Local nPos := 0

	If (cAliasSFT)->FT_TIPOMOV == "S" .And. Val(Substr((cAliasSFT)->FT_CFOP,1,1)) >= 5	
    	If (cAliasSFT)->FT_CPPRODE == 0 
    		If !(cSituaDoc$"90#81#")	
				aBloco8[1] += (cAliasSFT)->FT_VALCONT //Saidas nao incentivadas de PI
			Endif
		ElseIf (cAliasSFT)->FT_CPPRODE <> 0 
			If Val(Substr((cAliasSFT)->FT_CFOP,1,1)) == 6 .And. !((cAliasSFT)->FT_ESTADO $ "AL,BA,CE,MA,PB,PE,PI,RN,SE")
				If !(cSituaDoc$"90#81#")	
	  				aBloco8[2] += (cAliasSFT)->FT_VALCONT //Saidas incentivadas de PI para fora do Nordeste
	  			Endif
	  				aBloco8[9] += (cAliasSFT)->FT_CPPRODE
	  		EndIf
	  		If !(cSituaDoc$"90#81#")
	  			If (cAliasSFT)->FT_TPPRODE == '5' 	  			
	  				aBloco8[3] += (cAliasSFT)->FT_VALCONT -(cAliasSFT)->FT_ICMSRET  //Saidas incentivadas de PI - ICMS-ST
	  			Else
	  				aBloco8[3] += (cAliasSFT)->FT_VALCONT //Saidas incentivadas de PI
	  			Endif	  			
				If Val(Substr((cAliasSFT)->FT_CFOP,1,1)) = 5
					aBloco8[11] += (cAliasSFT)->FT_VALCONT //Saida interna incentivadas de PI					
				Endif
	  		Endif
	  		aBloco8[7]	+= (cAliasSFT)->FT_VALICM			
	  		
	  		If Val(Substr((cAliasSFT)->FT_CFOP,1,1)) >= 6
	  			aBloco8[10] += (cAliasSFT)->FT_CPPRODE
				aBloco8[12] += (cAliasSFT)->FT_VALCONT //Saida interna incentivadas de PI para fora do estado				
	  		Endif
   		EndIf
	aBloco8[14]	:= (cAliasSFT)->FT_ALIQICM		
   	EndIf 
   	
   	If (cAliasSFT)->FT_TIPOMOV == "E" .And. Val(Substr((cAliasSFT)->FT_CFOP,1,1)) < 5	
    	If (cAliasSFT)->FT_CPPRODE == 0 
			aBloco8[4] += (cAliasSFT)->FT_VALCONT //Entradas nao incentivadas de PI
		Else 
	  		aBloco8[5] += (cAliasSFT)->FT_VALCONT //Entradas incentivadas de PI
   		EndIf
   	EndIf 

	If Val(Substr((cAliasSFT)->FT_CFOP,1,1)) == 3 .And. (cAliasSFT)->FT_ICMSDIF > 0
		aBloco8[8] += (cAliasSFT)->FT_VALCONT
		
		// Soma por produto importacao com diferimento
		IF (nPos := aScan(aProdImpo, {|aX| AllTrim(aX[1])==AllTrim((cAliasSFT)->FT_PRODUTO) .and. aX[3]==(cAliasSFT)->FT_NRLIVRO})) > 0
			aProdImpo[nPos][2] += ((cAliasSFT)->FT_VALCONT)		
		Else
			aAdd(aProdImpo, {})
			nPos := Len(aProdImpo)
			aAdd (aProdImpo[nPos], AllTrim((cAliasSFT)->FT_PRODUTO))
			aAdd (aProdImpo[nPos], (cAliasSFT)->FT_VALCONT)
			aAdd (aProdImpo[nPos], (cAliasSFT)->FT_NRLIVRO)
		Endif
		
	Endif
	If !(cSituaDoc$"90#81#")
	 	aBloco8[6]:= (cAliasSFT)->F4_CPPRODE
		If Val(Substr((cAliasSFT)->FT_CFOP,1,1)) >= 6	.And. (cAliasSFT)->FT_CPPRODE <> 0
			aBloco8[13] := (cAliasSFT)->F4_CPPRODE			
		Endif
	Endif

Return .T.        



 /*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RegE080   ³ Autor ³Erick G. Dias          ³ Data ³26.10.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³E080 -  Mapa Resumo  				                          ³±
±±³          ³E085 -  DETALHE VALORES PARCIAIS                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RegE060(aRegE060,aRegE065,dDtIni,dDtFim,cAlias,cChv0450,aWizard)
	Local cAliasSFI := "SFI"
	Local cAliasSIT := "SFT"
	Local nPos		:=0			
	Local nPos65	:=0  
	Local nx	   	:=0  
	Local nVlAcumTot:=0      
	Local nVlAcumBas:=0 		
	Local cCFOP :="" 
	Local cCOP       :=""
	Local lQuery    := .F.                                                
	Local nRelat     :=0 
	Local dDtlast := ""  
	Local lE065  := .T. 
	Local nVlTot03 	:= 0
	Local nVlTot05 	:= 0
	Local lFiCro	:= (cAliasSFI)->(FieldPos("FI_CRO"))>0
	
#IFDEF TOP   	  
   dDtlast := dDtIni     
   for nX:= 0 to (dDtFim-dDtIni)   
		    If TcSrvType()<>"AS/400"
			    cAliasSFI:= "A940aSFI"
			  	lQuery   := .T.
				cAliasSFI	:= GetNextAlias() 
				cQuery := " Select *"
				cQuery += " from "
				cQuery +=   RetSqlName("SFI") + " SFI  "
				cQuery += " WHERE "      
				cQuery += " SFI.FI_FILIAL='"  +  xFilial("SFT") +"'  AND"
				cQuery += " SFI.FI_DTMOVTO>='" +  dtos(dDtlast)   + "' AND "
				cQuery += " SFI.FI_DTMOVTO<='" +  dtos(dDtlast)   + "' AND " 
				cQuery += " SFI.D_E_L_E_T_ <> '*' ORDER BY SFI.FI_PDV "
				cQuery := ChangeQuery(cQuery)			

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSFI)					 											
			Endif 		
		  nVlAcumTot := 0	

			dbSelectArea(cAliasSFI)								
			While (cAliasSFI)->(!Eof())	  			     

			  If TcSrvType()<>"AS/400"
		          cAliasSIT:= "A940aSIT"
		          cAliasSIT	:= GetNextAlias() 
		          cQuery := " Select SFT.FT_PDV, SFI.FI_DTMOVTO, SFT.FT_ALIQICM, SFT.FT_CFOP, SFT.FT_DTCANC, SUM(FT_TOTAL) FT_TOTAL, SUM(FT_BASEICM) FT_BASEICM , SUM(FT_VALICM) FT_VALICM ,"		          
		          cQuery += " SUM(FT_ISENICM) FT_ISENICM, SUM(FT_OUTRICM) FT_OUTRICM, " 
		          cQuery += " SUM(FT_ICMSRET) FT_ICMSRET, SUM(FT_OUTRRET) FT_OUTRRET "  
		          cQuery += " from "
		          cQuery +=   RetSqlName("SFI") + " SFI , "
		          cQuery +=   RetSqlName("SFT") + " SFT "
		          cQuery += " WHERE "  
		          cQuery += " SFI.FI_FILIAL='"  +  xFilial("SFT")+"'  AND"
		          cQuery += " SFI.FI_DTMOVTO>='" + dtos(dDtlast)  + "' AND "
		          cQuery += " SFI.FI_DTMOVTO<='" + dtos(dDtlast)  + "' AND "  		
		          cQuery += " SFI.FI_PDV =	'" + alltrim((cAliasSFI)->FI_PDV)  + "' AND "  
		          cQuery += " SFT.FT_FILIAL= SFI.FI_FILIAL AND SFT.FT_ENTRADA= SFI.FI_DTMOVTO "  
		          cQuery += " AND SFT.FT_PDV = SFI.FI_PDV "
		          cQuery += " AND SFT.D_E_L_E_T_ <> '*' and SFI.D_E_L_E_T_<> '*' "
		          cQuery += " GROUP BY SFI.FI_DTMOVTO, SFT.FT_PDV, SFT.FT_ALIQICM, SFT.FT_CFOP, SFT.FT_DTCANC"
		          cQuery += " ORDER BY SFI.FI_DTMOVTO, SFT.FT_PDV, SFT.FT_ALIQICM, SFT.FT_CFOP"
		          cQuery := ChangeQuery(cQuery)				
		          dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSIT) 	    	
			Endif 				

		   dbSelectArea(cAliasSIT)			    		 
	    	nRelat +=1		
			cCFOP := ""  
			cCOP  := "" 
			nVlAcumTot :=0 
			
			While (cAliasSIT)->(!Eof())  
			  	If (cAliasSIT )->FT_BASEICM>0 .AND. Empty((cAliasSIT)->FT_DTCANC)	// Notas Canceladas não devem entrar no E065                                                                                       				  
					If ((nPos65 := aScan (aRegE065, {|aX| aX[2]==IIf(Empty((cAliasSIT)->FT_DTCANC),(cAliasSIT)->FT_CFOP,"0000") .And. aX[4]==IIf(Empty((cAliasSIT)->FT_DTCANC),(cAliasSIT)->FT_ALIQICM,0)}))==0)								           	
			          	aAdd(aRegE065, {})     
			          	nPos65	:=	Len (aRegE065)	
			          	aAdd (aRegE065[nPos65], "E065") 				  												     //1-LIN
			          	aAdd (aRegE065[nPos65], (cAliasSIT)->FT_CFOP)													    //2-CFOP
						aAdd (aRegE065[nPos65], (cAliasSIT)->FT_BASEICM)												   //3-VL_BC_ICMS_P		              		              					  
			          	aAdd (aRegE065[nPos65], (cAliasSIT)->FT_ALIQICM) 											  //4-ALIQ_ICMS                   	
			          	aAdd (aRegE065[nPos65], NoRound(((aRegE065[nPos65][3]/100) * (cAliasSIT)->FT_ALIQICM)))	 //5-VL_ICMS_P
			          	aAdd (aRegE065[nPos65], "") 																	//6-IND_IMUN 		              
			         	lE065 := .F.   
			       Else   
						aRegE065[nPos65][3] += IIf(Empty((cAliasSIT)->FT_DTCANC),(cAliasSIT)->FT_BASEICM,0)  //3-VL_BC_ICMS_P		              		              					  
			         	lE065 := .F.  
				       
			      	EndIf
	             	nVlAcumbas +=(cAliasSIT)->FT_BASEICM			      					   
	             	nVlAcumTot +=(cAliasSIT)->FT_TOTAL				       			
			   		nVlTot05   += NoRound(((cAliasSIT)->FT_BASEICM * (cAliasSIT)->FT_ALIQICM)/100)
			   		nVlTot03   += (cAliasSIT)->FT_BASEICM
		            
			  	ElseIf (cAliasSIT)->FT_BASEICM==0  .And. "5405"$(cAliasSIT)->FT_CFOP 
	  			   	 
		  			If ((nPos65 := aScan (aRegE065, {|aX| aX[2]==(cAliasSIT)->FT_CFOP}))==0)
					    aAdd(aRegE065, {})
			           nPos65	:=	Len (aRegE065)	                                         
			         	 aAdd (aRegE065[nPos65], "E065") 				      							//1-LIN
			          	 aAdd (aRegE065[nPos65], IIf(Empty((cAliasSIT)->FT_DTCANC),(cAliasSIT)->FT_CFOP,"0000"))       							//2-CFOP
				        aAdd (aRegE065[nPos65], IIf(Empty((cAliasSIT)->FT_DTCANC),(cAliasSFI)->FI_SUBTRIB,0)) 	//3-VL_BC_ICMS_P		              		              
				        aAdd (aRegE065[nPos65], 0)   						  							//4-ALIQ_ICMS                   	
				        aAdd (aRegE065[nPos65], 0)   						  							//5-VL_ICMS_P
				        aAdd (aRegE065[nPos65], "") 				     	  							//6-IND_IMUN  					   					       			
					Else
						aRegE065[nPos65][3] += IIf(Empty((cAliasSIT)->FT_DTCANC),(cAliasSFI)->FI_SUBTRIB,0) 	//3-VL_BC_ICMS_P		              		              				     
					EndIf
				     	nVlAcumTot +=(cAliasSIT)->FT_TOTAL
			         	lE065 := .F. 
			       	  	
			    ElseIf ((nPos65 := aScan (aRegE065, {|aX| aX[2]==(cAliasSIT)->FT_CFOP}))==0)
					aAdd(aRegE065, {})
		  			nPos65	:=	Len (aRegE065)	
			  		aAdd (aRegE065[nPos65], "E065") 				    //1-LIN
			  		aAdd (aRegE065[nPos65], Iif((((cAliasSFI)->FI_GTFINAL-(cAliasSFI)->FI_GTINI)-(cAliasSFI)->FI_CANCEL) > 0,(cAliasSIT)->FT_CFOP,"0000")) 	    //2-CFOP
			  		aAdd (aRegE065[nPos65], 0)    					    //3-VL_BC_ICMS_P
			  		aAdd (aRegE065[nPos65], 0) 					     	//4-ALIQ_ICMS                   	
			  		aAdd (aRegE065[nPos65], 0) 					    	//5-VL_ICMS_P
			  		aAdd (aRegE065[nPos65], "") 				     	//6-IND_IMUN 
			  		lE065 := .F.			       	  
				  	nVlAcumTot +=(cAliasSIT)->FT_TOTAL
				EndIf		
		      	(cAliasSIT)->(DbSkip ())			      	
		      			      	
		  	EndDo   
				    				
			  if lE065				
        		aAdd(aRegE065, {})
  			    nPos65	:=	Len (aRegE065)	
  				aAdd (aRegE065[nPos65], "E065") 				    //1-LIN
  				aAdd (aRegE065[nPos65], "0000")      				//2-CFOP
  				aAdd (aRegE065[nPos65], 0)    						//3-VL_BC_ICMS_P
  				aAdd (aRegE065[nPos65], 0) 							//4-ALIQ_ICMS                   	
  			    aAdd (aRegE065[nPos65], 0) 							//5-VL_ICMS_P
  				aAdd (aRegE065[nPos65], "") 				     	//6-IND_IMUN 	 					 
        	  EndIf 
	     		lE065 := .T.
	        	 
      			dbSelectArea(cAliasSFI)	 
        		//³REGISTRO E060 - LANCAMENTO REDUCAO Z/ICMS
				aAdd(aRegE060, {})			
				nPos	:=	Len (aRegE060)	
				aAdd (aRegE060[nPos], "E060") 																			//1-LIN
				aAdd (aRegE060[nPos], "2D")   																	    	//2-COD_MOD
				aAdd (aRegE060[nPos], StrZero(Val(Right(Alltrim((cAliasSFI)->FI_PDV),3)),3)) 					    	//3-ECF_CX
				aAdd (aRegE060[nPos], (cAliasSFI)->FI_SERPDV) 													  	 	//4-ECF_FAB
				aAdd (aRegE060[nPos], IIF(lFiCro,PADR((cAliasSFI)->FI_CRO,3),"0")) 		//5-CRO
				aAdd (aRegE060[nPos], (cAliasSFI)->FI_NUMREDZ) 												   	 	//6-CRZ
				aAdd (aRegE060[nPos], stod((cAliasSFI)->FI_DTMOVTO)) 											     	//7-DT_DOC
				aAdd (aRegE060[nPos], (cAliasSFI)->FI_NUMINI) 													   	 	//8-NUM_DOC_INI
				aAdd (aRegE060[nPos], (cAliasSFI)->FI_NUMFIM) 														 	//9-NUM_DOC_FIN
				aAdd (aRegE060[nPos], (cAliasSFI)->FI_GTINI)  														 	//10-GT_INI
				aAdd (aRegE060[nPos], (cAliasSFI)->FI_GTFINAL) 												 		//11-GT_FIM
				aAdd (aRegE060[nPos], ((cAliasSFI)->FI_GTFINAL-(cAliasSFI)->FI_GTINI)) 								//12-VL_BRT
				aAdd (aRegE060[nPos], (cAliasSFI)->FI_CANCEL)  												 		//13-VL_CANC_ICMS
				aAdd (aRegE060[nPos], (cAliasSFI)->FI_DESC)    											   			//14-VL_DESC_ICMS
				aAdd (aRegE060[nPos], 0)                       											   		  		//15-VL_ACMO_ICMS
				aAdd (aRegE060[nPos], (cAliasSFI)->FI_ISS)     														//16-VL_OP_ISS
				aAdd (aRegE060[nPos], Abs(aRegE060[nPos][12] - (aRegE060[nPos][16] + aRegE060[nPos][13] + aRegE060[nPos][14])))  			//17- VL_LIQ
				
				aAdd (aRegE060[nPos], nVlTot03)			 																//18-VL_BC_ICMS
				aAdd (aRegE060[nPos], nVlTot05)					 												 		//19-VL_ICMS
				aAdd (aRegE060[nPos], Abs((cAliasSFI)->FI_ISENTO))													//20-VL_ISN
				aAdd (aRegE060[nPos], (cAliasSFI)->FI_NTRIB)   														//21-VL_NT
				aAdd (aRegE060[nPos], (cAliasSFI)->FI_SUBTRIB) 														//22-VL_ST
				aAdd (aRegE060[nPos], "")                     													    	//23-COD_INF_OBS
	        	nVlAcumTot :=0   
			    GrvRegSef (cAlias,nRelat,aRegE060)   
				GrvRegSef (cAlias,nRelat,aRegE065)    
			 	aRegE060 :={}
			 	aRegE065 :={}  
			   	(cAliasSFI)->(DbSkip ()) 
			   	                                                          
			   	nVlTot03 := 0 
			   	nVlTot05 := 0 						 
			EndDo 				
		dDtlast:= dDtlast + 1	 
 next nX             

If (TcSrvType() <> "AS/400")
	DbSelectArea (cAliasSFI)
	(cAliasSFI)->(DbCloseArea ())
EndIf 

#ENDIF				 	
Return  

 /*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |RegE080   ³ Autor ³Erick G. Dias          ³ Data ³26.10.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³E060 -  LANÇAMENTO - REDUÇÃO Z/ICMS                         ³±±
±±³          ³E055 -  DETALHE VALORES PARCIAIS                            ³±±
±±³          ³E080 -  LANCAMENTO - MAPA RESUMO DE ECF/ICMS                ³±±
±±³          ³- Geracao do Registro E060, E065 E E080                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegE080(aRegE080,aRegE085,dDtIni,dDtFim,cAlias,cChv0450,aWizard)
	Local cAliasSFI := "SFI"
	Local cAliasSIT := "SFT"		
	Local nPos80	:=0  	
	Local nx	   	:=0  	
	Local nNumOrdmp :=0  
	Local nVbru00   :=0  
	Local nCancel   :=0 
	Local nDesc     :=0                    
	Local nIss      :=0                    
	Local nVlCont   :=0                    
	Local nVlIcmsDeb :=0                    
	Local nTotnVl_NT :=0                    
	Local nTotnVl_ST :=0  
	Local nVlAcumTot:=0 
	Local nVlAcumMes:=0 
	Local cCFOP :="" 
	Local cCOP       :=""
	Local lQuery    := .F.     
	Local nRelat     :=0 
	Local nPos85     :=0
	Local dDtlast := ""
	
	#IFNDEF TOP 
			Return 
	#ENDIF   
	  
   dDtlast := dDtIni     
   for nX:= 0 to (dDtFim-dDtIni)   
	    If TcSrvType()<>"AS/400"
		    cAliasSFI:= "A940aSFI"
		  	lQuery   := .T.
			cAliasSFI	:= GetNextAlias()     			
			cQuery := " SELECT "
			cQuery += " SFI.FI_DTMOVTO, sum(SFI.FI_GTFINAL) FI_GTFINAL, SUM(SFI.FI_GTINI) FI_GTINI," 
			cQuery += " SUM(SFI.FI_DESC) FI_DESC, SUM(SFI.FI_CANCEL) FI_CANCEl," 
			cQuery += " SUM(SFI.FI_ISS) FI_ISS, SUM(SFI.FI_VALCON) FI_VALCON, SUM(SFI.FI_ISENTO) FI_ISENTO," 
			cQuery += " SUM(SFI.FI_IMPDEBT) FI_IMPDEBT, SUM(SFI.FI_SUBTRIB) FI_SUBTRIB , SUM(SFI.FI_NTRIB) FI_NTRIB "
			cQuery += " FROM "
			cQuery +=   RetSqlName("SFI") + " SFI  "
			cQuery += " WHERE "      
			cQuery += " SFI.FI_FILIAL='"  +  xFilial("SFI") +"' AND"
			cQuery += " SFI.FI_DTMOVTO>='" +  dtos(dDtlast)   + "' AND"
			cQuery += " SFI.FI_DTMOVTO<='" +  dtos(dDtlast)   + "' AND"	
			cQuery += "	SFI.D_E_L_E_T_ = ' ' "
   			cQuery += " GROUP BY SFI.FI_DTMOVTO ORDER BY SFI.FI_DTMOVTO "
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSFI)	
		Endif
		
		dbSelectArea(cAliasSFI)								
		While (cAliasSFI)->(!Eof())	    
		    	   		 	
		
		#IFDEF TOP   
		    If TcSrvType()<>"AS/400"
			    cAliasSIT:= "A940aSIT"
				cAliasSIT	:= GetNextAlias() 
				cQuery := " Select   SFI.FI_DTMOVTO, SFT.FT_ALIQICM, SFT.FT_CFOP, SFT.FT_DTCANC, SUM(FT_BASEICM) FT_BASEICM , SUM(FT_VALICM) FT_VALICM ,"
		 		cQuery += "	 SUM(FT_ISENICM) FT_ISENICM, SUM(FT_OUTRICM) FT_OUTRICM, " 
				cQuery += "  SUM(FT_ICMSRET) FT_ICMSRET, SUM(FT_OUTRRET) FT_OUTRRET, SUM(FT_VALCONT) FT_VALCONT "  
				cQuery += " from "
				cQuery +=   RetSqlName("SFI") + " SFI , "
				cQuery +=   RetSqlName("SFT") + " SFT "
				cQuery += " WHERE "  
   			  	cQuery += " SFI.FI_FILIAL='"  +  xFilial("SFI")+"'  AND"
				cQuery += " SFI.FI_DTMOVTO>='" + dtos(dDtlast)  + "' AND "
				cQuery += " SFI.FI_DTMOVTO<='" + dtos(dDtlast)  + "' AND "  
				cQuery += "	SFI.FI_FILIAL= SFT.FT_FILIAL AND  SFT.FT_PDV = SFI.FI_PDV AND SFT.FT_ENTRADA= SFI.FI_DTMOVTO AND SFI.D_E_L_E_T_ = ' ' AND SFT.D_E_L_E_T_ = ' ' "
				cQuery += " GROUP BY SFI.FI_DTMOVTO, SFT.FT_ALIQICM, SFT.FT_CFOP, SFT.FT_DTCANC"
				cQuery += " ORDER BY SFI.FI_DTMOVTO, SFT.FT_ALIQICM, SFT.FT_CFOP"
				cQuery := ChangeQuery(cQuery)				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSIT)	    				
			Endif
		#ENDIF	 
		
		   	dbSelectArea(cAliasSIT)			    		 
	    	nRelat +=1		
			cCFOP := ""  
			cCOP  := "" 
			nVlAcumTot :=0   
		
			 While (cAliasSIT)->(!Eof()) 
			 		
			   	If !Empty(Alltrim((cAliasSIT)->FT_CFOP))
	        		cCOP := RetCOP(@Alltrim((cAliasSIT)->FT_CFOP))
	       	 	EndIf 
	       	 	If ((nPos85 := aScan (aRegE085, {|aX| aX[4]==(cAliasSIT)->FT_CFOP}))==0)     
		           	aAdd(aRegE085, {})
					nPos85	:=	Len (aRegE085)	
					aAdd (aRegE085[nPos85], "E085")				   		   	   					//01-LIN
					aAdd (aRegE085[nPos85], (cAliasSIT)->FT_VALCONT ) 	   						//02-VL_CONT_P
					aAdd (aRegE085[nPos85], 0)      											//03-VL_OP_ISS_P
					aAdd (aRegE085[nPos85], (cAliasSIT)->FT_CFOP)  	       					//04-CFOP
					aAdd (aRegE085[nPos85], IIf(Empty((cAliasSIT)->FT_DTCANC),(cAliasSIT)->FT_BASEICM,0))							//05-VL_BC_ICMS_P
					aAdd (aRegE085[nPos85], (cAliasSIT)->FT_ALIQICM )     						//06-ALIQ_ICMS
		            aAdd (aRegE085[nPos85], NoRound(((aRegE085[nPos85][5]/100) * (cAliasSIT)->FT_ALIQICM)))	//7-VL_ICMS_P				
					aAdd (aRegE085[nPos85], (cAliasSIT)->FT_ISENICM + (cAliasSIT)->FT_OUTRICM)  //08-VL_ISNT_ICMS_P
					aAdd (aRegE085[nPos85], IIf("5405"$(cAliasSIT)->FT_CFOP,(cAliasSIT)->FT_VALCONT,(cAliasSIT)->FT_ICMSRET + (cAliasSIT)->FT_OUTRRET))  //09-VL_ST_P
					aAdd (aRegE085[nPos85], "")    				   		   						//10-IND_IMUN   																					  					  					  								
				Else
					aRegE085[nPos85][2] += (cAliasSIT)->FT_VALCONT 	   						//02-VL_CONT_P
					aRegE085[nPos85][5] += IIf(Empty((cAliasSIT)->FT_DTCANC),(cAliasSIT)->FT_BASEICM,0)								//05-VL_BC_ICMS_P
		            aRegE085[nPos85][7] += NoRound(((aRegE085[nPos85][5]/100) * (cAliasSIT)->FT_ALIQICM))	//7-VL_ICMS_P				
					aRegE085[nPos85][8] += (cAliasSIT)->FT_ISENICM + (cAliasSIT)->FT_OUTRICM  //08-VL_ISNT_ICMS_P
					aRegE085[nPos85][9] += IIf("5405"$(cAliasSIT)->FT_CFOP,(cAliasSIT)->FT_VALCONT,(cAliasSIT)->FT_ICMSRET + (cAliasSIT)->FT_OUTRRET)  //09-VL_ST_P						
				EndIf
					nVlAcumTot	 += IIf(Empty((cAliasSIT)->FT_DTCANC),(cAliasSIT)->FT_BASEICM,0)
																						  					  					  								
	    	(cAliasSIT)->(DbSkip ())  			  						 
			EndDo  
			
	        If (TcSrvType ()<>"AS/400")
				DbSelectArea (cAliasSIT)
				(cAliasSIT)->(DbCloseArea ())
        	Endif     			
			
	    	//³REGISTRO E080 - LANCAMENTO MAPA RESUMO DE ECF/ICMS³gerado por dia (IND_TOT igual a zero)
		  	aAdd(aRegE080, {})
			nPos80	:=	Len (aRegE080)	
			aAdd (aRegE080[nPos80], "E080") 														//1-LIN
			aAdd (aRegE080[nPos80], "0")    													   	//2-IND_TOT
			aAdd (aRegE080[nPos80], "2D")   														//3-COD_MOD
			aAdd (aRegE080[nPos80], SubStr((cAliasSFI)->FI_DTMOVTO,7,2) )							//4-NUM_MR
			aAdd (aRegE080[nPos80], stod((cAliasSFI)->FI_DTMOVTO)) 						     	//5-DT_DOC
			aAdd (aRegE080[nPos80], (cAliasSFI)->FI_GTFINAL-(cAliasSFI)->FI_GTINI) 				//6-VL_BRT
			aAdd (aRegE080[nPos80], (cAliasSFI)->FI_CANCEL) 										//7-VL_CANC_ICMS
			aAdd (aRegE080[nPos80], (cAliasSFI)->FI_DESC)   									    //8-VL_DESC_ICMS
			aAdd (aRegE080[nPos80], 0)                          								    //9-VL_ACMO_ICMS
			aAdd (aRegE080[nPos80], (cAliasSFI)->FI_ISS)    										//10-VL_OP_ISS
			aAdd (aRegE080[nPos80], cCOP)                   									 	//11-COP
			aAdd (aRegE080[nPos80], "")					                                         	//12- NUM_LACTO - não sera alimentado este campo
			aAdd (aRegE080[nPos80], nVlAcumTot + (cAliasSFI)->FI_ISENTO +(cAliasSFI)->FI_NTRIB + (cAliasSFI)->FI_SUBTRIB) //13-VL_CONT				
			aAdd (aRegE080[nPos80], nVlAcumTot)														//14-VL_BC_ICMS
			aAdd (aRegE080[nPos80], (cAliasSFI)->FI_IMPDEBT)										//15-VL_ICMS 
			aAdd (aRegE080[nPos80], (cAliasSFI)->FI_NTRIB+(cAliasSFI)->FI_ISENTO)			       	//16-VL_INST_ICMS
			aAdd (aRegE080[nPos80], (cAliasSFI)->FI_SUBTRIB)                                      	//17-VL_ST 
			aAdd (aRegE080[nPos80], 0)                     										    //18-IND_OBS     
                  
			//ACUMULA VALORES DIARIOS PARA GERAR REGE080 MENSAL
			nVbru00 	+= ((cAliasSFI)->FI_GTFINAL-(cAliasSFI)->FI_GTINI)  
			nCancel 	+=(cAliasSFI)->FI_CANCEL
			nDesc 		+=(cAliasSFI)->FI_DESC 
			nIss 		+=(cAliasSFI)->FI_ISS
			nVlCont 	+=(cAliasSFI)->FI_VALCON                                     
			nVlIcmsDeb	+= (cAliasSFI)->FI_IMPDEBT
			nTotnVl_NT	+=(cAliasSFI)->FI_ISENTO+(cAliasSFI)->FI_NTRIB
			nTotnVl_ST 	+=(cAliasSFI)->FI_SUBTRIB
			nVlAcumMes 	+=(cAliasSFI)->FI_VALCON - ((cAliasSFI)->FI_ISENTO + (cAliasSFI)->FI_NTRIB +(cAliasSFI)->FI_DESC)		    
 		    
   			GrvRegSef (cAlias,nRelat,aRegE080)   
			GrvRegSef (cAlias,nRelat,aRegE085)                 
   			aRegE080 :={}
  	    	aRegE085 :={}
	   		(cAliasSFI )->(DbSkip ())    	    						 
   		EndDo	    

   		If (TcSrvType ()<>"AS/400")	 
			DbSelectArea (cAliasSFI)	
			(cAliasSFI)->(DbCloseArea ())
   		EndIf	 

		dDtlast:= dDtlast + 1	 
 	next nX   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³REGISTRO E080 - LANCAMENTO MAPA RESUMO DE ECF/ICMS³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Totalizador do registro E080, que é por mês(IND_TOT igual a um)
	IF Len (aRegE080)> 0	
		aAdd(aRegE080, {})
		nPos80	:=	Len (aRegE080)	
		aAdd (aRegE080[nPos80], "E080")     //1-LIN
		aAdd (aRegE080[nPos80], "1")        //2-IND_TOT
		aAdd (aRegE080[nPos80], "2D")       //3-COD_MOD
		aAdd (aRegE080[nPos80], nNumOrdmp)  //4-NUM_MR
		aAdd (aRegE080[nPos80], "")         //5-DT_DOC
		aAdd (aRegE080[nPos80], nVbru00)    //6-VL_BTR
		aAdd (aRegE080[nPos80], nCancel)    //7-VL_CANC_ICMS
		aAdd (aRegE080[nPos80], nDesc)      //8-VL_DESC_ICMS
		aAdd (aRegE080[nPos80], 0)          //9-VL_ACMO_ICMS
		aAdd (aRegE080[nPos80], nIss)       //10-VL_OP_ISS 
		aAdd (aRegE080[nPos80], cCOP)       //11-COP
		aAdd (aRegE080[nPos80], space(9))   //12- NUM_LACTO	
		aAdd (aRegE080[nPos80], nVlCont)    //13-VL_CONT
		aAdd (aRegE080[nPos80], nVlAcumMes) //14-VL_BC_ICMS 
		aAdd (aRegE080[nPos80], nVlIcmsDeb) //15-VL_ICMS	
		aAdd (aRegE080[nPos80], nTotnVl_NT) //16-VL_ISNT_ICMS
		aAdd (aRegE080[nPos80], nTotnVl_ST) //17-VL_ST
		aAdd (aRegE080[nPos80], 0)          //18-IND_OBS				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³GRAVACAO REGISTRO E080 - LANCAMENTO MAPA RESUMO DE ECF/ICMS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		GrvRegSef (cAlias,nRelat +1 , aRegE080) 
	EndIf															 	
Return
						
 /*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±³Programa  |SelSFT    ³ Autor ³Mauro A. Goncalves     ³ Data ³14.11.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Seleciona as informacoes da SFT                             ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SelSFT(dDataDe, dDataAte, cNrLivro, cTpMov)

Local cAliasSFT := "SFT"
Local cSelect := ""
Local cFrom := ""
Local cWhere := ""
		
DbSelectArea (cAliasSFT)
(cAliasSFT)->(DbSetOrder(2))
		
#IFDEF TOP
	If (TcSrvType ()<>"AS/400")
		
		// *** SELECT ***
		
		cSelect := "SFT.FT_FILIAL,SFT.FT_TIPOMOV,SFT.FT_SERIE,SFT.FT_NFISCAL,SFT.FT_CLIEFOR,SFT.FT_LOJA,SFT.FT_ITEM, "
		cSelect += "SFT.FT_PRODUTO,SFT.FT_ENTRADA,SFT.FT_NRLIVRO,SFT.FT_CFOP,SFT.FT_ESPECIE,SFT.FT_TIPO,SFT.FT_EMISSAO, "
		cSelect += "SFT.FT_DTCANC,SFT.FT_FORMUL,SFT.FT_ALIQPIS,SFT.FT_VALPIS,SFT.FT_ALIQCOF,SFT.FT_VALCOF,SFT.FT_VALCONT, "
		cSelect += "SFT.FT_BASEICM,SFT.FT_VALICM,SFT.FT_ISSST,SFT.FT_BASERET,SFT.FT_ICMSRET,SFT.FT_VALIPI,SFT.FT_ISENICM, "
		cSelect += "SFT.FT_SEGURO,SFT.FT_DESPESA,SFT.FT_OUTRICM,SFT.FT_BASEIPI,SFT.FT_ISENIPI,SFT.FT_OUTRIPI,SFT.FT_ICMSCOM, "
		cSelect += "SFT.FT_BASEIRR,SFT.FT_ALIQICM,SFT.FT_ALIQIPI,SFT.FT_CTIPI,SFT.FT_POSIPI,SFT.FT_CLASFIS,SFT.FT_PRCUNIT, "
		cSelect += "SFT.FT_ESTADO,SFT.FT_CODISS,SFT.FT_ALIQIRR,SFT.FT_VALIRR,SFT.FT_BASEINS,SFT.FT_VALINS,SFT.FT_PDV, "
		cSelect += "SFT.FT_ISENRET, SFT.FT_OUTRRET,SFT.FT_OBSERV,SFT.FT_CHVNFE,SFT.FT_CPPRODE,SFT.FT_VALANTI,SFT.FT_TPPRODE, " 
		cSelect += "SFT.FT_QUANT,SFT.FT_DESCONT,SFT.FT_TOTAL,SFT.FT_FRETE,SFT.FT_RECISS,SFT.FT_CFPS,SFT.FT_ISSSUB,SFT.FT_ICMSDIF, "
		cSelect += "SFT.FT_ALIQSOL,SF4.F4_CPPRODE,SF4.F4_COP,SFT.FT_CONTA, "     //(ADCIONADO)

		cSelect += "SF3.R_E_C_N_O_ SF3RECNO, "
		cSelect += "SF4.R_E_C_N_O_ SF4RECNO, "
		cSelect += "SB1.R_E_C_N_O_ SB1RECNO, "
		cSelect += "SA1.R_E_C_N_O_ SA1RECNO, "
		cSelect += "SA2.R_E_C_N_O_ SA2RECNO, "
		cSelect += "SE4.R_E_C_N_O_ SE4RECNO, "
		
		If cTpmov == "E"
			cSelect += "SD1.R_E_C_N_O_ SDRECNO, "
			cSelect += "SF1.R_E_C_N_O_ SFRECNO "
		Else
			cSelect += "SD2.R_E_C_N_O_ SDRECNO, "
			cSelect += "SF2.R_E_C_N_O_ SFRECNO"
		EndIf
		
		// *** FROM ***
		
		cFrom := RetSQLName("SFT") + " SFT "
		
		cFrom += "LEFT JOIN " + RetSqlName("SB1") + " SB1 ON (SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD = SFT.FT_PRODUTO AND SB1.D_E_L_E_T_ = ' ') "
		cFrom += "LEFT JOIN " + RetSqlName("SA1") + " SA1 ON (SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND SA1.A1_COD = SFT.FT_CLIEFOR AND SA1.A1_LOJA = SFT.FT_LOJA AND SA1.D_E_L_E_T_ = ' ') "
		cFrom += "LEFT JOIN " + RetSqlName("SA2") + " SA2 ON (SA2.A2_FILIAL = '" + xFilial("SA2") + "' AND SA2.A2_COD = SFT.FT_CLIEFOR AND SA2.A2_LOJA = SFT.FT_LOJA AND SA2.D_E_L_E_T_ = ' ') "
	
		If cTpMov == "E"
			cFrom += "LEFT JOIN " + RetSqlName("SD1") + " SD1 ON (SD1.D1_FILIAL = '" + xFilial("SD1") + "' AND SD1.D1_DOC = SFT.FT_NFISCAL AND SD1.D1_SERIE = SFT.FT_SERIE AND SD1.D1_FORNECE = SFT.FT_CLIEFOR AND SD1.D1_LOJA = SFT.FT_LOJA AND SD1.D1_COD = SFT.FT_PRODUTO AND SD1.D1_ITEM = SFT.FT_ITEM AND SD1.D_E_L_E_T_ = ' ') "
			cFrom += "LEFT JOIN " + RetSqlName("SF1") + " SF1 ON (SF1.F1_FILIAL = '" + xFilial("SF1") + "' AND SF1.F1_DOC = SFT.FT_NFISCAL AND SF1.F1_SERIE = SFT.FT_SERIE AND SF1.F1_FORNECE = SFT.FT_CLIEFOR AND SF1.F1_LOJA = SFT.FT_LOJA AND SF1.D_E_L_E_T_ = ' ') "
			cFrom += "LEFT JOIN " + RetSqlName("SF4") + " SF4 ON (SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND SF4.F4_CODIGO = SD1.D1_TES AND SF4.D_E_L_E_T_ = ' ') "
			cFrom += "LEFT JOIN " + RetSqlName("SF3") + " SF3 ON (SF3.F3_FILIAL = '" + xFilial("SF3") + "' AND SF3.F3_CFO < '5' AND SF3.F3_SERIE = SFT.FT_SERIE AND SF3.F3_NFISCAL = SFT.FT_NFISCAL AND SF3.F3_CLIEFOR = SFT.FT_CLIEFOR AND SF3.F3_LOJA = SFT.FT_LOJA AND SF3.F3_IDENTFT = SFT.FT_IDENTF3 AND SF3.F3_ENTRADA = SFT.FT_ENTRADA AND SF3.D_E_L_E_T_ = ' ') "
			cFrom += "LEFT JOIN " + RetSqlName("SE4") + " SE4 ON (SE4.E4_FILIAL = '" + xFilial("SE4") + "' AND SF1.F1_COND = SE4.E4_CODIGO AND SE4.D_E_L_E_T_ = ' ') "
		Else
			cFrom += "LEFT JOIN " + RetSqlName("SD2") + " SD2 ON (SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND SD2.D2_DOC = SFT.FT_NFISCAL AND SD2.D2_SERIE = SFT.FT_SERIE AND SD2.D2_CLIENTE = SFT.FT_CLIEFOR AND SD2.D2_LOJA = SFT.FT_LOJA AND SD2.D2_COD = SFT.FT_PRODUTO AND SD2.D2_ITEM = SFT.FT_ITEM AND SD2.D_E_L_E_T_ = ' ') "
			cFrom += "LEFT JOIN " + RetSqlName("SF2") + " SF2 ON (SF2.F2_FILIAL = '" + xFilial("SF2") + "' AND SF2.F2_DOC = SFT.FT_NFISCAL AND SF2.F2_SERIE = SFT.FT_SERIE AND SF2.F2_CLIENTE = SFT.FT_CLIEFOR AND SF2.F2_LOJA = SFT.FT_LOJA AND SF2.D_E_L_E_T_ = ' ') "
			cFrom += "LEFT JOIN " + RetSqlName("SF4") + " SF4 ON (SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND SF4.F4_CODIGO = SD2.D2_TES AND SF4.D_E_L_E_T_ = ' ') "
			cFrom += "LEFT JOIN " + RetSqlName("SF3") + " SF3 ON (SF3.F3_FILIAL = '" + xFilial("SF3") + "' AND SF3.F3_CFO > '4' AND SF3.F3_SERIE = SFT.FT_SERIE AND SF3.F3_NFISCAL = SFT.FT_NFISCAL AND SF3.F3_CLIEFOR = SFT.FT_CLIEFOR AND SF3.F3_LOJA = SFT.FT_LOJA AND SF3.F3_IDENTFT = SFT.FT_IDENTF3 AND SF3.F3_ENTRADA = SFT.FT_ENTRADA AND SF3.D_E_L_E_T_ = ' ') "
			cFrom += "LEFT JOIN " + RetSqlName("SE4") + " SE4 ON (SE4.E4_FILIAL = '" + xFilial("SE4") + "' AND SF2.F2_COND = SE4.E4_CODIGO AND SE4.D_E_L_E_T_ = ' ') "
		EndIf				
		
		// *** WHERE ***
		
		cWhere := "SFT.FT_FILIAL = '" + xFilial("SFT") + "' AND "
		cWhere += "SFT.FT_TIPOMOV = '" + cTpMov + "' AND "
		cWhere += "SFT.FT_ENTRADA >= '" + DToS(dDataDe) + "' AND "
		cWhere += "SFT.FT_ENTRADA <= '" + DToS(dDataAte) + "' AND "
		cWhere += "((SFT.FT_CFOP NOT LIKE '000%' AND SFT.FT_CFOP NOT LIKE '999%') OR SFT.FT_TIPO = 'S') AND "
				
		If cNrLivro <> "*"
			cWhere += " SFT.FT_NRLIVRO = '" + %Exp:(cNrLivro)% + "' AND "
		EndIf
		
		cWhere += "SFT.D_E_L_E_T_ = ' '"			
    	// Formatando strings para execucao do BeginSQL
    	
		cSelect := "%" + cSelect + "%"
		cFrom   := "%" + cFrom   + "%"
		cWhere  := "%" + cWhere  + "%"
    	
    	// Execucao da query
    	
    	cAliasSFT	:=	GetNextAlias()
    	
    	BeginSql Alias cAliasSFT
		
			COLUMN FT_EMISSAO AS DATE
	    	COLUMN FT_ENTRADA AS DATE
    		COLUMN FT_DTCANC AS DATE
    	
			SELECT 			
				%Exp:cSelect%
			FROM 
				%Exp:cFrom%				
			WHERE 
				%Exp:cWhere%
			ORDER BY 1,2,3,4,5,6,7,8
		EndSql
	Else
#ENDIF
		cIndex	:= CriaTrab(NIL,.F.)
		cWhere := 'FT_FILIAL == "' + xFilial("SFT") + '".And. '
		cWhere += 'FT_TIPOMOV == "' + cTpMov + '" .And. '
		cWhere += 'DToS(FT_ENTRADA) >= "' + DToS(dDataDe) + '" .And. DToS(FT_ENTRADA) <= "' + DToS(dDataAte) + '" .And. '
		cWhere += '(!SubStr(FT_CFOP,1,3) $ "999/000" .Or. FT_TIPO == "S")'

		If (cNrLivro <> "*")
			cWhere += ' .And. FT_NRLIVRO == "' + cNrLivro + '" '
		EndIf
	
		IndRegua(cAliasSFT,cIndex,SFT->(IndexKey()),,cWhere,,.F.)
		nIndex := RetIndex(cAliasSFT)
#IFNDEF TOP
		DbSetIndex(cIndex + OrdBagExt()) 
#ENDIF	
		DbSelectArea(cAliasSFT)
		DbSetOrder(nIndex + 1)		    
#IFDEF TOP
	EndIf
#ENDIF
	
DbSelectArea(cAliasSFT)
(cAliasSFT)->(DbGoTop())

ProcRegua((cAliasSFT)->(RecCount()))
		
Return cAliasSFT

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg8505

Descr. 8505 GIAF - BENEFÍCIOS FISCAIS

Nível hierárquico: 4 

@return .T. / .F.
		
@author Jorge Souza
@since 09/12/2014
@version 11 

//-------------------------------------------------------------------
///*/
Static Function Reg8505 (cAlias, cAliasSFT, aReg8505, cSituaDoc, aWizard, nRelac, aReg8510, aReg8515, aReg8525,cNrLvSub,aMVPROPERC)
//Static nRelAnt
Local	nPos		:=	0
Local	lRet		:=	.T. 
Local cNatBen := ""
Local nNumBen := ""
Local dDtDecre := ""
Local cBenQd8	:=	""
Local lGrava	:= .F.

Default aMVPROPERC := {}
	
If SB5->(dbSeek (xFilial ("SB5")+(cAliasSFT)->FT_PRODUTO))
	cNatBen := SB5->B5_NATBEN
	nNumBen := SB5->B5_NUMBEN
	dDtDecre := SB5->B5_DTDECRE
EndIf 

/*
1- Indústria (crédito presumido)
*/

	If aScan(aReg8505, {|x| x[3]==nNumBen})==0 
		If ((((cAliasSFT)->FT_CPPRODE>0 ) .And. !((cAliasSFT)->FT_TPPRODE $ " #0")) .Or. ((cAliasSFT)->FT_TPPRODE$"#1#2#3#4#5#6"))
				
			If Left ((cAliasSFT)->FT_TPPRODE, 1)$"1#2#3"
				cBenQd8 :=  "1"
			Elseif Left ((cAliasSFT)->FT_TPPRODE, 1)$"4#5"
				cBenQd8 :=  "4"
			Elseif Left ((cAliasSFT)->FT_TPPRODE, 1)$"6"
				cBenQd8 :=  "3"
			Endif
		
			aAdd(aReg8505, {})
			nPos	:=	Len (aReg8505)
			aAdd (aReg8505[nPos], "8505")	 							//01 - REG		
			aAdd (aReg8505[nPos], cBenQd8)								//02 - IND_BF
			aAdd (aReg8505[nPos], nNumBen) 								//03 - DE_BF                              
			aAdd (aReg8505[nPos], iif(empty(dDtDecre),'',dDtDecre))		//04 - DT_BF
			aAdd (aReg8505[nPos], Right(cNatBen,1))	        			//05 - IND_NAT
			aAdd (aReg8505[nPos], 0)			 						//06 - IND_ICMS_MIN
			lGrava := .T.
		Elseif aScan(aReg8505, {|x| x[2]=="0"})==0 
			aAdd(aReg8505, {})
			nPos	:=	Len (aReg8505)
			aAdd (aReg8505[nPos], "8505")	 						//01 - REG
			aAdd (aReg8505[nPos], "0")								//02 - IND_BF
			aAdd (aReg8505[nPos], "") 								//03 - DE_BF                              
			aAdd (aReg8505[nPos], "")			 					//04 - DT_BF 
			aAdd (aReg8505[nPos], "")	        					//05 - IND_NAT
			aAdd (aReg8505[nPos], "1")								//06 - IND_ICMS_MIN
			lGrava := .T.
			
			//Quando produto possui incentivo mas esta no livro de não incentivadas // operação de entrada industrial
			//Devido relação dos registro 5805/8515 considerar numero do beneficio, retorno 0 conforme tratamento ja realizado nos registros 8510 e 8525
			nNumBen := '0'
		Endif		
		If lGrava
			aReg := {}
			aAdd( aReg, aReg8505[nPos])
			GrvRegSef (cAlias,Val(nNumBen),aReg)	
		Endif

	Endif
	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³8510 - GIAF - AJUSTES DO BENEFICIOS  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Reg8510 (cAlias, cAliasSFT, @aReg8510, cSituaDoc, aWizard)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GRAVACAO - 8515  SUB-APURAÇÕES POR BENEFÍCIO ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Reg8515(cAlias, @aReg8515, aWizard,cNrLvSub,cAliasSFT,nNumBen)

//ADICIONA O ITEM INCENTIVADO (PI) POR BENEFÍCIO REGISTRO 8525
Ad8525 (AllTrim((cAliasSFT)->FT_PRODUTO),@aReg8525,aWizard,(cAliasSFT)->F4_CPPRODE,cAliasSFT,nNumBen,cAlias,cNrLvSub,aMVPROPERC) //(ADICIONADO)


Return (lRet)  


//-------------------------------------------------------------------
/*/{Protheus.doc} Reg8510

Descr. 8510  GIAF - AJUSTES DO BENEFÍCIO

Nível hierárquico: 4 

@return .T. / .F.

@param cAliasSFT -> Alias da tabela SFT aberta no momento;
		aReg8510  -> Array com os ajustes
		cSituaDoc -> Situacao do documento fiscal conforme funcao RetSitDoc
		aWizard   -> Array com a Wizard da rotina;
		
@author Jorge Souza
@since 09/12/2014
@version 11 

//-------------------------------------------------------------------
///*/
Static Function Reg8510 (cAlias, cAliasSFT, aReg8510, cSituaDoc, aWizard)
Local	nPos		:=	0
Local	lRet		:=	.T. 
Local cNatBen 	:= ""
Local nNumBen 	:= 0
Local nNumBeal 	:= ""
Local dDtDecre 	:= ""
Local lGrava		:=.F.
Local aReg 		:={}

If SB5->(dbSeek (xFilial ("SB5")+(cAliasSFT)->FT_PRODUTO))
	cNatBen  := SB5->B5_NATALBE
	nNumBen  := SB5->B5_NUMBEN
	dDtDecre := SB5->B5_DTDECAL
	nNumBeal := SB5->B5_NUMBEAL
EndIf

If !Empty((cAliasSFT)->FT_TPPRODE) .and. !Empty(nNumBeal) .and. ascan(aReg8510,{|x| x[2]==nNumBeal .and. x[3]==dDtDecre .and. x[4]==Right(cNatBen,1)} )==0 
	aAdd(aReg8510, {})
	nPos	:=	Len (aReg8510)
	aAdd (aReg8510[nPos], "8510")	 							//01 - REG
	aAdd (aReg8510[nPos], nNumBeal) 					//03 - DE_BF_AJ                                   
	aAdd (aReg8510[nPos], dDtDecre)			 					//04 - DT_BF_AJ  
	aAdd (aReg8510[nPos], Right(cNatBen,1))	        	   //05 - IND_NAT_AJ
	lGrava = .t. 
	
	aadd(areg,aReg8510[npos])
	GrvRegSef (cAlias,Val(iif(empty(nNumBen),'0',nNumBen)),areg)
Endif	


Return (lRet)  

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg8515

Descr. 8515: SUB-APURAÇÕES POR BENEFÍCIO

Nível hierárquico: 4 

@param 	aReg8515  -> Array com informacoes de apuração por beneficios; 
		aWizard   -> Array com a Wizard da rotina;
				
@author Jorge Souza
@since 09/12/2014
@version 11 

//-------------------------------------------------------------------
/*/
Static Function Reg8515(cAlias, aReg8515, aWizard,cNrLvSub,cAliasSFT,cNumBen)
Local aReg			:={}
Local nPos       := 0	
Default cNumben 	:= ''

	If ascan(aReg8515,{|x| x[2]==IIF((cAliasSFT)->FT_CPPRODE>0 .Or. ((cAliasSFT)->FT_TPPRODE$"#1#2#3#4#5#6"),cNrLvSub,"1") })==0 
		aAdd(aReg8515, {})
		nPos	:=	Len (aReg8515)
		aAdd (aReg8515[nPos], "8515")			   //01 - REG 
		aAdd (aReg8515[nPos], IIF((cAliasSFT)->FT_CPPRODE>0 .Or. ((cAliasSFT)->FT_TPPRODE$"#1#2#3#4#5#6"),cNrLvSub,"1"))  	   //02 - IND_AP
	
		aadd(areg,aReg8515[npos])
		
		GrvRegSef (cAlias,Val(iif(aReg8515[nPos][2] == '1','0',cNumBen)),areg,,Val(cNrLvSub))
	EndIf 
Return 
 


//-------------------------------------------------------------------
/*/{Protheus.doc} Reg8530

Descr. 8530: GIAF - LANÇAMENTO COM ITEM INCENTIVADO

Nível hierárquico: 3 

@return .T. / .F.

@param cAlias -> Alias do TRB que recebera as informacoes;
		cEntSai -> Flag Entrada(1)/Saida(2);
		aCmpAntSFT -> Informacoes sobre o cabecalho dos documentos.
		aPartDoc -> Array com informacoes sobre o participante do 
		              documento fiscal, este array eh montado pela 
		              funcao principal;
		cEspecie -> Modelo do documento fiscal;
		cSituaDoc -> Situacao do documento fiscal conforme funcao RetSitDoc;
		aWizard -> Array com a Wizard da rotina;
		cPosApLV -> Sub-Apuração sobre o Livro
		
@author Jorge Souza
@since 09/12/2014
@version 11 

//-------------------------------------------------------------------
/*/
Static Function Reg8530 (cAlias, cEntSai, aCmpAntSFT, aPartDoc, cEspecie, cSituaDoc, aWizard, nRelac, aReg8535, nItem8535, cAliasSFT, aReg8540,aReg8530,cPosApLV)

Local	nPos	:=	0
Local	nCol	:=	0
Local	lRet	:=	.T.
Local	aReg	:=	{}
Local cChave  := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³REGISTRO 8535 -  GIAF - ITENS INCENTIVADOS NO DOCUMENTO  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cAliasSFT)->FT_TPPRODE$" #0#1#2#3#4#5#6" 
	Reg8535(cAlias, cAliasSFT,@aReg8535,@nItem8535,aWizard,cPosApLV,cSituaDoc)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³8540 - GIAF - VALORES PARCIAIS ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Reg8540 (cAlias, cAliasSFT, @aReg8540, cSituaDoc, aWizard,cPosApLV)
Endif
	
If !(cSituaDoc$"90#81#")	
	If "0"$aWizard[3][13]
		cChave :=  STR(Val (cEntSai)-1,1)+aPartDoc[1]+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL
	
	
		If (nPos := aScan(aReg8530, {|x| x[3]+x[5]+x[7]+x[8]==cChave})) == 0
			aAdd (aReg, {})
			nPos	:=	Len (aReg)
			aAdd (aReg[nPos], nRelac)								//00 - nRelac
			aAdd (aReg[nPos], "8530")								//01 - REG
			aAdd (aReg[nPos], STR(Val (cEntSai)-1,1))				//02 - IND_OPER
			
			If (Empty ((cAliasSFT)->FT_FORMUL)) .And. cEntSai=="1"
				aAdd (aReg[nPos], "1")								//03 - IND_EMIT
			ElseIf (Empty ((cAliasSFT)->FT_FORMUL)) .And. cEntSai=="2"
				aAdd (aReg[nPos], "0")								//03 - IND_EMIT
			ElseIf ("S"$(cAliasSFT)->FT_FORMUL)
				aAdd (aReg[nPos], "0") 								//03 - IND_EMIT
			Else
				aAdd (aReg[nPos], "1")								//03 - IND_EMIT
			EndIf
		
			aAdd (aReg[nPos], aPartDoc[1])               			//04 - COD_PART
			aAdd (aReg[nPos], cEspecie)								//05 - COD_MOD
			aAdd (aReg[nPos], (cAliasSFT)->FT_SERIE)  			//07 - SER
			aAdd (aReg[nPos], (cAliasSFT)->FT_NFISCAL)  			//08 - NUM_DOC
			aAdd (aReg[nPos], (cAliasSFT)->FT_ENTRADA)			//11 - DT_DOC
			aAdd (aReg[nPos], iif(cSituaDoc	==	"20" .AND. ((cAliasSFT)->FT_TOTAL > (cAliasSFT)->FT_VALCONT),(cAliasSFT)->FT_TOTAL,(cAliasSFT)->FT_VALCONT))	  		//09 - VL_CONT
			aAdd (aReg[nPos], (cAliasSFT)->FT_BASEICM)			//10 - VL_BC_ICMS
			aAdd (aReg[nPos], (cAliasSFT)->FT_VALICM)				//11 - VL_ICMS
			
			aAdd(aReg8530,aReg[nPos])
			 	
		Elseif !cSituaDoc$"90#81#"
			aReg8530[nPos][10] += iif(cSituaDoc	==	"20" .AND. ((cAliasSFT)->FT_TOTAL > (cAliasSFT)->FT_VALCONT),(cAliasSFT)->FT_TOTAL,(cAliasSFT)->FT_VALCONT) //09 - VL_CONT
			aReg8530[nPos][11] += (cAliasSFT)->FT_BASEICM			//10 - VL_BC_ICMS
			aReg8530[nPos][12] += (cAliasSFT)->FT_VALICM			//11 - VL_ICMS 	
		EndIf  				 	
		aReg :={}
		aadd(aReg,aReg8535[len(aReg8535)])		
		GrvRegSef (cAlias,nRelac, aReg)
	EndIf
EndIf

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} Reg8535

Descr. 8535: GIAF - ITENS INCENTIVADOS NO DOCUMENTO

Nível hierárquico: 4 

@param cAliasSFT -> Alias da tabela SFT aberta no momento;
		aReg8535  -> Array com informacoes analiticas do documento
		              fiscal processado na funcao principal para o documento;
		aReg8525  -> Array para cadastrar o item incentivado (PI) por benefício;
		nItem8535 -> Controle de item utilizado no processamento;
		aWizard   -> Array com a Wizard da rotina;
		cPosApLV -> Sub-Apuração sobre o Livro
		
@author Jorge Souza
@since 09/12/2014
@version 11 

//-------------------------------------------------------------------
/*/
Static Function Reg8535(cAlias, cAliasSFT,aReg8535,nItem8535,aWizard, cPosApLV,cSituaDoc)

Local nPos       := 0	
Local cItem8535  := ""
Local cCdProd 	:= ""
Local lValidaCFO := .F.

lValidaCFO := Left ((cAliasSFT)->FT_CFOP, 1)$"1#2#3" .and. !(cAliasSFT)->FT_TPPRODE $"4"
cCdProd := IIF((cAliasSFT)->FT_TPPRODE$"123456789" .And. (cAliasSFT)->FT_CPPRODE>0 .And. !((cAliasSFT)->FT_TPPRODE $ ' #0') ,"2","1")
cItem8535 := Alltrim(Strzero(nItem8535,10))
	
	If !(cSituaDoc$"90#81#")	
		aAdd(aReg8535, {})
		nPos	:=	Len (aReg8535)
		aAdd (aReg8535[nPos], "8535")					   		                	     //01 - REG
		aAdd (aReg8535[nPos], cItem8535)					   	              		 //02 - NUM_ITEM 
		aAdd (aReg8535[nPos], ALLTRIM((cAliasSFT)->FT_PRODUTO))	 				 				 //03 - COD_ITEM 
		aAdd (aReg8535[nPos], (cAliasSFT)->FT_CFOP)					   	           //04 - CFOP  
		If !(cAliasSFT)->FT_TIPO == "S"
			aAdd (aReg8535[nPos], (cAliasSFT)->FT_BASEICM)					    	//05 - VL_BC_ICMS_I 
			aAdd (aReg8535[nPos], (cAliasSFT)->FT_ALIQICM)					    	//06 - ALIQ_IMCS 
			aAdd (aReg8535[nPos], (cAliasSFT)->FT_VALICM)					   	       //07 - VL_ICMS_I	
		Else
			aAdd (aReg8535[nPos], 0)                  					   	 	   //05 - VL_BC_ICMS_I
			aAdd (aReg8535[nPos], 0)				                 	   		          //06 - ALIQ_IMCS
			aAdd (aReg8535[nPos], 0)			                 		   		          //07 - VL_ICMS_I		                                                                                               	
		EndIf		
		aAdd (aReg8535[nPos], IIF(((cAliasSFT)->FT_CPPRODE>0 .and. !((cAliasSFT)->FT_TPPRODE $ ' #0')) .Or. ((cAliasSFT)->FT_TPPRODE$"1#2#3#4#5#6"),cPosApLV,"1"))		    //08 - IND_AP

		If lValidaCFO .OR. (cAliasSFT)->FT_TPPRODE $ " #0"
			aAdd (aReg8535[nPos], "1")													//09 - IND_ESP
		Else
			aAdd (aReg8535[nPos], cCdProd)													//09 - IND_ESP
		Endif
	Endif
			
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Ad8525

Descr.  8525: GIAF - ITEM INCENTIVADO (PI) POR BENEFÍCIO

Nível hierárquico: 5

@param cCodProd -> Código do Produto;
		aReg8525  -> Array para cadastrar o item incentivado (PI) por benefício;
	
@author Jorge Souza
@since 09/12/2014
@version 11 

//-------------------------------------------------------------------
/*/
Static Function Ad8525 (cCodProd,aReg8525,aWizard,nProde,cAliasSFT,cNumBen,cAlias,cNrLvSub,aMVPROPERC)
Local	 nPos		:=	0 
Local   nNcm		:=	""
Local   nUnidade	:=	0
Local   cDescr	:= ""
Local   cProd 	:= ""
Local 	 cDtAno 	:= ""
Local   nNumBen 	:= ""
Local   dDataAte	:=	SToD (aWizard[1][2])
Local   aReg := {}
Local	nX			:= 0

Default cNumBen :=	""
Default aMVPROPERC := {}
		
cProd := cCodProd + xFilial("SB1")

If SB1->(MsSeek (xFilial ("SB1")+(cAliasSFT)->FT_PRODUTO))
	nNcm     := SB1->B1_POSIPI
	nUnidade := SB1->B1_UM
	
	If SB5->(MsSeek (xFilial ("SB5")+(cAliasSFT)->FT_PRODUTO))
		nNumBen := SB5->B5_NUMBEN
		cDtAno := SB5->B5_ANOBEN
	EndIf 
	
	cNumBen := iif((empty(cNumBen) .or. (cAliasSFT)->FT_TPPRODE $ " #0"),'0',cNumBen)
			
	If (nPos := (aScan (aPro8525, {|aX| AllTrim(aX[1])==AllTrim((cAliasSFT)->FT_PRODUTO) .And. aX[2]==nUnidade })))==0

		//Tratamento para que itens não incentivados nos livros de icentivo
		//isso ocorre quando produto possui icentivo mas na operação não foi incentivado
		//Na validação da assinatura é exigido percentual do icentivo, mas caso seja informado percentual sistema calcula imposto
		If nProde == 0
			If ( Valtype(aMVPROPERC) == "A" )	
				IF (nX := aScan (aMVPROPERC, {|aX| AllTrim(aX[1])== Alltrim(cNrLvSub)}))>0
					IF Valtype(aMVPROPERC[nX][2]) == "N"
						nProde := aMVPROPERC[nX][2]
					Elseif Valtype(aMVPROPERC[nX][2]) == "C"
						nProde := Val(aMVPROPERC[nX][2])
					Endif
				Endif
			Endif
		Endif	
		
		cDescr:=SB1->B1_DESC  
		aAdd(aReg8525, {})
		nPos	:=	Len (aReg8525)
		aAdd (aReg8525[nPos], cNumBen)		// controle decreto
		aAdd (aReg8525[nPos], cNrLvSub)		// controle livro para quando mesmo decreto em livros diferentes com percentual diferentes
		aAdd (aReg8525[nPos], "8525")												//01 - LIN	
		aAdd (aReg8525[nPos], ALLTRIM((cAliasSFT)->FT_PRODUTO))						//02 - COD_ITEM
		aAdd (aReg8525[nPos], SubStr(cDescr,1,80)) 									//03 - DESCR_ITEM
		aAdd (aReg8525[nPos], nNcm) 				 								//04 - NBMSH
		aAdd (aReg8525[nPos], nUnidade) 			 								//05 - UNID
		aAdd (aReg8525[nPos], iif( (cAliasSFT)->FT_TPPRODE $ " #0" , 0 , nProde))  	//06 - PCT_BF
		aAdd (aReg8525[nPos], Iif(Empty(nNumBen),cvaltochar(Year(dDataAte)),cDtAno))//05 - PRZ_BF
		
		aAdd(aPro8525, {})
		nPos	:=	Len (aPro8525)
		aAdd (aPro8525[nPos], ALLTRIM((cAliasSFT)->FT_PRODUTO))						//02 - COD_ITEM
		aAdd (aPro8525[nPos], nUnidade) 			 								//05 - UNID
		
		aadd(areg,aReg8525[npos])
		//GrvRegSef (cAlias,Val(iif(empty(cNumBen),'0',cNumBen)),areg,,Val(cNrLvSub))
	Else
		//Tratamento para quando produto incentivado esta nos livros incentivado e não incentivado
		//Quando achar produto no livro incentivado com percentual, grava no 8515 do produto incentivado
		IF aReg8525[nPos][1] == '0' .And. nProde > 0
			aReg8525[nPos][1] := cNumBen
			aReg8525[nPos][2] := cNrLvSub
			aReg8525[nPos][8] := nProde
		Endif
	EndIF
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Reg8540

Descr. 8540 GIAF - VALORES PARCIAIS

Nível hierárquico: 4 

@return .T. / .F.

@param cAliasSFT -> Alias da tabela SFT aberta no momento;
		aReg8540  -> Array com informacoes parciais do documento fiscal 
		cSituaDoc -> Situacao do documento fiscal conforme funcao RetSitDoc
		aWizard   -> Array com a Wizard da rotina;
		cPosApLV -> Sub-Apuração sobre o Livro
		
@author Jorge Souza
@since 09/12/2014
@version 11 

//-------------------------------------------------------------------
/*/
Static Function Reg8540(cAlias, cAliasSFT, aReg8540, cSituaDoc, aWizard,cPosApLV)
Local	nPos		:=	0
Local	lRet		:=	.T. 
Local  cIndPetr	:= ""
Local cCdProd 	:= ""
Local lValidaCFO := .F.
Local cPvl:= ""

lValidaCFO := Left ((cAliasSFT)->FT_CFOP, 1)$"1#2#3" .and. !(cAliasSFT)->FT_TPPRODE $"4"
cCdProd := IIF((cAliasSFT)->FT_TPPRODE $ "1#2#3#4#5#6" .And. (cAliasSFT)->FT_CPPRODE>0 .and. !((cAliasSFT)->FT_TPPRODE $ " #0"),"2","1")
/*alteração para que possa aglutinar pois não estaria pesquisando igual ao gravado*/
cCdProd := IIF(lValidaCFO,"1",cCdProd)
cPvl := IIF(((cAliasSFT)->FT_CPPRODE>0 .Or. ((cAliasSFT)->FT_TPPRODE$"1#2#3#4#5#6")),cPosApLV,"1")
If !(cSituaDoc$"90#81#")
	If "0"$aWizard[3][13]
		If ((nPos := aScan (aReg8540, {|aX| aX[3]==(cAliasSFT)->FT_CFOP .And. aX[5]==(cAliasSFT)->FT_ALIQICM .And. aX[7]==cPvl .And. aX[8]==cCdProd}))==0)
			aAdd(aReg8540, {})
			nPos	:=	Len (aReg8540)
			aAdd (aReg8540[nPos], "8540")										//01 - REG
			aAdd (aReg8540[nPos], 0)											//02 - VL_CONT_P
			aAdd (aReg8540[nPos], (cAliasSFT)->FT_CFOP)							//03 - CFOP
			aAdd (aReg8540[nPos], 0)											//04 - VL_BC_ICMS_P
			aAdd (aReg8540[nPos], (cAliasSFT)->FT_ALIQICM)						//05 - ALIQ_ICMS
			aAdd (aReg8540[nPos], 0)											//06 - VL_ICMS_P
			aAdd (aReg8540[nPos], IIF(((cAliasSFT)->FT_CPPRODE>0 .and. !((cAliasSFT)->FT_TPPRODE $ " #0")) .Or. ((cAliasSFT)->FT_TPPRODE$"1#2#3#4#5#6") ,cPosApLV,"1"))	//07 - IND_AP
			If lValidaCFO .Or. (cAliasSFT)->FT_TPPRODE $ " #0"
				aAdd (aReg8540[nPos], "1")										//09 - IND_ESP
			Else
				aAdd (aReg8540[nPos], cCdProd)									//09 - IND_ESP
			Endif
		EndIf
		If !(cSituaDoc$"90#81#")
			aReg8540[nPos][2]	+=	iif(cSituaDoc	==	"20" .AND. ((cAliasSFT)->FT_TOTAL > (cAliasSFT)->FT_VALCONT),(cAliasSFT)->FT_TOTAL,(cAliasSFT)->FT_VALCONT)	//04 - VL_CONT_P
			aReg8540[nPos][4]	+=	(cAliasSFT)->FT_BASEICM						//05 - VL_BC_ICMS_P
			aReg8540[nPos][6]	+=	(cAliasSFT)->FT_VALICM						//06 - VL_ICMS_P
		EndIf
	Endif
Endif

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg8550

Descr.  8550 GIAF - CONSOLIDAÇÃO POR CFOP DAS OPERAÇÕES INCENTIVADAS

Nível hierárquico: 4 

@return .T. / .F.

@param cAliasSFT -> Alias da tabela SFT aberta no momento.
		cEntSai -> Flag Entrada(1)/Saida(2);
		aReg8550  -> Array com informacoes consolidadas por CFOP das operações Inc. 
		cEspecie -> Modelo do documento fiscal;
		cSituaDoc -> Situacao do documento fiscal conforme funcao RetSitDoc;
		cPosApLV -> Sub-Apuração sobre o Livro
				
@author Jorge Souza
@since 09/12/2014
@version 11 
/*/
//-------------------------------------------------------------------

Static Function Reg8550 (cAliasSFT, cEntSai, aReg8550, cSituaDoc, cEspecie, aWizard,cPosApLV)

Local	nPos	:=	0
Local	lRet	:=	.T.

If !(cSituaDoc$"90#81#") 
	If ((nPos := aScan (aReg8550, {|aX| aX[1]+aX[4]==cPosApLV+(cAliasSFT)->FT_CFOP}))==0)
		aAdd(aReg8550, {})
		nPos	:=	Len (aReg8550)
		aAdd (aReg8550[nPos], cPosApLV)
		aAdd (aReg8550[nPos], "8550")	 	   					//01 - REG
		aAdd (aReg8550[nPos], 0)								    //02 - VL_CONT
		aAdd (aReg8550[nPos], (cAliasSFT)->FT_CFOP)			//04 - CFOP
		aAdd (aReg8550[nPos], 0)								    //06 - VL_ICMS
	EndIf
	
	If !(cSituaDoc$"90#81#80") 
		aReg8550[nPos][3]	+=	(cAliasSFT)->FT_VALCONT			//02 - VL_CONT
		aReg8550[nPos][5]	+=	(cAliasSFT)->FT_VALICM			//06 - VL_ICMS			
	EndIf
EndIf	

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg8555

Descr.  8555 GIAF - TOTALIZAÇÃO DAS OPERAÇÕES INCENTIVADAS

Nível hierárquico: 4 

@return .T. / .F.

@param 	cAlias -> Alias do TRB que recebera as informacoes;
		cAliasSFT -> Alias da tabela SFT aberta no momento.
		cEntSai -> Flag Entrada(1)/Saida(2);
		cEspecie -> Modelo do documento fiscal;
		cSituaDoc -> Situacao do documento fiscal conforme funcao RetSitDoc;
		aReg8550  -> Array com informacoes das operações Inc. 
		cPosApLV -> Sub-Apuração sobre o Livro
						
@author Jorge Souza
@since 09/12/2014
@version 11 
/*/
//-------------------------------------------------------------------

Static Function Reg8555 (cAlias,cAliasSFT, cEntSai, cSituaDoc, cEspecie, aReg8555, aWizard,cPosApLV)
Local	lRet	:=	.T.
Local	nPos	:=	0
Local	nX		:=	0
Local  cNordeste := "MA#PI#CE#RN#PB#PE#AL#SE#BA" 
Local 	cIndTot	:=	""
Local 	cIndTot2	:=	""


	cEstado := (cAliasSFT)->FT_ESTADO	
	cIndTot	:=	Left ((cAliasSFT)->FT_CFOP, 1)    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Consolidado CFOPs 1, 2, 3, 5, 6, 7.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
	If cIndTot == "6"
		If cEstado$cNordeste
			cIndTot := cIndTot + "1"
		Else
			cIndTot := cIndTot + "2"
		Endif
	Else 
		cIndTot := cIndTot + "0" 
	Endif
	
	If ((nPos := aScan (aReg8555, {|aX| aX[3]+aX[1]==cIndTot+cPosApLV}))==0)
		aAdd(aReg8555, {})
		nPos	:=	Len (aReg8555)
		aAdd (aReg8555[nPos], cPosApLV)
		aAdd (aReg8555[nPos], "8555")	   			//01 - REG
		aAdd (aReg8555[nPos], cIndTot)				//02 - IND_TOT
		aAdd (aReg8555[nPos], 0)						//03 - VL_CONT
		aAdd (aReg8555[nPos], 0)						//06 - VL_ICMS
	EndIf 
		 
	If !(cSituaDoc$"90#81#80")
		aReg8555[nPos][4]	+=	(cAliasSFT)->FT_VALCONT		//03 - VL_CONT
		aReg8555[nPos][5]	+=	(cAliasSFT)->FT_VALICM		//06 - VL_ICMS			
	EndIf
		
	//ÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Totalizando  | 
	//ÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If !(cSituaDoc$"90#81#80")
		If (cIndTot$"61#62")
			If ((nPos := aScan (aReg8555, {|aX| aX[3]+aX[1]=="60"+cPosApLV}))==0)
				aAdd(aReg8555, {})
				nPos	:=	Len (aReg8555)
				aAdd (aReg8555[nPos], cPosApLV)
				aAdd (aReg8555[nPos], "8555")	   			//01 - REG
				aAdd (aReg8555[nPos], "60")				//02 - IND_TOT
				aAdd (aReg8555[nPos], 0)						//03 - VL_CONT
				aAdd (aReg8555[nPos], 0)						//04 - VL_ICMS
			EndIf		
			If !(cSituaDoc$"90#81#")
				aReg8555[nPos][4]	+=	(cAliasSFT)->FT_VALCONT		//03 - VL_CONT
				aReg8555[nPos][5]	+=	(cAliasSFT)->FT_VALICM		//04 - VL_ICMS			
			EndIf
		EndIf	
	Endif	
	
	If !(cSituaDoc$"90#81#80")
		cIndTot2	:=	Iif (Val(cIndTot)<40, "40", "80")
		If ((nPos := aScan (aReg8555, {|aX| aX[3]+aX[1]==cIndTot2+cPosApLV}))==0)
			aAdd(aReg8555, {})
			nPos	:=	Len (aReg8555)
			aAdd (aReg8555[nPos], cPosApLV)
			aAdd (aReg8555[nPos], "8555")	   			//01 - REG
			aAdd (aReg8555[nPos], cIndTot2)				//02 - IND_TOT
			aAdd (aReg8555[nPos], 0)						//03 - VL_CONT
			aAdd (aReg8555[nPos], 0)						//04 - VL_ICMS
		EndIf		
		If !(cSituaDoc$"90#81#80")
			aReg8555[nPos][4]	+=	(cAliasSFT)->FT_VALCONT		//03 - VL_CONT
			aReg8555[nPos][5]	+=	(cAliasSFT)->FT_VALICM		//04 - VL_ICMS			
		EndIf
	Endif
	
	aSort(aReg8555,,,{|x,y|val(x[3]) < val(y[3])})	
	
Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg8560

Descr.  8560 GIAF - SALDOS DA APURAÇÃO INCENTIVADA

Nível hierárquico: 4 

@return .T. / .F.

@param 	dDataAte -> Data final do periodo de apuracao;
		dDataAte -> Data final do periodo de apuracao;
		cNrLivro -> Numero do livro selecionado no wizard.;
		cPosApLV -> Sub-Apuração sobre o Livro;
		cNrLvSub -> Numero do livro de acordo com o parâmetro MV_PROIND
				
@author Jorge Souza
@since 09/12/2014
@version 11 
/*/
//-------------------------------------------------------------------

Static Function Reg8560 (cAlias, dDataAte, cNrLivro,aWizard,cPosApLV, cNrLvSub, aReg8560, aReg8565,aProAPFil,aProAPST)
Local	lRet		:=	.T.
Local  lAchou 	:=	.F.
Local	nApuracao	:=	GetSx1 (PadR("MTA951",10), "04", .T.)	//1-Decendial, 2-Quinzenal, 3-Mensal, 4-Semestral ou 5-Anual
Local	nPeriodo	:=	1								//GetSx1 ("MTA951", "05", .T.)	//1-1., 2-2., 3-3.	
Local	aApICM		:=	{}
Local	aApST 		:=	{}
Local	aApSIM 	:=	{}
Local	aReg		:=	{}
Local	nPos		:=	0
Local	nX			:=	0
Local	nVL_01		:=	0
Local	nVL_05		:=	0
Local	nVL_06		:=	0
Local	nVL_07		:=	0
Local	nVL_08		:=	0
Local	nVL_09		:=	0
Local	nVL_10		:=	0
Local	nVL_11		:=	0
Local	nVL_12		:=	0
Local	nVL_13		:=	0
Local	nVL_14		:=	0
Local 	nVlAj		:=	0 	
Local	nPosic		:=	0
Local  nPos2		:=	0
Local  nTam		:=	0
LocaL  nPos1		:=	0
Local	cProc		:=	""
Local  cCodAj 	:=	""
Local  cDescri	:=	"" 
Local  aPurFil 	:= {}

Default aProAPFil := {}
Default aProAPST  := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fixo que o periodo de geracao podera ser somente Mensal ou Anual.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nApuracao==1) .Or. (nApuracao==2)
	nApuracao	:=	3
ElseIf (nApuracao==4)
	nApuracao	:=	5
EndIf

If (nPos := aScan(aProAPFil, {|x| x[1]==cNrLvSub})) > 0

	nVL_01	:=	Iif (aScan (aProAPFil[nPos][2], {|a| a[1]=="005"})<>0, aProAPFil[nPos][2][aScan (aProAPFil[nPos][2], {|a| a[1]=="005"})][3], 0)    
	nVL_05	:=	Iif (aScan (aProAPFil[nPos][2], {|a| a[4]=="006.00"})<>0, aProAPFil[nPos][2][aScan (aProAPFil[nPos][2], {|a| a[4]=="006.00"})][3], 0)
	nVL_06	:=	Iif (aScan (aProAPFil[nPos][2], {|a| a[4]=="007.00"})<>0, aProAPFil[nPos][2][aScan (aProAPFil[nPos][2], {|a| a[4]=="007.00"})][3], 0)		
	nVL_07	:=	Iif (aScan (aProAPFil[nPos][2], {|a| a[1]=="009"})<>0, aProAPFil[nPos][2][aScan (aProAPFil[nPos][2], {|a| a[1]=="009"})][3], 0)
	nVL_08	:=	Iif (aScan (aProAPFil[nPos][2], {|a| a[1]=="010"})<>0, aProAPFil[nPos][2][aScan (aProAPFil[nPos][2], {|a| a[1]=="010"})][3], 0)
	nVL_09	:=	Iif (aScan (aProAPFil[nPos][2], {|a| a[1]=="001"})<>0, aProAPFil[nPos][2][aScan (aProAPFil[nPos][2], {|a| a[1]=="001"})][3], 0)
	nVL_10	:=	Iif (aScan (aProAPFil[nPos][2], {|a| a[4]=="002.00"})<>0, aProAPFil[nPos][2][aScan (aProAPFil[nPos][2], {|a| a[4]=="002.00"})][3], 0)
	nVL_11	:=	Iif (aScan (aProAPFil[nPos][2], {|a| a[4]=="003.00"})<>0, aProAPFil[nPos][2][aScan (aProAPFil[nPos][2], {|a| a[4]=="003.00"})][3], 0)
	nVL_12	:=	Iif (aScan (aProAPFil[nPos][2], {|a| a[1]=="004"})<>0, aProAPFil[nPos][2][aScan (aProAPFil[nPos][2], {|a| a[1]=="004"})][3], 0)
	nVL_13	:=	Iif (aScan (aProAPFil[nPos][2], {|a| a[1]=="014"})<>0, aProAPFil[nPos][2][aScan (aProAPFil[nPos][2], {|a| a[1]=="014"})][3], 0)
	nVL_14	:=	Iif (aScan (aProAPFil[nPos][2], {|a| a[1]=="011"})<>0, aProAPFil[nPos][2][aScan (aProAPFil[nPos][2], {|a| a[1]=="011"})][3], 0)

Endif 
	IF (nVL_08-nVL_12) > 0
		nVL_13 := nVL_08-nVL_12
	Else
		nVL_13 := 0
	Endif	

If (nPos := aScan(aReg8560, {|x| x[1]==cPosApLV}))==0	
	aAdd(aReg8560, {})
	nPos	:=	Len (aReg8560)
	aAdd (aReg8560[nPos], cPosApLV)
	aAdd (aReg8560[nPos], "8560")	   				//01 - REG
	aAdd (aReg8560[nPos], nVL_01)					//02 - VL_01
	aAdd (aReg8560[nPos], nVL_05)					//03 - VL_05
	aAdd (aReg8560[nPos], nVL_06)					//04 - VL_06
	aAdd (aReg8560[nPos], nVL_07)					//05 - VL_07
	aAdd (aReg8560[nPos], nVL_08)					//06 - VL_08
	aAdd (aReg8560[nPos], nVL_09)					//07 - VL_09
	aAdd (aReg8560[nPos], nVL_10)					//08 - VL_10
	aAdd (aReg8560[nPos], nVL_11)					//09 - VL_11
	aAdd (aReg8560[nPos], nVL_12)					//10 - VL_12
	aAdd (aReg8560[nPos], nVL_13)					//11 - VL_13
	aAdd (aReg8560[nPos], nVL_14)					//12 - VL_14   
Endif   	
//

If (nPos1 := aScan(aProAPFil, {|x| x[1]==cNrLvSub}))>0
	aPurFil := aProAPFil[nPos1][2]
	//8565 GIAF - AJUSTES DA APURAÇÃO INCENTIVADA
	For nX := 1 To Len (aPurFil)
   		lAchou := .F. 
   		nPosic 	:= 0
   		nPos2 	:= 0
   		nTam 	:=0
    	If aPurFil[nX][1]=="002" .and. substr(aPurFil[nX][4],1,3)<>"002"         
   		  lAchou := .T.   
   		  cCodAj := aPurFil[nX][4]
   		  nVlAj  := aPurFil[nX][3]

   		  cDescri := aPurFil[nX][2]
   		  nPosic:= At("/",cDescri)
   		  nPos2:= At("|",cDescri) 
   		  nTam := Len(cDescri)
   		Endif
   		
   		If aPurFil[nX][1]=="003" .and. substr(aPurFil[nX][4],1,3)<>"003"           
   		  lAchou := .T.   
   		  cCodAj := aPurFil[nX][4]
   		  nVlAj  := aPurFil[nX][3]
   		  
   		  cDescri := aPurFil[nX][2]
   		  nPosic:= At("/",cDescri)
   		  nPos2:= At("|",cDescri) 
   		  nTam := Len(cDescri)
		Endif
		 
   		If aPurFil[nX][1]=="006" .and. substr(aPurFil[nX][4],1,3)<>"006"           
   		  lAchou := .T.   
   		  cCodAj := aPurFil[nX][4]
   		  nVlAj  := aPurFil[nX][3]
   		  cDescri := aPurFil[nX][2]
   		  
   		  nPosic:= At("/",cDescri)
   		  nPos2:= At("|",cDescri) 
   		  nTam := Len(cDescri)
  		Endif
  		 
   		If aPurFil[nX][1]=="007" .and. substr(aPurFil[nX][4],1,3)<>"007"           
   		  lAchou := .T.   
   		  cCodAj := aPurFil[nX][4]
   		  nVlAj  := aPurFil[nX][3]
   		  
   		  cDescri := aPurFil[nX][2]
   		  nPosic:= At("/",cDescri)
   		  nPos2:= At("|",cDescri) 
   		  nTam := Len(cDescri)
 
   		Endif
   		If aPurFil[nX][1]=="012" .and. substr(aPurFil[nX][4],1,3)<>"012"           
   		  lAchou := .T.   
   		  cCodAj := aPurFil[nX][4]
   		  nVlAj  := aPurFil[nX][3]
   		  
   		  cDescri := aPurFil[nX][2]
   		  nPosic:= At("/",cDescri)
   		  nPos2:= At("|",cDescri) 
   		  nTam := Len(cDescri)

   		Endif
   		If lAchou 
			If (nPos := aScan(aReg8565, {|x| x[1]==cPosApLV}))==0	
				If nVlAj > 0
					aAdd(aReg8565, {})
					nPos	:=	Len (aReg8565)
					aAdd (aReg8565[nPos], cPosApLV)
					aAdd (aReg8565[nPos], "8565")	   		  //01 - REG 
					aAdd (aReg8565[nPos], SubStr(cCodAj,1,3))		     //02 - COD_AJ 
					aAdd (aReg8565[nPos], nVlAj)		     //03 - VL_AJ]
				Endif  			  
		   	Endif
	   	Endif			
	Next nI
Endif
	
Return (lRet) 


//-------------------------------------------------------------------
/*/{Protheus.doc} Reg8580

Descr. 8580: GIAF 3 - PRODEPE IMPORTAÇÃO (DIFERIMENTO NA ENTRADA E CRÉDITO PRESUMIDO NA SAÍDA SUBSEQUENTE)

Nível hierárquico: 4 

@param cAliasSFT -> Alias da tabela SFT aberta no momento;
		aReg8580  -> Array com informacoes analiticas do documento
		              fiscal processado na funcao principal para o documento;
		aWizard   -> Array com a Wizard da rotina;
		
@author Jorge Souza
@since 09/12/2014
@version 11 

//-------------------------------------------------------------------
/*/
Static Function Reg85801 (cAlias,dDataDe,dDataAte,aWizard,cPosApLV,cNrLvSub,aReg8580,aReg8585,cAliasSFT,aProAPFil,cSituaDoc)

//Local aReg8585	:= {}
Local nPos		:= 0
Local nApuracao	:= GetSx1 (PadR("MTA951",10), "04", .T.)
Local nPeriodo	:= 1
Local nVL_01	:= 0
Local nVL_02	:= 0
Local nVL_03	:= 0
Local nVL_04	:= 0
Local nVL_05	:= 0
Local nVL_06	:= 0
Local nVL_07	:= 0
Local nVL_08	:= 0
Local nVL_09	:= 0
Local nVL_12	:= 0

DEFAULT aProAPFil := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Fixo que o periodo de geracao podera ser somente Mensal ou Anual.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nApuracao==1) .Or. (nApuracao==2)
		nApuracao := 3
	ElseIf (nApuracao==4)
		nApuracao := 5
	EndIf
	
	If (cAliasSFT)->FT_TIPOMOV == "S" .And. !(cSituaDoc$"90#81#")
		IF Val(Substr((cAliasSFT)->FT_CFOP,1,1)) >= 5	.And. (cAliasSFT)->FT_CPPRODE == 0
			nVL_03	 := (cAliasSFT)->FT_VALCONT //Saidas nao incentivadas de PI
		Endif
		
		If Val(Substr((cAliasSFT)->FT_CFOP,1,1)) >= 6	.And. (cAliasSFT)->FT_CPPRODE <> 0
			nVL_05	:= (cAliasSFT)->FT_VALCONT //Saidas nao incentivadas de PI para fora do nordeste
			nVL_06	:= (cAliasSFT)->FT_VALICM			
		Endif
	Endif
	nVL_04 := aBloco8[13] //Percentual de incentivo nas saídas para fora do Estado
	nVL_01 := aBloco8[8] //-> importação difefimento	
	//nVL_07 := aBloco8[9] //-> Percentual do credito presumido para fora do nordeste saida	
	nVL_07:=(nVL_06 * (nVL_04/100))

	If (nPos := aScan(aProAPFil, {|x| x[1]==cNrLvSub}))>0		
		nVL_02	:= Iif (aScan (aProAPFil[nPos][2], {|a| a[1]=="018"})<>0, aProAPFil[nPos][2][aScan (aProAPFil[nPos][2], {|a| a[1]=="018"})][3], 0)
		nVL_08	:=	Iif (aScan (aProAPFil[nPos][2], {|a| a[1]=="011"})<>0, aProAPFil[nPos][2][aScan (aProAPFil[nPos][2], {|a| a[1]=="011"})][3], 0)
	Endif
	nVL_09 := nVL_08 - nVL_07
		
	//aBloco8[3] //-> Saidas incentivadas de PI
	//aBloco8[4] //-> Entradas nao incentivadas de PI
	//aBloco8[5] //-> Entradas incentivadas de PI	
	//aBloco8[10]//-> Percentual do credito presumido total saidas
	
	If (nPos := aScan(aReg8580, {|x| x[1]==cPosApLV}))==0
		aAdd(aReg8580, {})
		nPos	:=	Len (aReg8580)
		aAdd (aReg8580[nPos], cPosApLV)
		aAdd (aReg8580[nPos], "8580")	//01 - LIN
		aAdd (aReg8580[nPos], nVL_01)	//02 - G3_01 - Importações com ICMS diferido
		aAdd (aReg8580[nPos], nVL_02)	//03 - G3_02 - ICMS diferido nas importações
		aAdd (aReg8580[nPos], nVL_03)	//04 - G3_03 - Saídas não incentivadas de PI 
		aAdd (aReg8580[nPos], nVL_04)	//05 - G3_04 - Percentual de incentivo nas saídas para fora do Estado
		aAdd (aReg8580[nPos], nVL_05)	//06 - G3_05 - Saídas incentivadas de PI para fora do Estado
		aAdd (aReg8580[nPos], nVL_06)	//07 - G3_06 - ICMS das saídas incentivadas de PI para fora do Estado
		aAdd (aReg8580[nPos], nVL_07)	//08 - G3_07 - Crédito presumido nas saídas para fora do Estado, dedução de incentivo Prodepe Importação (diferimento na entrada e crédito presumido na saída 
		aAdd (aReg8580[nPos], nVL_08)	//09 - G3_08 - Saldo devedor do ICMS
		aAdd (aReg8580[nPos], nVL_09)	//10 - G3_09 - Saldo a recolher após deduções Prodepe
	Else
		aReg8580[nPos][3] += nVL_01		//02 - G3_01
		aReg8580[nPos][5] += nVL_03		//04 - G3_03
		IF nVL_04 > 0
			aReg8580[nPos][6] := nVL_04		//05 - G3_04
		Endif
		aReg8580[nPos][7] += nVL_05		//06 - G3_05
		aReg8580[nPos][8] += nVL_06		//07 - G3_06
		aReg8580[nPos][9] += nVL_07		//08 - G3_07
		aReg8580[nPos][11] -= nVL_07		//09 - G3_08
	Endif

	//LINHA 8585: GIAF 3 - PRODEPE IMPORTAÇÃO (SAÍDAS INTERNAS POR FAIXA DE ALÍQUOTA)
	If len(aReg8580) > 0
		Reg85851(cAlias,cAliasSFT,@aReg8585,aWizard,cPosApLV,@nVL_12)
	Endif
	
	IF (aReg8580[nPos][11] - nVL_12) < 0
		aReg8580[nPos][11] := 0	//10 - G3_09 - Saldo a recolher após deduções Prodepe	
	Else
		aReg8580[nPos][11] -= nVL_12	//10 - G3_09 - Saldo a recolher após deduções Prodepe	
	Endif

Return .T.


/*/{Protheus.doc} Reg8585

Descr.  8585: GIAF 3 - PRODEPE IMPORTAÇÃO (SAÍDAS INTERNAS POR FAIXA DE ALÍQUOTA)

Nível hierárquico: 5 

@param cAliasSFT -> Alias da tabela SFT aberta no momento;
		aReg8580  -> Array com informacoes analiticas do documento
		              fiscal processado na funcao principal para o documento;
			
@author Jorge Souza
@since 09/12/2014
@version 11 
/*/
Static Function Reg85851(cAlias,cAliasSFT,aReg8585,aWizard,cPosApLV,nVL_12)

Local nPos	:= 0
Local nX	:= 0
Local nVal1	:= 0
Local lRet	:= .F.
Local nY	:= 0
Local nVL_11 := 0
Local nAliq85 := 17
Local dDataAte	:=	SToD (aWizard[1][1])

	If Year(dDataAte) >= 2016 .And. Year(dDataAte) <= 2019
		nAliq85 := 18
	Endif

	If (nPos := aScan(aReg8585, {|x| x[1]==cPosApLV}))==0
		For nX:= 1 to 4
			aAdd(aReg8585, {})
			nPos	:=	Len (aReg8585)
			aAdd (aReg8585[nPos], cPosApLV)
			aAdd (aReg8585[nPos], "8585")					//01 - LN
			aAdd (aReg8585[nPos], alltrim(str(nX)))			//02 - IND_FX
			aAdd (aReg8585[nPos], 0)				//03 - G3_10
			aAdd (aReg8585[nPos], 0)	//04 - G3_11
			aAdd (aReg8585[nPos], 0)				//05 - G3_12
			lRet := .F.
		Next
	Endif
	
	If "S"$(cAliasSFT)->FT_TIPOMOV .and. Val(Substr((cAliasSFT)->FT_CFOP,1,1)) == 5	//.And. (cAliasSFT)->FT_CPPRODE <> 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Indicador da alíquota da faixa de incentivo:³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Do Case
			Case aBloco8[14] <= 7 
				nVal1 := 1  //1- Ate 7% (3,5 % sobre as importacoes-base)				
			Case aBloco8[14] > 7 .And. aBloco8[14] <= 12
				nVal1 := 2  //2- Acima 7%, ate 12% (6,0 % sobre as importacoes-base)
			Case aBloco8[14] > 12 .And.aBloco8[14] <= nAliq85
				nVal1 := 3  //3- Acima de 12%, ate 17% (8,0 % sobre as importacoes-base)
			Case aBloco8[14] > nAliq85
				nVal1 := 4  //4- Acima de 17% (10,0 % sobre as importacoes-base)
		EndCase
		
		If (nPos := aScan(aReg8585, {|x| x[1]==cPosApLV .and. x[3]==alltrim(str(nVal1))})) > 0			
			
			IF (nY := aScan(aProdImpo, {|aX| AllTrim(aX[1])==AllTrim((cAliasSFT)->FT_PRODUTO) .And. AllTrim(aX[3])==cPosApLV})) > 0
				nVL_11 :=  aProdImpo[nY][2]
			Endif
			
			aReg8585[nPos][5] += nVL_11 //04 - G3_11
			
			If	alltrim(str(nVal1)) == '1'
				nVL_12 := (nVL_11 * 3,5) /100
			Elseif alltrim(str(nVal1)) == '2'
				nVL_12 := (nVL_11 * 6) /100
			Elseif alltrim(str(nVal1)) == '3'
				nVL_12 := (nVL_11 * 8) /100
			Elseif alltrim(str(nVal1)) == '4'
				nVL_12 := (nVL_11 * 10) /100
			Endif
			
			aReg8585[nPos][6] += nVL_12 //05 - G3_12
		Endif		
		
	Endif

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} SetSubAp

Retorna o array do parâmetro com Livro, Sub-apuração

@author Jorge Souza
@since 09/12/2014
@version 11 

//-------------------------------------------------------------------
/*/
      
Static Function SubAp(aWizard)

Local 	aSubApRet 		:= {}
Local 	aMVRLIND		:= {}
Local 	nX				:= {}

aMVRLIND:= &(GetNewPar( "MV_PROIND","{}" ) )

For nX := 1 to Len(aMVRLIND)
	Aadd(aSubApRet ,{aMVRLIND[nX,1],aMVRLIND[nX,2]})      
Next nX
 
Return aSubApRet


//-------------------------------------------------------------------
/*/{Protheus.doc} VldSFT

Query responsável em filtrar os documentos que não
houve movimentação de prodepe

@author Jorge Souza
@since 20/02/2015
@version 11 

//-------------------------------------------------------------------
/*/
           
Static Function VldSFT(cAliasSFT)      

Local lRet := .F.
Local cVldSFT :=	"ALSVLDSFT"
		
//cVldSFT	:=	GetNextAlias()

BeginSql Alias cVldSFT    	
	SELECT 
		SFT.FT_FILIAL,SFT.FT_TIPOMOV,SFT.FT_SERIE,SFT.FT_NFISCAL,SFT.FT_CLIEFOR,SFT.FT_LOJA,SFT.FT_ITEM,SFT.FT_PRODUTO,
		SFT.FT_CPPRODE  
	FROM 
		%Table:SFT% SFT 
		LEFT JOIN %Table:SB5% SB5 ON(SB5.B5_FILIAL=%xFilial:SB5%  AND SB5.B5_COD=SFT.FT_PRODUTO AND SB5.%NotDel% AND SB5.B5_NUMBEN <> ' ')
	WHERE 
		SFT.FT_FILIAL=%xFilial:SFT% AND 
		SFT.FT_NFISCAL=%Exp:(cAliasSFT)->FT_NFISCAL% AND
		SFT.FT_SERIE=%Exp:(cAliasSFT)->FT_SERIE% AND
		SFT.FT_CLIEFOR=%Exp:(cAliasSFT)->FT_CLIEFOR% AND
		SFT.FT_LOJA=%Exp:(cAliasSFT)->FT_LOJA% AND
		SFT.FT_CPPRODE > 0 AND		
		SFT.%NotDel%
EndSql          				

If 	!(cVldSFT)->(EOF())
 	lRet := .T.	
Endif

(cVldSFT)->(dbCloseArea())
		
Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} VldSFT

Funcao responsavel por posicionar as tabelas utilizadas na geracao
da SEFII. Posiciona a tabela utilizando o RECNO passado como parametro
ou faz o Seek conforme o ambiente.

Obs: Funcao transcrita do SPEDXFUN.PRW p/ nao criar dependencia.

@author Joao Pellegrini
@since 18/05/2015
@version 11 

//-------------------------------------------------------------------
/*/
Static Function SEFIISeek(cAlias,nOrder,cSeek,nRecno)
Local	lRet		:=	.F.
Local	lProcSeek	:=	!lTop

Default	nOrder	:=	0

If lTop
	If nRecno <> Nil .And. nRecno > 0
		
		If (cAlias)->(Recno()) <> nRecno
			(cAlias)->(dbGoTo(nRecno))
		EndIf
		
		lRet	:=	.T.

	ElseIf nRecno == Nil
		lProcSeek	:=	.T.
	EndIf
EndIf

If lProcSeek .And. cSeek <> Nil
	
	If nOrder == 0
		nOrder	:=	(cAlias)->(IndexOrd())
	EndIf

	(cAlias)->(dbSetOrder(nOrder))

	lRet :=	(cAlias)->(MSSeek(cSeek))
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DumpFile
@description geracao do arquivo texto
@author Flavio Luiz Vicco
@since 15/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DumpFile(nAcao, cDir, cFileDest)
Local cLib       := ""
Local cStartPath := AllTrim(GetSrvProfString("StartPath",""))
Local nRemType   := GetRemoteType(@cLib)
Local lHtml      := IIf(nRemType == 5 ,.T.,.F.)
Local nRet       := 0

Default nAcao    := 1
Default cDir     := ""
Default cFileDest:= ""

If nAcao == 1
	If Empty(cDir) .Or. lHtml
		cDir := cStartPath
	EndIf
	If !SubStr(cDir,Len(cDir),1)$"\/"
		cDir += "\"
	EndIf
	cFileDest := AllTrim(cFileDest)
	cFileDest := cDir+cFileDest
	If IsSrvUnix() .Or. nRemType == 2
		cFileDest := StrTran(cFileDest,"\","/")
		cFileDest := StrTran(StrTran(StrTran(Alltrim(cFileDest)," ","_"),chr(13),""),chr(10),"")
	Else
		//Se o drive nao existir, pergunto ao usuario se deseja cria-lo atraves da funcao LjDirect()
		If !ExistDir(cDir)
			LjDirect(cDir,.T.)
		Endif
	EndIf
Else
	If File(cFileDest)
		If lHtml
			MsgAlert("Em função do acesso ao sistema ser via SmartClient HTML, o caminho informado para salvar o arquivo será desconsiderado, e será processado conforme configuração do navegador.")
			nRet := CPYS2TW(cFileDest)
			If nRet == 0
				FErase(cFileDest)
				MsgInfo(OemToAnsi(STR0001 + cFileDest + STR0002)) //"Arquivo "###" gerado com sucesso!"
			EndIf
		Else
			MsgInfo(OemToAnsi(STR0001 + cFileDest + STR0002)) //"Arquivo "###" gerado com sucesso!"
		EndIf
	Else
		MsgAlert(OemToAnsi(STR0003)) //"Não foi possível gerar o arquivo!"
	EndIf
EndIf

Return Nil
