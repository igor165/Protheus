#INCLUDE "FISA063.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWCOMMAND.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} Fisa063


@param  	
		
@return lRet
			
@author Erick Dias 
@since  22/04/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function Fisa063()
Local cAlias := "TRB"

Local aWizard := {}
Local cNomWiz	:= "FISA063" + FWGETCODFILIAL //Fisa062
Local cNomeAnt	:= Iif(File(cNomWiz+".cfp"),"","FISA063")
Local lEnd		:= .F.
Local cNomeCfp	:= "FISA063" + FWGETCODFILIAL
Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)

//Monta Wizard de geração do arquivo
If !lVerpesssen .Or. !CriaWizard (cNomWiz,cNomeAnt)
	Return	
EndIF 

cNomeCFP := Iif(File(cNomeCfp+".cfp"),cNomeCfp,"FISA063")   
	
If !xMagLeWiz(cNomeCfp,@aWizard,.T.)
	Return	//Se por algum motivo a leitura do CFP falhar aborto a rotina.
EndIf

oProcess := FISProgress():New({|lEnd| ProcAgro(lEnd,@oProcess,aWizard)},STR0012)//"Processando arquivo
oProcess:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaTRB
Função para criar arquivo de trabalho onde serão gravadas as informações 
para arquivo magnético

@param	cAlias->	Alias do arquivo temporário
		aArq  ->	array do arquivo de trabalho
		nOp	  ->	Opção, 1 para criar e 2 para fechar  	
		
@return 
			
@author Erick Dias 
@since  15/04/2013
@version P11
/*/
//-------------------------------------------------------------------
Static Function CriaTRB(cAlias,aArq, nOp)

Local aCmp	:= {}
Local cArq	:= ""
Local nTamTRBIt	:= 50
Local nI	:= 0
If nOp == 1
	
	//Cria arquivo de trabalho
	cAlias	:=	"TRB"
	aAdd (aCmp, {"TRB_TPREG",	"C", 	004,	   			0})
	aAdd (aCmp, {"TRB_RELAC",	"C", 	nTamTRBIt*2,		0})
	aAdd (aCmp, {"TRB_FLAG",		"C", 	001,				0})
	aAdd (aCmp, {"TRB_CONT",		"C", 	1500,				0})
	aAdd (aCmp, {"TRB_ITEM",		"N", 	007,				0})
	cArq	:=	CriaTrab (aCmp)
	DbUseArea (.T., __LocalDriver, cArq, cAlias)
	IndRegua (cAlias, cArq, "TRB_TPREG+TRB_RELAC+StrZero (TRB_ITEM, 7, 0)")
	 	aAdd (aArq, {cAlias, cArq})
Else
	//Deleta arquivo de trabalho
	For nI := 1 To Len (aArq)
		DbSelectArea (aArq[nI][1])
		(aArq[nI][1])->(DbCloseArea ())
	Next nI
EnDIF

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} CriaWizard
Função que irá criar a Wizard de geração do arquivo, com informações para processamento do arquivo magnético.

@param  	
		
@return Nil
			
@author Erick Dias 
@since  15/05/2013
@version P11
/*/
//-------------------------------------------------------------------
Static Function CriaWizard (cNomWiz,cNomeAnt)	

Local 	lRet		:= .F.
Local	aTxtApre	:=	{}
Local	aPaineis	:=	{}
Local	cTitObj1	:=	""
Local	cTitObj2	:=	""

//
aAdd (aTxtApre, STR0001)
aAdd (aTxtApre, "")	
aAdd (aTxtApre, STR0002)
aAdd (aTxtApre, STR0003)

//ÚÄÄÄÄÄÄÄÄ¿
//³Painel 0³
//ÀÄÄÄÄÄÄÄÄÙ	
aAdd (aPaineis, {})
nPos	:=	Len (aPaineis)
aAdd (aPaineis[nPos], STR0005)
aAdd (aPaineis[nPos], "")
aAdd (aPaineis[nPos], {})
//
cTitObj1	:=	STR0005 ;								   			cTitObj2	:=	STR0006 //Data de - Data Ate 
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
//
aAdd (aPaineis[nPos][3], {2,,,3,,,,});							aAdd (aPaineis[nPos][3], {2,,,3,,,,}) 
//
aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})

//
cTitObj1	:=	STR0007 ;					   					    cTitObj2	:=	STR0008   //Diretorio do Arquivo Destino / Nome arquivo Destino
aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});				aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
																	aItens2	:=	{}
																	aAdd (aItens2, STR0009) //1-Sim	
																	aAdd (aItens2, STR0010)	 //2-não
//
cTitObj1	:=	Replicate ("X", 50);								cTitObj2	:=	Replicate ("X", 20)
aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});					aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,})


aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})


lRet	:=	xMagWizard (aTxtApre, aPaineis, cNomWiz, cNomeAnt)
Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} RegPai
Função que inclui as informações da nota fiscal no array

