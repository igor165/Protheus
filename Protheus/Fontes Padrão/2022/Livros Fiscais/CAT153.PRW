#INCLUDE "CAT153.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWCOMMAND.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³CAT153³ Autor ³Cecilia Carvalho           ³ Data ³20.03.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao do meio-magnetico E-CREDRURAL                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Funcao inicial do processamento. Esta funcao apresenta ao   ³±±
±±³          ³ usuario o wizard de configuracao, recebe os parametros e   ³±±
±±³          ³ chama a funcao PrCat153, responsavel pelo processamento    ³±±
±±³          ³ dos livros fiscais e geracao do meio magnetico.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tabelas   ³As tabelas abaixo devem estar alimentadas corretamente e re-³±±
±±³          ³ lacionadas entre si atraves dos campos chaves para manter a³±±
±±³          ³ integridade das informacoes extraidas para o meio-magnetico³±±
±±³          ³ em questao.                                                ³±±
±±³          ³                                                            ³±±
±±³          ³SFT - Livro Fiscal por item                                 ³±±
±±³          ³SX5 - Tabelas Genericas                                     ³±±
±±³          ³SA1 - Cadastro do Cliente/Fornecedor                        ³±±
±±³          ³SA2 - Cadastro do Cliente/Fornecedor                        ³±±
±±³          ³SF1 - Cabecalho das Notas Fiscais de Entrada/Saida          ³±±
±±³          ³SF2 - Cabecalho das Notas Fiscais de Entrada/Saida          ³±±
±±³          ³SF3 - Posicionando Livros Fiscais                           ³±±
±±³          ³SF4 - Cadastro de TES                                       ³±±
±±³          ³SF6 - GNRE                                                  ³±±
±±³          ³SD1 - Itens das NF´s de Entrada                             ³±±
±±³          ³SD2 - Itens das NF´s de Saida                               ³±±
±±³          ³SB1 - Cadastro de Produtos                                  ³±±
±±³          ³SX6 - Parametros do sistema                                 ³±±
±±³          ³CD5 - Complemento de Importação                             ³±±
±±³          ³CDT - Informacoes Complementares por NF                     ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Function CAT153(aWizScreen)

Local	lEnd		:=	.F.
Local	cNomWiz		:=	"CAT153"+ FWGETCODFILIAL
Local	cFileDest	:=	"CAT153.TXT"
Local	cCmpsNaoEx	:=	"" 
Local  cMens		:=	""   
Local	lJob		:= .F.
Local	lTabComp	:= .F.
Local 	lTabCD5	:= .F.
Local 	lTabCDT	:= .F.
Local   lAborta	:= .F.
Local	lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)

Private cVersao		:= "01"
Private oProcess		:=	Nil	//Utilizo private pq faco varias consistencias com VALTYPE
Private cCodProdED	:=  Alltrim(GetNewPar ("MV_B1ECRED", ""))
Private cCodClieED	:=  Alltrim(GetNewPar ("MV_A1ECRED", ""))
Private cCodFornED	:=  Alltrim(GetNewPar ("MV_A2ECRED", ""))     
Private aFiliais		:= {}

DEFAULT aWizScreen	:= {}	//Wizard preenchido antes de chamar function CAT153, permitindo utilizar CAT153 via Job/RPC

lJob := IIF(Len(aWizScreen) > 0,.T.,.F.)     
If SuperGetMv("MV_ESTADO") <> "SP"
   	MsgAlert(STR0004)
    lAborta := .T.
EndIf                                   
If Empty(cCodProdED)
   	MsgAlert(STR0006)
    lAborta := .T.
Else
	If SB1->(FieldPos(cCodProdED)==0)
	   	MsgAlert(STR0007 + cCodProdED + STR0008)
	    lAborta := .T.
	EndIf
EndIf

If Empty(cCodClieED)
   	MsgAlert(STR0009)
    lAborta := .T.
Else
	If SA1->(FieldPos(cCodClieED)==0)
	   	MsgAlert(STR0007 + cCodClieED + STR0008)
	    lAborta := .T.
	EndIf
EndIf

If Empty(cCodFornED)
   	MsgAlert(STR0010)
    lAborta := .T.
Else
	If SA2->(FieldPos(cCodFornED)==0)
	   	MsgAlert(STR0007 + cCodFornED + STR0008)
	    lAborta := .T.
	EndIf
EndIf

If !lAborta
	//Chamada da funcao que monta o Wizard da rotina
	If lVerpesssen .And. (lJob .Or. MontWiz(cNomWiz))
		If !lJob
			oProcess := FISProgress():New({|lEnd| PrCat153(@lEnd,@cFileDest,@oProcess,lTabComp,aWizScreen)},STR0022) 	//"Processamento CAT153"
			oProcess:Activate()
		Else                    
			Processa({|lEnd|PrCat153(@lEnd,@cFileDest,@oProcess,lTabComp,aWizScreen)})
		EndIf
	EndIf
EndIf
Return         

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³  PrCAT153  ³ Autor ³Cecilia Carvalho          ³ 20.03.2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao do meio-magnetico E-CREDRURAL                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Funcao principal de processamento. Esta funcao tem como     ³±±
±±³          ³ objetivo filtrar a tabela SFT(Livros Fiscais por item) e   ³±±
±±³          ³ montar os registros necessarios atraves de funcoes auxilia-³±±
±±³          ³ res.                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lEnd       - controle de cancelamento do processamento da   ³±±
±±³                        rotina                                         ³±±
±±³          ³cFileDest  - Caminho e nome do arquivo de destino           ³±±
±±³          ³oProcess   - Obj do novo newprocessa                        ³±±
±±³          ³lTabComp   - Flag de existencias das tabelas de complementos³±±
±±³          ³aWizScreen - Array com os parametros de wizard da rotina    ³±±
±±³          ³             para casos de chamada via RPC                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PrCAT153(lEnd,cFileDest,oProcess,lTabComp,aWizScreen)
//Variaveis de diversos controles
Local	aAreaSM0		:=	SM0->(GetArea ())
Local	aPartDoc		:=	{}
Local	cAlsSF			:=	""
Local	cAlsSD			:=	""
Local	cAlsSA			:=	""
Local	cEntSai			:=	""
Local	cEspecie		:=	""
Local	nRelacDoc		:=	0
Local 	nItem			:=	0
Local	nX				:=	0
Local	nY				:=	0
Local	lIss			:=	.F.         
Local	cMVSUBTRIB		:=	""
Local 	cMVEstado		:= 	""       
Local   aTpMov          := {'E','S'} //- Tipo de Movimentos
Local   nContMov        := 0  //- Contador do tipo de movimentos
Local	aWizard			:=	{}
Local	cSituaDoc		:=	""
Local	cNomeCfp		:=	"CAT153" + FWGETCODFILIAL
Local   lTop            := .F.                               // Verifica se esta usando o Top.  
Local   lGrvGnreE       := .F.
Local   lGrvGnreS       := .F.
Local	aArq			:=	{}
Local	aParFil			:=	{}
Local	dDataDe			:=	CToD ("//")
Local	dDataAte		:=	CToD ("//")
Local	cNrLivro		:=	""
Local	cFilDe			:=	""
Local	cFilAte			:=	""
Local	cDir			:=	""
Local	aLisFil			:=	{}
Local	nFilial			:=	0
Local	cIndex			:=	""
Local	nIndex			:=	0
Local	cChvSeek		:=	""
Local	cUnid			:=	""
Local	cProd			:=	""
Local	cCliFor			:= 	""
Local	aCmpAntSFT		:=	{}
Local   aProdB1			:=  {}
Local	aAreaSA			:=	{}
Local	nCtdFil			:=	0 
Local	nCountTot		:=	0
Local	nRegsProc		:=	0
Local	nEmpProc		:=	0
Local	cTimeDocs 		:=	Time()
Local	nDocsXTime		:=	0
Local	cFilSoma		:=	""
Local	bWhileSM0		:=	{||!SM0->(Eof ()) .And. ((!"1"$aWizard[2][4] .And. cEmpAnt==SM0->M0_CODIGO .And. FWGETCODFILIAL<=cFilAte) .Or. ("1"$aWizard[2][4] .And. Len(aLisFil)>0 .And. cEmpAnt==SM0->M0_CODIGO))}
Local	nRecnoSF3		:=	Nil
Local 	cMV_StUf		:=	SuperGetMV("MV_STUF")	// Define os estados a serem utilizados para o artigo 281
Local 	cMV_StUfS		:=	SuperGetMV("MV_STUFS")	// Define os estados a serem utilizados para o artigo 281 - para as saidas
Local	aVlrMovST		:=	{}
Local	aResF3FT		:=	{}
Local	aIcmPago		:=	{}
Local	dDtEntSai		:=	CToD("  /  /  ")
Local 	nRecSF3DBF		:=	Nil

//Variaveis para nomes de campos
Local	cCmpUm			:=	""
Local	cCmpTrans		:=	""
Local	cCmpEst			:=	""
Local	cCmpTipo		:=	""
Local	cCmpTes			:=	""
Local	cCmpNFCupom		:=	""
Local	cCmpPrefixo		:=	""
Local	cCmpDupl		:=	""
Local	cCmpPBruto		:=	""
Local	cCmpPLiqui		:=	""
Local	cCmpDescIcm	:=	""
//Variaveis de FLAG de seek
Local	lAchouSF4		:=	.T.
Local	lAchSFSD		:=	.F.
Local	lAchouCD5		:=	.F.
Local	lAchouCDT		:=	.F.
//Variaveis de alias de tabelas
Local	cAlias			:=	""
Local	cAliasSB1		:=	"SB1"
Local	cAliasSF4		:=	"SF4"
Local	cAliasSFT		:=	"SFT"
Local	cAliasSA4		:=	"SA4"
Local	cAliasSF6		:=	"SF6"
Local	cAliasCD5		:=	"CD5"
Local	cAliasCDT		:=	"CDT"
//Variaveis de FLAG para gravacao de registrso
Local lGrava0150     :=	.F.
Local lGrava0300     :=	.F.
//Variaveis de registros
Local	aReg0000		:=	{}
Local	aReg0150		:=	{}
Local	aReg0300		:=	{}
Local	aReg0990		:=	{}
Local	aReg5001		:=	{}
Local	aReg5200		:=	{}
Local	aReg5220		:=	{}
Local	aReg5240		:=	{}
Local	aReg5260		:=	{}
Local	aReg5400		:=	{}
Local	aReg5440		:=	{}
Local	aReg5460		:=	{}
Local	aReg5480		:=	{}
Local	aReg5600		:=	{}
Local	aReg5640		:=	{}
Local	aReg5800		:=	{}
Local	aReg5990		:=	{}
Local	aReg9001		:=	{}
Local	aReg9900		:=	{}
Local	aReg9990		:=	{}
Local	aReg9999		:=	{}              
Local	aArrec  		:=	{} 
Local	lJob			:= .F.
Local	lR5480			:= .F.
Local	nRetCpy			:= 	1
Local	cLib
Local	nRetType		:= 0


#IFDEF TOP
	Local 	cL2Temp			:= ""									// Pega o proximo Alias Disponivel   
	Local 	nCountSD2		:= 0
	
	If TcSrvType() <> "AS/400"
		lTop 	:= .T.		
	Endif
#ENDIF

DEFAULT aWizScreen := {} //Recebe via Job/Rpc aWizard preenchida

//Verifica se aWizScreen preenchido, sinalizando processamento via Job/Rpc
lJob := Iif(Len(aWizScreen) > 0, .T.,.F.)

//Atribuo o conteudo do CFP gerado pelo wizard no array aWizard
If !lJob
	If !xMagLeWiz(cNomeCfp,@aWizard,.T.)
		Return	//Se por algum motivo a leitura do CFP falhar aborto a rotina.
	EndIf
//Wizard preenchido antes de chamar function CAT153, tratamento para RPC
Else 
	aWizard := aWizScreen
EndIf                                 

//Criacao do TRB para ser alimentado durante o processamento da rotina
GeraTrb(1,@aArq,@cAlias)

dDataDe	:=	SToD(aWizard[1][1])
dDataAte	:=	SToD(aWizard[1][2])
cFilDe	:=	aWizard[2][2]
cFilAte	:=	aWizard[2][3]	
cDir		:=	AllTrim(aWizard[1][5])
lR5480	:=	Substr(aWizard[2][5]	,1,1)=="1"

//Tratamento para Linux onde a barra e invertida                      
If GetRemoteType() == 2 // REMOTE_LINUX  
	If !Empty(cDir) .And. (SubStr (cDir, Len (cDir), 1)<>"/")
		cDir	+=	"/"
	EndIf