@param aReg-> array com informações do registro 
		aPar-> array com informações da nota fiscal 	
		
@return nPos -> Posição das informações da nota do array.
			
@author Erick Dias 
@since  15/05/2013
@version P11
/*/
//-------------------------------------------------------------------
Static Function RegPai(aReg, aPar )

Local nPos	:= 0

//Adiciona as informações do cabecalho da nota no registro
aAdd(aReg, {})
nPos	:=	Len (aReg)    
aAdd (aReg[nPos], aPar[1])	//01-CNPJ
aAdd (aReg[nPos], aPar[2])	//02-Tipo de Movimentação
aAdd (aReg[nPos], aPar[3])  //03-Número da Nota
aAdd (aReg[nPos], aPar[4])  //04-Série da Nora
aAdd (aReg[nPos], aPar[5])  //05-Dt.Entrada/Dt.Emissao
aAdd (aReg[nPos], aPar[6])  //06-Razão Social/Nome Produtor
aAdd (aReg[nPos], aPar[7])  //07-CPF/CNPJ
aAdd (aReg[nPos], aPar[8])  //08-Endereço Produtor/Estabelecimento
aAdd (aReg[nPos], aPar[9])  //09-Código Município do Produtor/Estabelecimento-IBGE
aAdd (aReg[nPos], aPar[10]) //10-Número da Receita Agronôma
aAdd (aReg[nPos], aPar[11]) //11-Nome da Propriedade/Estabelecimento
aAdd (aReg[nPos], aPar[12]) //12-Inscrição Estadual da Propiredade
aAdd (aReg[nPos], aPar[13]) //13-Município da revenda/Município da Propriedade - IBGE

Return nPos

//-------------------------------------------------------------------
/*/{Protheus.doc} RegItem
Função para adicionar os itens no array que já foi populado com as informações do documento fiscal

@param aReg-> array com informações do registro 
		aPar-> array com informações da nota fiscal 	
		nPos->Posição do array onde estão gravadas as informações da nota fiscal
		
@return Nil
			
@author Erick Dias 
@since  15/05/2013
@version P11
/*/
//-------------------------------------------------------------------
Static Function RegItem(aReg, aPar)

Local nX	:= 0

//Adiciona os itens no array já populado com os campos do cabecalho da nota fiscal
For nX:= 1 to Len(aPar)
	aAdd (aReg[1], aPar[nX])
Next nX

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} QryAgro
Função para realizar query das notas de entradas e saídas para arquivo magnético

@param	nEntSai->	Indica se irá processar operações de entradas ou saídas
  		dDataDe-> 	Data inicial da geração do arquivo
		dDataAte->	Data Final da geração do arquivo
		
@return Nil
			
@author Erick Dias 
@since  16/05/2013
@version P11
/*/
//-------------------------------------------------------------------
Static Function QryAgro(nEntSai,dDataDe,dDataAte)

Local cAliasSF1 := "SF1"
Local cAliasSF2 := "SF2"
Local cCampos	  := ""
Local cFiltro	  := ""
Local nRetType	:= 0

If nEntSai == 1

	//Campos da SF1 e SD1
	cCampos	:= "SF1.F1_DOC,	SF1.F1_SERIE,	SF1.F1_FORNECE, 	SF1.F1_DTDIGIT,	SF1.F1_TIPO, SF1.F1_LOJA,SF1.F1_ESPECIE, 	SD1.D1_QUANT"
	
	//Campos Cliente SA1
	cCampos += ",SA1.A1_NOME,		SA1.A1_COD_MUN,		SA1.A1_CGC,	SA1.A1_END,	SA1.A1_BAIRRO,	SA1.A1_INSCR,	SA1.A1_EST  "
	
	//Campos Fornecedor SA2
	cCampos += ",SA2.A2_NOME,		SA2.A2_COD_MUN,		SA2.A2_CGC,	SA2.A2_END,	SA2.A2_BAIRRO,	SA2.A2_INSCR,	SA2.A2_EST  "
	
	//Campos Complemento do Produto SB5			
	cCampos	+=	", SB5.B5_REGMAPA"
	cCampos	+=	", SB5.B5_EMBAGRO"
	
	cFiltro := "%"		
	cFiltro += " SB5.B5_REGMAPA <> ''  AND SB5.B5_EMBAGRO <> '' "
	cFiltro += "%"
  
    cCampos	:=	"%"+cCampos+"%" 	

	//Ordena por Documento, Serie e Data de digitação
	cOrderBy  := "%ORDER BY 1,2,3 %"
    	cAliasSF1 := GetNextAlias()
    	BeginSql Alias cAliasSF1			
		
		COLUMN F1_DTDIGIT AS DATE
		COLUMN F1_EMISSA0 AS DATE			
		
		SELECT			    
			%Exp:cCampos%
		FROM 
			%Table:SF1% SF1
			INNER JOIN %Table:SD1% SD1 ON(SD1.D1_FILIAL=%xFilial:SD1%  AND SD1.D1_DOC=SF1.F1_DOC AND SD1.D1_SERIE=SF1.F1_SERIE AND SD1.D1_FORNECE=SF1.F1_FORNECE AND SD1.D1_LOJA=SF1.F1_LOJA AND SD1.%NotDel%)					
			INNER JOIN %Table:SF4% SF4 ON(SF4.F4_FILIAL=%xFilial:SF4%  AND SF4.F4_CODIGO=SD1.D1_TES AND SF4.%NotDel%)
			LEFT JOIN %Table:SA1% SA1 ON(SA1.A1_FILIAL=%xFilial:SA1%  AND SA1.A1_COD=SF1.F1_FORNECE AND SA1.A1_LOJA=SF1.F1_LOJA AND SA1.%NotDel%)
			LEFT JOIN %Table:SA2% SA2 ON(SA2.A2_FILIAL=%xFilial:SA2%  AND SA2.A2_COD=SF1.F1_FORNECE AND SA2.A2_LOJA=SF1.F1_LOJA AND SA2.%NotDel%)
			INNER JOIN %Table:SB1% SB1 ON(SB1.B1_FILIAL=%xFilial:SB1%  AND SB1.B1_COD=SD1.D1_COD AND SB1.%NotDel%)				
			INNER JOIN %Table:SB5% SB5 ON(SB5.B5_FILIAL=%xFilial:SB5%  AND SB1.B1_COD=SB5.B5_COD AND SB5.%NotDel%)
		WHERE 
			SF1.F1_FILIAL=%xFilial:SF1% 		      AND
			SF1.F1_EMISSAO>=%Exp:DToS(dDataDe)%  AND 
			SF1.F1_EMISSAO<=%Exp:DToS(dDataAte)% AND
			SF1.F1_TIPO IN ('N', 'D', 'B') 		  AND
			SF4.F4_ESTOQUE = 'S'					  AND
			%Exp:cFiltro%							  AND
			SF1.%NotDel%
		%Exp:cOrderBy%
							
	EndSql	

Else
 
	//Campos da SF1 e SD1
	cCampos	:= "SF2.F2_DOC,	SF2.F2_SERIE, 	SF2.F2_DTDIGIT, SF2.F2_EMISSAO, SF2.F2_TIPO, SF2.F2_CLIENTE, SF2.F2_LOJA,SF2.F2_ESPECIE, 	SD2.D2_QUANT"
	
	//Campos Cliente SA1
	cCampos += ",SA1.A1_NOME,		SA1.A1_COD_MUN,		SA1.A1_CGC,	SA1.A1_END,	SA1.A1_BAIRRO,	SA1.A1_INSCR,	SA1.A1_EST  "
	
	//Campos Fornecedor SA2
	cCampos += ",SA2.A2_NOME,		SA2.A2_COD_MUN,		SA2.A2_CGC,	SA2.A2_END,	SA2.A2_BAIRRO,	SA2.A2_INSCR,	SA2.A2_EST  "
	
	//Campos Complemento do Produto SB5			
	cCampos	+=	", SB5.B5_REGMAPA"

	cCampos	+=	", SB5.B5_EMBAGRO"
	
	cFiltro := "%"		
	cFiltro += " SB5.B5_REGMAPA <> ''  AND SB5.B5_EMBAGRO <> '' "
	cFiltro += "%"
  
    cCampos	:=	"%"+cCampos+"%" 	

	//Ordena por Documento, Serie e Data de digitação
	cOrderBy  := "%ORDER BY 1,2,3 %"
    	cAliasSF2 := GetNextAlias()
    	BeginSql Alias cAliasSF2			
		
		COLUMN F2_DTDIGIT AS DATE
		COLUMN F2_EMISSAO AS DATE			
		
		SELECT			    
			%Exp:cCampos%
		FROM 
			%Table:SF2% SF2
			INNER JOIN %Table:SD2% SD2 ON(SD2.D2_FILIAL=%xFilial:SD2%  AND SD2.D2_DOC=SF2.F2_DOC AND SD2.D2_SERIE=SF2.F2_SERIE AND SD2.D2_CLIENTE=SF2.F2_CLIENTE AND SD2.D2_LOJA=SF2.F2_LOJA AND SD2.%NotDel%)					
			INNER JOIN %Table:SF4% SF4 ON(SF4.F4_FILIAL=%xFilial:SF4%  AND SF4.F4_CODIGO=SD2.D2_TES AND SF4.%NotDel%)
			LEFT JOIN %Table:SA1% SA1 ON(SA1.A1_FILIAL=%xFilial:SA1%  AND SA1.A1_COD=SF2.F2_CLIENTE AND SA1.A1_LOJA=SF2.F2_LOJA AND SA1.%NotDel%)
			LEFT JOIN %Table:SA2% SA2 ON(SA2.A2_FILIAL=%xFilial:SA2%  AND SA2.A2_COD=SF2.F2_CLIENTE AND SA2.A2_LOJA=SF2.F2_LOJA AND SA2.%NotDel%)
			INNER JOIN %Table:SB1% SB1 ON(SB1.B1_FILIAL=%xFilial:SB1%  AND SB1.B1_COD=SD2.D2_COD AND SB1.%NotDel%)				
			INNER JOIN %Table:SB5% SB5 ON(SB5.B5_FILIAL=%xFilial:SB5%  AND SB1.B1_COD=SB5.B5_COD AND SB5.%NotDel%)
		WHERE 
			SF2.F2_FILIAL=%xFilial:SF2% 		      AND
			SF2.F2_EMISSAO>=%Exp:DToS(dDataDe)%  AND 
			SF2.F2_EMISSAO<=%Exp:DToS(dDataAte)% AND
			SF2.F2_TIPO IN ('N', 'D', 'B') 		  AND
			SF4.F4_ESTOQUE = 'S'					  AND
			%Exp:cFiltro%							  AND
			SF2.%NotDel%
		%Exp:cOrderBy%
							
	EndSql