Else
	If !Empty(cDir) .And. (SubStr (cDir, Len (cDir), 1)<>"\")
		cDir	+=	"\"
	EndIf
EndIf
cFileDest	:=	AllTrim(cDir)+AllTrim(aWizard[1][6])

//Verifico se devo abrir a tela para fazer o processamento de multifiliais
If !lJob .And. "1"$aWizard[2][4]
	If "1"$aWizard[2][6]
		aLisFil  :=	MatFilCalc(.T., , , .T., , 2)	
	Else
		aLisFil  :=	MatFilCalc(.T.)
	EndIf
	If !Empty(aLisFil)
		cFilDe	:=	PadR("",FWGETTAMFILIAL)
		cFilAte	:=	Repl("Z",FWGETTAMFILIAL)
	Else
		MsgAlert(OemToAnsi(STR0021))	//"Nenhuma filial foi selecionada para o processamento. Será considerada a filial corrente."
		//Para considerar a filial corrente, preciso alem de atribuir o cFilAnt, preciso forcar a 
		//   opcao 2 neste array que eh o resultado do wizard                                     
		aWizard[2][4]	:=	"2 - Não"
		cFilDe			:=	cFilAnt
		cFilAte			:=	cFilAnt
	EndIf
ElseIf lJob
	aWizard[2][4]	:=	"2 - Não"
	cFilDe			:=	cFilAnt
	cFilAte			:=	cFilAnt
EndIf
                                                                        
If (Empty (cFilDe) .And. Empty (cFilAte))
	cFilDe	:=	cFilAnt
	cFilAte	:=	cFilAnt
EndIf          

//GRAVACAO - REGISTRO 0000 - ABERTURA DO ARQUIVO DIGITAL E IDENTIFICACAO DO CONTRIBUINTE
Reg0000 (aWizard, cAlias)

//Monta a quantidade de filiais que estao no processamento para montar
//a regua de processamento corretamente com as informacoes dos       
//registros mais significantes (os outros sao muito rapidos)         
DbSelectArea ("SM0")
SM0->(DbGoTop ())
SM0->(DbSeek (cEmpAnt+cFilDe, .T.))	//Pego a filial mais proxima 
Do While Eval(bWhileSM0)
	cFilAnt := FWGETCODFILIAL	
	If Len(aLisFil)>0 .And. cFilAnt <= cFilAte
       nFilial := Ascan(aLisFil,{|x|x[2]==cFilAnt})
	   If nFilial==0 .Or. !(aLisFil[nFilial,1])  //Filial não marcada, vai para proxima
			SM0->( dbSkip() ) 
			Loop
		EndIf
	Else
		If "1"$aWizard[2][4]  //Somente faz skip se a opção de selecionar filiais estiver como Sim.
			 SM0->(dbSkip())
			 Loop
		EndIf		
	EndIf
	If Len(aLLTRIM(SM0->(M0_CGC)))<>14 
   	    MsgAlert(STR0005)	
	    SM0->(dbSkip())
		Loop
	EndIf     
	
	//Armazeno o numero preciso de registros que serao processados
	nCountTot	+=	CATQryPrin(1,"E",dDataDe,dDataAte,@cAliasSFT,lTabComp)
	nCountTot	+=	CATQryPrin(1,"S",dDataDe,dDataAte,@cAliasSFT,lTabComp)      
	
	nCtdFil		+=	1
	SM0->(dbSkip()) 
End
nCtdFil	:=	Iif(nCtdFil==0,1,nCtdFil)

If Type("oProcess")=="O"
	oProcess:Set1Progress(nCtdFil)
	oProcess:Set2Progress(nCountTot)
Else
	ProcRegua(nCountTot)
EndIf

SM0->(DbGoTop ())
SM0->(DbSeek (cEmpAnt+cFilDe, .T.))	//Pego a filial mais proxima 
//Quando a opcao de seleciona filiais estiver configurada como sim, serah    
//    considerado as filiais selecionadas no browse. Caso contrario, valera o
//    que estiver configurado na pergunta 'Filial DE/ATE'                    
Do While Eval(bWhileSM0)
	cFilAnt 	:= 	FWGETCODFILIAL
	If Len(aLisFil)>0 .And. cFilAnt <= cFilAte
       nFilial := Ascan(aLisFil,{|x|x[2]==cFilAnt})
	   If nFilial==0 .Or. !(aLisFil[nFilial,1])  //Filial não marcada, vai para proxima
			SM0->( dbSkip() ) 
			Loop
		EndIf
	Else
		If "1"$aWizard[2][4]  //Somente faz skip se a opção de selecionar filiais estiver como Sim.
			 SM0->(dbSkip())
			 Loop
		EndIf		
	EndIf
	If Len(aLLTRIM(SM0->(M0_CGC)))<>14 
	    SM0->(dbSkip())
		Loop
	EndIf     
	nEmpProc	+=	1
	cMVSUBTRIB		:=	CatPrSeq("MV_SUBTRI")
	cMVEstado 		:= 	GetMv("MV_ESTADO")
   MontaFil(@aFiliais,@cFilAnt)	
	
	If Type("oProcess")=="O"
		oProcess:Inc1Progress(STR0012+cEmpAnt+"/"+cFilAnt,StrZero(nEmpProc,3)+"/"+StrZero(nCtdFil,3))	//"Processando empresa :"
		oProcess:Inc2Progress(STR0013,"")	//"Obtendo Informações de Apuração de ICMS"
		If oProcess:Cancel()
			Exit
		EndIf
	Else
		If Interrupcao(@lEnd)
			Exit
		EndIf
	EndIf
                            
   //Leitura do arquivo de apuração para posteriormente montar os registros 5240, 5460, 5800                        
   CATApICMS(aWizard,@aArrec,@aReg5800,cAlias,cMVEstado,lTop,cMVSUBTRIB,oProcess)   

	lGrvGnreE	:= .F.
   lGrvGnreS	:= .F. 
	aReg5480		:=	{}  	
	cChave		:= ""
	//FOR criado para inserir o campo FT_TIPOMOV na query para usar o indice 1 da tabela SFT
	For nContMov := 1 to Len(aTpMov)         
		If Type("oProcess")=="O"
			oProcess:Inc1Progress(STR0012+cEmpAnt+"/"+cFilAnt,StrZero(nEmpProc,3)+"/"+StrZero(nCtdFil,3))	//"Processando empresa :"
			oProcess:Inc2Progress(STR0014,"")	//"Processando documentos"
			If oProcess:Cancel()
				Exit
			EndIf
		Else
			If Interrupcao(@lEnd)
				Exit
			EndIf
		EndIf		
		//Chamando funcao que monta a query principal de processamento da CAT153
		CATQryPrin(2,aTpMov[nContMov],dDataDe,dDataAte,@cAliasSFT,lTabComp)
		//Para ambiente TOP, as tabelas abaixos estao no JOIN e o alias eh o mesmo da query
		If lTop
			cAliasSF4 := cAliasSFT
			cAliasSB1 := cAliasSFT
		EndIf
		
		Do While !(cAliasSFT)->(Eof ())		
			If Type("oProcess")=="O"
				If oProcess:Cancel()
					Exit
				EndIf
			Else
				If Interrupcao(@lEnd)
					Exit
				EndIf
			EndIf	
         //Modelo NF   
			cEspecie		:=	CATModNot((cAliasSFT)->FT_ESPECIE)
			//Determina o Alias para as Tabelas SF1/SF2 e SD1/SD2.
			cEntSai		:=	Iif ("E"$(cAliasSFT)->FT_TIPOMOV, "1", "2")
			cAlsSF		:=	"SF"+cEntSai	//Determina o Alias para as Tabelas SF1/SF2
			cAlsSD		:=	"SD"+cEntSai	//Determina o Alias para as Tabelas SD1/SD2
			cAlsSA		:=	"SA"+Iif((cEntSai=="1" .And. !(cAliasSFT)->FT_TIPO$"BD") .or.;
											(cEntSai=="2" .And. (cAliasSFT)->FT_TIPO$"BD"), "2", "1")	//Determina o Alias para as Tabelas SA1/SA2
			nItem			:=	1
			aParFil		:=	{}
			aAreaSA		:=	{}
			nPosGener	:=	0
			nRecnoSF3	:=	Iif(lTop,(cAliasSFT)->SF3RECNO,Nil)
			aResF3FT		:=	{}
			//Variaveis de registros
			aReg5220		:=	{}
			aReg5240		:=	{}
			aReg5260		:=	{}
			aReg5440		:=	{}
			aReg5460		:=	{}
			aReg5600		:=	{}
			aReg5640		:=	{}
			//Variaveis de seek
			lAchouSF4	:=	.F.
			lAchSFSD		:=	.F.
			lAchSFSD		:=	.F.
			lAchSFSD		:=	.F.
			lAchouCD5	:=	.F.
			lAchouCDT	:=	.F.
			//Campos das tabelas SF/SD
			cCmpEst		:=	SubStr(cAlsSA,2,2)+"_EST"
			cCmpUm		:=	SubStr(cAlsSD,2,2)+"_UM"
			cCmpTipo		:=	SubStr(cAlsSD,2,2)+"_TIPO"
			cCmpTes		:=	SubStr(cAlsSD,2,2)+"_TES"
			//Variaveis de Alias de tabelas
			cAliasCDT	:=	"CDT"
			cAliasCD5	:=	"CD5"
			//Efetuo o pocisionamento da tabela SF3 para utilizar a tabela na funcao CATSitDoc 
			cChvSeek		:=	xFilial("SF3")+(cAliasSFT)->(DToS (FT_ENTRADA)+FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_CFOP+STR(FT_ALIQICM,5,2))
			CATSeek("SF3",,cChvSeek,nRecnoSF3)			
			//Efetuo o pocisionamento da tabela SA(1/2) para utilizar a tabela na funcao CATSitDoc                                               
			If !lTop
				CATSeek(cAlsSA,,xFilial(cAlsSA)+(cAliasSFT)->(FT_CLIEFOR+FT_LOJA))								
			EndIf
			cSituaDoc	:=	CATSitDoc(cAliasSFT,Iif(lTop,cAliasSFT,cAlsSA),dDataDe,dDataAte) 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³SOMENTE MODELOS:                               ³
			//³01 - NOTA FISCAL NORMAL                        ³
			//³02 - NOTA FISCAL AVULSA                        ³
			//³03 - NOTA FISCAL DE VENDA A CONSUMIDOR FINAL   ³
         //³04 - CUPOM FISCAL EMITIDO POR ECF              ³
         //³06 - NOTA FISCAL PRODUTOR                      ³
			//³07 - NOTA FISCAL/CONTA DE ENERGIA ELETRICA     ³
			//³08 - NOTA FISCAL SERVICO DE TRANSPORTE         ³
			//³09 - CONHECIMENTO DE TRANSPORTE RODOVIARIO     ³
			//³11 - CONHECIMENTO DE TRANSPORTE AQUAVIARIO     ³
			//³12 - CONHECIMENTO DE TRANSPORTE AEREO          ³
			//³13 - CONHECIMENTO DE TRANSPORTE FERROVIARIO    ³
			//³21 - NOTA FISCAL DE SERVICO DE COMUNICACAO     ³
			//³22 - NOTA FISCAL DE SERVICO DE TELECOMUNICACAO ³
			//³26 - CONHECIMENTO DE TRANSPORTE MULTIMODAL     ³
			//³27 - NOTA FISCAL DE AGUA CANALIZADA            ³
			//³28 - NOTA FISCAL DE GAS CANALIZADO             ³
			//³31 - NF-e                                      ³
			//³32 - CT-e                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !(cEspecie$"01#02#03#04#06#07#08#09#11#12#13#21#22#26#27#28#31#32") .Or. cSituaDoc$"02/04/05"
				(cAliasSFT)->(DbSkip ())
				Loop
			EndIf              			
			//Quando for TOP, os referidos campos ja estao no SELECT
			If lTop
				lAchSFSD	:=	!cSituaDoc$"02/04/05"
				If lAchSFSD
					lCompIcm	:=	(cAliasSFT)->(&(cCmpTipo))	//D1/D2_TIPO
				EndIf
			Else
				CATSeek(cAlsSA,,xFilial(cAlsSA)+(cAliasSFT)->(FT_CLIEFOR+FT_LOJA))
				lAchSFSD	:=	CATSeek(cAlsSF,,xFilial(cAlsSF)+(cAliasSFT)->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA))				
				If lAchSFSD
					lCompIcm	:=	(&(cAlsSF+"->"+SubStr (cAlsSF,2,2)+"_TIPO")=="I") // Indica se NF de complemento de ICMS
				EndIf
			EndIf				
			dDtEntSai	:=	Iif((cEntSai=="2") .Or. cEntSai=="1", (cAliasSFT)->FT_ENTRADA, CToD("  /  /  "))
			//Campos que se referem ao cabecalho do documento fiscal
			aCmpAntSFT	:=	{(cAliasSFT)->FT_NFISCAL,;															//01 - Doc. Fiscal
								(cAliasSFT)->FT_SERIE,;																//02 - Serie NF
								(cAliasSFT)->FT_CLIEFOR,;															//03 - Cliente/Fornecedor
								(cAliasSFT)->FT_LOJA,;																//04 - Codigo Loja
								dDtEntSai,;																				//05 - Data Docto.
								(cAliasSFT)->FT_EMISSAO,;	 														//06 - Data Emissao
								(cAliasSFT)->FT_DTCANC,;	   													//07 - Data Canc.
								(cAliasSFT)->FT_FORMUL,;															//08 - Formulario Proprio
								(cAliasSFT)->FT_CFOP,;																//09 - CFOP
								(cAliasSFT)->FT_ALIQICM,;															//10 - Aliq. ICMS
								(cAliasSFT)->FT_PDV,;																//11 - Nro. PDV
								(cAliasSFT)->FT_BASEICM,;															//12 - Base  ICMS
								(cAliasSFT)->FT_ALIQICM,;															//13 - Aliq. ICMS
								(cAliasSFT)->FT_VALICM,;															//14 - Valor ICMS
								(cAliasSFT)->FT_ISENICM,;															//15 - Valor Isento ICMS
								(cAliasSFT)->FT_OUTRICM,;															//16 - Outros ICMS
								(cAliasSFT)->FT_ICMSRET,;															//17 - ICMS Retido ST
								(cAliasSFT)->FT_TIPO,;																//18 - Tipo Lancamento
								(cAliasSFT)->FT_VALCONT,;															//19 - Valor Contábil				
								(cAliasSFT)->FT_FILIAL,;															//20 - Filial
								(cAliasSFT)->FT_ESTADO,;															//21 - Estado
								(cAliasSFT)->FT_OBSERV,;													     	//22 - Formulario proprio 
								(cAliasSFT)->FT_CHVNFE,;		//23 - Chave NFE
								Iif(lAchSFSD,(Iif(lTop,cAliasSFT,cAlsSF))->(&(cCmpNFCupom)),""),;	//24 - Cupom Fiscal
								Iif(lAchSFSD,(Iif(lTop,cAliasSFT,cAlsSF))->(&(cCmpTrans)),""),;		//25 - Transportadora   
								(cAliasSFT)->FT_FORMUL} 															//26 - Formulario proprio		
			//Posicionamento das tabelas complementares conforme documento fiscal em processamento
			If lTabComp
				//Somente para documentos de entrada, pois se refere ao registro de importacao
				If cEntSai=="1" .And. Substr((cAliasSFT)->FT_CFOP,1,1)=="3"
					lAchouCD5	:=	CATFiltro(1,"CD5",@cAliasCD5,aParFil)
				EndIf
				lAchouCDT := CATFiltro(1,"CDT",@cAliasCDT,aParFil)
         EndIf
			//Retornando dados do participante em um array e efetuo a gravacao dos registros
			aPartDoc		:=	CATInfPart(cAlsSA,dDataDe,dDataAte,cAliasSFT)
						
			nRegsProc	+=	1
			lAchouSF4	:=	.F.
			cUnid     	:=	""
      	cProd			:=	""
			lGrava0300	:=	.F.
			lIss 			:=	(cAliasSFT)->FT_TIPO=="S"
         nRecnoSF3	:=	Iif(lTop,(cAliasSFT)->SF3RECNO,Nil)
			nRecSF3DBF	:=	Nil
			aParFil		:=	{}
				
			If Type("oProcess")=="O"
				oProcess:Inc2Progress(STR0014+" ("+(cAliasSFT)->FT_TIPOMOV+") "+STR0015+" "+DToC((cAliasSFT)->FT_ENTRADA),StrZero(nRegsProc,6)+"/"+StrZero(nCountTot,6))	//"Processando documentos"###do dia
				If cTimeDocs<>Time()
					oProcess:SetDetProgress(STR0016,nCountTot,;											//"Total de registros do periodo solicitado"
													STR0017,nDocsXTime,;											//"Total de registros processados por segundo"
													STR0018,nCountTot-nRegsProc,;	   						//"Total de registros pendentes para processamento"
													STR0019,Round((nCountTot-nRegsProc)/nDocsXTime,0))//"Tempo estimado para termino do processamento (Seg.)"
					cTimeDocs	:=	Time()
					nDocsXTime	:=	1
				Else
					nDocsXTime	+=	1
				EndIf
				If oProcess:Cancel()
					Exit
				EndIf
			Else
				IncProc(STR0011+SM0->M0_CODFIL+" / "+AllTrim(SM0->M0_FILIAL)) //"Processando filial: "
				If Interrupcao(@lEnd)
					Exit
				EndIf
			EndIf
			//Executando filtros nas tabelas complementares conforme documento fiscal
			aParFil	:=	{}
			aAdd(aParFil,(cAliasSFT)->FT_TIPOMOV)
			aAdd(aParFil,(cAliasSFT)->FT_NFISCAL)
			aAdd(aParFil,(cAliasSFT)->FT_SERIE)
			aAdd(aParFil,(cAliasSFT)->FT_CLIEFOR)
			aAdd(aParFil,(cAliasSFT)->FT_LOJA)
			aAdd(aParFil,(cAliasSFT)->FT_ITEM)
			aAdd(aParFil,(cAliasSFT)->FT_PRODUTO)
			aAdd(aParFil,"ICM")
			//Efetuo o pocisionamento da tabela SF3 para utilizar a tabela na funcao CATSitDoc
			cChvSeek := xFilial("SF3")+(cAliasSFT)->(DToS (FT_ENTRADA)+FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_CFOP+STR(FT_ALIQICM,5,2))
			CATSeek("SF3",,cChvSeek,nRecnoSF3)
			//Para Top nao preciso fazer este while, pois jah estah posicionado conforme recno correto pela query principal
			If !lTop
				//Tratamento para Apurar alguns valores durante o processamento da SFT, como se estivesse
				//executando a RESUMEF3.                                                                 
				//Como na resumeF3 tem a opcao de obter as informacoes das tabelas SF3 ou SFT, tenho tambem
				//que replicar isso aqui, para isso tenho que criar um controle para a tabela SF3, pois  
				//ela pode duplicar para cada SFT, entao tenho que garantir que estou processando somente
				//1 vez.                                                                                
				If !lResF3FT
					While SF3->(!Eof() .And. F3_FILIAL+DTOS(F3_ENTRADA)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA+F3_CFO+STR(F3_ALIQICM,5,2)==cChvSeek)
						//Garanto a leitura do IDENT correto
						If SF3->F3_IDENTFT==(cAliasSFT)->FT_IDENTF3
							nRecSF3DBF	:=	SF3->(Recno())
							Exit
						EndIf                               
						SF3->(dbSkip())
					End
				EndIf
			EndIf
			//Posicionando tabelas de acordo com os itens dos documentos fiscais.
			If lTop
				lAchouSF4	:=	!Empty((cAliasSFT)->(&(cCmpTes)))
				cUnid 		:=	(cAliasSFT)->(&(cCmpUm))     
			Else
				If (cAlsSD)->(dbSeek (xFilial(cAlsSD)+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA+(cAliasSFT)->FT_PRODUTO+(cAliasSFT)->FT_ITEM))
					lAchouSF4	:=	CATSeek("SF4",,xFilial ("SF4")+(cAlsSD)->(&(cCmpTes)))
					cUnid 		:=	(cAlsSD)->(&(cCmpUm))
				Else
					lAchouSF4	:=	.F.
				EndIf
				CATSeek("SB1",,xFilial("SB1")+(cAliasSFT)->FT_PRODUTO)
			EndIf     
		   If !Empty(cCodProdED)
				If !Empty((cAliasSB1)->&cCodProdED)
					cProd := Alltrim(IIf(ValType((cAliasSB1)->&cCodProdED)=="N",Str((cAliasSB1)->&cCodProdED),(cAliasSB1)->&cCodProdED))+Strzero(BuscaFil(@aFiliais,xFilial("SB1")),3) //CATRetNro(Alltrim(xFilial("SB1")))
				EndIf
			EndIf				     
			If Empty(cProd)
				(cAliasSFT)->(dbSkip())
				Loop		                      
			EndIf				     
			//Caso nao encontre a NF, utilizo do produto
			If Empty(cUnid)
				cUnid		:=	(cAliasSB1)->B1_UM
			EndIf 
			
			If cChave <> (cAliasSFT)->(FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA)
				//Grava o REGISTRO 5480-NOTA FISCAL MODELO 4 - CFOP 5949
				If Len(aReg5480) > 0
					CATRegTrS(cAlias,nRelacDoc,aReg5480,nItem)
				Endif
				nRelacDoc++		//Utilizado para relacionar os documentos fiscais aos seus elementos inferiores/dependentes
				If cEspecie$"01#02#03#04#06#07#08#09#11#12#13#21#22#26#27#28#31#32" .And. !cSituaDoc$"02/04/05"
					CATSeek(cAlsSF,,xFilial(cAlsSF)+aCmpAntSFT[1]+aCmpAntSFT[2]+aCmpAntSFT[3]+aCmpAntSFT[4])
					If cEntSai=="1"  //entradas           
						Reg5200(aPartDoc,cEspecie,cAlias,cAliasCDT,nRelacDoc,aCmpAntSFT,@aReg5200,@lGrava0150,dDataDe,cAlsSF,cAliasSFT)
					ElseIf cEntSai=="2" .and. cEspecie<>"06" //saídas
						Reg5400(aPartDoc,cEspecie,cAlias,nRelacDoc,aCmpAntSFT,@aReg5400,@lGrava0150,cAlsSF,cAliasSFT)
					EndIf
				EndIf
				aReg5200	:=	{}
				aReg5400	:=	{}
				aReg5480	:=	{}
				cChave	:= (cAliasSFT)->(FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA)
				lGrvGnreS := .F.				// Adicionado Valdemir José 17/04/2018
			EndIf

			If cEspecie$"01#02#03#04#06#07#08#09#11#12#13#21#22#26#27#28#31#32" .And. !cSituaDoc$"02/04/05"
				If cEntSai=="1" //entradas
					//REGISTRO 5220-ITENS DO DOCUMENTO FISCAL DE ENTRADA
					lGrava0300 := Reg5220(cAlias,nRelacDoc,nItem,@aReg5220,cEspecie,cAliasSFT,@cAliasCD5,lIss,cProd,@aReg5260,@aReg5800)
				ElseIf cEntSai=="2" .and. cEspecie<>"06" //saídas
					//REGISTRO 5440-ITENS DO DOCUMENTO FISCAL DE SAIDA
					lGrava0300 := Reg5440(cAlias,nRelacDoc,nItem,@aReg5440,cEspecie,cAliasSFT,lIss,cProd)
					//REGISTRO 5480-NOTA FISCAL MODELO 4 - CFOP 5949
					If lR5480 .And. cEspecie=="31" .And. !Empty((cAliasSFT)->(FT_SERORI+FT_NFORI))  //NF-E
						Reg5480(cAlias,nRelacDoc,nItem,@aReg5480,cAliasSFT)
					EndIf
				EndIf
			EndIf
              
			//REGISTRO 0300 - Cadastro das Mercadorias Compradas e Produzidas
			//Funcao independente, monta a estrutura dos registros e efetua as gravacoes no TRB       
			If lGrava0300																									
				Reg0300(cAlias,@aReg0300,cProd,cAliasSB1,cEspecie)		   			
			EndIf

			If Type("oProcess")=="O"
				If oProcess:Cancel()
					Exit
				EndIf
			Else
				If Interrupcao(@lEnd)
					Exit
				EndIf
			EndIf
			
			If cEntSai=="1"    
				If !lGrvGnreE
					lGrvGnreE := Reg5240(@aReg5240,@aArrec,cAlias,nRelacDoc,nItem) 
				EndIf
						 
				Reg5260(cAliasCD5, @aReg5260,(cAliasSFT)->FT_FILIAL,(cAliasSFT)->FT_NFISCAL,SerieNfId(cAliasSFT,2,"FT_SERIE")) 		

				If Len(aReg5260) > 0
					CATRegTrS(cAlias,nRelacDoc,aReg5260,nItem)
				EndIf   
			ElseIf cEntSai=="2"
				If !lGrvGnreS
					Reg5460(@aReg5460,@aArrec,cAlias,nRelacDoc,nItem,@aReg5400,(cAliasSFT)->FT_FILIAL,(cAliasSFT)->FT_NFISCAL,(cAliasSFT)->FT_SERIE,(cAliasSFT)->FT_CLIEFOR,(cAliasSFT)->FT_LOJA,aWizard,Iif((cAliasSFT)->FT_VALICM> 0, .T.,.F.),(cAlsSF)->F2_VALICM)
					lGrvGnreS := .T.					// Adicionado por Valdemir José 17/04/2018
				EndIf
			EndIf	
			If lGrava0150
				Reg0150(@aReg0150,aPartDoc,cAlias,aWizard)
			EndIf			
			nItem++
			(cAliasSFT)->(DbSkip ())
		EndDo	//ENDDO da NF
        
		If Len(aReg5480) > 0
			CATRegTrS(cAlias,nRelacDoc,aReg5480,nItem)
		Endif
		
		#IFDEF TOP
			If (TcSrvType ()<>"AS/400")
				DbSelectArea (cAliasSFT)
				(cAliasSFT)->(DbCloseArea())
			Else
		#ENDIF
				RetIndex("SFT")
				FErase(cIndex+OrdBagExt())
		#IFDEF TOP
			EndIf
		#ENDIF

		cAliasSFT	:=	"SFT"
		If Type("oProcess")=="O"
			If oProcess:Cancel()
				Exit
			EndIf
		Else
			If Interrupcao(@lEnd)
				Exit
			EndIf
		EndIf
	Next nContMov

	If Type("oProcess")=="O"
		If oProcess:Cancel()
			Exit
		EndIf
	Else
		If Interrupcao(@lEnd)
			Exit
		EndIf
	EndIf
	SM0->(DbSkip ())
EndDo	//ENDDO da SM0 para a mesma EMPRESA

//Restauro a area do SM0
RestArea(aAreaSM0)
cFilAnt := FWGETCODFILIAL

If Type("oProcess")=="O"
	If oProcess:Cancel()
		//Funcao de fechamento do TRB criado
		GeraTrb(2,@aArq,@cAlias)
		Return
	EndIf
Else
	If Interrupcao(@lEnd)
		//Funcao de fechamento do TRB criado
		GeraTrb(2,@aArq,@cAlias)
		Return
	EndIf
EndIf

//Gravacao do REGISTRO 0300 - TABELA DE IDENTIFICACAO DO ITEM³
CATRegDep(cAlias,aReg0300,,.F.,,.T.,"",.T.)

//Gravacao do REGISTRO 5800 - OUTROS CRÉDITOS
If Len(aReg5800) > 0
    CATRegDep(cAlias,aReg5800,,.F.,,.T.,"",.F.)
EndIf

If Type("oProcess")=="O"
	If oProcess:Cancel()
		//Funcao de fechamento do TRB criado
		GeraTrb(2,@aArq,@cAlias)	
		MsgAlert(OemToAnsi(STR0003)) //"Não foi possível gerar o arquivo!"
		Return
	EndIf
Else
	If Interrupcao(@lEnd)
		//Funcao de fechamento do TRB criado
		GeraTrb(2,@aArq,@cAlias)	
		MsgAlert(OemToAnsi(STR0003)) //"Não foi possível gerar o arquivo!"
		Return
	EndIf
EndIf
                                                             
//Gravacao dos indicadores de movimento dos registros 
CATIndMov(cAlias)

//Funcao responsavel geracao meio-magnetico com base no TRB
OrgTxt(cAlias,cFileDest,@oProcess,@lEnd,@nRetCpy)

//Funcao de fechamento do TRB criado
GeraTrb(2,@aArq,@cAlias)	

//Mensgem de final de processamento da rotina
If (File(cFileDest) .OR. nRetCpy == 0 )
	nRetType := GetRemoteType( @cLib )
	QOut( cLib )
	IF	nRetType == 5 //"HTML" $ cLib
		MsgInfo(OemToAnsi(STR0001+" "+STR0002)) //"Arquivo "###" gerado com sucesso!"
	ELSE
		MsgInfo(OemToAnsi(STR0001+cFileDest+STR0002)) //"Arquivo "###" gerado com sucesso!"
	ENDIF
Else
	MsgAlert(OemToAnsi(STR0003)) //"Não foi possível gerar o arquivo!"
EndIf

Return (.T.)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡ao    ³CATApICMS    | Autor ³Cecilia Carvalho		   ³ Data ³13.04.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³PREPARAÇÃO PARA GERAÇÃO DOS REGISTROS 5240, 5460 E 5800            ³±± 
±±³          ³Funcao utilizada para montar a estrutura dos registros acima e     ³±±
±±³          ³  gravar no TRB para geracao do TXT                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard    - Informacoes do assistente da rotina                   ³±±
±±³          ³aArrec     - array com as informações dos documentos de arrecadação³±±
±±³          ³cAlias     - Alias do TRB                                          ³±±
±±³          ³cMVEstado  - Conteudo do parametro MV_ESTADO                       ³±±
±±³          ³lTop       - Flag para identificar ambiente TOP                    ³±±
±±³          ³cMVSUBTRIB - Conteudo do parametro MV_SUBTRIB                      ³±±
±±³          ³oProcess   - Objeto da nova barra de progressao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - CAT153                                                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CATApICMS(aWizard,aArrec,aReg5800,cAlias,cMVEstado,lTop,cMVSUBTRIB,oProcess)
Local	dDataDe		:=	SToD(aWizard[1][1])
Local	dDataAte		:=	STod(aWizard[1][2])
Local	cArqICMS		:=	aWizard[1][4]
Local	aApICM		:=	{}
Local	aApICMST    :=	{}
Local	nApuracao	:=	3
Local	nPeriodo		:=	1  
Local nVlrCred    :=	0
Local nImpICMS    :=	0
Local nImpICMSST  :=	0
Local	nUf			:=	0
Local nPos        :=	0
Local nPos1       :=	0
Local nPos2       :=	0          
Local nX          :=	0     
Local nVlTotal    :=	0   
Local cCampos	  :=	"SF6.F6_FILIAL,SF6.F6_NUMERO,SF6.F6_DTPAGTO,SF6.F6_DTVENC,SF6.F6_AUTENT,SF6.F6_EST,SF6.F6_TIPOIMP,SF6.F6_OPERNF,"+;
						"SF6.F6_VALOR,SF6.F6_JUROS,SF6.F6_MULTA,SF6.F6_ATMON,SF6.F6_DOC,SF6.F6_SERIE,SF6.F6_CLIFOR,SF6.F6_LOJA "
Local cAliasSF6	:= "SF6"           
Local lQuery		:= .F.

If SF6->(FieldPos("F6_VIMPDED"))>0
	cCampos += ",SF6.F6_VIMPDED"
Endif
//Leitura da SF6 para pegar as guias geradas
#IFDEF TOP

    If TcSrvType()<>"AS/400"

		cCampos		:= "% " + cCampos + " %"
		lQuery 		:= .T.
		cAliasSF6	:= GetNextAlias()   
		
		BeginSql Alias cAliasSF6
			COLUMN F6_DTARREC AS DATE
			COLUMN F6_DTVENC  AS DATE
			COLUMN F6_DTPAGTO AS DATE
			SELECT %Exp:cCampos%
			
			FROM %table:SF6% SF6
				
			WHERE SF6.F6_FILIAL = %xFilial:SF6% AND
					SF6.F6_EST = %Exp:cMVEstado% AND
					SF6.F6_DTARREC >= %Exp:Dtos(dDataDe)% AND
					SF6.F6_DTARREC <= %Exp:Dtos(dDataAte)% AND
					SF6.%NotDel% 
				
			ORDER BY %Order:SF6%
		EndSql
	
		dbSelectArea(cAliasSF6)

	Else
	                  
#ENDIF
		cArqInd		:=	CriaTrab(Nil,.F.)
		cChave		:=	SF6->(IndexKey())
		cCondicao 	:= 'F6_FILIAL == "' + xFilial("SF6") + '" .And. '
		cCondicao 	+= 'F6_EST == "' + cMVEstado + '" .And. '
		cCondicao 	+= 'F6_DTARREC >= "' + Dtos(dDataDe) + '" .And. '
		cCondicao 	+= 'F6_DTARREC <= "' + Dtos(dDataAte) '

		IndRegua(cAliasSF6,cArqInd,cChave,,cCondicao,"Selecionando Registros")  
		#IFNDEF TOP
			DbSetIndex(cArqInd+OrdBagExt())
		#ENDIF                
		(cAliasSF6)->(dbGotop())
		
#IFDEF TOP
	Endif    
#ENDIF

Do While !(cAliasSF6)->(Eof())
	If (cAliasSF6)->F6_TIPOIMP$"0/1/3"    
		nVlTotal := (cAliasSF6)->F6_VALOR + (cAliasSF6)->F6_JUROS + (cAliasSF6)->F6_MULTA + (cAliasSF6)->F6_ATMON
		aAdd(aArrec, {})
      	nPos2 := Len(aArrec)
      	aAdd(aArrec[nPos2], Iif((cAliasSF6)->F6_OPERNF=="1","1","2"))          	//01 - ENTRADA/SAÍDA
   		aAdd(aArrec[nPos2], Iif((cAliasSF6)->F6_TIPOIMP=="3","1","0"))         	//02 - COD_DA
		aAdd(aArrec[nPos2], (cAliasSF6)->F6_EST)						       		//03 - UF       
		aAdd(aArrec[nPos2], (cAliasSF6)->F6_NUMERO)	              				//04 - NUM_DA		    
		aAdd(aArrec[nPos2], (cAliasSF6)->F6_AUTENT)						        	//05 - COD_AUT
		aAdd(aArrec[nPos2], AllTrim(Transform(nVlTotal,"@E 99999999999.99")))		//06 - VL_DA
		aAdd(aArrec[nPos2], (cAliasSF6)->F6_DTVENC)  					  				//07 - DT_VCTO
		aAdd(aArrec[nPos2], (cAliasSF6)->F6_DTPAGTO)  						    	//08 - DT_PGTO
      	If (cAliasSF6)->F6_TIPOIMP$"1/3"
      		If SF6->(FieldPos("F6_VIMPDED"))>0
      			aAdd(aArrec[nPos2], (cAliasSF6)->F6_VIMPDED)
      		Else
				aAdd(aArrec[nPos2], (cAliasSF6)->F6_VALOR)
			Endif
      	Else
			aAdd(aArrec[nPos2], "0,00")  						         
	   	EndIf
		aAdd(aArrec[nPos2], (cAliasSF6)->F6_DOC)  						        //10 - Nr. Doc.
		aAdd(aArrec[nPos2], (cAliasSF6)->F6_SERIE)  						    //11 - Serie Doc.
		aAdd(aArrec[nPos2], (cAliasSF6)->F6_CLIFOR)  						    //12 - Cli/For
		aAdd(aArrec[nPos2], (cAliasSF6)->F6_LOJA)  						        //13 - Loja
		aAdd(aArrec[nPos2], (cAliasSF6)->F6_FILIAL)								//14 - FILIAL
	EndIf            
	(cAliasSF6)->(dbSkip())
Enddo           

If !lQuery
	RetIndex("SF6")	
	dbClearFilter()	
	Ferase(cArqInd+OrdBagExt())
Else
	dbSelectArea(cAliasSF6)
	dbCloseArea()
Endif