EndIF 


If nEntSai == 1
	cAliasRet	:= cAliasSF1
Else
	cAliasRet	:= cAliasSF2
EndIF

Return cAliasRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcAgro
Função para processar os documentos fiscais para arquivo magnético da SICCA

@param	
		
@return Nil
			
@author Erick Dias 
@since  16/05/2013
@version P11
/*/
//-------------------------------------------------------------------

Static Function ProcAgro(lEnd,oProcess,aWizard)
Local cDir			:=  ""
Local cFileDest	:= ""
Local cAliasSF1	:= "SF1"
Local cChvNota		:= ""
Local cAlias		:= "TRB"
Local cFilDe		:= ""
Local cFilAte		:= ""
Local cData		:= ""
Local cCodMun		:= ""

Local aArq	 		:=	{}
Local aReg	 		:= {}
Local aLisFil		:= {}
Local aPar			:= {}
Local aAreaSM0		:=	SM0->(GetArea ())

Local dDataDe		:=	CToD ("//")
Local dDataAte		:=	CToD ("//")

Local nEntSai		:= 1
Local nTotLin		:= 0

Local lCancel		:= .F.
 
Local bWhileSM0	:= {||!SM0->(Eof ()) .And. ((!"1"$aWizard[1][4] .And. cEmpAnt==SM0->M0_CODIGO .And. FWGETCODFILIAL<=cFilAte) .Or. ("1"$aWizard[1][4] .And. Len(aLisFil)>0 .And. cEmpAnt==SM0->M0_CODIGO))}
Local nRetCpy 		:= 0
Private cLib		:= ""

dDataDe	:=	SToD(aWizard[1][1])
dDataAte	:=	SToD(aWizard[1][2])
cDir		:=  AllTrim (aWizard[1][3])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para Linux onde a barra e invertida                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetRemoteType() == 2 // REMOTE_LINUX  
	If (SubStr (cDir, Len (cDir), 1)<>"/")
		cDir	+=	"/"
	EndIf
Else
	If (SubStr (cDir, Len (cDir), 1)<>"\")
		cDir	+=	"\"
	EndIf
EndIf


alCopied := Directory(cDir+"*.*","D")

IF Len(alCopied)==0
	Alert("É necessário informar um diretório válido para a geração do arquivo.")
	Return
EndIF

If len(alltrim(dtos(dDataDe))) == 0 .OR. len(alltrim(dtos(dDataAte))) ==0
	Alert("Informar data dos período corretamente")
	Return
EndIF

//Conforme layout, arquivo terá o CNPJ no nome
cFileDest	:= cDir+SM0->M0_CGC + ".CSV"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico se devo abrir a tela para fazer o processamento de multifiliais³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If "1" $aWizard[1][4] 
	aLisFil  :=	MatFilCalc( .T. )
	If !Empty(aLisFil)
		cFilDe	:=	PadR("",FWGETTAMFILIAL)
		cFilAte	:=	Repl("Z",FWGETTAMFILIAL)
	Else
		MsgAlert(STR0013)	//"Nenhuma filial foi selecionada para o processamento. Será considerada a filial corrente."
		cFilDe			:=	cFilAnt
		cFilAte		:=	cFilAnt
	EndIf
Else
	cFilDe			:=	cFilAnt
	cFilAte		:=	cFilAnt
EndIF

//Cria arquivo de trabalho.
CriaTRB(@cAlias,@aArq,1)  

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
		If "1"$aWizard[1][4]  //Somente faz skip se a opção de selecionar filiais estiver como Sim.
			 SM0->(dbSkip())
			 Loop
		EndIf		
	EndIf	

	For nEntSai:= 1 to 2
		
		
		
		If Type("oProcess")=="O"
			oProcess:Set1Progress(2)
			oProcess:Set2Progress(2)
		Else
			ProcRegua(2)
		EndIf
		
		
		
		If Type("oProcess")=="O"
			oProcess:Inc1Progress("Processando Empresa"+cEmpAnt+"/"+cFilAnt + ": Documentos de " +  IIf(nEntSai==1,"Entrada" ,"Saída" ) )//"Processando Empresa: Período"
			oProcess:Inc2Progress("Processando","Buscando documentos fiscais" )//"Processando" "Buscando informações do estoque			
			If oProcess:Cancel()
				lCancel:=.T.
				Exit
			EndIf			
		Else
			IncProc("Processando Empresa"+cEmpAnt+"/"+cFilAnt + ": Documentos de " + IIf(nEntSai==1,"Entrada" ,"Saída" ))			
			//Controle do cancelamento da rotina
			If Interrupcao(@lEnd)
				lCancel:=.T.
				Exit
			EndIf
		EndIf

		
		//Realiza query
		If nEntSai == 1
			cAliasSF1:= QryAgro(nEntSai,dDataDe,dDataAte)
			
			If Type("oProcess")=="O"				
				oProcess:Set2Progress((cAliasSF1)->(RecCount()))
			Else
				ProcRegua(2)
			EndIf
			
		Else
			cAliasSF2:= QryAgro(nEntSai,dDataDe,dDataAte)
			
			If Type("oProcess")=="O"
				oProcess:Set2Progress((cAliasSF2)->(RecCount()))
			Else
				ProcRegua(2)
			EndIf			
					
		EndIF		
		
		
		IF nEntSai == 1//Entradas
		
			//Laço para as notas fiscais
			Do While !(cAliasSF1)->(Eof())	
				
				aPar		:= {}
				aReg		:= {}
				cChvNota	:= (cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA	
				
				aAdd(aPar,SM0->M0_CGC)
				aAdd(aPar,"ENTRADA") //Aguardar resposta da SEFAZ para saber se é somente E/S ou terá mais modelos
				aAdd(aPar,(cAliasSF1)->F1_DOC)	
				aAdd(aPar,(cAliasSF1)->F1_SERIE)

				cData:= cvaltochar(Year((cAliasSF1)->F1_DTDIGIT ) )+ "-" + cvaltochar(strzero(month((cAliasSF1)->F1_DTDIGIT ),2)) + "-" + cvaltochar(strzero((day((cAliasSF1)->F1_DTDIGIT )),2))
				
				aAdd(aPar,cData) 	
					
				IF (cAliasSF1)->F1_TIPO $"B/D"
					aAdd(aPar,(cAliasSF1)->A1_NOME)
					aAdd(aPar,(cAliasSF1)->A1_CGC)		
					aAdd(aPar,(cAliasSF1)->A1_END)
					
					IF Len( Alltrim( (cAliasSF1)->A1_COD_MUN  )  ) <=5						
						cCodMun:=UfCodIBGE((cAliasSF1)->A1_EST)+Alltrim((cAliasSF1)->A1_COD_MUN )
					Else						
						cCodMun:= (cAliasSF1)->A1_COD_MUN
					EndIF
					aAdd(aPar,cCodMun)
		
				Else
					aAdd(aPar,(cAliasSF1)->A2_NOME)
					aAdd(aPar,(cAliasSF1)->A2_CGC)
					aAdd(aPar,(cAliasSF1)->A2_END)
					
					IF Len( Alltrim( (cAliasSF1)->A2_COD_MUN  )  ) <=5						
						cCodMun:=UfCodIBGE((cAliasSF1)->A2_EST)+Alltrim((cAliasSF1)->A2_COD_MUN )						
					Else
						cCodMun:=(cAliasSF1)->A2_COD_MUN
					EndIF
					
					aAdd(aPar,cCodMun)					
							
				EndIF
				aAdd(aPar,"")
				aAdd(aPar,"")
				
				IF (cAliasSF1)->F1_TIPO $"B/D"	
					aAdd(aPar,(cAliasSF1)->A1_INSCR)
				Else
					aAdd(aPar,(cAliasSF1)->A2_INSCR)	
				EndIF	
				
				aAdd(aPar,cCodMun)				
				
				//Adiciona as informações referente ao cabeçalho do documento fiscal
				RegPai(@aReg, aPar )	
				
				//Laço para os itens do documento fiscal
				Do While !(cAliasSF1)->(Eof ()) .And.;
					cChvNota==(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA					
					
					
					If Type("oProcess")=="O"
						oProcess:Inc2Progress("Processando","Documento :" + (cAliasSF1)->F1_DOC + " Série:" + (cAliasSF1)->F1_SERIE  )//"Processando" "Buscando informações do estoque			
						If oProcess:Cancel()
							lCancel:=.T.
							Exit
						EndIf			
					Else
						IncProc("Processando","Documento :" + (cAliasSF1)->F1_DOC + " Série:" + (cAliasSF1)->F1_SERIE)			
						//Controle do cancelamento da rotina
						If Interrupcao(@lEnd)
							lCancel:=.T.
							Exit
						EndIf
					EndIf				
					
					
					aPar:= {}
					aAdd(aPar,(cAliasSF1)->B5_REGMAPA)
					aAdd(aPar,(cAliasSF1)->D1_QUANT)		
					aAdd(aPar,(cAliasSF1)->B5_EMBAGRO)		
					
					//Implementa registro com informações dos itens
					RegItem(@aReg, aPar )		
						
					(cAliasSF1)->(DbSkip())//Próximo item
				EndDo
				
				//Grava informações na tabela temporária
				GrvRegTrS (cAlias,, aReg,,,,)
								
				If cChvNota==(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA
					(cAliasSF1)->(DbSkip())//Próxima nota
				Endif	
			EndDo
		Else //Saídas
	
			//Laço para as notas fiscais
			Do While !(cAliasSF2)->(Eof())
				
				aPar		:= {}
				aReg		:= {}
				cChvNota	:= (cAliasSF2)->F2_DOC+(cAliasSF2)->F2_SERIE+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA	
				
				aAdd(aPar,SM0->M0_CGC)
				aAdd(aPar,"SAIDA") //Aguardar resposta da SEFAZ para saber se é somente E/S ou terá mais modelos
				aAdd(aPar,(cAliasSF2)->F2_DOC)	
				aAdd(aPar, Iif((cAliasSF2)->F2_ESPECIE <>"CF" ,(cAliasSF2)->F2_SERIE,"CF") )
				cData:= cvaltochar(Year((cAliasSF2)->F2_EMISSAO ) )+ "-" + cvaltochar(strzero(month((cAliasSF2)->F2_EMISSAO ),2)) + "-" + cvaltochar(strzero((day((cAliasSF2)->F2_EMISSAO )),2))				
				aAdd(aPar,cData) 	
					
				IF (cAliasSF2)->F2_TIPO $"B/D"
					aAdd(aPar,(cAliasSF2)->A2_NOME)
					aAdd(aPar,(cAliasSF2)->A2_CGC)
					aAdd(aPar,(cAliasSF2)->A2_END)					
					
					IF Len( Alltrim( (cAliasSF2)->A2_COD_MUN  )  ) <=5
						cCodMun:=UfCodIBGE((cAliasSF2)->A2_EST)+Alltrim((cAliasSF2)->A2_COD_MUN )						
					Else
						cCodMun:=(cAliasSF2)->A2_COD_MUN
					EndIF	
					aAdd(aPar,cCodMun)					
		
				Else
					aAdd(aPar,(cAliasSF2)->A1_NOME)
					aAdd(aPar,(cAliasSF2)->A1_CGC)		
					aAdd(aPar,(cAliasSF2)->A1_END)		
					
					IF Len( Alltrim( (cAliasSF2)->A1_COD_MUN  )  ) <=5
						cCodMun:=UfCodIBGE((cAliasSF2)->A1_EST)+Alltrim((cAliasSF2)->A1_COD_MUN )
					Else
						cCodMun:=(cAliasSF2)->A1_COD_MUN
					EndIF
					aAdd(aPar,cCodMun)					
				EndIF
				aAdd(aPar,"")				
				aAdd(aPar,Iif((cAliasSF2)->F2_TIPO $"B/D",(cAliasSF2)->A2_NOME,(cAliasSF2)->A1_NOME))  				
				
				IF (cAliasSF2)->F2_TIPO $"B/D"	
					aAdd(aPar,(cAliasSF2)->A1_INSCR)
				Else
					aAdd(aPar,(cAliasSF2)->A2_INSCR)	
				EndIF	
				
				aAdd(aPar,cCodMun)
				
				//Adiciona as informações referente ao cabeçalho do documento fiscal
				RegPai(@aReg, aPar )	
				
				//Laço para os itens do documento fiscal
				Do While !(cAliasSF2)->(Eof ()) .And.;
					cChvNota==(cAliasSF2)->F2_DOC+(cAliasSF2)->F2_SERIE+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA
					
					If Type("oProcess")=="O"
						oProcess:Inc2Progress("Processando","Documento :" + (cAliasSF2)->F2_DOC + " Série:" + (cAliasSF2)->F2_SERIE  )//"Processando" "Buscando informações do estoque			
						If oProcess:Cancel()
							lCancel:=.T.
							Exit
						EndIf			
					Else
						IncProc("Processando","Documento :" + (cAliasSF2)->F2_DOC + " Série:" + (cAliasSF2)->F2_SERIE)			
						//Controle do cancelamento da rotina
						If Interrupcao(@lEnd)
							lCancel:=.T.
							Exit
						EndIf
					EndIf	
					
					
					aPar:= {}
					aAdd(aPar,(cAliasSF2)->B5_REGMAPA)
					aAdd(aPar,(cAliasSF2)->D2_QUANT)		
					aAdd(aPar,(cAliasSF2)->B5_EMBAGRO)		
					
					//Implementa registro com informações dos itens
					RegItem(@aReg, aPar )		
						
					(cAliasSF2)->(DbSkip())//Próximo item
				EndDo
				
				//Grava informações na tabela temporária
				GrvRegTrS (cAlias,, aReg,,,,)
				// validação pois dentro do laço de item já da dbskip e só sai quando muda a chave
				IF cChvNota==(cAliasSF2)->F2_DOC+(cAliasSF2)->F2_SERIE+(cAliasSF2)->F2_CLIENTE+(cAliasSF2)->F2_LOJA
					(cAliasSF2)->(DbSkip())//Próxima nota
				ENDIF	
			EndDo
		
		EndIF		
		
		IF nEntSai == 1
			DbSelectArea (cAliasSF1)
			(cAliasSF1)->(DbCloseArea())
		Else
			DbSelectArea (cAliasSF2)
			(cAliasSF2)->(DbCloseArea())		
		EndIF
		
	
	Next nEntSai	
	
	SM0->(DbSkip ())	
EndDo

RestArea(aAreaSM0)
cFilAnt := FWGETCODFILIAL

If Type("oProcess")=="O"
	//Controle do cancelamento da rotina
	If !oProcess:Cancel()
		OrgTxt (cAlias, cFileDest, @nRetCpy)
		nTotLin:= (cAlias)->(RecCount())
	EndIf
EndIF

CriaTRB(@cAlias,@aArq,2)



If Type("oProcess")=="O"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Condicao implementada para controlar os numeros apresentadas na tela³
	//³  de processamento da rotina, os detalhes.                          ³
	//³Ao final do processamento, para este caso da funcao, atualizo altero³
	//³  o tratamento de registros lidos, pois a funcao utiliza bastante   |		
	//³  a funcao SPDRePorNf e ela nao tem o controle de soma da variavel  ³		
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oProcess:Inc1Progress("Finalizado","Arquivo" + " " + cFileDest + " " + " gerado com sucesso!")	 // "Gerando arquivo texto"
	oProcess:SetDetProgress("Total de Registros Processados",nTotLin,;		//"Total de registros do periodo solicitado"
			"Concluído",0,;	
			"Concluído",0,;	
			"Concluído",0)	
EndIf


If Type("oProcess")=="O"

	oProcess:Set1Progress(1)
	oProcess:Inc1Progress("Arquivo Gerado com Sucesso!",)//"Finalizando Processamento"
	oProcess:Set2Progress(1)
	oProcess:Inc2Progress("","")
EndIf

If (File(cFileDest) .OR. nRetCpy == 0 ) .AND. !lCancel
nRetType := GetRemoteType( @cLib )
QOut( cLib )
	IF	nRetType == 5 //"HTML" $ cLib
		MsgInfo(OemToAnsi("Arquivo"+ " " + " gerado com sucesso!")) //"Arquivo gerado com sucesso!"
	ELSE
		MsgInfo(OemToAnsi("Arquivo"+ " " + cFileDest + " " + " gerado com sucesso!")) //"Arquivo "###" gerado com sucesso!"
	ENDIF
Else
	MsgAlert(OemToAnsi("Não foi possível gerar o arquivo.")) //"Não foi possível gerar o arquivo!"
EndIf 


Return


//-------------------------------------------------------------------
/*/{Protheus.doc} OrgTxt
Função que irã ler arquivo de trabalho e gerar informações no arquivo txt