//Leitura do arquivo de apuracao ICMS para pegar os valores de outros créditos para levar para o registro 5800  
aApICM		:=	FisApur("IC",Year(dDataAte),Month(dDataAte),nApuracao,nPeriodo,"*",.F.,{},1,.F.,"")
aApICMST    :=	FisApur("ST",Year(dDataAte),Month(dDataAte),nApuracao,nPeriodo,"*",.F.,{},1,.F.,"")
//verificar os créditos na guia ICMS Próprio
nVlrCred :=	Iif (aScan(aApICM, {|a| a[4]=="006.00"})<>0, aApICM[aScan(aApICM, {|a| a[4]=="006.00"})][3],0)
If nVlrCred > 0 
	nPos1 := aScan(aApICM,{|a|a[1]=="006"})
	If nPos1 > 0
		For nX:=nPos1 to Len(aApICM)
			If aApICM[nX][1]=="006" .And. aApICM[nX][4]<>"006.00"
				aAdd(aReg5800, {})
				nPos2 := Len (aReg5800)
				aAdd(aReg5800[nPos2], "5800")			//01 - REG
				aAdd(aReg5800[nPos2], aApICM[nX][3])	//02 - VL_CRED
				aAdd(aReg5800[nPos2], aApICM[nX][2])	//03 - DESCRICAO       
			EndIf   
		Next nX 
	EndIf
EndIf
//verificar os créditos na guia ICMS ST
nVlrCred :=	Iif (aScan(aApICMST, {|a| a[4]=="007.00"})<>0, aApICMST[aScan(aApICMST, {|a| a[4]=="007.00"})][3],0)
If nVlrCred > 0 
   nPos1 := aScan(aApICMST,{|a|a[1]=="007"})
	If nPos1 > 0
		For nX:=nPos1 to Len(aApICMST)
			If aApICMST[nX][1]=="007" .And. aApICMST[nX][4]<>"007.00"
				aAdd(aReg5800, {})
		      nPos2 := Len (aReg5800)
		      aAdd(aReg5800[nPos2], "5800")                                            //01 - REG
			   aAdd(aReg5800[nPos2], aApICMST[nX][3])	                                 //02 - VL_CRED
			   aAdd(aReg5800[nPos2], aApICMST[nX][2])						             //03 - DESCRICAO       
		   EndIf   
		Next nX 
	EndIf
EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡ao    ³Reg0000   | Autor ³Cecilia Carvalho              ³ Data ³20.03.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ABERTURA DO ARQUIVO DIGITAL E IDENTIFICACAO DO CONTRIBUINTE        ³±±
±±³          ³- Geracao do Registro 0000 e gravacao do mesmo                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpL1 := Reg0000(aWizard,cAlias,dDataDe,dDataAte)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aWizard  - informacoes preenchidas no Wizard                       ³±±
±±³          ³cAlias   - Alias do TRB que recebera as informacoes                ³±±
±±³          ³dDataDe  - Data incial do periodo de apuracao.                     ³±±
±±³          ³dDataAte - Data final do periodo de apuracao.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 - Sempre .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - CAT153                                                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Reg0000(aWizard, cAlias)
Local	aReg	:= {}
Local	lRet	:= .T.
Local	nPos	:=	0

cVersao := "01"
aAdd(aReg, {})
nPos	:=	Len (aReg)
aAdd (aReg[nPos], "0000")													//01 - REG
aAdd (aReg[nPos], "PRODCRED")												//02 - PRODCRED
aAdd (aReg[nPos], cVersao)													//03 - COD_VER
aAdd (aReg[nPos], Strzero(Val(SubStr (aWizard[2][1], 1, 1))+1,2))		//04 - COD_FIN
aAdd (aReg[nPos], aWizard[1][3])											//05 - PERIODO
aAdd (aReg[nPos], SM0->M0_NOMECOM)											//06 - NOME
aAdd (aReg[nPos], CATConType(SM0->M0_CGC))    	                    	//07 - CNPJ  
aAdd (aReg[nPos], CATConType(CATVldIE(SM0->M0_INSC)))                	//08 - IE    
CATRegTrS (cAlias,, aReg)
Return (lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡ao    ³Reg0150   | Autor ³Cecilia Carvlaho              ³ Data ³30.03.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³REGISTRO 0150 - TABELA DE CADASTRO DE PARTICIPANTES                ³±±
±±³          ³                                                                   ³±±
±±³          ³- Geracao e gravacao dos Registros                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpL1 := Reg0150(aReg0150,aPartDoc,cAlias,aWizard)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aReg0150 - Array com todas as informacoes do Cliente/Fornecedor    ³±±
±±³          ³            para controle da rotina.                               ³±±
±±³          ³aPartDoc - Array com todas as informacoes do Cliente/Fornecedor    ³±±
±±³          ³cAlias   - Alias do arquivo temporario base de geracao do TXT      ³±±
±±³          ³aWizard  - Parametros informados no wizard da rotina               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - CAT153                                                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Reg0150(aReg0150,aPartDoc,cAlias,aWizard)
Local	nPos		:=	0
Local	nX			:=	0
Local	dDataDe		:=	SToD (aWizard[1][1])
Local	dDataAte	:=	SToD (aWizard[1][2])

If Len(aPartDoc)>0 .And. aScan(aReg0150, {|aX| aX[2]==aPartDoc[1]})==0
	aAdd (aReg0150, {})
	nPos	:=	Len (aReg0150)
	aAdd (aReg0150[nPos], "0150")
	For nX := 1 To 13
		aAdd (aReg0150[nPos], aPartDoc[nX])
	Next
	CATRegTrS (cAlias,aReg0150[nPos][2], {aReg0150[nPos]})
EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡ao    ³Reg0300  | Autor ³Cecilia Carvalho              ³ Data ³30.03.2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³TABELA DE IDENTIFICACAO DO ITEM                                    ³±±
±±³          ³                                                                   ³±±
±±³          ³- Geracao do Registro 0300                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpL1 :=Reg0300(cAlias,aReg0300,cProd,cAliasSB1)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias    - Alias do TRB que recebera as informacoes               ³±±
±±³          ³aReg0300  - Array com as informacoes a serem retornadads por       ³±±
±±³          ³            referencia para gerar o registro 0300                  ³±±
±±³          ³cProd     - Codigo do produto formatado pela rotina                ³±±
±±³          ³cAliasSB1 - Pode ser o proprio SB1 ou um alias gerado por uma      ³±±
±±³          ³            query                                                  ³±±
±±³          ³cEspecie  - Especie da NF                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 - Sempre .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - CAT153                                                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Reg0300(cAlias,aReg0300,cProd,cAliasSB1,cEspecie)
Local	nX					:=	0
Local	aReg300			:= {}
Local	nPos				:=	0
Local cDscServ			:= ""
Local cCodNCM			:= ""
Local cCodUND			:= ""

DEFAULT cAliasSB1		:=	"SB1"
DEFAULT cProd			:=	(cAliasSB1)->B1_COD+Strzero(BuscaFil(@aFiliais,xFilial("SB1")),3) 

//REGISTRO 0300 - TABELA DE IDENTIFICACAO DO ITEM         
//Verifico a existencia do produto para evitar duplicidade
If (nPos := aScan(aReg0300,{|aX| aX[2]==cProd}))==0
   //CTR (09) - CTA (11) - CA (12) - CTF (13) - NFST (22) - CT-e (32)
	If cEspecie$"09,11,12,13,32" //Conhecimento de Transporte
		cDscServ	:= "SERVIÇO DE TRANSPORTE"        
	//NFSC (21) - NTSC (21) - NTST (22)	
	ElseIf cEspecie$"21,22" //Servico Comunicação
		cDscServ	:= "SERVIÇO DE COMUNICAÇÃO"
	Else	        
		cDscServ	:= xFilial("SB1")+Alltrim((cAliasSB1)->B1_DESC)
		cCodNCM	:= (cAliasSB1)->B1_POSIPI
		cCodUND	:= (cAliasSB1)->B1_UM
	Endif	
	aAdd(aReg0300,{})
	nPos	:=	Len (aReg0300)
	aAdd(aReg0300[nPos], "0300")			//01 - REG
	aAdd(aReg0300[nPos], cProd)     		//02 - COD_ITEM
	aAdd(aReg0300[nPos], cCodNCM)	  		//03 - COD_NCM
	aAdd(aReg0300[nPos], cDscServ)		//04 - DESCRICAO	
	aAdd(aReg0300[nPos], cCodUND)			//05 - UNIDADE		
EndIf
Return (.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³Reg5200   ³ Autor ³Cecilia Carvalho       ³ Data ³12.04.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³DOCUMENTO FISCAL DE ENTRADA                                 ³±±
±±³          ³                                                            ³±±
±±³          ³Geracao e gravacao do Registro 5200                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao CATRegTrS com as informacoes de todos os docu-   ³±±
±±³          ³ mentos fiscais processados.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aPartDoc   - Array com todas as informacoes do Cliente/Forne³±±
±±³          ³             cedor.                                         ³±±
±±³          ³cEspecie   - Modelo do documento fiscal                     ³±±
±±³          ³cAlias     - Alias do TRB que recebera as informacoes       ³±±
±±³          ³nRelac     - Flag de relacionamento com os sub-registros    ³±±
±±³          ³aCmpAntSFT - Informacoes de cabecalho do documento fiscal   ³±±
±±³          ³aReg5200   - Informacoes sobre todos documentos fiscais pro ³±±
±±³          ³             cessados no while da funcao principal.         ³±±
±±³          ³lGrava0150 - Flag para indicar se deve gerar 0150           ³±±
±±³          ³dDataDe    - Data de início do período de referência        ³±±
±±³          ³cAlsSF		 - Alias do SF1								           ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Reg5200(aPartDoc,cEspecie,cAlias,cAliasCDT,nRelac,aCmpAntSFT,aReg5200,lGrava0150,dDataDe,cAlsSF,cAliasSFT)
Local	nPos		:=	0
Local	nX			:=	0
Local cIndExt  :=  "0"
Local dDtEnt   :=  CToD("  /  /  ")                 

//Tratamento para evitar duplicidade no registro
If aScan(aReg5200,{|aX| Alltrim(aX[5])==Alltrim(aCmpAntSFT[2]) .And. aX[6]==aCmpAntSFT[1] .And. aX[3]==aCmpAntSFT[6]})==0
 	//Inicio da montagem do registro
 	dDtEnt := aCmpAntSFT[5]					   			                  	    
	If (cAliasCDT)->CDT_TPMOV == "E" .And. (cAliasCDT)->CDT_DOC + (cAliasCDT)->CDT_SERIE == aCmpAntSFT[1] + aCmpAntSFT[2]
		If !Empty((cAliasCDT)->CDT_SITEXT)
			cIndExt := "1"    
			dDtEnt := (cAliasCDT)->CDT_DTAREC
		Endif
	Else
	    If aCmpAntSFT[5] < dDataDe
	        cIndExt := "1"
	        dDtEnt  := aCmpAntSFT[5]  
	    EndIf	
	EndIf
	aAdd(aReg5200, {})
	nPos	:=	Len (aReg5200)
	aAdd (aReg5200[nPos], "5200")																//01 - REG
	aAdd (aReg5200[nPos], cIndExt)																//02 - IND_EXT
	aAdd (aReg5200[nPos], aCmpAntSFT[6])														//03 - DT_EMISSAO
	aAdd (aReg5200[nPos], Iif(aCmpAntSFT[26]=="S","31",cEspecie))								//04 - TIP_DOC
//	aAdd (aReg5200[nPos], Space(3-Len(Alltrim(aCmpAntSFT[2])))+Alltrim(aCmpAntSFT[2]))			//05 - SER
	aAdd (aReg5200[nPos], Padl(Alltrim(SerieNfId(cAliasSFT,2,"FT_SERIE")),3,"0"))				//05 - SER
	aAdd (aReg5200[nPos], Alltrim(aCmpAntSFT[1]))												//06 - NUM_DOC
	aAdd (aReg5200[nPos], aPartDoc[1])															//07 - COD_REMETENTE
	aAdd (aReg5200[nPos], dDtEnt)																//08 - DT_E	
	aAdd (aReg5200[nPos], (cAlsSF)->F1_VALBRUT)													//09 - VL_DOC (Vl Contabil)
	aAdd (aReg5200[nPos], (cAlsSF)->F1_BASEICM)													//10 - VL_BC_ICMS
	aAdd (aReg5200[nPos], (cAlsSF)->F1_VALICM)													//11 - VL_ICMS	
	If cEspecie=="31" .Or. cEspecie=="32"														//12 - CHAVE_ACESSO
		aAdd (aReg5200[nPos], aCmpAntSFT[23])			 			
	Else
		aAdd (aReg5200[nPos], "")						  			
	EndIf
	CATRegTrS(cAlias,nRelac,aReg5200)	
	lGrava0150 := .T.
EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³Reg5220   ³ Autor ³Cecilia Carvalho       ³ Data ³12.04.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ITENS DO DOCUMENTO DE ENTRADA                               ³±±
±±³          ³                                                            ³±±
±±³          ³Geracao e gravacao do Registro 5220                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao CATRegTrS com a informacao de cada item do docu- ³±±
±±³          ³ mento fiscal processado no while da funcao principal.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3(1:N) Para cada Registro 5200                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias    - Alias do TRB que recebera as informacoes        ³±±
±±³          ³nRelac    - Flag de relacionamento com os sub-registros     ³±±
±±³          ³nItem     - Contador do item para cada documento fiscal.    ³±±
±±³          ³aReg5220  - Informacoes sobre os itens do documento fiscal  ³±±
±±³          ³            processado no while da funcao principal.        ³±±
±±³          ³cEspecie  - Modelo do documento fiscal                      ³±±
±±³          ³cAliasSFT - Alias da tabela SFT posicionada                 ³±±
±±³          ³cAlsSD    - Alias da tabela SD? posicionada                 ³±±
±±³          ³lIss      - Indica se o documento incide ISS.               ³±±
±±³          ³cProd     - Codigo de produto do item emm processamento     ³±±
±±³          ³aReg5260  - Informacoes sobre operações de importação       ³±±
±±³          ³aReg5800  - Informacoes sobre outros créditos               ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Reg5220(cAlias,nRelac,nItem,aReg5220,cEspecie,cAliasSFT,cAliasCD5,lIss,cProd,aReg5260,aReg5800)
Local	lRet		:=	.F.
Local	nPos		:=	0
Local	nPos1		:=	0   
Local cTexto   :=  ""                   

//Montando array com a estrutura do registro 5220
aAdd(aReg5220, {})
nPos :=	Len (aReg5220)
aAdd(aReg5220[nPos], "5220")		                                          //01 - REG
aAdd(aReg5220[nPos], (cAliasSFT)->FT_CFOP)		                           //02 - CFOP
If Alltrim((cAliasSFT)->FT_CFOP)$"1356/2356/3356/1306/2306"
	aAdd(aReg5220[nPos], cProd)								  							//03 - COD_MERC
	aAdd(aReg5220[nPos], "")	        					 				            //04 - QTDE_ENT
	aAdd(aReg5220[nPos], (cAliasSFT)->FT_PRCUNIT)	   				 			//05 - VL_ITEM
	aAdd(aReg5220[nPos], IIf(lIss,0,(cAliasSFT)->FT_BASEICM))					//06 - VL_BC_ICMS
	aAdd(aReg5220[nPos], IIf(lIss,0,(cAliasSFT)->FT_ALIQICM))		  			//07 - ALIQ_ICMS
ElseIf Alltrim((cAliasSFT)->FT_CFOP)$"1604"
   aAdd(aReg5220[nPos], "") 								  								//03 - COD_MERC
	aAdd(aReg5220[nPos], "")       					 				               //04 - QTDE_ENT
	aAdd(aReg5220[nPos], "0,00")   				 					               //05 - VL_ITEM
	aAdd(aReg5220[nPos], "0,00")				 	                              //06 - VL_BC_ICMS
	aAdd(aReg5220[nPos], "0,00")	
	cTexto := "Lcto destinado ao registro da apropriação de crédito do imposto, qdo admitido, de bens do ativo imobilizado. NF:" + Alltrim((cAliasSFT)->FT_NFISCAL)
	aAdd(aReg5800, {})
	nPos1 := Len (aReg5800)
   aAdd(aReg5800[nPos1], "5800") 							  							//01 - REG
	aAdd(aReg5800[nPos1], (cAliasSFT)->FT_VALICM)					 			   //02 - VL_CRED
	aAdd(aReg5800[nPos1], cTexto)	   					 					         //03 - DESCRICAO
Else
	aAdd(aReg5220[nPos], cProd)								  							//03 - COD_MERC
	aAdd(aReg5220[nPos], (cAliasSFT)->FT_QUANT)						 				//04 - QTDE_ENT
	aAdd(aReg5220[nPos], (cAliasSFT)->FT_PRCUNIT)	   				 			//05 - VL_ITEM
	aAdd(aReg5220[nPos], IIf(lIss,0,(cAliasSFT)->FT_BASEICM))					//06 - VL_BC_ICMS
	aAdd(aReg5220[nPos], IIf(lIss,0,(cAliasSFT)->FT_ALIQICM))		  			//07 - ALIQ_ICMS
EndIf	
CATRegTrS(cAlias,nRelac,aReg5220,nItem) 
lRet := .T.
Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³Reg5240   ³ Autor ³Cecilia Carvalho       ³ Data ³13.04.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ DOCUMENTO DE ARRECADAÇÃO - ENTRADA                         ³±±
±±³          ³                                                            ³±±
±±³          ³Geracao e gravacao do Registro 5240                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao CATRegTrS com as informacoes de todos os docu-   ³±±
±±³          ³ mentos de arrecadação     .                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aReg5240 - Array com todas as informacoes do docuemnto de   ³±±
±±³          ³           arrecadação.                                     ³±±
±±³          ³aArrec   - Array com os números de docto de arrecadação     ³±±
±±³          ³           gravados na rotina CATApICMS                     ³±±
±±³          ³cAlias   - Alias do TRB que recebera as informacoes         ³±±
±±³          ³nRelac   - Flag de relacionamento com os sub-registros      ³±±
±±³          ³nItem    - Contador do item para cada documento fiscal.     ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Reg5240(aReg5240,aArrec,cAlias,nRelac,nItem)
Local	nPos		:=	0
Local	nX			:=	0
Local lRet     := .F.     

For nX = 1 to Len(aArrec)
	If aArrec[nX][1]=="1"
		aAdd(aReg5240, {})
		nPos :=	Len (aReg5240)
		aAdd(aReg5240[nPos], "5240")		 //01 - REG
		aAdd(aReg5240[nPos], aArrec[nX][2])	 //02 - COD_DA
		aAdd(aReg5240[nPos], aArrec[nX][3])	 //03 - UF       
		aAdd(aReg5240[nPos], aArrec[nX][4])	 //04 - NUM_DA		    
		aAdd(aReg5240[nPos], aArrec[nX][5])	 //05 - COD_AUT
		aAdd(aReg5240[nPos], aArrec[nX][6])  //06 - VL_DA
		aAdd(aReg5240[nPos], aArrec[nX][7])  //07 - DT_VCTO
		aAdd(aReg5240[nPos], aArrec[nX][8])  //08 - DT_PGTO
		aAdd(aReg5240[nPos], aArrec[nX][9])  //09 - CRED_UTIL   
     	CATRegTrS(cAlias,nRelac,aReg5240,nItem)
     	lRet := .T.
    EndIf
Next nX    
Return (lRet)   


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³Reg5260   ³ Autor ³Graziele Paro          ³ Data ³25.06.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ DOCUMENTO DE ARRECADAÇÃO - ENTRADA                         ³±±
±±³          ³                                                            ³±±
±±³          ³Geracao e gravacao do Registro 5260                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no array       ³±±
±±³          ³ aReg5260, neste array contem informações dos 			  ³±±
±±³          ³ Complementos de Docs de Importação.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAliasCD5 - Alias da tabela CD5							  ³±±
±±³          ³aReg5260   Array                                            ³±±
±±³          ³cFil     - Filial      								      ³±±
±±³          ³nNotaFis - Nota Fiscal         							  ³±±
±±³          ³cSerie   - Serie										      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Reg5260(cAliasCD5,aReg5260,cFil,nNotaFis,cSerie) 
Local nPos    :=  0         
Local cDocImp  :=  ""
DEFAULT cFil:= ""
DEFAULT nNotaFis:= ""  
DEFAULT cSerie := ""
(cAliasCD5)->(DbSetOrder(1))
(cAliasCD5)->(DbGoTop())  	  
(cAliasCD5)->(dbSeek(cFil + nNotaFis + cSerie))
	While !(cAliasCD5)->(Eof()) .And. (((cAliasCD5)->CD5_FILIAL + (cAliasCD5)->CD5_DOC + (cAliasCD5)->CD5_SERIE)) == cFil + nNotaFis + cSerie
			cDocImp	:=	(cAliasCD5)->CD5_DOCIMP
			//Nao podem ser informados para um mesmo documento fiscal, dois ou mais registros  
			//com o mesmo conteudo no campo NUM_DOC_IMP e NUM_ACDRAW                			
			If (nPos := aScan(aReg5260, {|aZ| aZ[3] == cDocImp})) == 0
				aAdd(aReg5260, {})
				nPos := Len (aReg5260)
				aAdd(aReg5260[nPos], "5260")	 						//01 - REG	
				aAdd(aReg5260[nPos], (cAliasCD5)->CD5_TPIMP)	//02 - COD_DOC_IMP
				aAdd(aReg5260[nPos], (cAliasCD5)->CD5_DOCIMP)	//03 - NUM_DOC_IMP
			Endif
		(cAliasCD5)->(DbSkip())
	End
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³Reg5400   ³ Autor ³Cecilia Carvalho       ³ Data ³12.04.2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³DOCUMENTO FISCAL DE SAÍDA                                    ³±±
±±³          ³                                                             ³±±
±±³          ³Geracao e gravacao do Registro 5400                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves  ³±±
±±³          ³ da funcao CATRegTrS com as informacoes de todos os docu-    ³±±
±±³          ³ mentos fiscais processados.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³2                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aPartDoc   - Array com todas as informacoes do Cliente/Forne-³±±
±±³          ³             cedor.                                          ³±±
±±³          ³cEspecie   - Modelo do documento fiscal                      ³±±
±±³          ³cAlias     - Alias do TRB que recebera as informacoes        ³±±
±±³          ³nRelac     - Flag de relacionamento com os sub-registros     ³±±
±±³          ³aCmpAntSFT - Informacoes de cabecalho do documento fiscal    ³±±
±±³          ³aReg5400   - Informacoes sobre todos documentos fiscais pro- ³±±
±±³          ³             cessados no while da funcao principal.          ³±±
±±³          ³lGrava0150 - Flag para indicar se deve gerar 0150            ³±±
±±³          ³cAlsSF		 - Alias do SF2								            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Reg5400(aPartDoc,cEspecie,cAlias,nRelac,aCmpAntSFT,aReg5400,lGrava0150,cAlsSF,cAliasSFT)
Local	nPos		:=	0
Local	nX			:=	0

//Tratamento para evitar duplicidade no registro
If aScan(aReg5400,{|aX| aX[5]==aCmpAntSFT[2] .And. aX[6]==aCmpAntSFT[1] .And. aX[3]==aCmpAntSFT[6]})==0
	//Inicio da montagem do registro
	aAdd(aReg5400, {})
	nPos :=	Len (aReg5400)
	aAdd (aReg5400[nPos], "5400")					   											//01 - REG
   aAdd (aReg5400[nPos], aCmpAntSFT[6])		   				    							//02 - DT_EMISSAO
	aAdd (aReg5400[nPos], cEspecie)   							 								//03 - TIP_DOC
	aAdd (aReg5400[nPos], Space(3-Len(Alltrim(aCmpAntSFT[2])))+Alltrim(aCmpAntSFT[2]))	//05 - SER
	aAdd (aReg5400[nPos], AllTrim(aCmpAntSFT[1]))    										//05 - NUM_DOC
	aAdd (aReg5400[nPos], aPartDoc[1])															//06 - COD_DESTINATARIO
	aAdd (aReg5400[nPos], aCmpAntSFT[5])		 				    							//07 - DT_S
	aAdd (aReg5400[nPos], (cAlsSF)->F2_VALBRUT)												//08 - VL_DOC (Vl Contabil)
	aAdd (aReg5400[nPos], (cAlsSF)->F2_BASEICM)												//09 - VL_BC_ICMS
	aAdd (aReg5400[nPos], (cAlsSF)->F2_VALICM)												//10 - VL_ICMS	
	If cEspecie=="31" .Or. cEspecie=="32"                           						//11 - CHAVE_ACESSO
		aAdd (aReg5400[nPos], aCmpAntSFT[23])			 			
	Else
		aAdd (aReg5400[nPos], "")						  			
	EndIf
	CATRegTrS(cAlias,nRelac,aReg5400)	
	lGrava0150 := .T.
EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³Reg5440   ³ Autor ³Cecilia Carvalho       ³ Data ³12.04.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ITENS DO DOCUMENTO DE SAÍDA                                 ³±±
±±³          ³                                                            ³±±
±±³          ³Geracao e gravacao do Registro 5440                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao CATRegTrS com a informacao de cada item do docu- ³±±
±±³          ³ mento fiscal processado no while da funcao principal.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3(1:N) Para cada Registro 5440                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias    - Alias do TRB que recebera as informacoes        ³±±
±±³          ³nRelac    - Flag de relacionamento com os sub-registros     ³±±
±±³          ³nItem     - Contador do item para cada documento fiscal.    ³±±
±±³          ³aReg5440  - Informacoes sobre os itens do documento fiscal  ³±±
±±³          ³            processado no while da funcao principal.        ³±±
±±³          ³cEspecie  - Modelo do documento fiscal                      ³±±
±±³          ³cAliasSFT - Alias da tabela SFT posicionada                 ³±±
±±³          ³cAlsSD    - Alias da tabela SD? posicionada                 ³±±
±±³          ³lIss      - Indica se o documento incide ISS.               ³±±
±±³          ³cProd     - Codigo de produto do item emm processamento     ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Reg5440(cAlias,nRelac,nItem,aReg5440,cEspecie,cAliasSFT,lIss,cProd)
Local	lRet		:=	.F.
Local	nPos		:=	0

//Montando array com a estrutura do registro 5440
aAdd(aReg5440, {})
nPos :=	Len (aReg5440)
aAdd (aReg5440[nPos], "5440")   					  			  						//01 - REG
aAdd (aReg5440[nPos], (cAliasSFT)->FT_CFOP)  			   				  				//02 - CFOP
aAdd (aReg5440[nPos], cProd)								  						    //03 - COD_MERC
aAdd (aReg5440[nPos], (cAliasSFT)->FT_QUANT)						 				    //04 - QTDE_SAI
aAdd (aReg5440[nPos], (cAliasSFT)->FT_TOTAL)		   				 					//05 - VL_SAI
aAdd (aReg5440[nPos], IIf(lIss,0,(cAliasSFT)->FT_BASEICM))							    //06 - VL_BC_ICMS
aAdd (aReg5440[nPos], IIf(lIss,0,(cAliasSFT)->FT_ALIQICM))		  					    //07 - ALIQ_ICMS
aAdd (aReg5440[nPos], IIf(lIss,0,(cAliasSFT)->FT_VALICM))		  					    //08 - VL_ICMS
CATRegTrS(cAlias,nRelac,aReg5440,nItem)
lRet := .T.
Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³Reg5460   ³ Autor ³Cecilia Carvalho       ³ Data ³13.04.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ DOCUMENTO DE ARRECADAÇÃO - ENTRADA                         ³±±
±±³          ³                                                            ³±±
±±³          ³Geracao e gravacao do Registro 5460                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Atribui em um array o conteudo a ser gravado no TRB atraves ³±±
±±³          ³ da funcao CATRegTrS com as informacoes de todos os docu-   ³±±
±±³          ³ mentos de arrecadação     .                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aReg5460 - Array com todas as informacoes do docuemnto de   ³±±
±±³          ³           arrecadação.                                     ³±±
±±³          ³aArrec   - Array com os números de docto de arrecadação     ³±±
±±³          ³           gravados na rotina CATApICMS                     ³±±
±±³          ³cAlias   - Alias do TRB que recebera as informacoes         ³±±
±±³          ³nRelac   - Flag de relacionamento com os sub-registros      ³±±
±±³          ³nItem    - Contador do item para cada documento fiscal.     ³±±
±±³          ³lNfTrib  - Indicador se a NF é Tributada.				      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Reg5460(aReg5460,aArrec,cAlias,nRelac,nItem,aReg5400,cFil,nNotaFis,cSerie,cClifor,cloja,aWizard,lNfTrib,nValIcms)
Local	nX			:=	0
Local	nPos		:=	0
Local	nPosDev		:=	0 
Local	nPeriodo	:=	1  
Local	nApuracao	:=	3
Local	lRet		:= .F.
Local	aApICM		:= {}
Local	dDataAte	:=	SToD(aWizard[1][2])
Local	cEstado		:= SuperGetMv("MV_ESTADO")
Local	aDatas		:=	DetDatas(Month(dDataAte),Year(dDataAte),nApuracao,nPeriodo)
Local	cData		:=	DataValida(aDatas[2]+1,.T.)  

aApICM	:=	FisApur("IC",Year(dDataAte),Month(dDataAte),nApuracao,nPeriodo,"*",.F.,{},1,.F.,"")     

For nX = 1 to Len(aArrec)
	If aArrec[nX][1]=="2" .And. (aArrec[nX][14]+aArrec[nX][10]+aArrec[nX][11]+aArrec[nX][12]+aArrec[nX][13])==(cFil+nNotaFis+cSerie+cClifor+cloja)
		aAdd(aReg5460, {})
		nPos :=	Len (aReg5460)
		aAdd(aReg5460[nPos], "5460")				//01 - REG
		aAdd(aReg5460[nPos], aArrec[nX][2])	//02 - COD_DA
		aAdd(aReg5460[nPos], aArrec[nX][3])	//03 - UF       
		aAdd(aReg5460[nPos], aArrec[nX][4])	//04 - NUM_DA		    
		aAdd(aReg5460[nPos], aArrec[nX][5])	//05 - COD_AUT
		aAdd(aReg5460[nPos], aArrec[nX][6])	//06 - VL_DA
		aAdd(aReg5460[nPos], aArrec[nX][7])	//07 - DT_VCTO
		aAdd(aReg5460[nPos], IIf(Empty(aArrec[nX][8]),aArrec[nX][7],aArrec[nX][8]))	//08 - DT_PGTO
		aAdd(aReg5460[nPos], aArrec[nX][9])	//09 - CRED_UTIL   
    EndIf
Next nX

nPosDev  := aScan(aApICM,{|x|x[1]=="011"})

// Se não existir guia de recolhimento e o saldo devedor é zero, gero informação 
// apenas no campo 09 - CRED_UTILIZADO
If Len(aArrec) == 0 .And. Len(aReg5460) == 0 .And. Len(aApICM) > 0 .And. aApICM[nPosDev,3] == 0 .And. lNfTrib
	aAdd(aReg5460, {})
	nPos :=	Len (aReg5460)
	aAdd(aReg5460[nPos], "5460")				//01 - REG
	aAdd(aReg5460[nPos], "0")					//02 - COD_DA
	aAdd(aReg5460[nPos], cEstado)				//03 - UF
	aAdd(aReg5460[nPos], "0")					//04 - NUM_DA		    
	aAdd(aReg5460[nPos], "0")					//05 - COD_AUT
	aAdd(aReg5460[nPos], 0)						//06 - VL_DA (aApICM[nPosCred,3] - Retirado por Valdemir Jose 18/04/2018 conforme CAT153/2009)
	aAdd(aReg5460[nPos], cData)					//07 - DT_VCTO
	aAdd(aReg5460[nPos], cData)					//08 - DT_PGTO
	aAdd(aReg5460[nPos], nValIcms)				//09 - CRED_UTIL     
Endif
   
If Len(aReg5460) > 0
	CATRegTrS(cAlias,nRelac,aReg5460,nItem)            
   	lRet := .T.
EndIf     
Return (lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³Reg5480   ³ Autor ³Mauro A. Goncalves     ³ Data ³22.01.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³NOTA FISCAL MODELO 4 - CFOP 5949 - EMITIDA PARA ACOBERTAR O ³±±
±±³          ³TRANSPORTE DE MERCADORIA NA HIPÓTESE DE IMPOSSIBILIDADE DE  ³±±
±±³          ³EMISSÃO DA NOTA FISCAL ELETRÔNICA – MODELO 55               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³3(1:1) Para cada Registro 5400                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias    - Alias do TRB que recebera as informacoes        ³±±
±±³          ³nRelac    - Flag de relacionamento com os sub-registros     ³±±
±±³          ³nItem     - Contador do item para cada documento fiscal.    ³±±
±±³          ³aReg5480  - Informacoes sobre os itens do documento fiscal  ³±±
±±³          ³            processado no while da funcao principal.        ³±±
±±³          ³cAliasSFT - Alias da tabela SFT posicionada                 ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Reg5480(cAlias,nRelac,nItem,aReg5480,cAliasSFT)
Local	aAreaSFT		:=	(cAliasSFT)->(GetArea())
Local	nPos	 		:= 0
Local nVlCtOri		:= 0
Local dDtNFOri		:= CtoD("  /  /    ")
Local cNrNFOri		:=	""
Local cSerOri		:=	""
Local	cCliForOri	:= ""
Local	cLojaOri		:= ""

DbSelectArea("SFT")
DbSetOrder(1)
If MsSeek(xFilial("SFT")+"S"+(cAliasSFT)->(FT_SERORI+FT_NFORI+FT_CLIEFOR+FT_LOJA)) .And. CATModNot(FT_ESPECIE)=="06" .And. AllTrim(FT_CFOP)$"5949,6949"
	cCliForOri	:= FT_CLIEFOR
	cLojaOri		:= FT_LOJA
   dDtNFOri		:= FT_EMISSAO
   cNrNFOri		:=	Alltrim(FT_NFISCAL)
   cSerOri		:=	Space(3-Len(Alltrim(FT_SERIE)))+Alltrim(FT_SERIE)
	
	
	If aScan(aReg5480,{|aX| aX[2]==dDtNFOri .And. aX[3]==cSerOri .And. aX[4]==cNrNFOri})==0
		While !EOF() .And. FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA==(cAliasSFT)->(FT_SERORI+FT_NFORI+FT_CLIEFOR+FT_LOJA)
			nVlCtOri += FT_TOTAL
			DbSkip()
		Enddo
	   DbSelectArea(cAliasSFT)                                                                          
		aAdd(aReg5480, {})
		nPos :=	Len(aReg5480)
		aAdd(aReg5480[nPos], "5480")															//01 - REG
		aAdd(aReg5480[nPos], dDtNFOri)														//02 - Data da emissão do documento fiscal
		aAdd(aReg5480[nPos], +Alltrim(SerieNfId("SFT",2,"FT_SERIE")))	//03 - Série do documento		
//		aAdd(aReg5480[nPos], Space(3-Len(Alltrim(cSerOri)))+Alltrim(cSerOri))	//03 - Série do documento
		aAdd(aReg5480[nPos], cNrNFOri)														//04 - Número da nota fiscal
		aAdd(aReg5480[nPos], dDtNFOri)														//05 - Data da saída
		aAdd(aReg5480[nPos], nVlCtOri)														//06 - Valor total do documento fiscal
	Endif	
Endif	
RestArea(aAreaSFT)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡ao    ³Reg9900   | Autor ³Cecilia Carvalho              ³ Data ³20.03.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³REGISTROS DO ARQUIVO                                               ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Expl1 := Reg9900(cAlias,aReg9900)                                  ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias   -> Alias do TRB que recebera as informacoes               ³±±
±±³          ³aReg9900 -> Array com informacoes que serao gravadas no TRB        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 - Sempre .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - CAT153                                                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Reg9900(cAlias,aReg9900)
Local	lRet	:=	.T.

CATRegTrS (cAlias,,aReg9900,)
Return (lRet)                        

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡ao    |Reg9999   | Autor ³Gustavo G. Rueda              ³ Data ³03.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ENCERRAMENTO DO ARQUIVO DIGITAL                                    ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpN1 := Reg9999(cAlias)                                           ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias   -> Alias do TRB que recebera as informacoes               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 - Sempre .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - CAT153                                                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Reg9999(cAlias)
Local	lRet	:=	.T.
Local	nPos	:=	0
Local	aReg	:= {}

aAdd(aReg, {})
nPos	:=	Len (aReg)
nTotLin := (cAlias)->(RecCount()) + 1
aAdd (aReg[nPos], "9999")					//01 - REG
aAdd (aReg[nPos], Alltrim(STR(nTotLin)))	//02 - QTD_LIN
CATRegTrS (cAlias,,aReg,)
Return (lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡ao    |BlAbEnc   | Autor ³Gustavo G. Rueda              ³ Data ³03.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³GRAVACAO DO INDICADOR DE BLOCO COM MOVIMENTO                       ³±±
±±³          ³                                                                   ³±±
±±³          ³Funcao de gravacao do indicador de bloco com movimento(0) ou       ³±±
±±³          ³ sem movimento(1) conforme passagem de parametros. Utilizado       ³±±
±±³          ³ na funcao CATIndMov.                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpN1 := BlAbEnc(cAbEnc,cAlias,cReg,cIndMov,nQtdLin)               ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAbEnt -> Indicador de Bloco de Abertura (A) ou Encerramento (E).  ³±±
±±³          ³cAlias -> Alias do TRB onde sera gravado as informacoes.           ³±±
±±³          ³cReg -> Codigo do registro                                         ³±±
±±³          ³cIndMov -> Indicador de movimento (0=Sim, 1=Nao)                   ³±±
±±³          ³nQtdLin -> Quantidade de linha do registro                         ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 - Sempre .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - CAT153                                                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static function BlAbEnc(cAbEnc,cAlias,cReg,cIndMov,nQtdLin)
Local	lRet		:=	.T.
Local	aBlAbEnc	:=	{}

aAdd(aBlAbEnc, {})
nPos	:=	Len (aBlAbEnc)
If ("A"$cAbEnc)
	aAdd (aBlAbEnc[nPos], cReg)
	aAdd (aBlAbEnc[nPos], cIndMov)
Else
	aAdd (aBlAbEnc[nPos], cReg)
	aAdd (aBlAbEnc[nPos], Alltrim(STR(nQtdLin+2)))	// O +2 eh para somar o registro de abertura mais o registro de encerramento
EndIf
CATRegTrS (cAlias,,aBlAbEnc,)
Return (lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡ao    |GeraTrb   | Autor ³Gustavo G. Rueda              ³ Data ³03.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ GERACAO DA ESTRUTURA DO TRB                                       ³±±
±±³          ³                                                                   ³±±
±±³          ³Geracao da estrutura do TRB utilizado em todo o processamento      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpL1 := GeraTrb (nTipo, aArq, cAlias)                             ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|nTipo -> 1=Gerar o TRB, 2=Fechar o TRB                             ³±±
±±³          ³cArq -> Nome fisico do TRB criado                                  ³±±
±±³          ³cAlias -> Alias do TRB criado                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 - Sempre .T.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - CAT153                                                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GeraTrb(nTipo,aArq,cAlias)
	Local	lRet  		:=	.T.
	Local	aCmp  		:=	{}
	Local	cArq  		:=	""
	Local	nI	  		:=	0
	Local	nTamTRBIt	:=	50	//Tamanho do campo relac no TRB - Tem que ser numero exato, pois faco divisao por dois nos calculos.
	//
	If (nTipo==1)
		//TRB Geral
		cAlias	:=	"TRB"
		aAdd (aCmp, {"TRB_TPREG",	"C", 	004,	   			0})
		aAdd (aCmp, {"TRB_RELAC",	"C", 	nTamTRBIt*2,		0})
		aAdd (aCmp, {"TRB_FLAG",	"C", 	001,				0})
		aAdd (aCmp, {"TRB_CONT",	"C", 	999,				0})
		aAdd (aCmp, {"TRB_ITEM",	"N", 	007,				0})
		cArq	:=	CriaTrab (aCmp)
		DbUseArea (.T., __LocalDriver, cArq, cAlias)
		IndRegua (cAlias, cArq, "TRB_TPREG+TRB_RELAC+StrZero (TRB_ITEM, 7, 0)")
    	aAdd (aArq, {cAlias, cArq})
	Else
		For nI := 1 To Len (aArq)
			DbSelectArea (aArq[nI][1])
			(aArq[nI][1])->(DbCloseArea ())
		Next nI
	EndIf
	cAlias	:=	"TRB"	//Devo sempre retornar para os casos que nao tiverem TRB proprio.
Return (lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  |OrgTxt    ³ Autor ³Cecilia Carvalho       ³ Data ³20.03.2012³±±
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
±±³          |oProcess -> Objeto da nova barra de progressao              ³±±
±±³          |lEnd     -> Flag de cancelamento de processamento           ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function OrgTxt(cAlias,cFile,oProcess,lEnd,nRetCpy)
Local	lRet		:=	.T.
Local	lGravaReg9	:=	.F.
Local	nHandle		:=	-1
Local	cRelac		:=	""
Local   aAreaLoc	:= {}
Local	nRecCount	:=	(cAlias)->(RecCount())
Local	nRegsProc	:=	0
Local	cTimeDocs	:=	Time()
Local	nDocsXTime	:=	0    
Local   cTrab	    := CriaTrab(,.F.)+".TXT"
Local	cDrive		:=	""
Local	cPath		:=	""
Local	cNewFile	:=	""
Local	cExt		:=	""
Local 	cStartPath 	:= 	AllTrim(GetSrvProfString("StartPath",""))
Local cLib
Local nRetType      := 0
//Tratamento para Linux onde a barra e invertida                      
If GetRemoteType()==2 // REMOTE_LINUX  
	If (SubStr(cStartPath,1,1)<>"/") .And. (SubStr(cStartPath,1,1)<>"\")
		cStartPath	:=	"/"+cStartPath
	EndIf	
	If (SubStr(cStartPath,Len(cStartPath),1)<>"/") .And. (SubStr(cStartPath,Len(cStartPath),1)<>"\")
		cStartPath	+=	"/"
	EndIf
Else    
	If (SubStr(cStartPath,1,1)<>"\") .And. (SubStr(cStartPath,1,1)<>"/")
		cStartPath	:=	"\"+cStartPath
	EndIf
	If (SubStr(cStartPath,Len(cStartPath),1)<>"\") .And. (SubStr(cStartPath,Len(cStartPath),1)<>"/")
		cStartPath	+=	"\"
	EndIf	                
EndIf

//Tratamento para consistir o arquivo caso exista
If (File(cTrab))		
	FErase (cTrab)
Endif
nHandle	:=	MsFCreate(cTrab)
                     
DbSelectArea (cAlias)  
(cAlias)->(DbSetOrder (1))
(cAlias)->(DbGoTop ())

If Type("oProcess")=="O"
	oProcess:Set1Progress(nRecCount)
	oProcess:Set2Progress(1)
	oProcess:Inc2Progress("","")
	oProcess:SetDetProgress(STR0016,nRecCount,;		//"Total de registros do periodo solicitado"
				STR0017,0,;							//"Total de registros processados por segundo"
				STR0018,0,;							//"Total de registros pendentes para processamento"
				STR0019,0) 							//"Tempo estimado para termino do processamento (Seg.)"
Else
	ProcRegua(nRecCount)
EndIf

Do While !(cAlias)->(Eof ())
	If (Empty((cAlias)->TRB_FLAG))
		nRegsProc	+=	1
		If Type("oProcess")=="O"
			oProcess:Inc1Progress(STR0020,StrZero(nRegsProc,6)+"/"+StrZero(nRecCount,6))	 // "Gerando arquivo texto"				
			If cTimeDocs<>Time()
				oProcess:SetDetProgress(STR0016,nRecCount,;	 				//"Total de registros do periodo solicitado"
						STR0017,nDocsXTime,;	   		  					//"Total de registros processados por segundo"
						STR0018,nRecCount-nRegsProc,; 						//"Total de registros pendentes para processamento"
						STR0019,Round((nRecCount-nRegsProc)/nDocsXTime,0))	//"Tempo estimado para termino do processamento (Seg.)"

				cTimeDocs	:=	Time()
				nDocsXTime	:=	1
			Else
				nDocsXTime	+=	1
			EndIf
			If oProcess:Cancel()
				Exit
			EndIf

		Else
			IncProc(STR0020) // "Gerando arquivo texto"
			If Interrupcao(@lEnd)
				Exit
			EndIf
		EndIf

		cRelac	 :=	(cAlias)->TRB_RELAC
		aAreaLoc :=	(cAlias)->(GetArea ())
		If ("0150"$(cAlias)->TRB_TPREG)
			LeRegRelac(nHandle,cAlias,"0150",{},cRelac)
		ElseIf ("0300"$(cAlias)->TRB_TPREG)
			CATGrvLin(nHandle,cAlias)
		ElseIf ("5200"$(cAlias)->TRB_TPREG)
			CATGrvLin(nHandle,cAlias)
			LeRegRelac(nHandle,cAlias,"5220",{},cRelac)
			RegPorNf(nHandle,cAlias,"5240",cRelac)
			RegPorNf(nHandle,cAlias,"5260",cRelac)			
		ElseIf ("5400"$(cAlias)->TRB_TPREG)
			CATGrvLin (nHandle, cAlias)
			LeRegRelac(nHandle,cAlias,"5440",{},cRelac)
			RegPorNf(nHandle,cAlias,"5460",cRelac)
			RegPorNf(nHandle,cAlias,"5480",cRelac)
//			LeRegRelac(nHandle,cAlias,"5480",{},cRelac)
		ElseIf ("5800"$(cAlias)->TRB_TPREG)
			CATGrvLin(nHandle,cAlias)
		ElseIf ( "9" $ Substr((cAlias)->TRB_TPREG,1,1))
			lGravaReg9 := .T.
		Else
			CATGrvLin(nHandle,cAlias)
		EndIf
		RestArea (aAreaLoc)
	EndIf
	(cAlias)->(DbSkip ())
EndDo

If lGravaReg9
	(cAlias)->(DbSeek("9"))
	Do While !(cAlias)->(Eof ()) .And. Substr((cAlias)->TRB_TPREG,1,1) == "9"
		If (Empty ((cAlias)->TRB_FLAG))
			CATGrvLin (nHandle, cAlias)
		EndIf
		(cAlias)->(DbSkip ())
	EndDo
EndIf

If (nHandle>=0)
	FClose (nHandle)
Endif

If (File(cFile))
	FErase(cFile)
Endif

SplitPath(cFile,@cDrive,@cPath, @cNewFile,@cExt)
cNewFile := cNewFile+cExt

nRetType := GetRemoteType( @cLib )
QOut( cLib )

If Empty(cDrive)
	IF	nRetType == 5 //"HTML" $ cLib
		msg:= "Em função do acesso ao sistema ser via SmartClient HTML, o caminho informado para salvar o arquivo será desconsiderado, e será processado conforme configuração do navegador." //FISMSG("HTML")
		msgAlert(msg)
		If File(cStartPath+cTrab)
			FRename(cStartPath+cTrab,cNewFile)
		EndIf
		nRetCpy := CPYS2TW(cNewFile)
		If nRetCpy == 0
			FErase(cTrab)
		EndIf
	ELSE
		lCopied := __CopyFile(cTrab,cDrive+cPath+cNewFile)
		If lCopied 
			FErase (cTrab)
			If File(cDrive+cPath+cTrab)
				FRename(cDrive+cPath+cTrab,cFile)
			EndIf
		EndIf
	ENDIF 
Else
	If Substr(cStartPath,Len(AllTrim(cStartPath)),1) <> "\"
		cStartPath := cStartPath + "\"
	EndIf
	
	IF	nRetType == 5//"HTML" $ cLib
		msg:= "Em função do acesso ao sistema ser via SmartClient HTML, o caminho informado para salvar o arquivo será desconsiderado, e será processado conforme configuração do navegador." //FISMSG("HTML")
		msgAlert(msg)
		If File(cStartPath+cTrab)
			FRename(cStartPath+cTrab,cNewFile)
		EndIf
		nRetCpy := CPYS2TW(cNewFile)
		If nRetCpy == 0
			FErase (cTrab)
		EndIf
	ELSE
		lCopied := CpyS2T( cStartPath+cTrab,cDrive+cPath, .F. )
		If lCopied 
			FErase (cTrab)
			If File(cDrive+cPath+cTrab)
				FRename(cDrive+cPath+cTrab,cFile)
			EndIf
		EndIf
	ENDIF

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³No caso de o objeto oProcess existir, significa que a nova barra  ³
//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
//| portanto deve ser efetuado os controles para demonstrar o        |
//| resultado do processamento.                                      |
//|                                                                  |
//|Atualizando o incremento da regua no final da execucao, pois pode |
//| ocorrer dos numeros nao estarem "redondos", assim os corrijo     |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("oProcess")=="O"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Condicao implementada para controlar os numeros apresentadas na tela³
	//³  de processamento da rotina, os detalhes.                          ³
	//³Ao final do processamento, para este caso da funcao, atualizo altero³
	//³  o tratamento de registros lidos, pois a funcao utiliza bastante   |		
	//³  a funcao RegPorNf e ela nao tem o controle de soma da variavel    ³		
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oProcess:Inc1Progress(STR0020,StrZero(nRecCount,6)+"/"+StrZero(nRecCount,6))	 // "Gerando arquivo texto"
	oProcess:SetDetProgress(STR0016,nRecCount,;		//"Total de registros do periodo solicitado"
			STR0017,nDocsXTime,;					//"Total de registros processados por segundo"
			STR0018,0,;								//"Total de registros pendentes para processamento"
			STR0019,0)								//"Tempo estimado para termino do processamento (Seg.)"
EndIf
Return (lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  |LeRegRelac³ Autor ³Gustavo G. Rueda       ³ Data ³16.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o³Essa funcao primeiramente procura o relacionamento exato,    ³±±
±±³          ³ caso nao encontre, ela procura novamente quebrando pelo    ³±±
±±³          ³ grupo. Os codigos de grupo devem ser unicos por grupo, para³±±
±±³          ³ nao gerar informacoes divergentes.                         ³±±
±±³          ³Esta funcao soh prepara os registros para gravacao que serah³±±
±±³          ³ efetuada pela funcao RegPorNf                              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|nHandle -> Handle do arquivo txt aberto.                    ³±±
±±³          |cAlias -> Alias do TRB criado atraves da funcao principal.  ³±±
±±³          |cRegP  -> Identificador do registro PAI                     ³±±
±±³          |aRegF  -> Array com os identificadores dos registros filhos ³±±
±±³          |cRelac -> Relacionamento do registro pai para com os filhos ³±±
±±³          |nTo    -> Determina se permite fazer o segundo seek ou nao  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LeRegRelac(nHandle,cAlias,cRegP,aRegF,cRelac,nTo)
Local	nTamTRBIt	:=	Len((cAlias)->TRB_RELAC)/2		//Efetuo divisao por dois porque faco dois controles em um mesmo campo. O relacionamento e sequencia. Ex: ...0001...1, ...0001...2
Local	cChave		:=	cRegP+cRelac					//Chave do primeiro SEEK
Local	cChave2		:=	cRegP+SubStr(cRelac,1,nTamTRBIt)//Chave do segundo SEEK				
Local	nI			:=	0
Local	nX			:=	0
Local	aAreaLoc	:=	(cAlias)->(GetArea())

Default	nTo			:=	1
					
For nI := 1 To nTo					
	If (cAlias)->(DbSeek (cChave))
		Do While !(cAlias)->(Eof ()) .And. cChave==Left((cAlias)->TRB_TPREG+(cAlias)->TRB_RELAC,Len(cChave))
			If Empty((cAlias)->TRB_FLAG)
				CATGrvLin(nHandle,cAlias)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Utilizo o codigo de relacionamento do PAI para procurar os FILHOS.     ³
				//³Esta troca deve ser executada sometne para o segundo seek, pois no pri-³
				//³ meiro o RELAC fica a criterio de como for passado, para o segundo nao,³
				//| pego do TRB                                                           |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nI==2
					cRelac	:=	(cAlias)->TRB_RELAC
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Gravo todos os filhos correspondentes ao PAI³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nX := 1 To Len(aRegF)
			   		RegPorNf(nHandle,cAlias,aRegF[nX],cRelac,(cAlias)->TRB_ITEM,nTo==2)
			 	Next nX
			EndIf
			(cAlias)->(DbSkip ())
		EndDo                  
		//Exit
	EndIf
	cChave	:=	cChave2	//Trocando a chave para o segundo SEEK
Next nI
RestArea(aAreaLoc)
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  |RegPorNf  ³ Autor ³Gustavo G. Rueda       ³ Data ³16.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³   GRAVACAO DE UM REGISTRO RELACIONADO COM SEU SUPERIOR     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Posiciono no registro com a chave passada como parametro e  ³±±
±±³          ³ gero o TXT na funcao CATGrvLin                            ³±±
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
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RegPorNf(nHandle,cAlias,cTpReg,cRelac,nItem,lExact)
	Local	lRet		:=	.T.
	Local	cChave		:=	cTpReg+cRelac
	Local	aAreaLoc	:=	(cAlias)->(GetArea())
	Local	bWhile		:=	{||!(cAlias)->(Eof ()) .And. cChave==(cAlias)->TRB_TPREG+(cAlias)->TRB_RELAC+Iif (nItem<>Nil .And. nItem>0, StrZero ((cAlias)->TRB_ITEM, 7, 0),"")}

	Default	lExact		:=	.F.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para considerar o item de quebra ao efetuar o seek³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nItem<>Nil .And. nItem>0)
		cChave	+=	StrZero (nItem, 7, 0)
	EndIf
	
	If lExact
		bWhile		:=	{|| !(cAlias)->(Eof ()) .And. cChave==Left((cAlias)->TRB_TPREG+(cAlias)->TRB_RELAC+Iif(nItem<>Nil .And. nItem>0,StrZero((cAlias)->TRB_ITEM, 7, 0),""),Len(cChave))}
	EndIf

	If ((cAlias)->(DbSeek (cChave)))
		Do While Eval(bWhile)
			CATGrvLin(nHandle, cAlias)
			(cAlias)->(DbSkip ())
		EndDo
	EndIf

	RestArea (aAreaLoc)
Return (lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  |CATIndMov ³ Autor ³Cecilia Carvalho       ³ Data ³20.03.2012³±±
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
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CATIndMov (cAlias)
	Local	lRet		:=	.T.
	Local	nQtd0990	:=	0
	Local	nQtd5990	:=	0
	Local 	nQtd9990	:=	0
	Local	nPos		:=	0
	Local	aReg9900	:=	{}

	DbSelectArea (cAlias) 
	(cAlias)->(DbSetOrder (1))
	(cAlias)->(DbGoTop ())
	Do While !(cAlias)->(Eof ())
		If (nPos := aScan (aReg9900, {|aX| aX[2]==(cAlias)->TRB_TPREG}))==0
			aAdd (aReg9900, {"9900",(cAlias)->TRB_TPREG,"1"})
		Else
			aReg9900[nPos][3] := Alltrim(STR( Val( aReg9900[nPos][3] )+1))
		EndIf
		//REGISTROS - 0
		If (Left ((cAlias)->TRB_TPREG, 1)$"0")
		    If (cAlias)->TRB_TPREG<>"0000"	
			    nQtd0990++
		    EndIf
		//REGISTROS - 5
		ElseIf (Left ((cAlias)->TRB_TPREG, 1)$"5")
			nQtd5990++
		EndIf	
		(cAlias)->(DbSkip ())
	EndDo
	//Gravacao do indicador de movimento do bloco 0.   
	BlAbEnc ("A", cAlias, "0001", Iif (nQtd0990>0, "0", "1"),)
	BlAbEnc ("E", cAlias, "0990",, nQtd0990)
	aAdd (aReg9900, {"9900","0001","1"})
	aAdd (aReg9900, {"9900","0990","1"})
	//Gravacao do indicador de movimento do bloco 5.   
	BlAbEnc ("A", cAlias, "5001", Iif (nQtd5990>0, "0", "1"),)
	BlAbEnc ("E", cAlias, "5990",, nQtd5990)
	aAdd (aReg9900, {"9900","5001","1"})
	aAdd (aReg9900, {"9900","5990","1"})	
	
	//Outros registros que devem ser totalizados       
	aAdd (aReg9900, {"9900","9001","1"})
	aAdd (aReg9900, {"9900","9990","1"})
	aAdd (aReg9900, {"9900","9999","1"})
	aAdd (aReg9900, {"9900","9900",STR(len(aReg9900)+1)})

	// Ordenando o array 9900 por tipo de registro
	aReg9900 := aSort(aReg9900, , , {|x,y| x[2] < y[2] } )
	
	//Gravacao do bloco 9 (Totalizacao dos registros)  
	Reg9900 (cAlias, aReg9900)
	nQtd9990 := len(aReg9900)
	BlAbEnc ("A", cAlias, "9001", Iif (nQtd9990>0, "0", "1"),)
	BlAbEnc ("E", cAlias, "9990",, nQtd9990)
	
	//Gravacao do registro 9999 (Encerramento do arquivo) 
	Reg9999 (cAlias)
Return (lRet)
           
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  |MontWiz³ Autor ³Cecilia Carvalho          ³ Data ³20.03.2012³±±
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
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MontWiz (cNomWiz,cPerfil)
Local	aTxtApre	:=	{}
Local	aPaineis	:=	{}
Local	aItens1	:=	{}
Local	cTitObj1	:=	""
Local	cTitObj2	:=	""

aAdd (aTxtApre, "Parâmetros necessários.")
aAdd (aTxtApre, "")	
aAdd (aTxtApre, "Preencha corretamente as informações solicitadas.")
aAdd (aTxtApre, "Informações necessárias para a geração do meio-magnético para E-CredRural da Portaria CAT153.")
//ÚÄÄÄÄÄÄÄÄ¿
//³Painel 0³
//ÀÄÄÄÄÄÄÄÄÙ	
aAdd (aPaineis, {})
nPos	:=	Len (aPaineis)
aAdd (aPaineis[nPos], "Preencha corretamente as informações solicitadas.")
aAdd (aPaineis[nPos], "Parâmetros para Geração")
aAdd (aPaineis[nPos], {})
//
cTitObj1	:=	"Data de";								   		cTitObj2	:=	"Data até"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});		aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
//
aAdd (aPaineis[nPos][3], {2,,,3,,,,});					aAdd (aPaineis[nPos][3], {2,,,3,,,,}) 
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj1	:=	"Mês/Ano de referência (MMAAAA)";         cTitObj2	:=	"Arq.Apuração ICMS"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});		aAdd (aPaineis[nPos][3], {1,cTitObj2,,,,,,})
//
cTitObj1	:=	Replicate ("X", 6);                       cTitObj2	:=	Replicate ("X", 50)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,6});		aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,50})
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj1	:=	"Diretório do Arquivo Destino";				cTitObj2	:=	"Nome do Arquivo Destino"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});		aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
//
cTitObj1	:=	Replicate ("X", 50);							   cTitObj2	:=	Replicate ("X", 20)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});		aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,20})
//
aAdd (aPaineis[nPos][3], {1,"",,,,,,});					aAdd (aPaineis[nPos][3], {1,"",,,,,,})
aAdd (aPaineis[nPos][3], {1,"",,,,,,});					aAdd (aPaineis[nPos][3], {1,"",,,,,,})
//ÚÄÄÄÄÄÄÄÄ¿
//³Painel 1³
//ÀÄÄÄÄÄÄÄÄÙ	
aAdd (aPaineis, {})
nPos	:=	Len (aPaineis)
aAdd (aPaineis[nPos], "Preencha corretamente as informações solicitadas.")
aAdd (aPaineis[nPos], "Identificação do Contribuinte")
aAdd (aPaineis[nPos], {})
//
cTitObj1	:=	"Código da Finalidade do Arquivo";		  					cTitObj2	:=	""
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});						aAdd (aPaineis[nPos][3], {0, cTitObj2,,,,,,})
//
aItens1	:=	{}
aAdd (aItens1, "0-Remessa regular de arquivo")
aAdd (aItens1, "1-Remessa de arquivo substituto")
//
aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,});		 					aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});			 						aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj1	:=	"Filial de";														cTitObj2	:=	"Filial ate"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});						aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
//
cTitObj1	:=	Replicate ("X", FWGETTAMFILIAL);						    	cTitObj2	:=	Replicate ("X", FWGETTAMFILIAL)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,FWGETTAMFILIAL});		aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,FWGETTAMFILIAL})
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});									aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj1	:=	"Seleciona Filiais ?"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
aAdd (aPaineis[nPos][3], {3,,,,,{"1 - Sim","2 - Não"},,,,,});  		aAdd (aPaineis[nPos][3], {0,"",,,,,,})
aAdd (aPaineis[nPos][3], {0,"",,,,,,});  							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
cTitObj1	:=	"Gera Registro 5480?"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,}); 						aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
aAdd (aPaineis[nPos][3], {3,,,,,{"2 - Não","1 - Sim"},,});  		aAdd (aPaineis[nPos][3], {0,"",,,,,,})
aAdd (aPaineis[nPos][3], {0,"",,,,,,});  							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//