@param	
		
@return Nil
			
@author Erick Dias 
@since  16/05/2013
@version P11
/*/
//-------------------------------------------------------------------
Static Function OrgTxt (cAlias, cFile, nRetCpy)

Local	nHandle		:=	-1
Local  cTrab	    := CriaTrab(,.F.)+".CSV"	
Local	cDrive		:=	""                                            	
Local	cPath		:=	""
Local	cNewFile	:=	""
Local	cExt		:=	""
Local 	cStartPath 	:= 	GetSrvProfString("StartPath","")
Local  aAreaLoc	:= {}
Local  nRetType		:= 0

nHandle	:=	MsFCreate (cTrab)
//
DbSelectArea (cAlias)  
(cAlias)->(DbSetOrder (1))
ProcRegua ((cAlias)->(RecCount ()))
(cAlias)->(DbGoTop ()) 

Do While !(cAlias)->(Eof ())
	If (Empty((cAlias)->TRB_FLAG))
		aAreaLoc :=	(cAlias)->(GetArea ())
		//Grava o registro que está no arquivo de trabalho
		SPEDGrvLin(nHandle,cAlias)
		                         
		RestArea (aAreaLoc)
	EndIF
	(cAlias)->(DbSkip ())
EndDo

If (nHandle>=0)
	FClose (nHandle)
Endif

If (File(cFile))		
	FErase (cFile)
Endif             

SplitPath(cFile,@cDrive,@cPath, @cNewFile,@cExt)
cNewFile	:=	cNewFile+cExt                    

nRetType := GetRemoteType( @cLib )
QOut( cLib )

If Empty(cDrive) 
	IF	nRetType == 5 //"HTML" $ cLib
		msg:= "Em função do acesso ao sistema ser via SmartClient HTML, o caminho informado para salvar o arquivo será desconsiderado, e será processado conforme configuração do navegador." //FISMSG("HTML")
		msgAlert(msg)
		nRetCpy := CPYS2TW(cStartPath+cTrab)
		if nRetCpy == 0
			FErase (cTrab)
   	 		If File(cStartPath+cTrab)
     			FRename(cStartPath+cTrab,cFile)
    		EndIf
   		endIf
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
	IF	nRetType == 5 //"HTML" $ cLib
		msg:= "Em função do acesso ao sistema ser via SmartClient HTML, o caminho informado para salvar o arquivo será desconsiderado, e será processado conforme configuração do navegador." //FISMSG("HTML")
		msgAlert(msg)
		nRetCpy := CPYS2TW(cStartPath+cTrab)
		if nRetCpy == 0
			FErase (cTrab)
   	 		If File(cStartPath+cTrab)
     			FRename(cStartPath+cTrab,cFile)
    		EndIf
   		endIf
   	ELSE
		lCopied := CpyS2T(cStartPath+cTrab,cDrive+cPath, .F. )
		If lCopied
			FErase (cTrab)
			If File(cDrive+cPath+cTrab)
				FRename(cDrive+cPath+cTrab,cFile)
			EndIf
		EndIf
	ENDIF	
EndIf                           



Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvRegTrS
Grava informação no arquivo de trabalho

@param	
		
@return Nil
			
@author Erick Dias 
@since  16/05/2013
@version P11
/*/
//-------------------------------------------------------------------
Static Function GrvRegTrS(cAlias,nRelac,aReg,nItem)
Local	nX			:=	0
Local	cDelimit	:=	";"
Local	nZ			:=	0
Local	cLinha		:=	"" 
Local	cReg		:=	""
Local	nTamTRBIt	:=	Len((cAlias)->TRB_RELAC)/2	//Efetuo divisao por dois porque faco dois controles em um mesmo campo. O relacionamento e sequencia. Ex: ...0001...1, ...0001...2