cTitObj1	:=	"Aglutina seleção por CNPJ+I.E. ?"
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});						aAdd (aPaineis[nPos][3], {0,"",,,,,,})
//
aAdd (aPaineis[nPos][3], {3,,,,,{"2 - Não","1 - Sim"},,}) 


Return(xMagWizard (aTxtApre, aPaineis, cNomWiz))

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CATRegs  | Autor ³Gustavo G. Rueda  			   ³ Data ³28.03.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao que efetua a gravacao de registros dependentes de forma     ³±±
±±³          ³ herarquica no TRB utilizando uma formatacao diferenciada do campo ³±±
±±³          ³ TRB_RELAC, onde o mesmo eh dividido em dois e o primeiro grupo    ³±±
±±³          ³ corresponde ao PAI e o segundo ao FILHO. Exemplo:                 ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³1) Os array a serem passados devem seguir a ordem hierarquica de   ³±±
±±³          ³   gracao.                                                         ³±±
±±³          ³2) Para os registros que estiverem na sequencia mais nao correspon-³±±
±±³          ³   derem a hierarquia informada, deve ser passado no seguinte for- ³±±
±±³          ³   mato. Ex: (aReg,2}                                              ³±±
±±³          ³   a) O primeiro nivel corresponde ao registro;                    ³±±
±±³          ³   b) O segundo corresponde ao pai deste registro que nao eh o     ³±±
±±³          ³      antecessor. Um exemplo de utilizacao eh a geracao do bloco E.³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CATRegs(cAlias,aRegs)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias    -> Alias do TRB em processamento para gravar as informa- ³±±
±±³          ³             coes                                                  ³±±
±±³          ³aRegs     -> Array com as informacoes dos registros a serem grava- ³±±
±±³          ³             dos.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - CAT153                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CATRegs(cAlias,aRegs,cMensagem)
Local	aAux		:=	{}
Local	nAux		:=	0
Local	nI1			:=	0
Local	nI2			:=	0
Local	nI3			:=	0
Local	aPai		:=	{}
Local	lProc		:=	.T.
Local	nRegsProc	:=	0
Local	cTimeDocs	:=	Time()
Local	nDocsXTime	:=	0
Local	nSvnI3		:=	0

Default	cMensagem	:=	""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem de um array de hierarquias como base para leitura dos arrays pela funcao.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI1 := 1 To Len(aRegs)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³O primeiro sempre serah o pai de todos, portanto nao tem um PAI³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nI1==1
		aAdd(aPai,{nI1,0})	//Sem pai, eh o pai de todos
	Else

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para verificar o registro cujo pai NA0 estah na sequencia. ³
		//³  Ex: E200 eh pai do E210 que eh pai do E220 que eh pai do E230 e E240³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType(aRegs[nI1])=="A" .And. Len(aRegs[nI1])>=2 .And. ValType(aRegs[nI1,2])=="N"
			aAdd(aPai,{nI1,aRegs[nI1,2]})
		Else
			aAdd(aPai,{nI1,nI1-1})
		EndIf
	EndIf

Next nI1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processamento da estrutura hierarquica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI1 := 2 To Len(aPai)	//A primeira posicao sempre eh o pai de todos
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Localizo o registro PAI e utilizo as informacoes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRegsPai	:=	aRegs[aPai[nI1,2]]
	If ValType(aRegsPai)=="A" .And. Len(aRegsPai)>=2 .And. ValType(aRegsPai[2])=="N"	//Tratamento para verificar o registro cujo pai nao eh o antecessor
   		aRegsPai	:=	aRegsPai[1]
 	EndIf
 	
	aRegsFil	:=	aRegs[aPai[nI1,1]]
 	If ValType(aRegsFil)=="A" .And. Len(aRegsFil)>=2 .And. ValType(aRegsFil[2])=="N"	//Tratamento para verificar o registro cujo pai nao eh o antecessor
		aRegsFil	:=	aRegsFil[1]
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³No caso de o objeto oProcess existir, significa que a nova barra  ³
	//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
	//| portanto deve ser efetuado os controles para demonstrar o        |
	//| resultado do processamento.                                      |
	//|                                                                  |
	//|O tratamento da nova regua serah efetuada em particular nesta     |
	//| funcao, quando o parametro "cMensagem" vier preenchido, pois com |
	//| ele identificamos qual gravacao do TRB pode ser realmente        |
	//| demorada, caso contrario nao precisa, eh muito rapido            |
	//|                                                                  |
	//|Definicao do tamanho das reguas e atualizacao dos detalhes de     |
	//| processamento, pois como o caso da funcao OrgTxt, este tambem    |
	//| deve ser tratado isoladamente do movimento.                      |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cMensagem) .And. Type("oProcess")=="O"
		oProcess:Set1Progress(Len(aRegsPai))

		//Neste caso nao eh necessario o controle da segunda regua, basta somente a primeira
		oProcess:Set2Progress(1)
		oProcess:Inc2Progress("","")

		oProcess:SetDetProgress(STR0016,Len(aRegsFil),;		//"Total de registros do periodo solicitado"
					STR0017,0,;		//"Total de registros processados por segundo"
					STR0018,0,;		//"Total de registros pendentes para processamento"
					STR0019,0)		//"Tempo estimado para termino do processamento (Seg.)"
	EndIf
	
	For nI2 := 1 To Len(aRegsPai)

		lProc	:=	.T.

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³No caso de o objeto oProcess existir, significa que a nova barra  ³
		//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
		//| portanto deve ser efetuado os controles para demonstrar o        |
		//| resultado do processamento.                                      |
		//|                                                                  |
		//|Incremento da segunda  regua, somente a mensagem, pois os numeros |
		//| neste caso nao sao sequenciais e fica confuso a demonstracao em  |
		//| tela.                                                            |
		//|Tambem estah sendo efetuada a atualizacao dos detalhes.           |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cMensagem) .And. Type("oProcess")=="O"
			nRegsProc	+=	1		
			oProcess:Inc1Progress("Processamento secundário: Gravando estruturas "+cMensagem,StrZero(nRegsProc,4)+"/"+StrZero(Len(aRegsPai),4))
		
			If cTimeDocs<>Time()
				oProcess:SetDetProgress(STR0016,Len(aRegsPai),;	 			//"Total de registros do periodo solicitado"
						STR0017,nDocsXTime,;	  								//"Total de registros processados por segundo"
						STR0018,Len(aRegsPai)-nRegsProc,;						//"Total de registros pendentes para processamento"
						STR0019,Round((Len(aRegsPai)-nRegsProc)/nDocsXTime,0))	//"Tempo estimado para termino do processamento (Seg.)"
		
				cTimeDocs	:=	Time()
				nDocsXTime	:=	1
			Else
				nDocsXTime	+=	1
			EndIf		
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Controle do cancelamento da rotina³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If oProcess:Cancel()
				Exit
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se nao existir filho para este PAI, deve gerar as informacoes doo PAI independente³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aScan(aRegsFil,{|aX| aX[1]==nI2})==0 .And. nI1==2
			aAux		:=	{}
			For nAux := 1 To Len(aRegsPai[nI2])
				aAdd(aAux,aRegsPai[nI2,nAux])
			Next nAux
			CATRegTrS(cAlias,0,{aAux},,nI2)		
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Variavel de controle do flag de relacionamento dos filhos com o pai³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nSvnI3	:=	0
		For nI3 := 1 To Len(aRegsFil)
		
			If aRegsFil[nI3,1]==nI2
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Para cada pai, efetuo a gravacao do PAI e do FILHO³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nI1==2 .And. lProc 
					lProc		:=	.F.

					aAux		:=	{}
					For nAux := Iif(nI1==2,1,2) To Len(aRegsPai[nI2])
						aAdd(aAux,aRegsPai[nI2,nAux])
					Next nAux
					CATRegTrS(cAlias,nI3,{aAux},,nI2)
					
					aAux		:=	{}
					For nAux := 2 To Len(aRegsFil[nI3])
						aAdd(aAux,aRegsFil[nI3,nAux])
					Next nAux
					CATRegTrS(cAlias,nI3,{aAux},,nI3)
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Variavel utilizada para salvar a posicao do nI3 para utilizar quando existir mais de um filho³
					//³  para o mesmo pai (else abaixo).                                                            ³
					//³                                                                                             ³
					//³Quando sair do FOR (processamento de todos os filhos do mesmo pai), devo ZERAR a             ³
					//³  variavel para manter o controle que havia antes, "nI2"                                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nSvnI3	:=	nI3

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Quando o processamento ainda estiver no loop, gravo o pai somente para o³
				//³  primeiro registro e para os outros, somente os filhos                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Else

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atribuicao do nI2 para quando o nivel hierarquico for acima de 2 (nI1>2)³
					//³  nao entrando no if acima, somente neste else, e neste momento devo    ³
					//³  considerar o nI2.                                                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nSvnI3==0
						nSvnI3	:=	nI2
					EndIf
					
					aAux		:=	{}
					For nAux := 2 To Len(aRegsFil[nI3])
						aAdd(aAux,aRegsFil[nI3,nAux])
					Next nAux
					CATRegTrS(cAlias,nI3,{aAux},,nSvnI3)
				EndIf
			EndIf
		Next nI3

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³No caso de o objeto oProcess existir, significa que a nova barra  ³
		//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
		//| portanto deve ser efetuado os controles para demonstrar o        |
		//| resultado do processamento.                                      |
		//|                                                                  |
		//|Tratamento para o cancelamento de execucao da rotina              |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cMensagem) .And. Type("oProcess")=="O" .And. oProcess:Cancel()
			Exit
		EndIf
	Next nI2
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³No caso de o objeto oProcess existir, significa que a nova barra  ³
	//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,       |
	//| portanto deve ser efetuado os controles para demonstrar o        |
	//| resultado do processamento.                                      |
	//|                                                                  |
	//|Tratamento para o cancelamento de execucao da rotina              |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cMensagem) .And. Type("oProcess")=="O" .And. oProcess:Cancel()
		Exit
	EndIf
Next nI1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³No caso de o objeto oProcess existir, significa que a nova barra    ³
//³ de processamento (CLASSE Fiscal) estah em uso pela rotina,         |
//| portanto deve ser efetuado os controles para demonstrar o          |
//| resultado do processamento.                                        |
//|                                                                    |
//³Condicao implementada para controlar os numeros apresentadas na tela³
//³  de processamento da rotina, os detalhes.                          ³
//³Ao final do processamento, para este caso da funcao, atualizo altero³
//³  o tratamento de registros lidos, pois a funcao utiliza bastante   |		
//³  a funcao RegPorNf e ela nao tem o controle de soma da variavel    ³		
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cMensagem) .And. Type("oProcess")=="O"
	oProcess:SetDetProgress(STR0016,Len(aRegsPai),;		//"Total de registros do periodo solicitado"
			STR0017,nDocsXTime,;		//"Total de registros processados por segundo"
			STR0018,0,;					//"Total de registros pendentes para processamento"
			STR0019,0)					//"Tempo estimado para termino do processamento (Seg.)"