Default	nRelac	:=	0

cFlag	:=	Iif(Valtype(nRelac)=="N",StrZero (nRelac, nTamTRBIt, 0),nRelac)

For nZ := 1 To Len (aReg)

	For nX := 1 To Len (aReg[nZ])
		If (ValType (aReg[nZ][nX])="A")
			cLinha	+=	RetStr (aReg[nZ][nX][1], aReg[nZ][nX][2])+cDelimit
		Else
			cLinha	+=	RetStr (aReg[nZ][nX])+cDelimit
		EndIf
	Next (nX)   
		 
	cReg := SubStr (cLinha, 2, 4)
	
	//Tratamento para nao permitir gerar uma string maior que o tamanho do campo TRB_CONT. Se acontecer, somente serah no registro 0450.
	If Len(cLinha)>Len((cAlias)->TRB_CONT)
		cLinha	:=	AllTrim(Left(cLinha,Len((cAlias)->TRB_CONT)-1))+cDelimit
	EndIf
	cLinha:=substr(cLinha,1,Len(cLinha)-1)	
	//
	//Monto TRB
	RecLock (cAlias, .T.)
		(cAlias)->TRB_TPREG		:=	cReg
		(cAlias)->TRB_RELAC		:=	cFlag+Iif(Valtype(nRelac)=="N",StrZero (nRelac, nTamTRBIt, 0),nRelac)
		(cAlias)->TRB_CONT		:=	cLinha
		(cAlias)->TRB_ITEM		:=	nItem
	MsUnLock ()
Next nZ
Return

Static Function RetStr(xValor,nDec)
Local	xRet

If (ValType (xValor)=="N")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Todas as variaveis numericas que nao tiverem definicao de casas decimais     |
	//³serao convertidas para apresentarem 2 decimais                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (xValor==0)
		xRet	:=	"0"
	ElseIf nDec == NIL
		xRet	:=	AllTrim (StrTran (Str (xValor,,2), ".", ","))
	Else
		xRet	:=	AllTrim (StrTran (Str (xValor,,nDec), ".", ","))
	EndIf
	
ElseIf (ValType (xValor)=="C")
	xRet	:=	AllTrim (xValor)

ElseIf (ValType (xValor)=="D")
	xRet	:=	StrZero (Day(xValor),2)+StrZero(Month(xValor),2)+StrZero(Year(xValor),4)
	
Else
	xRet	:=	""
	
EndIf
Return(xRet)