EndIf		
Return  	

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡ao    ³CATLeRegs| Autor ³Cecilia Carvalho  			   ³ Data ³20.03.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao efetua a leitura das informacoes gravadas pela funcao       ³±±
±±³          ³ CATRegs, conforme seu criterio de gravacao                       ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³1) Os array a serem passados devem seguir a ordem hierarquica de   ³±±
±±³          ³   gracao.                                                         ³±±
±±³          ³2) Para os registros que estiverem na sequencia mais nao correspon-³±±
±±³          ³   derem a hierarquia informada, deve ser passado no seguinte for- ³±±
±±³          ³   mato. Ex: (aReg,2}                                              ³±±
±±³          ³   a) O primeiro nivel corresponde ao registro;                    ³±±
±±³          ³   b) O segundo corresponde ao pai deste registro que nao eh o     ³±±
±±³          ³      antecessor. Um exemplo de utilizacao eh a geracao do bloco E.³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CATRegs(cAlias,aRegs)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nHandle   -> Handle do arquivo texto                               ³±±
±±³          ³cAlias    -> Alias do TRB em processamento para gravar as informa- ³±±
±±³          ³             coes                                                  ³±±
±±³          ³aRegs     -> Array com os codigos de registros a serem tratados    ³±±
±±³          ³cRelac    -> Conteudo do campo TRB_RELAC do registro PAI gravado   ³±±
±±³          ³             fora desta funcao para relacionamento com seus filhos ³±±
±±³          ³nFor      -> Controle da recursividade (NAO USAR)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - CAT153                                                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CATLeRegs(nHandle,cAlias,aRegs,cRelac,nFor)
Local	nTamTRBIt	:=	Len((cAlias)->TRB_RELAC)/2	//Efetuo divisao por dois porque faco dois controles em um mesmo campo. O relacionamento e sequencia. Ex: ...0001...1, ...0001...2
Local	nX			:=	0
Local	nRecno		:=	0
Local	nPai		:=	0
Local	aAux  		:=	aClone(aRegs)
Local	lTemFil		:=	.T.
Local	nPosFil		:=	0
Local	cReg		:=	""
Local	cRelacPai	:=	""
Local	cRelacFil	:=	""

Default	nFor		:=	1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Percorrendo os registros a serem gerados segundo sua hierarquia (conforme passado no array).³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := nFor To Len(aRegs)
	cRelacPai	:=	SubStr(cRelac,1,nTamTRBIt)
	cRelacFil	:=	SubStr(cRelac,nTamTRBIt+1)
	nRecno		:=	(cAlias)->(Recno())

	If ValType(aRegs[nX])=="A"
		cReg	:=	aRegs[nX,1]
		nPai	:=	aRegs[nX,2]
	Else
		cReg	:=	aRegs[nX]
		nPai	:=	nX-1
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Este eh um tratamento para retornar a posicao, se tiver na cadeia,                 ³
	//³  outro registro fora da sequencia que seja filho deste em processamento.          ³
	//³                                                                                   ³
	//³Este tratamento eh necessario para que se nao encontrar o registro filho,          ³
	//³  seja verificado se pode abandonar o processamento, jah que nao tem mais          ³
	//³  filhos a verificar, ou se o filho estah fora da sequencia, neste caso vou direto ³
	//³  a ele no ELSEIF abaixo.                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPosFil	:=	aScan(aRegs,{|aX| ValType(aX)<>"C" .And. aX[2]==nPai},nX+1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento de buscao do filho correspondente ao pai em processamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTemFil .And. (lTemFil := (cAlias)->(MsSeek(cReg+cRelacFil)))

		While !(cAlias)->(Eof()) .And. (cAlias)->TRB_TPREG==cReg .And. SubStr((cAlias)->TRB_RELAC,1,nTamTRBIt)==cRelacFil

			If (cAlias)->TRB_FLAG<>"*"
				CATGrvLin(nHandle,cAlias)
		
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Para que se procure um registro filho, deve-se fazer as seguintes verificacoes:               ³
				//³1) O array deve ter o tamanho compativel com o proximo nivel a ser processado;                ³
				//³2) Este proximo registro(filho) deve ter como ordem hierarquica a sequencia do array passado; ³
				//³3) Ou, no caso de array, o segundo indice que indica o Pai, deve ser o registro corrente, pois³
				//³    caso seja um que jah foi processado, nao preciso chamar a funcao recursica, pois nao irah ³
				//³    encontrar a correspondencia.                                                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Len(aAux)>=nX+1 .And. (ValType(aAux[nX+1])<>"A" .Or. (ValType(aAux[nX+1])=="A" .And. aAux[nX+1,2]>=nX))
					nRecno	:=	(cAlias)->(Recno())
					CATLeRegs(nHandle,cAlias,aAux,(cAlias)->TRB_RELAC,nX+1)
					(cAlias)->(dbGoTo(nRecno))
				EndIf
			EndIf
			
			(cAlias)->(dbSkip())
		End
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Este eh um tratamento para retornar a posicao, se tiver na cadeia,                 ³
		//³  outro registro fora da sequencia que seja filho deste em processamento.          ³
		//³                                                                                   ³
		//³Este tratamento eh necessario para que se nao encontrar o registro filho,          ³
		//³  seja verificado se pode abandonar o processamento, jah que nao tem mais          ³
		//³  filhos a verificar, ou se o filho estah fora da sequencia, neste caso vou direto ³
		//³  a ele no ELSEIF abaixo.                                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nPosFil := aScan(aRegs,{|aX| ValType(aX)<>"C" .And. aX[2]==nPai},nX+1))==0
			Exit
		Else
			nX		:=	nPosFil-1
		EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para seguir com o processamento. Ele se dah em duas situacoes:               ³
	//³1) Caso o registro PAI nao esteja na cadeia (nPai===0), isso significa que o registro   ³
	//³    principal (Nivel 1) nao foi encontrado, entao nao tem o que gerar, portanto continuo³
	//³    o processamento caso existam outros para serem gerados;                             ³
	//³                                                                                        ³
	//³2) No caso de o filho nao estar na sequencia passada, mas se referir a algum fora da    ³
	//³    sequencia, neste caso, deve-se posicionar no referido e processa-lo                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf nPai==0 .Or. (!lTemFil .And. nPosFil>0)
			
		(cAlias)->(dbGoTo(nRecno))

		If nPai<>0 .And. !lTemFil .And. nPosFil>0
			nX		:=	nPosFil-1
		EndIf
		
		lTemFil	:=	.T.
	Else
		Exit
	EndIf	
Next nX
Return
                   
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡ao    ³CATQryPri| Autor ³Cecilia Carvalho  			   ³ Data ³20.03.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao que retorna o valor de reducao da base de calculo do ICMS   ³±±
±±³          ³ utilizando a regra convencional (SENTO/OUTROS/BASE)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                   ³±±
±±³          ³nOpc      -> Opcao de utilizacao da funcao, 1 eh para retornar um  ³±±
±±³          ³             reccount de registros e dieferente de 1 eh para retor-³±±
±±³          ³             nar as informacoes.                                   ³±±
±±³          ³cTpMov    -> Tipo de movimentacao, E=Entrada, S=Saida              ³±±
±±³          ³dDataDe   -> Data inicial do periodo                               ³±±
±±³          ³dDataAte  -> Data final do periodo                                 ³±±
±±³          ³cAliasSFT -> Alias da tabela SFT a ser retornada por referencia    ³±±
±±³          ³lTabComp -> Flag de existencias das tabelas de complementos ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpN1 - 0=Nao tem movimento e maior que ZERO identifica com movimto³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - CAT153                                                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CATQryPrin(nOpc,cTpMov,dDataDe,dDataAte,cAliasSFT,lTabComp)                     
Local	cFiltro			:=	""
Local	cSlctSFT 		:=	""
Local	cSlctF1F2		:=	""
Local	cSlctD1D2		:=	""
Local	cSlctA1			:=	""
Local	cSlctA2			:=	""
Local	cSlctF4			:=	""
Local	cSlctAll		:=	""
Local	cJoinF3			:=	""
Local	cJoinD1D2		:=	""
Local	cJoinF1F2		:=	""
Local	cJoinSF4		:=	""
Local	cJoinSA4		:=	""
Local	nRecCount		:=	0
Local	cOrderBy		:=	"%%"
Local	cSlvAlias		:=	cAliasSFT
Local	aFieldDt		:=	{}
Local	nX				:=	0
Local 	cSerieView		:= ""

DbSelectArea (cAliasSFT)
(cAliasSFT)->(DbSetOrder(2))

#IFDEF TOP
	If TcSrvType() <> "AS/400"
    	cFiltro := "%"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Montagem do SELECT FULL em uma unica variavel, pois hora pode ser o SELECT³
		//³  normal e hora pode ser um SELECT COUNT()                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc==1
			cSlctAll	:=	"COUNT(*) SFTCOUNT"
		Else

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Campos da tabela SFT³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSlctSFT := "SFT.FT_FILIAL,  SFT.FT_TIPOMOV,	SFT.FT_ENTRADA, SFT.FT_SERIE,   SFT.FT_NFISCAL, SFT.FT_CLIEFOR,"
			cSlctSFT += "SFT.FT_LOJA,    SFT.FT_ITEM,   	SFT.FT_PRODUTO, SFT.FT_NRLIVRO, SFT.FT_CFOP,    SFT.FT_ESPECIE, "
			cSlctSFT += "SFT.FT_TIPO,    SFT.FT_EMISSAO,	SFT.FT_DTCANC,  SFT.FT_FORMUL,  SFT.FT_ALIQPIS, SFT.FT_VALPIS, "
			cSlctSFT += "SFT.FT_ALIQCOF, SFT.FT_VALCOF, 	SFT.FT_VALCONT, SFT.FT_BASEICM, SFT.FT_VALICM,  SFT.FT_ISSST, "
			cSlctSFT += "SFT.FT_BASERET, SFT.FT_ICMSRET,	SFT.FT_VALIPI,  SFT.FT_ISENICM, SFT.FT_QUANT,   SFT.FT_DESCONT, "
			cSlctSFT += "SFT.FT_TOTAL,   SFT.FT_FRETE,  	SFT.FT_SEGURO,  SFT.FT_DESPESA, SFT.FT_OUTRICM, SFT.FT_BASEIPI, "
			cSlctSFT += "SFT.FT_ISENIPI, SFT.FT_OUTRIPI,	SFT.FT_ICMSCOM, SFT.FT_RECISS,  SFT.FT_BASEIRR, SFT.FT_ALIQICM, "
			cSlctSFT += "SFT.FT_ALIQIPI, SFT.FT_CTIPI,  	SFT.FT_POSIPI,  SFT.FT_CLASFIS, SFT.FT_PRCUNIT, SFT.FT_CFPS, "
			cSlctSFT += "SFT.FT_OBSERV,  SFT.FT_ESTADO, 	SFT.FT_CODISS,  SFT.FT_ALIQIRR, SFT.FT_VALIRR,  SFT.FT_BASEINS, "
			cSlctSFT += "SFT.FT_VALINS,  SFT.FT_PDV,    	SFT.FT_ISSSUB,  SFT.FT_CREDST,  SFT.FT_ISENRET, SFT.FT_OUTRRET, "
			cSlctSFT += "SFT.FT_CONTA,   SFT.FT_BASEPIS,	SFT.FT_BASECOF, SFT.FT_PESO,    SFT.FT_SOLTRIB, SFT.FT_NFORI, "
			cSlctSFT += "SFT.FT_SERORI,  SFT.FT_ITEMORI,	SFT.FT_IDENTF3, SFT.FT_OBSSOL,  SFT.FT_FORMULA"
			cSlctSFT += ", SFT.FT_CHVNFE"
			cSlctSFT += ", SFT.FT_RGESPST"
			cSlctSFT += ", SFT.FT_AGREG"

			cSerieView := SerieNfId(cAliasSFT,3,"FT_SERIE")

			If cSerieView == "FT_SDOC"
				cSlctSFT += ", SFT.FT_SDOC"			    
				cSlctSFT 	+= ","
			Else
				cSlctSFT 	+= ","
			EndIf

			aAdd(aFieldDt,"FT_EMISSAO")
			aAdd(aFieldDt,"FT_ENTRADA")
			aAdd(aFieldDt,"FT_DTCANC")
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Campos para o SELECT da tabela SB1³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSlctSB1	:=	"SB1.B1_UM,      SB1.B1_SELO,    SB1.B1_TAB_IPI, SB1.B1_VLR_IPI, SB1.B1_TIPO,    SB1.B1_DESC, "
			cSlctSB1	+=	"SB1.B1_CODBAR,  SB1.B1_CODANT,  SB1.B1_POSIPI,  SB1.B1_EX_NCM,  SB1.B1_CODISS,  SB1.B1_PICM, "
			cSlctSB1	+=	"SB1.B1_FECP,    SB1.B1_CC,		SB1.B1_SEGUM,   SB1.B1_TIPCONV, SB1.B1_CONV,    SB1.B1_VLR_PIS, "
			cSlctSB1	+=	"SB1.B1_VLR_COF, SB1.B1_CLASSE,  SB1.B1_CONTA,   SB1.B1_ORIGEM, SB1.B1_IMPORT,"
			If SB1->(FieldPos(cCodProdED))>0       
			    cSlctSB1 += "SB1." + cCodProdED + ","                        
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Campos para o SELECT da tabela SF2 ou SF1³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSlctF1F2	:=	""
			If cTpMov=="E"				
				cSlctF1F2	+=	"SF1.F1_FRETE, SF1.F1_COND, SF1.F1_TIPO, SF1.F1_FORMUL, SF1.F1_ESPECIE, SF1.F1_DOC, SF1.F1_SERIE, "
				cSlctF1F2	+=	"SF1.F1_FORNECE, SF1.F1_LOJA, SF1.F1_EMISSAO, SF1.F1_PREFIXO, SF1.F1_DUPL, SF1.F1_CHVNFE, SF1.F1_HAWB "
				cSlctF1F2	+=	", SF1.F1_TRANSP "
				cSlctF1F2	+=	", SF1.F1_TPFRETE "
				cSlctF1F2	+=	", SF1.F1_TPCTE "
				cSlctF1F2	+=	", SF1.F1_TIPO_NF "
			Else
				cSlctF1F2	+=	"SF2.F2_FRETE, SF2.F2_COND, SF2.F2_TIPO, SF2.F2_FORMUL, SF2.F2_ESPECIE, SF2.F2_EMISSAO, SF2.F2_CLIENTE, "
				cSlctF1F2	+=	"SF2.F2_LOJA, SF2.F2_NFCUPOM, SF2.F2_PDV, SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_TRANSP, SF2.F2_VEICUL1, "
				cSlctF1F2	+=	"SF2.F2_VEICUL2, SF2.F2_VEICUL3, SF2.F2_PBRUTO, SF2.F2_PLIQUI, SF2.F2_PREFIXO, SF2.F2_DUPL, SF2.F2_ECF, "
				cSlctF1F2	+=	"SF2.F2_VALPIS, SF2.F2_VALCOFI, SF2.F2_FILIAL, SF2.F2_CHVNFE"
			EndIf
			cSlctF1F2 += ","
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Campos para o SELECT da tabela SD2 ou SD1³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cTpMov=="E"
				cSlctD1D2	:=	"SD1.D1_TES,SD1.D1_TIPO,SD1.D1_UM,SD1.D1_PEDIDO,SD1.D1_ITEM,SD1.D1_SEGUM,SD1.D1_QTSEGUM,SD1.D1_DOC,"
				cSlctD1D2+="SD1.D1_DESCICM,"
			Else
				cSlctD1D2	:=	"SD2.D2_TES,SD2.D2_TIPO,SD2.D2_UM,SD2.D2_PEDIDO,SD2.D2_SEGUM,SD2.D2_QTSEGUM,SD2.D2_DOC,"
				cSlctD1D2+="SD2.D2_DESCICM,"
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Campos para o SELECT da tabela SA1, SA2 e SA4³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//Tabela SA1
			cSlctA1	:=	"SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA1.A1_PESSOA, SA1.A1_CGC, SA1.A1_EST, SA1.A1_INSCR, SA1.A1_COD_MUN, "
			cSlctA1	+=	"SA1.A1_END, SA1.A1_BAIRRO,SA1.A1_CEP,SA1.A1_TEL"
			cSlctA1	+=	", SA1.A1_CODPAIS"
			cSlctA1	+=	", SA1.A1_COMPLEM"
			cSlctA1	+=	", SA1.A1_ENDNOT"
			If SA1->(FieldPos(cCodClieED))>0       
			    cSlctA1 += ", SA1." + cCodClieED                        
			EndIf
			cSlctA1 += ","
			
			//Tabela SA2
			cSlctA2	:=	"SA2.A2_COD, SA2.A2_LOJA, SA2.A2_NOME, SA2.A2_TIPO, SA2.A2_CGC, SA2.A2_EST, SA2.A2_INSCR, SA2.A2_COD_MUN, "
			cSlctA2	+=	"SA2.A2_END, SA2.A2_BAIRRO,SA2.A2_CEP,SA2.A2_TEL"
			cSlctA2	+=	", SA2.A2_CODPAIS"
			cSlctA2	+=	", SA2.A2_COMPLEM"
			cSlctA2	+=	", SA2.A2_ENDNOT"
			If SA2->(FieldPos(cCodFornED))>0       
			    cSlctA2 += ", SA2." + cCodFornED                        
			EndIf
			cSlctA2 += ","
			
            //Tabela SA4
			cSlctA4	:=	"SA4.A4_COD, SA4.A4_NOME, SA4.A4_CGC, SA4.A4_INSEST, SA4.A4_EST, SA4.A4_END, SA4.A4_BAIRRO,SA4.A4_CEP,SA4.A4_TEL"
			cSlctA4	+=	", SA4.A4_CODPAIS"
			cSlctA4	+=	", SA4.A4_COD_MUN"
			cSlctA4	+=	", SA4.A4_COMPLEM"
			cSlctA4	+=	", SA4.A4_ENDNOT"
			cSlctA4 	+= ","			

			//Tabela SF4
			cSlctF4	:=	"SF4.F4_VLAGREG, SF4.F4_SELO, SF4.F4_TEXTO, SF4.F4_ESTOQUE, SF4.F4_BASEICM, SF4.F4_SITTRIB"
			cSlctF4	+=	", SF4.F4_AGREG"
			cSlctF4 	+= 	","
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Concateno todas as variaveis individuais de SELECT para formar uma³
			//³  soh a ser utilizada no EMBEDED SQL                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSlctAll	:=	cSlctSFT+cSlctSB1+cSlctD1D2+cSlctF4+cSlctF1F2+cSlctA1+cSlctA2+cSlctA4		
			cSlctAll	+=	"SF3.R_E_C_N_O_ SF3RECNO"
			cOrderBy	:=	"%ORDER BY 1,2,3,4,5,6,7,8,9%"
		EndIf
		cSlctAll	:=	"%"+cSlctAll+"%" 
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para campos de tabelas que variam quando ENTRADA ou SAIDA³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		//JOIN SF3
		If cTpMov=="E"
			cJoinF3	:=	"SF3.F3_CFO<'5'"
		Else
			cJoinF3	:=	"SF3.F3_CFO>'4'"
		EndIf
		cJoinF3 := "%" + cJoinF3 + "%"
		
		//JOIN SD1 e SD2
		If cTpMov=="E"
			cJoinD1D2	:=	"LEFT JOIN "+RetSqlName("SD1")+" SD1 ON(SD1.D1_FILIAL='"+xFilial("SD1")+"'  AND SD1.D1_DOC=SFT.FT_NFISCAL AND SD1.D1_SERIE=SFT.FT_SERIE AND SD1.D1_FORNECE=SFT.FT_CLIEFOR AND SD1.D1_LOJA=SFT.FT_LOJA AND SD1.D1_COD=SFT.FT_PRODUTO AND SD1.D1_ITEM=SFT.FT_ITEM AND SD1.D_E_L_E_T_=' ') "
		Else
			cJoinD1D2	:=	"LEFT JOIN "+RetSqlName("SD2")+" SD2 ON(SD2.D2_FILIAL='"+xFilial("SD2")+"'  AND SD2.D2_DOC=SFT.FT_NFISCAL AND SD2.D2_SERIE=SFT.FT_SERIE AND SD2.D2_CLIENTE=SFT.FT_CLIEFOR AND SD2.D2_LOJA=SFT.FT_LOJA AND SD2.D2_COD=SFT.FT_PRODUTO AND SD2.D2_ITEM=SFT.FT_ITEM AND SD2.D_E_L_E_T_=' ') "
		EndIf
		cJoinD1D2 := "%" + cJoinD1D2 + "%"
		
		//JOIN SF1 e SF2
		If cTpMov=="E"
			cJoinF1F2	:=	"LEFT JOIN "+RetSqlName("SF1")+" SF1 ON(SF1.F1_FILIAL='"+xFilial("SF1")+"'  AND SF1.F1_DOC=SFT.FT_NFISCAL AND SF1.F1_SERIE=SFT.FT_SERIE AND SF1.F1_FORNECE=SFT.FT_CLIEFOR AND SF1.F1_LOJA=SFT.FT_LOJA AND SF1.D_E_L_E_T_=' ') "
		Else
			cJoinF1F2	:=	"LEFT JOIN "+RetSqlName("SF2")+" SF2 ON(SF2.F2_FILIAL='"+xFilial("SF2")+"'  AND SF2.F2_DOC=SFT.FT_NFISCAL AND SF2.F2_SERIE=SFT.FT_SERIE AND SF2.F2_CLIENTE=SFT.FT_CLIEFOR AND SF2.F2_LOJA=SFT.FT_LOJA AND SF2.D_E_L_E_T_=' ') "
		EndIf
		cJoinF1F2 := "%" + cJoinF1F2 + "%"
		
		//JOIN SF4
		If cTpMov=="E"
			cJoinSF4	:=	"SF4.F4_CODIGO=SD1.D1_TES"
		Else
			cJoinSF4	:=	"SF4.F4_CODIGO=SD2.D2_TES"
		EndIf
		cJoinSF4 := "%" + cJoinSF4 + "%"      
		
		//JOIN SA4
		If cTpMov=="E"
			cJoinSA4	:=	"SA4.A4_COD=SF1.F1_TRANSP"
		Else
			cJoinSA4	:=	"SA4.A4_COD=SF2.F2_TRANSP"
		EndIf
		cJoinSA4 := "%" + cJoinSA4 + "%"		
		 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³SELECT real para a execucao da rotina³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    	cAliasSFT		:=	GetNextAlias()

    	BeginSql Alias cAliasSFT
	    	SELECT			    	 
				%Exp:cSlctAll%			
			FROM 
				%Table:SFT% SFT
				LEFT JOIN %Table:SF3% SF3 ON(SF3.F3_FILIAL=%xFilial:SF3%  AND %Exp:cJoinF3% AND SF3.F3_SERIE=SFT.FT_SERIE AND SF3.F3_NFISCAL=SFT.FT_NFISCAL AND SF3.F3_CLIEFOR=SFT.FT_CLIEFOR AND SF3.F3_LOJA=SFT.FT_LOJA AND SF3.F3_IDENTFT=SFT.FT_IDENTF3 AND SF3.F3_ENTRADA=SFT.FT_ENTRADA AND SF3.F3_OBSERV NOT LIKE('NOTA FISCAL DE SERVICO%') AND SF3.%NotDel%)
				%Exp:cJoinD1D2%
				LEFT JOIN %Table:SB1% SB1 ON(SB1.B1_FILIAL=%xFilial:SB1%  AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.%NotDel%)
				LEFT JOIN %Table:SF4% SF4 ON(SF4.F4_FILIAL=%xFilial:SF4%  AND %Exp:cJoinSF4% AND SF4.%NotDel%)

				LEFT JOIN %Table:SA1% SA1 ON(SA1.A1_FILIAL=%xFilial:SA1%  AND SA1.A1_COD=SFT.FT_CLIEFOR AND SA1.A1_LOJA=SFT.FT_LOJA AND SA1.%NotDel%)
				LEFT JOIN %Table:SA2% SA2 ON(SA2.A2_FILIAL=%xFilial:SA2%  AND SA2.A2_COD=SFT.FT_CLIEFOR AND SA2.A2_LOJA=SFT.FT_LOJA AND SA2.%NotDel%)						
				%Exp:cJoinF1F2%     
				LEFT JOIN %Table:SA4% SA4 ON(SA4.A4_FILIAL=%xFilial:SA4%  AND %Exp:cJoinSA4% AND SA4.%NotDel%)
			
			WHERE 
				SFT.FT_FILIAL=%xFilial:SFT% AND 
				SFT.FT_TIPOMOV = %Exp:cTpMov% AND 
				SFT.FT_ENTRADA>=%Exp:DToS (dDataDe)% AND 
				SFT.FT_ENTRADA<=%Exp:DToS (dDataAte)% AND 
				((SFT.FT_CFOP NOT LIKE '000%' AND SFT.FT_CFOP NOT LIKE '999%') OR SFT.FT_TIPO='S') AND 
				SFT.FT_ESPECIE <> 'CF' AND 
				%Exp:cFiltro%
				SFT.%NotDel% 
        
			%Exp:cOrderBy%
		EndSql
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o objetivo for soh para retornar o COUNT, posso salvar em uma variavel ³
		//³  e fechar o alias, pois nao serah mais utilizado                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc==1
			nRecCount	:=	(cAliasSFT)->SFTCOUNT
			(cAliasSFT)->(DbCloseArea())
			cAliasSFT	:=	cSlvAlias
		Else
            For nX := 1 To Len(aFieldDt)
				TcSetField(cAliasSFT,aFieldDt[nX],"D",8,0)
			Next nX
		EndIf
	Else
#ENDIF
	    cIndex	:= CriaTrab(NIL,.F.)
	    cFiltro	:= 'FT_FILIAL=="'+xFilial ("SFT")+'".And.'
	    cFiltro += 'FT_TIPOMOV=="'+cTpMov+'" .And. '
	    cFiltro += 'DToS (FT_ENTRADA)>="'+DToS (dDataDe)+'".And.DToS (FT_ENTRADA)<="'+DToS (dDataAte)+'" '
		cFiltro += '.And. (!SubStr (FT_CFOP,1,3)$"999/000" .Or. FT_TIPO=="S")'
		cFiltro += '.And. FT_ESPECIE <> "CF"'

	    IndRegua (cAliasSFT, cIndex, SFT->(IndexKey ()),, cFiltro)
	    nIndex := RetIndex(cAliasSFT)

		#IFNDEF TOP
			DbSetIndex(cIndex+OrdBagExt ())
		#ENDIF
		
		DbSelectArea(cAliasSFT)
	    DbSetOrder(nIndex+1)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o objetivo for soh para retornar o COUNT, posso salvar em uma variavel ³
		//³  e fechar o alias, pois nao serah mais utilizado                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc==1
			nRecCount	:=	(cAliasSFT)->(RecCount ())
			(cAliasSFT)->(DbCloseArea())
			Ferase(cIndex+GetDBExtension())
			Ferase(cIndex+OrdBagExt())
			cAliasSFT	:=	cSlvAlias			
		EndIf	    
	    
		DbSelectArea (cAliasSFT)
		(cAliasSFT)->(DbGoTop ())
		
#IFDEF TOP
	Endif
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para quando nao for um SELECT de registros, retornar ZERO ³
//³  quando nao tiver movimento no periodo, e UM para quando tiver.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc<>1 .And. !(cAliasSFT)->(Eof())
	nRecCount	:=	1
EndIf
Return nRecCount    

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡ao    ³CATSeek  | Autor ³Cecilia Carvalho 			   ³ Data ³20.03.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao de posicionamento de tabelas especifica para CAT153       . ³±±
±±³          ³ Onde ora posiciono pelo RECNO e ora pelo Seek.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias - Alias da tabela que serah efetuado o posicionamento      ³±±
±±³          ³ nOrder - Ordem da tabela que serah utilizada para posicionamento. ³±±
±±³          ³ cSeek  - Chave de seek para a ordem selecionada. (QUANDO FOR EFE- ³±±
±±³          ³          TUAR O MSSEEK)                                           ³±±
±±³          ³ nRecno - RECNO da tabela em caso de DBGOTO()                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - CAT153                                                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CATSeek(cAlias,nOrder,cSeek,nRecno)
Local	lRet		:=	.F.
Local	lTop		:=	.F.
Local	lProcSeek	:=	.T.

Default	nOrder	:=	0

#IFDEF TOP
	If TcSrvType() <> "AS/400"
		lTop 		:= 	.T.		
		lProcSeek	:=	.F.
	Endif
#ENDIF

If lTop
	If nRecno<>Nil .And. nRecno>0
		If (cAlias)->(Recno())<>nRecno
			(cAlias)->(dbGoTo(nRecno))
		EndIf
		lRet	:=	.T.

	ElseIf nRecno==Nil
		lProcSeek	:=	.T.
	EndIf
EndIf

If lProcSeek .And. cSeek<>Nil	
	If nOrder==0
		nOrder	:=	(cAlias)->(IndexOrd())
	EndIf
	(cAlias)->(dbSetOrder(nOrder))
	lRet	:=	(cAlias)->(MSSeek(cSeek))
EndIf
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡ao    ³CATFiltr| Autor ³Cecilia Carvalho  			   ³ Data ³13.04.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao que efetua filtros em tabelas, indregua em dbf e query em   ³±±
±±³          ³ top. Ela deve ser chamada como 1 para criar e 2 para fechar a area³±±
±±³          ³ criada.                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpL1 := CATFiltro(nPar,cPar,cPar,aPar)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nPar - Parametro que define se criara o filtro ou feche um filtro  ³±±
±±³          ³       jah criado. 1=Criar, 2=Fechar.                              ³±±
±±³          ³cPar - Se trata de um flag atraves do nome da tabela a ser criada o³±±
±±³          ³       o filtro. No caso de haver mais de um filtro para a mesma   ³±±
±±³          ³       tabela em situacoes diferentes, basta acrescentar um identi-³±±
±±³          ³       ficador na quarta posicao do nome. Ex: SFT, SFT1, SF2, etc..³±±
±±³          ³cPar - Variavel passada por referencia para retornar o alias criado³±±
±±³          ³       para a tabela em questao.                                   ³±±
±±³          ³aPar - Parametros para execucao dos filtros                        ³±±
±±³          ³nPar - Se esta variavel for passada diferente de NIL, significa que³±±
±±³          ³       a query deve retornar a quantidade de registros. Utilizado  ³±±
±±³          ³       para montar a regua de processamento mais precisa. O retorno³±±
±±³          ³       serah nesta mesma variavel que deve ser passada como        ³±±
±±³          ³       referencia. O retorno da funcao ainda continua sendo .T.    ³±±
±±³          ³       quando tiver registros ou .F. quando nao tiver.             ³±±
±±³          ³nPar - Indica o indice a ser usado (base Codebase)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 - Booleano para identificar se a tabela possui registros ou  ³±±
±±³          ³        nao. No caso de retornar .F., nao eh necessário chamar a   ³±±
±±³          ³        funcao com o primeiro parametro igual a 2, pois se nao     ³±±
±±³          ³        houver movimento, ela fecha o alias automaticamente.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - CAT153                                                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CATFiltro(nOpc,cTabela,cAlias,aPar,nRecCount,nOrdDBF)
Local	cFiltro		:=	""
Local	cIndex		:=	""
Local	nIndex		:=	0
Local	lRet		:=	.F.
Local	lCountReg	:=	nRecCount<>Nil

#IFDEF TOP
	Local	aSetField	:=	{}
	Local	nI			:=	0
	Local	cOrderBy	:=	""
#ENDIF
Default nOrdDBF     := 0           

If nOpc==1         		
	If cTabela=="CDT"
		#IFDEF TOP
			If (TcSrvType ()<>"AS/400")
				cSelect	:=	"%CDT.CDT_IFCOMP,CDT.CDT_INDFRT" 
				cSelect	+=	",CDT.CDT_DTAREC"
				cSelect	+=	",CDT.CDT_SITEXT"
				cSelect	+= "%"
				cFrom	:=	"%"+RetSqlName("CDT")+" CDT "
				cWhere	:=	"%CDT.CDT_FILIAL='"+xFilial("CDT")+"' AND "
				cWhere	+=	"CDT.CDT_TPMOV='"+aPar[1]+"' AND "
				cWhere	+=	"CDT.CDT_DOC='"+aPar[2]+"' AND "
				cWhere	+=	"CDT.CDT_SERIE='"+aPar[3]+"' AND "
				cWhere	+=	"CDT.CDT_CLIFOR='"+aPar[4]+"' AND "
				cWhere	+=	"CDT.CDT_LOJA='"+aPar[5]+"' AND "
				cWhere	+=	"CDT.D_E_L_E_T_=' '%"
			Else
		#ENDIF
				cFiltro	:= 	"CDT_FILIAL=='"+xFilial("CDT")+"' .And. "
				cFiltro	+= 	"CDT_TPMOV=='"+aPar[1]+"' .And. " 
				cFiltro	+= 	"CDT_DOC=='"+aPar[2]+"' .And. " 
				cFiltro	+= 	"CDT_SERIE=='"+aPar[3]+"' .And. " 
				cFiltro	+= 	"CDT_CLIFOR=='"+aPar[4]+"' .And. "
				cFiltro	+= 	"CDT_LOJA=='"+aPar[5]+"'"
		#IFDEF TOP
			EndIf
		#ENDIF

	ElseIf cTabela=="SFT"	
		#IFDEF TOP
			If (TcSrvType ()<>"AS/400")	
				cSelect	:=	"%SFT.FT_FILIAL,SFT.FT_TIPOMOV,SFT.FT_SERIE,SFT.FT_NFISCAL,SFT.FT_CLIEFOR,SFT.FT_LOJA,SFT.FT_ITEM,SFT.FT_PRODUTO,SFT.FT_CFOP,SFT.FT_EMISSAO,"
				cSelect	+=	"SFT.FT_CHVNFE,"
				cSelect	+=	"SFT.FT_ESPECIE, "
				cSelect	+=	"SB1.B1_UM,      SB1.B1_SELO,    SB1.B1_TAB_IPI, SB1.B1_VLR_IPI, SB1.B1_TIPO,    SB1.B1_DESC, "
				cSelect	+=	"SB1.B1_CODBAR,  SB1.B1_CODANT,  SB1.B1_POSIPI,  SB1.B1_EX_NCM,  SB1.B1_CODISS,  SB1.B1_PICM, "
				cSelect	+=	"SB1.B1_FECP,    SB1.B1_DATREF,  SB1.B1_SEGUM,   SB1.B1_TIPCONV, SB1.B1_CONV,    SB1.B1_VLR_PIS, "
				cSelect	+=	"SB1.B1_VLR_COF, SB1.B1_CLASSE,  SB1.B1_CONTA,   SB1.B1_ORIGEM,  SB1.B1_IMPORT,  SB1.B1_CC%"
				cFrom	:=	"%"+RetSqlName("SFT")+" SFT "
				cFrom	+=	"LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SFT.FT_PRODUTO=SB1.B1_COD AND SB1.D_E_L_E_T_=' '%"
		        cWhere	:=	"%SFT.FT_FILIAL='"+xFilial("SFT")+"' AND "
				cWhere	+=	"SFT.FT_TIPOMOV='"+aPar[1]+"' AND "
				cWhere	+=	"SFT.FT_SERIE='"+aPar[2]+"' AND "
				cWhere	+=	"SFT.FT_NFISCAL='"+aPar[3]+"' AND "
				cWhere	+=	"SFT.FT_CLIEFOR='"+aPar[4]+"' AND "
				cWhere	+=	"SFT.FT_LOJA='"+aPar[5]+"' AND "
				cWhere	+=	"SFT.D_E_L_E_T_=' '%"
				aAdd(aSetField,{"FT_EMISSAO","D",8,0})
			Else
		#ENDIF
				cFiltro	:= 	"FT_FILIAL=='"+xFilial("SFT")+"' .And. "
				cFiltro	+= 	"FT_TIPOMOV=='"+aPar[1]+"' .And. " 
				cFiltro	+= 	"FT_SERIE=='"+aPar[2]+"' .And. " 
				cFiltro	+= 	"FT_NFISCAL=='"+aPar[3]+"' .And. " 
				cFiltro	+= 	"FT_CLIEFOR=='"+aPar[4]+"' .And. " 
				cFiltro	+= 	"FT_LOJA=='"+aPar[5]+"'"
		#IFDEF TOP
			EndIf
		#ENDIF

	ElseIf cTabela=="CD5"
		#IFDEF TOP
			If (TcSrvType ()<>"AS/400")	
				cSelect	:=	"%CD5.CD5_FILIAL,CD5.CD5_DOC,CD5.CD5_SERIE,CD5.CD5_FORNEC,CD5.CD5_LOJA,CD5.CD5_DOCIMP,CD5.CD5_ESPEC,CD5.CD5_TPIMP"
				cSelect	+=	"%"
				cFrom	:=	"%"+RetSqlName("CD5")+" CD5 %"						
				cWhere	:=	"%CD5.CD5_FILIAL='"+xFilial("CD5")+"' AND "
				cWhere	+=	"CD5.CD5_DOC='"+aPar[2]+"' AND "
				cWhere	+=	"CD5.CD5_SERIE='"+aPar[3]+"' AND "
				cWhere	+=	"CD5.CD5_FORNEC='"+aPar[4]+"' AND "
				cWhere	+=	"CD5.CD5_LOJA='"+aPar[5]+"' AND "  
				cWhere	+=	"CD5.D_E_L_E_T_=' '%"
			Else
		#ENDIF
				cFiltro	:=	"CD5_FILIAL=='"+xFilial("CD5")+"' .AND. "
				cFiltro	+=	"CD5_DOC=='"+aPar[2]+"' .AND. "
				cFiltro	+=	"CD5_SERIE=='"+aPar[3]+"' .AND. "
				cFiltro	+=	"CD5_FORNEC=='"+aPar[4]+"' .AND. "     
				cFiltro	+=	"CD5_LOJA=='"+aPar[5]+"' "
		#IFDEF TOP
			EndIf
		#ENDIF
		
	ElseIf cTabela=="CD2"
		#IFDEF TOP
			If (TcSrvType ()<>"AS/400")		
				cSelect	:=	"%CD2.CD2_FILIAL,CD2.CD2_TPMOV,CD2.CD2_SERIE,CD2.CD2_DOC,CD2.CD2_CODCLI,CD2.CD2_LOJCLI,CD2.CD2_CODFOR,CD2.CD2_LOJFOR,CD2.CD2_ITEM,CD2.CD2_CODPRO,CD2.CD2_IMP,CD2.CD2_PREDBC%"
				cFrom	:=	"%"+RetSqlName("CD2")+" CD2 %"		
				cWhere	:=	"%CD2.CD2_FILIAL='"+xFilial("CD2")+"' AND "
				cWhere	+=	"CD2.CD2_TPMOV='"+aPar[1]+"' AND "
				cWhere	+=	"CD2.CD2_SERIE='"+aPar[3]+"' AND "
				cWhere	+=	"CD2.CD2_DOC='"+aPar[2]+"' AND "
				If aPar[1]=="S"
					cWhere	+=	"CD2.CD2_CODCLI='"+aPar[4]+"' AND "
					cWhere	+=	"CD2.CD2_LOJCLI='"+aPar[5]+"' AND "
				Else
					cWhere	+=	"CD2.CD2_CODFOR='"+aPar[4]+"' AND "
					cWhere	+=	"CD2.CD2_LOJFOR='"+aPar[5]+"' AND "
				EndIf
				cWhere	+=	"CD2.CD2_ITEM='"+aPar[6]+"' AND "
				cWhere	+=	"CD2.CD2_CODPRO='"+aPar[7]+"' AND "
				
				If aPar[8]==Nil .Or. !Empty(aPar[8])
					cWhere	+=	"SUBSTRING(CD2.CD2_IMP,1,3)='"+aPar[8]+"' AND "
				EndIf
				cWhere	+=	"CD2.D_E_L_E_T_=' '%"
			Else
		#ENDIF
				cFiltro	:=	"CD2_FILIAL=='"+xFilial("CD2")+"' .AND."
				cFiltro	+=	"CD2_TPMOV=='"+aPar[1]+"' .AND. "
				cFiltro	+=	"CD2_SERIE=='"+aPar[3]+"' .AND. "
				cFiltro	+=	"CD2_DOC=='"+aPar[2]+"' .AND. "
				If aPar[1]=="S"
					cFiltro	+=	"CD2_CODCLI=='"+aPar[4]+"' .AND. "
					cFiltro	+=	"CD2_LOJCLI=='"+aPar[5]+"' .AND. "
				Else
					cFiltro	+=	"CD2_CODFOR=='"+aPar[4]+"' .AND. "
					cFiltro	+=	"CD2_LOJFOR=='"+aPar[5]+"' .AND. "
				EndIf
				cFiltro	+=	"CD2_ITEM=='"+aPar[6]+"' .AND. "
				cFiltro	+=	"CD2_CODPRO=='"+aPar[7]+"' "

				If aPar[8]==Nil .Or. !Empty(aPar[8])
					cFiltro	+=	" .AND. CD2_IMP=='"+PadR(aPar[8],TamSx3("CD2_IMP")[1])+"' "
				EndIf
		#IFDEF TOP
			EndIf
		#ENDIF

    Elseif cTabela=="CE6"
    	#IFDEF TOP
			If (TcSrvType ()<>"AS/400")
				If lCountReg
					cSelect	:=	"%COUNT(*) COUNTREG%"
				Else
					cSelect :=	"%CE6.*, CE5.*%"
				EndIf
				cFrom	:=	"%"+RetSqlName("CE6")+" CE6 "
				cFrom	+=	" LEFT JOIN "+RetSqlName("CE5")+" CE5 ON CE5.CE5_FILIAL='"+xFilial("CE6")+"' AND CE5.CE5_CODLAN=CE6.CE6_CODLAN AND "
				cFrom	+=	"CE5.CE5_PERIOD=CE6.CE6_PERIOD%"
				cWhere	:=	"%CE6.CE6_FILIAL='"+xFilial("CE6")+"' AND "
				cWhere	+=	"CE6.CE6_PERIOD='"+aPar[1]+"' AND "
				cWhere	+=	"CE5.CE5_TPMOV='U' AND "
				cWhere	+=	"CE6.D_E_L_E_T_=''%"
			Else
		#ENDIF
				cFiltro	:=	"CE6_FILIAL=='"+xFilial("CE6")+"' .AND. "
				cFiltro	+=	"CE6_PERIOD=='"+aPar[1]+"' "
		#IFDEF TOP
			EndIf
		#ENDIF
        
	EndIf

	#IFDEF TOP
    	If (TcSrvType ()<>"AS/400")
    		cAlias	:=	CATGetAlias(cTabela)
			BeginSql Alias cAlias
			
				SELECT 
					%Exp:cSelect%
			
				FROM 
					%Exp:cFrom%
			
				WHERE 
					%Exp:cWhere+cOrderBy%
			EndSql
			If !lCountReg
				For nI := 1 To Len(aSetField)
					TcSetField(cAlias,aSetField[nI,1],aSetField[nI,2],aSetField[nI,3],aSetField[nI,4])
				Next
			EndIf
			//Se o retorno deve ser a quantidade de registros, armazeno em uma variavel para retornar
			If lCountReg
				nRecCount	:=	(cAlias)->COUNTREG
			EndIf
		Else
	#ENDIF	
		    cIndex	:= 	CriaTrab(Nil,.F.)
		    cTabela	:=	SubStr(cTabela,1,3)
		
		    IndRegua (cAlias,cIndex,(cTabela)->(IndexKey (nOrdDBF)),,cFiltro,,.F.)
		    nIndex := RetIndex(cAlias)
		
			#IFNDEF TOP
				DbSetIndex(cIndex+OrdBagExt())
			#ENDIF
			
			DbSelectArea (cAlias)
		    DbSetOrder (nIndex+1)
			(cAlias)->(DbGoTop ())
		    
			//Se o retorno deve ser a quantidade de registros, armazeno em uma variavel para retornar
			If lCountReg
				nRecCount	:=	(cAlias)->(RecCount())
			EndIf
	#IFDEF TOP
		EndIf
	#ENDIF

	//Como jah armazenei em uma variavel o valor da quantidade de registros, 
	//posso fechar a area. O retorno da quantidade eh atraves de um        
	//parametro passado por referencia. O retorno da funcao ainda continua 
	//sendo .T. quando tiver registros ou .F. quando nao tiver.            
	If lCountReg
		CATFiltro(2,"",cAlias)			
		lRet	:=	nRecCount>0
	ElseIf !(cAlias)->(Eof())
		lRet	:=	.T.		
	Else
		CATFiltro(2,"",cAlias)
	EndIf
Else  
	#IFDEF TOP
		If (TcSrvType ()<>"AS/400")
			If Select(cAlias)<>0
				(cAlias)->(DbCloseArea())
			EndIf
		Else
	#ENDIF
			RetIndex(cAlias)
	#IFDEF TOP
		EndIf
	#ENDIF
EndIf

Return      
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡ao    ³CATInfPart| Autor ³Cecilia Carvalho              ³ Data ³20.03.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ATRIBUICAO DOS DADOS DO PARTICIPANTE NO ARRAY                      ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpN1 := CATInfPart(cAlsSA,dDataDe,dDataAte,cAliasSFT)             ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cAlsSA    -> Alias da tabela SA1, SA2 ou SA4.                      ³±±
±±³          |dDataDe   -> Data inicial para utilizar os dados cadastrais do     ³±±
±±³          |             periodo de processamento.                             ³±±
±±³          |dDataAte  -> Data final  para utilizar os dados cadastrais do      ³±±
±±³          |             periodo de processamento.                             ³±±
±±³          |cAliasSFT -> Alias da query com join quando houver                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1 - Array com as informacoes do participante do documento      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - CAT153                                                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CATInfPart(cAlsSA,dDataDe,dDataAte,cAliasSFT)
Local	aA1A2			:=	{}
Local	cA1A2			:=	SubStr (cAlsSA, 3, 1)
Local	cCLieForn	:=	""
Local	cCmpLoja		:=	""           
Local	cCmpTipo		:=	""
Local	cCmpCod		:=	""
Local	cCmpNome		:=	""
Local	cCmpCdPais	:=	""
Local	cCmpCgc		:=	""                            
Local	cCmpInsc		:=	""
Local	cCmpEst		:=	""
Local	cCmpCEP 		:=	""
Local	cCmpEnd		:=	""
Local	cCmpNum  	:=	""
Local	cCmpBairro	:=	""
Local	cCmpCodM		:=	""
Local	cCmpFone		:=	""
Local	cContCampo	:=	""
Local	nX				:=	0
Local	aPart			:= {}
Local	lTop			:= .F.

Default cAliasSFT	:=	""

#IFDEF TOP
	If TcSrvType() <> "AS/400"
		lTop 	:= .T.		
	Endif
#ENDIF

//Tratamento para utilizar os campos do SELECT quando for TOP ao inves de posicionar a tabela
If lTop .And. !Empty(cAliasSFT)
	cAlsCorr	:=	cAliasSFT
Else
	cAlsCorr	:=	cAlsSA
EndIf
//Campos do cadastro a serem considerados   
cCmpLoja		:=	cAlsCorr+"->A"+cA1A2+"_LOJA"
cCmpTipo		:=	cAlsCorr+"->A"+cA1A2+Iif ("2"$cA1A2, "_TIPO", "_PESSOA")
cCmpPessoa	:= cAlsCorr+"->A"+cA1A2+"_PESSOA"
cCmpCod		:=	cAlsCorr+"->A"+cA1A2+"_COD"
If cA1A2 == "1"
    cCmpCod   :=  AllTrim(cAlsCorr+"->A"+cA1A2+Substr(cCodClieED,3))
Else
    cCmpCod   :=  AllTrim(cAlsCorr+"->A"+cA1A2+Substr(cCodFornED,3))
EndIf  

cCLieForn	:=	&cCmpCod                   
cCLieForn 	:= Iif(ValType(cCLieForn)=="N",Alltrim(Str(cCLieForn)),Alltrim(cCLieForn))
cCmpNome		:=	cAlsCorr+"->A"+cA1A2+"_NOME"
cCmpCdPais	:=	cAlsCorr+"->A"+cA1A2+"_CODPAIS"
cCmpCgc		:=	cAlsCorr+"->A"+cA1A2+"_CGC"
cCmpInsc		:=	cAlsCorr+"->A"+cA1A2+"_INSCR"
cCmpEst		:=	cAlsCorr+"->A"+cA1A2+"_EST"
cCmpCEP		:=	cAlsCorr+"->A"+cA1A2+"_CEP"
cCmpEnd		:=	cAlsCorr+"->A"+cA1A2+"_END"
cCmpBairro	:=	cAlsCorr+"->A"+cA1A2+"_BAIRRO"
cCmpCodM		:=	cAlsCorr+"->A"+cA1A2+"_COD_MUN"
cCmpFone		:=	cAlsCorr+"->A"+cA1A2+"_TEL"

If cAlsSA == "SA4"
	aAdd (aA1A2, "4"+Strzero(BuscaFil(@aFiliais,cFilAnt),3)+Alltrim((cAlsCorr)->A4_COD))    //01-COD_PART
	aAdd (aA1A2, "4"+Alltrim((cAlsCorr)->A4_NOME))   //02-NOME
	If !Empty(cCmpCdPais)                                     //03-COD_PAIS
		aAdd (aA1A2, AllTrim(cCmpCdPais))																 	 	
	Else                                                                                                 	
		aAdd (aA1A2, "01058")				  															 		
	EndIf
	aAdd (aA1A2, "") //04	-	CNPJ/CPF
	aAdd (aA1A2, "") //05	-	IE
	aAdd (aA1A2, "") //06	-	UF
	aAdd (aA1A2, "") //07	-	CEP
	aAdd (aA1A2, "") //08	-	END
	aAdd (aA1A2, "") //09	-	NUM
	aAdd (aA1A2, "") //10	-	COMPL
	aAdd (aA1A2, "") //11	-	BAIRRO
	aAdd (aA1A2, "") //12	-	COD_MUN
	aAdd (aA1A2, "") //13	-	FONE
	If "01058" $ aA1A2[3]
		aA1A2[04] := CATConType(CATVldIE(ccCmpCgc,,.F.)) 	     	                //04-CNPJ/CPF
		aA1A2[05] := CATConType(CATVldIE((cAlsCorr)->A4_INSEST))	                //05-IE
		//12-COD_MUN  
		If Upper((cAlsCorr)->A4_EST) <> "EX"
		    If Len(Alltrim(cCmpCodM))<=5
			    aA1A2[12]	:=	UfCodIBGE((cAlsCorr)->A4_EST)+Alltrim(cCmpCodM)	
		    Else
			    aA1A2[12]	:=	Alltrim(cCmpCodM)								
		    EndIf
		EndIf			
	Else
		aA1A2[12] := "9999999"
	EndIf
   aA1A2[04]	:= cCmpEst                                   //06-UF   
   aA1A2[05]	:= cCmpCEP                                   //07-CEP   
	aEnd			:=	CATGetEnd(cCmpEnd,cAlsSA,cAlsCorr)		
	aAdd (aA1A2, CATConType(aEnd[1]))                      //08-END											 								
	aAdd (aA1A2, Iif (!Empty(aEnd[2]),aEnd[3],"SN"))       //09-NUM	  												  		
	aAdd (aA1A2, CATConType(aEnd[4]))   				   //10-COMPL 												 
	aAdd (aA1A2, CATConType(cCmpBairro))	               //11-BAIRRO
	aAdd (aA1A2, cCmpFone)					               //12-FONE
Else                
	aAdd (aA1A2, Substr(cAlsSA,3,1)+Strzero(BuscaFil(@aFiliais,cFilAnt),3)+cCLieForn)     //01-COD_PART
	aAdd (aA1A2,AllTrim(&cCmpNome))    		 	   //02-NOME
	If !Empty(&cCmpCdPais)                                 //03-COD_PAIS
		aAdd(aA1A2,&cCmpCdPais)																					
	Else                                                                                                 	
		aAdd (aA1A2, "01058")				  															 		
	EndIf
	If &cCmpEst == "EX"
    	aAdd (aA1A2, "")   	 				                  //04-CNPJ/CPF
		aAdd (aA1A2, "")		                               //05-IE      
		aAdd (aA1A2, "")   	 				                   //06-UF
		aAdd (aA1A2, "")   	 				                   //07-CEP
		aAdd (aA1A2, "")    				                   //08-END
		aAdd (aA1A2, "") 	                                   //09-NUM
		aAdd (aA1A2, "") 								       //10-COMPL
		aAdd (aA1A2, "")							           //11-BAIRRO						   					   			
		aAdd (aA1A2, "")							           //12-COD_MUN						   					   			
    	aAdd (aA1A2, "")    						           //13-FONE											   			//14	-	InscMun
	Else
		aAdd (aA1A2, &cCmpCgc)   	 				           //04-CNPJ/CPF
		aAdd (aA1A2, CATConType(CATVldIE(&cCmpInsc)))		   //05-IE      
		aAdd (aA1A2, &cCmpEst)   	 				           //06-UF
		aAdd (aA1A2, &cCmpCEP)   	 				           //07-CEP
		aEnd :=	CATGetEnd(&cCmpEnd,cAlsSA,cAlsCorr)		
		aAdd (aA1A2, CATConType(aEnd[1]))    				   //08-END
		aAdd (aA1A2, Iif (!Empty(aEnd[2]),aEnd[3],"SN")) 	   //09-NUM
		aAdd (aA1A2, CATConType(aEnd[4]))   			       //10-COMPL													 
		aAdd (aA1A2, &(cCmpBairro))							   //11-BAIRRO						   					   			
		If !"01058"$aA1A2[3] .And. AllTrim(aA1A2[3])<>""      //12-COD_MUN
			aAdd (aA1A2, "9999999")																				   	
		Else
			If Len(Alltrim(&cCmpCodM))<=5
				aAdd (aA1A2, UfCodIBGE(&(cCmpEst))+Alltrim(&cCmpCodM))										
			Else
				aAdd (aA1A2, &cCmpCodM)								
			EndIf
		EndIf
	   aAdd (aA1A2, &(cCmpFone))							   //13-FONE	 
    EndIf    										   		
EndIf
Return (aA1A2)
                       
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³CATConvType  ³ Autor ³Cecilia Carvalho    ³ Data ³20.03.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcoes de tratamento de caracteres especiais copiadas do   ³±±
±±³          ³ NFESEFAZ                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1 -> Retorna a string convertida                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³xValor -> String a ser convertida                           ³±±
±±³          ³nTam	 -> Tamanho da string                                 ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CATConType(xValor,nTam)
Local cNovo := ""

If nTam==Nil
	xValor := AllTrim(xValor)
EndIf
DEFAULT nTam := 60
cNovo := AllTrim(EnCodeUtf8(NoAcento(SubStr(xValor,1,nTam))))
Return(cNovo)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  ³CATVldIE ³ Autor ³Cecilia Carvalho        ³ Data ³20.03.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcoes de validacao da IE do contribuinte                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1 -> Retorna a string convertida                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cInsc -> Inscricao                                          ³±±
±±³          ³lContr-> Indica se retorna a palavra isento                 ³±±
±±³          ³lIsent-> Indica se trata isento                             ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CATVldIE(cInsc,lContr,lIsent)
Local 		cRet	:=	""
Local 		nI		:=	1
Default 	lContr  :=	.T.
Default		lIsent	:=	.T.

For nI:=1 To Len(cInsc)
	If Isdigit(Subs(cInsc,nI,1)) .Or. IsAlpha(Subs(cInsc,nI,1))
		cRet+=Subs(cInsc,nI,1)
	Endif
Next nI
cRet := AllTrim(cRet)

If lIsent
	If "ISENT"$Upper(cRet)
		cRet := ""
	EndIf
	If !(lContr) .And. !Empty(cRet)
		cRet := "ISENTA"
	EndIf
EndIf
Return(cRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡ao    ³CATGetAli| Autor ³Cecilia Carvalho  			   ³ Data ³13.04.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao parecia com a GetNextAlias(), que gera um alias aleatorio   ³±±
±±³          ³ para a query com um limite maior. A GETNEXTALIAS() estava chegando³±±
±±³          ³ ao limite e reiniciando a numeracao, apresentando erro de alias in³±±
±±³          ³ use                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Os array aA GETNEXTALIAS() estava chegando ao limite e reiniciando ³±±
±±³          ³ a numeracao, apresentando erro de alias in use                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CATGetAlias(ExpC)                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC -> PARAMETRO NAO OBRIGATORIO: Flag de controle para tornar o  ³±±
±±³          ³ alias mais exclusivo.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC -> Retorna o alias a ser utilizado e que não esteja aberto    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - CAT153                                                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CATGetAlias(cTabela)
Local	cArq		:=	"000000000"

Default	cTabela	:=	""

cTabela	:=	AllTrim(cTabela)
While Select("SF_"+cTabela+cArq)<>0
	cArq	:=	SOMA1(cArq)
End
Return "SF_"+cTabela+cArq

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡ao    ³CATPrSeq  | Autor ³Cecilia Carvalho              ³ Data ³13.04.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao para ler varios paramentros que se iniciam com o mesmo      |±±
±±³          ³ nome. Ex: MV_DCTF??? onde pode ser MV_DCTF000, MV_DCTF001,        ³±±
±±³          ³etc...                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpN1 := CATPrSeq(cPar,cContPad)                                   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cRet -> Conteudo do parametro                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|cPar -> Nome do parametro                                          ³±±
±±³          ³cContPad -> Conteudo padrao a ser retornado caso o mesmo nao       ³±±
±±³          ³ exista.                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - CAT153                                                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CATPrSeq(cPar,cContPad)
Local	cRet	:=	""

Default	cPar	:=	""

cPar	:=	AllTrim(cPar)
//Leitura exclusiva
If SX6->(DbSeek (cFilAnt+cPar))
	Do While !SX6->(Eof ()) .And. (cPar$SX6->X6_VAR) .And. (cFilAnt==SX6->X6_FIL)
		If !Empty(SX6->X6_CONTEUD)
			cRet	+=	"/"+AllTrim (SX6->X6_CONTEUD)
		EndIf
		SX6->(DbSkip ())
	EndDo
EndIf	
	
//Leitura Compartilhada
If SX6->(DbSeek (PadR("",FWGETTAMFILIAL)+cPar))
	Do While !SX6->(Eof ()) .And. (cPar$SX6->X6_VAR) .And. Empty(SX6->X6_FIL)
		If !Empty(SX6->X6_CONTEUD)
			cRet	+=	"/"+AllTrim (SX6->X6_CONTEUD)
		EndIf
		SX6->(DbSkip ())
	EndDo
EndIf

If Empty(cRet)
	cRet	:=	Iif(cContPad<>Nil,cContPad,"")
EndIf

If cPar=="MV_SUBTRI" .And. Empty(cRet) .And. FindFunction("GETSUBTRIB")
	cRet := GetSubTrib()
Endif

Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡ao    |CATSitDoc| Autor ³Cecilia Carvalho               ³ Data ³15.04.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³SITUACAO DO DOCUMENTO FISCAL                                       ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpN1 := CATSitDoc (cAliasSFT)                                     ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cSituaDoc -> Situacao do documento                                 ³±±
±±³          ³ onde:                                                             ³±±
±±³          ³ 00=Normal                                                         ³±±
±±³          ³ 02=Cancelado														 ³±±
±±³          ³ 04=Uso Denegado                                                   ³±±
±±³          ³ 05=Inutilizacao                                                   ³±±
±±³          ³ 06=Complemento                                                    ³±±
±±³          ³ 08=Regime especial ou norma especifica				   		     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|NaoUsar   -> Nao utilizar este parametro, pois trata-se de uma com-³±±
±±³          ³             patibilidade com outras chamadas desta funcao         ³±±
±±³          ³cAliasSFT -> Alias da tabela SFT filtrada e posicionada            ³±±
±±³          ³             na funcao principal                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - CAT153                                                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CATSitDoc(cAliasSFT,cAliasSA,dDataDe,dDataAte)
Local	cSituaDoc	:=	""
Local 	dDtCanc   	:= 	(cAliasSFT)->FT_DTCANC	
Local	cOriglan	:=  ""

Default dDataDe	:= Ctod("  /  /    ")
Default dDataAte := Ctod("  /  /    ")
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posicionamento realizado para encontrar os itens das Notas Fiscais ³
//³ de Frete incluidas atraves da rotina MATA116.                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("SD1")			
SD1->(dbSetOrder(1))
	If SD1->(MsSeek(xFilial("SD1")+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA+(cAliasSFT)->FT_PRODUTO+(cAliasSFT)->FT_ITEM))		
		cOriglan := SD1->D1_ORIGLAN
	EndIf

//Situacao da NF
If ((cAliasSFT)->FT_TIPO$"ICP") .And. !cOriglan$"FR|F |FD"
	cSituaDoc	:=	"06"	//Complemento de IPI, Complemento de ICMS, Complemento de Preco e Beneficiamento			
EndIf

If !(Empty (dDtCanc))
	If !Empty(dDataDe) .And. !Empty(dDataAte)
		If dDtCanc >= dDataDe .And. dDtCanc <= dDataAte
			cSituaDoc	:=	"02"
		Else
			cSituaDoc	:=	"00"
		EndIf
	Else
		cSituaDoc	:=	"02"	//Cancelado
	EndIf
EndIf

If Empty(cSituaDoc)
	cSituaDoc	:=	"00"	//Normal
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para notas fiscais eletronicas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
If !Empty(SF3->F3_CODRSEF)
	//NFe - Uso denegado
	If Alltrim(SF3->F3_CODRSEF) $ "110/301/302/303/304/305/306"
		cSituaDoc := "04"
	//NFe - Numeracao Inutilizada
	ElseIf Alltrim(SF3->F3_CODRSEF) $ "102"
		cSituaDoc := "05"	
	EndIf
EndIf
Return cSituaDoc

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³CATGetEnd  ³ Autor ³Cecilia                      ³ Data ³15.04.2012³±±
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
Static Function CATGetEnd(cEndereco,cAlias,cAlsQry)

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

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  |CATRegDep  ³ Autor ³Cecilia Carvalho      ³ Data ³20.03.2012³±±
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
±±³Parametros|cAlias     - Alias do TRB criado atraves da funcao principal³±±
±±³          |aRegPai    - Registro Pai.                                  ³±±
±±³          |aRegFilho  - Registro tipo filho (1:N) Varios para cada Pai.³±±   
±±³          |lOrdPai    - Ordena registro pai ?                          ³±±   
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CATRegDep(cAlias,aRegPai,aRegFilho,lRegPaiDup,nFlag,lOrdena,cMensagem,lOrdPai)
Local	aReg		:=	{}
Local	nCtd		:=	1
Local	nZ			:=	0
Local	nX			:=	0
Local 	bRblSort	:= 	{|x,y|x[1]<y[1]} 
Local 	bRblSortP	:= 	{|x,y|x[2]<y[2]}
Local 	nTamReg1	:= 	0
Local	nRegsProc	:=	0
Local	cTimeDocs	:=	Time()
Local	nDocsXTime	:=	0

DEFAULT lRegPaiDup 	:= .F.
DEFAULT nFlag		:=	Nil
DEFAULT lOrdena		:=	.T.
DEFAULT	cMensagem	:=	""
    
//Se o registro PAI tiver somente 1 item, nao precisa ordenar, pois o filho somente terah 
//um codigo de relacionamento, o que corresponde ao PAI                                  
If lOrdena
	aRegFilho  := Asort(aRegFilho,,,bRblSort)	
EndIf	
If lOrdPai
	aRegPai  := Asort(aRegPai,,,bRblSortP)	
EndIf	

If !Empty(cMensagem) .And. Type("oProcess")=="O"
	oProcess:Set1Progress(Len(aRegFilho))
	oProcess:Set2Progress(1)
	oProcess:Inc2Progress("","")
	oProcess:SetDetProgress("Total de registros do periodo solicitado",Len(aRegFilho),;
				"Total de registros processados por segundo",0,;
				"Total de registros pendentes para processamento",0,;
				"Tempo estimado para termino do processamento (Seg.)",0)
EndIf

For nZ := 1 To Len(aRegPai)
	If !lRegPaiDup
		CATRegTrS(cAlias,nZ,{aRegPai[nZ]},,nFlag)
	Endif
Next (nZ)

If !Empty(cMensagem) .And. Type("oProcess")=="O"
	oProcess:SetDetProgress("Total de registros do periodo solicitado",Len(aRegFilho),;
			"Total de registros processados por segundo",nDocsXTime,;
			"Total de registros pendentes para processamento",0,;
			"Tempo estimado para termino do processamento (Seg.)",0)
EndIf		
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  |CATGrvLin³ Autor ³Cecilia Carvalho        ³ Data ³20.03.2012³±±
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
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|nHandle -> Handle do arquivo txt aberto.                    ³±±
±±³          |cAlias -> Alias do TRB criado atraves da funcao principal.  ³±±
±±³          |cTpReg -> Tipo de registro que compoe a chave de pesquisa.  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CATGrvLin(nHandle, cAlias)	
	Local	cConteudo := AllTrim ((cAlias)->TRB_CONT)+Chr (13)+Chr (10)	

	FWrite (nHandle, cConteudo, Len (cConteudo))

	RecLock (cAlias, .F.)
		(cAlias)->TRB_FLAG	:=	"*"
	MsUnLock ()
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  |CATRegTrS ³ Autor ³Cecilia Carvalho       ³ Data ³20.03.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³              GRAVACAO DO REGISTRO NO TRB                   ³±±
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
±±³          ³nFlag -> Flag de controle de grupo que antecede o           ³±±
±±³          ³ relacionamento entre registros. Ex:                        ³±±
±±³          ³ Se o FLAG nao for passado o codigo fica ...2...2, se for   ³±±
±±³          ³ passado por exemplo 3, o codigo fiscal ...3...2            ³±±         
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CATRegTrS(cAlias,nRelac,aReg,nItem,nFlag)
Local	nX			:=	0
Local	lRet		:=	.T.
Local	cDelimit	:=	"|"
Local	nZ			:=	0
Local nDec        :=  0
Local	cLinha		:=	"" 
Local	cReg		:=	""
Local	nTamTRBIt	:=	Len((cAlias)->TRB_RELAC)/2	//Efetuo divisao por dois porque faco dois controles em um mesmo campo. O relacionamento e sequencia. Ex: ...0001...1, ...0001...2
Local lTira       :=  .T.
Local sRegDec := "520009/520010/520011/522004/522005/522006/522007/524006/524009/540008/540009/540010/544004/544005/544006/544007/544008/546006/546009/548006/580002"

Default	nRelac	:=	0
Default	nFlag	:=	Nil

If nFlag==Nil
	cFlag	:=	Iif(Valtype(nRelac)=="N",StrZero (nRelac, nTamTRBIt, 0),nRelac)
Else
	cFlag	:=	StrZero (nFlag, nTamTRBIt, 0)
EndIf

For nZ := 1 To Len (aReg)
		//cLinha	:=	cDelimit
		cLinha := ""                      
		If aReg[nZ][1]$"5200/5400/5480" 
		    lTira := .F.
		Else
		    lTira := .T.
		EndIf
		//Monto cLinha para gravar no TRB
		For nX := 1 To Len (aReg[nZ])
			//verificar quais registros-campos que devem ser gerados com 2 casas decimais
			If Alltrim(aReg[nZ][1])+Strzero(nX,2)$sRegDec
				nDec := 2
			Else
				nDec := 0
			EndIf
			If (ValType (aReg[nZ][nX])="A")
				cLinha	+=	CATRetStr (aReg[nZ][nX][1], aReg[nZ][nX][2],lTira)+Iif(nX==Len (aReg[nZ]),"",cDelimit)
			Else
				cLinha	+=	CATRetStr (aReg[nZ][nX],Iif(nDec==2,2,""),lTira)+Iif(nX==Len (aReg[nZ]),"",cDelimit)
			EndIf
		Next (nX)   		 
		cReg := SubStr (cLinha, 1, 4)	
		//Tratamento para nao permitir gerar uma string maior que o tamanho do campo TRB_CONT. Se acontecer, somente serah no registro 0450.
		If Len(cLinha)>Len((cAlias)->TRB_CONT)
			cLinha	:=	AllTrim(Left(cLinha,Len((cAlias)->TRB_CONT)-1))//+cDelimit
		EndIf
		//Monto TRB
		RecLock(cAlias, .T.)
				(cAlias)->TRB_TPREG		:=	cReg
				(cAlias)->TRB_RELAC		:=	cFlag+Iif(Valtype(nRelac)=="N",StrZero (nRelac, nTamTRBIt, 0),nRelac)
				(cAlias)->TRB_CONT		:=	cLinha
				(cAlias)->TRB_ITEM		:=	nItem
		MsUnLock ()
Next nZ
Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  |CATRetStr  ³ Autor ³Cecilia Carvalho      ³ Data ³20.03.2012³±±
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
±±³          ³nDec   -> Quantidade de decimais para valores numericos     ³±±
±±³          ³lLimpa -> Indica se deve ser usado Alltrim no campo         ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CATRetStr(xValor,nDec,lLimpa)
Local	xRet

If (ValType (xValor)=="N")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Todas as variaveis numericas que nao tiverem definicao de casas decimais     |
	//³serao convertidas para apresentarem 2 decimais                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (xValor==0) .And. nDec<>2
		xRet	:=	"0"
	ElseIf nDec == NIL
		xRet	:=	AllTrim (StrTran (Str (xValor,,2), ".", ","))
	Else
		xRet	:=	AllTrim (StrTran (Str (xValor,,nDec), ".", ","))
	EndIf
ElseIf (ValType (xValor)=="C")
	If lLimpa
	    xRet	:=	AllTrim (xValor)
    Else
        xRet	:=	xValor
    EndIf
ElseIf (ValType (xValor)=="D")
	xRet	:=	StrZero (Day(xValor),2)+StrZero(Month(xValor),2)+StrZero(Year(xValor),4)
Else
	xRet	:=	""
EndIf
Return(xRet)

/*/ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³CATModNot  ³Autor ³ Cecilia Carvalho    ³ Data ³ 20/03/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna codigo do modelo da nota fiscal                     ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CATModNot(cEspecie)	
Local cCodigo:="01" // Outros
	
Do Case           
	Case Alltrim(cEspecie)=="NFE" 	
		cCodigo:="01" // NF Entrada
	Case Alltrim(cEspecie)=="NFA"
		cCodigo:="02" // Nota Fiscal Avulsa	
	Case Alltrim(cEspecie)=="NFCF" 	
		cCodigo:="03" // NF de venda a Consumidor Final
	Case Alltrim(cEspecie)=="CF" .OR. Alltrim(cEspecie)=="ECF"
		cCodigo:="04" // Cupon Fiscal gerado pelo SIGALOJA
	Case Alltrim(cEspecie)=="NFP" 	
		cCodigo:="06" // NF de Produtor
	Case Alltrim(cEspecie)=="NFCEE" 
		cCodigo:="07" // Conta de Energia Eletrica
	Case Alltrim(cEspecie)=="NFST" 	
		cCodigo:="08" // NF Servico de Transporte
	Case Alltrim(cEspecie)=="CTR" 	
		cCodigo:="09" // Conh.Transp.Rodoviario
	Case Alltrim(cEspecie)=="CTA" 	
		cCodigo:="11" // Conh.Transp.Aquaviario
	Case Alltrim(cEspecie)=="CA"		
		cCodigo:="12" // Conh.Aereo
	Case Alltrim(cEspecie)=="CTF" 	
		cCodigo:="13" // Conh.Transp.Ferroviario      
	Case Alltrim(cEspecie)=="RMD" 	
		cCodigo:="19" // Resumo Movimento Diario		
	Case Alltrim(cEspecie)=="NFSC" 	
		cCodigo:="21" // NF Servico de Comunicacao
	Case Alltrim(cEspecie)=="NTSC" 	
		cCodigo:="21" // NF Servico de Comunicacao
	Case Alltrim(cEspecie)=="NTST" 	
		cCodigo:="22" // NF Servico de Telecomunicacoes
	Case Alltrim(cEspecie)=="CTM" 	
		cCodigo:="26" // Conh.Transp.Multimodal
	Case Alltrim(cEspecie)=="NFFA" 	
		cCodigo:="27" // Nota fiscal de fornecimento de agua
	Case Alltrim(cEspecie)=="NFCFG"
		cCodigo:="28" // Nota fiscal/conta de fornecimento de gas
	Case Alltrim(cEspecie)=="SPED" 	
		cCodigo:="31" // Nota fiscal eletronica do SEFAZ.
	Case Alltrim(cEspecie)=="CTE"
		cCodigo:="32" // Conhecimento de Transporte Eletronico
EndCase
Return (cCodigo)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  |MontaFil  ³ Autor ³Cecilia Carvalho       ³ Data ³29.05.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³  MONTA ARRAY COM AS FILIAIS PROCESSADAS                    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|aFiliais -> array com as filiais processadas                ³±±
±±³          |cCodFil  -> Codigo da filial                                ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MontaFil(aFiliais,cCodFil)
                   
If Len(aFiliais)>0 .And. Ascan(aFiliais,cCodFil)==0
	aAdd(aFiliais,cCodFil)
EndIf

Return				

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Programa  |BuscaFil  ³ Autor ³Cecilia Carvalho       ³ Data ³29.05.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³  BUSCA O CODIGO DA FILIAL                                  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nivel Hier³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|aFiliais -> array com as filiais processadas                ³±±
±±³          |aCodFil  -> Codigo da filial                                ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function BuscaFil(aFiliais,cCodFil)
Local nFil := 0                                
                   
If Len(aFiliais) > 0   
   nFil := Ascan(aFiliais,{|x|x==cCodFil})
EndIf
Return(nFil)				
