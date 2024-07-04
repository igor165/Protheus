#Include 'Protheus.ch'
#INCLUDE 'FILEIO.CH'
#INCLUDE "GTPM423.CH"

Static nHdlArq	:= 0
Static cNomeArq	:= ''
//------------------------------------------------------------------------------------------  
/*/{Protheus.doc} GTPM423
Geração do Arquivo DER
@type function
@author cris
@since 12/12/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see http://www.stc.der.pr.gov.br/stc/help/AJUDA.pdf
/*///------------------------------------------------------------------------------------------  
Function GTPM423(lAut)
Local cPerg := "GTPR423" 	
Default lAut := .F.

If Pergunte(cPerg,.T.)
	FWMsgRun( ,{|| GeraArq(lAut)}, "Montando informações para criação do arquivo texto DER" , "Aguarde a finalização do arquivo..." )
Else
	Alert( STR0015 )//"Cancelado pelo usuário"
EndIf
		
Return

Static Function GeraArq(lAut)
Local cTmpDados := GetNextAlias()
Local cMes      := ''
Local cAno      := ''
Local lFimGrv   := .T.
Local lFaz      := .F.
Local aDdLinha  := {}
Local aInfs     := {}
Local nTotOrd   := 0
Local nTotRT    := 0
Local cNumLin   := ''
	
	cMes := PadL(AllTrim(Str(Month(MV_PAR06))),2,'0')
	cAno := AllTrim(Str(Year(MV_PAR06)))

	//Seleciona os dados
	G423RetLin(@cTmpDados ) 			
	If !(cTmpDados)->(Eof())
		cNomeArq	:= "STC"+cMes+Substring(cAno,3,2)+"1"+StrTran(time(),":","")+".txt"
		If SelDirGrv(lAut) .OR. lAut
			(cTmpDados)->(dbGotop())
			While !(cTmpDados)->(Eof())	
				cNumLin := (cTmpDados)->GI2_NUMLIN
		
				G423TViag(cNumLin, MV_PAR06, MV_PAR07, @nTotOrd, @nTotRT)
				
				G423RetTrc(cNumLin, @aInfs,nTotOrd,nTotRT)
				
				lFaz := ValCCSGI4((cTmpDados)->GI2_COD)
				If lFaz	
					//Para cada linha monta os blocos J,P e P9999.	
					MntBloco( cTmpDados, @aInfs, @aDdLinha, @lFimGrv, cAno+cMes ) 
				
					//Grava no arquivo
					DescReg( aDdLinha , lFimGrv )
					 
					aDdLinha	:= {}
				EndIf
				(cTmpDados)->(dbSkip())
			EndDo
			(cTmpDados)->(dbClosearea())
		EndIf
	Else
		FwAlertWarning(STR0011+cMes+STR0012+cAno+STR0013 , STR0014 )//"Para o mês/Ano("##'/'##") informado não existem registros!"##"Aviso"
		(cTmpDados)->(dbClosearea())
	EndIf

Return

Static Function ValCCSGI4(cCodGi2)

Local cTmpGi4 := GetNextAlias()
Local lRet    := .F.
Local cStatus := ''
Local cCCS    := ''


If MV_PAR09 == 1
	
	cStatus := "%GI4.GI4_MSBLQL = 2%"
	
ElseIf MV_PAR09 == 2

	cStatus := "%GI4.GI4_MSBLQL = 1%"

Else

	cStatus := "%GI4.GI4_MSBLQL IN (1,2)%"

Endif

If MV_PAR10 == 1
	
	cCCS := "%GI4.GI4_CCS <> ''%"
		
Elseif MV_PAR10 == 2
	
	cCCS := "%GI4.GI4_CCS = ''%"
Else
	cCCS := "%GI4.GI4_CCS = GI4.GI4_CCS%"
Endif


	BeginSql Alias cTmpGi4
					
		SELECT GI4.GI4_CCS 
		FROM %Table:GI2% GI2
		INNER JOIN 
			%Table:GI4% GI4
			ON GI4.%NotDel%
			AND GI4.GI4_FILIAL = GI2.GI2_FILIAL
			AND GI4.GI4_LINHA  = GI2.GI2_COD
			AND GI4.GI4_HIST   = '2'
			AND %Exp:cStatus%
			AND %Exp:cCCS%
		WHERE
			GI2.GI2_FILIAL = %xFilial:GI2% 
			AND GI2.%NotDel%
			AND GI2.GI2_HIST   = '2'
			AND GI2.GI2_COD = %Exp:cCodGi2%
			AND GI2.%NotDel%
		
	EndSql

	If !((cTmpGi4)->(EoF()))
		lRet := .T.
	EndIf

Return lRet

//------------------------------------------------------------------------------------------  
/*/{Protheus.doc} SelDirGrv
Solicitando o diretório para gravar o arquivo
@type function
@author cris
@since 12/12/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------------------ 
Static Function SelDirGrv(lAut)

Local lDirArq  		:= .T.
Local lNAborta		:= .T.
Local cDirArq		:= ''
Private nLastKey	:= 0

	If !IsBlind()
		cDirArq := cGetFile("",,1, STR0016 ,.F.,GETF_LOCALHARD+GETF_RETDIRECTORY )//"Diretório para gravação"
	Else
		cDirArq := "C:\temp\"
	EndIf
	
	If nLastKey == 27
	
		lDirArq	:= .F.
		HELP("HELP",, ,STR0017, STR0018 , 1, 0)//"Seleção do diretório"##"Operação abortada pelo usuário!"
		
		Return lDirArq
		
	Endif
	
	If !ExistDir(cDirArq)
		if !lAut
			While !ExistDir(cDirArq) .AND. lNAborta
				If (lNAborta :=	MsgYesNo(STR0019))//"Diretório não existe deseja criá-lo?"
					MakeDir(cDirArq)
				EndIf
			EndDo
		EndIf
	EndIf   
	
	If (nHdlArq := FCreate(cDirArq+cNomeArq, FC_NORMAL)) < 0
	
		lDirArq	:= .F.
	 	HELP("HELP",, STR0020 ,, (STR0021+ Str(Ferror())), 1, 0)//Criação do Arquivo##"Erro ao criar arquivo: " 
	 	
	EndIf
	
	If FT_FUse(cDirArq+cNomeArq) < 0
	
		lDirArq	:= .F.
	 	HELP("HELP",,STR0020 ,, STR0022 , 1, 0)//Criação do Arquivo##"O arquivo criado não pode ser aberto. Operação Abortada. Verifique suas permissões de acesso."
	 	
	EndIf   

Return lDirArq
//------------------------------------------------------------------------------------------ 
/*/{Protheus.doc} MntBloco
Monta o blocos e sub-blocos
@type function
@author cris
@since 12/12/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------------------ 
Static Function MntBloco( cTmpDados, aInfs, aDdLinha, lFimGrv, cAnoMes )
Local cCodDER   := "0001"
Local cPrefix   := PADR(AllTrim((cTmpDados)->GI2_PREFIX),10,"0")
Local cSecao    := ''
Local cModulo11 := '0'
Local cIdaOrd   := '0' // Total de passageiros Ida Viagens Ordinárias
Local cVolOrd   := '0' // Total de passageiros Volta Viagens Ordinárias
Local cIdaMult  := '0' // Total de passageiros na Ida das Viagens Múltiplas
Local cVolMult  := '0' // Total de passageiros na volta das Viagens Multiplas
Local cIdaRefT  := '0' // Total de passageiros na Ida das Viagens de Reforço total 
Local cVolRefT  := '0' // Total de passageiros na Volta das Viagens de Reforço total
Local cIdaRefP  := '0' // Total de passageiros na Ida das Viagens de Reforço parcial
Local cVolRefP  := '0' // Total de passageiros na Ida das Viagens de Reforço parcial
Local cQtdePEx  := '0' // Quantidade de Viagens de Reforço Parcial executada ( que não deve existir para seção 0001)
Local cQtdTar1  := '0' // Quantidade de bilhetes vendidos com a tarifa 1
Local cQtdTar2  := '0' // Quantidade de bilhetes vendidos com a tarifa 2
Local cQtdTar3  := '0' // Quantidade de bilhetes vendidos com a tarifa 3
Local nTotTar1  := 0
Local nTotTar2  := 0
Local nTotTar3  := 0
Local cBlocoJ   := ''
Local cBlocoP   := ''
Local cBlcP99   := ''
Local nX        := 0
Local cMedLot   := ''
Local nTotOrd   := 0 	// Total de viagens ordinárias
Local nTotMult  := 0 	// Total de viagens multiplas
Local nTotRT    := 0 	// Total de viagens reforço total
Local nTotRP    := 0 	// Total de viagens reforço parcial
Local nLugOrd   := 0 	// Total de lugares oferecidos para viagem ordinária
Local nLugMult  := 0 	// Total de lugares oferecidos para viagem multipla
Local nLugRT    := 0 	// Total de lugares oferecidos para viagem reforço total
Local nLugRP    := 0 	// Total de lugares oferecidos para viagem reforço parcial
Local nTotViag  := 0 	// Soma viagens ordinarias + multiplas + ref. total + ref. parcial
Local nTotLug   := 0 	// Soma lugares oferecidos (ordinarias + multiplas + ref. total + ref. parcial
Local cISento   := AllTrim(GTPGetRules("ISENTOIMP")) 	//Relação dos tipos de linhas com isenção de impostos
Local nAlqICMS  := SuperGetMv("MV_GTPICM",,12 )	// Aliquota ICMS a ser utilizada no cálculo
Local nAlqIASP  := SuperGetMv("MV_GTPIAS",,2 )	// Aliquota IASP a ser utilizada no cálculo
Local nVlTotal  := 0 // Receita total da linha
Local nVlICMS   := 0 // Valor ICMS
Local nVlIASP   := 0 // Valor IASP


cMedLot	:= G423MedLot( (cTmpDados)->GI2_COD, MV_PAR06, MV_PAR07, 2 )
		
G423TViag((cTmpDados)->GI2_NUMLIN, MV_PAR06, MV_PAR07, @nTotOrd, @nTotRT)


nLugOrd := nTotOrd * Val(cMedLot)
nLugRT  := nTotRT * Val(cMedLot)

nTotViag := (nTotOrd + nTotMult + nTotRt + nTotRP)
nTotLug  := (nLugOrd + nLugMult + nLugRT + nLugRP)	


For nX := 1 To Len(aInfs)
	cSecao   := PadL(AllTrim(aInfs[nX][13]),4, '0') // StrZero(aInfs[nX][13], 4)	// GI4_CCS
	cModulo11:= MODULO11(PadL(AllTrim(aInfs[nX][13]),4, '0'))
	cIdaOrd  := StrZero(aInfs[nX][9], 6)
	cVolOrd  := StrZero(aInfs[nX][10], 6)
	cIdaMult := StrZero(0, 6)
	cVolMult := StrZero(0, 6)
	cIdaRefT := StrZero(aInfs[nX][11], 6)
	cVolRefT := StrZero(aInfs[nX][12], 6)
	cIdaRefP := StrZero(0, 6)
	cVolRefP := StrZero(0, 6)
	cQtdePEx := StrZero(0, 5)
	cQtdTar1 := StrZero((aInfs[nX][9]+aInfs[nX][10]+aInfs[nX][11]+aInfs[nX][12]), 7)
	cQtdTar2 := StrZero(0, 7)
	cQtdTar3 := StrZero(0, 7)
	
	nTotTar1 += (aInfs[nX][9]+aInfs[nX][10]+aInfs[nX][11]+aInfs[nX][12])
	nTotTar2 := 0
	nTotTar3 := 0 
	
	nVlTotal += ((aInfs[nX][9]+aInfs[nX][10]+aInfs[nX][11]+aInfs[nX][12]) * aInfs[nX][7])
	
	cBlocoP	+= 'P' + cCodDER + cPrefix + cSecao + cModulo11 + cIdaOrd + cVolOrd + cIdaMult + cVolMult + cIdaRefT + cVolRefT 
	cBlocoP	+= cIdaRefP + cVolRefP + cQtdePEx + cQtdTar1 + cQtdTar2 + cQtdTar3 + 'I' + CRLF	
Next 

If (cTmpDados)->GI2_TIPLIN $ cIsento // Verifica se o tipo da linha é isento de impostos
	nAlqICMS	:= 0
	nAlqIASP	:= 0
Endif


nVlICMS := (nVlTotal * nAlqICMS) / 100
nVlIASP := ((nVlTotal - nVlICMS) * nAlqIASP) / 100

//Retirado a data e hora conforme layout mostrado

cBlocoJ	:= 'J' + cCodDER + cPrefix + '0000' + '0' +  StrZero(nTotOrd, 5) + StrZero(nLugOrd, 7) + StrZero(nTotMult, 5) + StrZero(nLugMult, 7)
cBlocoJ	+= StrZero(nTotRT, 5) + StrZero(nLugRT, 7) + StrZero(nTotRP, 5) + StrZero(nLugRP, 7) + StrZero(nTotViag, 6)
cBlocoJ	+= StrZero(nTotLug, 8) + Space(12) + 'I' + CRLF

cBlcP99	:= 'P' + cCodDER + cPrefix + '9999' + '9' + Space(20) + StrZero(nTotTar1, 7) + StrZero(nTotTar2, 7) + StrZero(nTotTar3, 7)
cBlcP99 	+= StrZero((nVlTotal * 100),11) + StrZero((nVlICMS * 100),11) + StrZero(0,11)/*StrZero((nVlIASP * 100),11)*/ + 'I' + CRLF

aAdd( aDdLinha, cBlocoJ )
aAdd( aDdLinha, cBlocoP )
aAdd( aDdLinha, cBlcP99 )

lFimGrv	:= (cTmpDados)->(Eof())
			
Return 

//------------------------------------------------------------------------------------------  
/*/{Protheus.doc} DescReg
Grava informações no arquivo.
@type function
@author crisf
@since 12/12/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------------------  
Static Function DescReg( aConteudo, lFimGrv )
	
	Local 	nY		:= 0
	Default lFimGrv	:= .T.
	
		FT_FGoTop()    
	
		For nY := 1 To len(aConteudo)
			FWrite(nHdlArq, aConteudo[nY] )   
		Next nY
		
		//Quando final de arquivo
		if lFimGrv
		
			FT_FUse()
			
			if FClose(nHdlArq)  
			
				Aviso( STR0023, STR0024+cNomeArq, { STR0025 },3)//"Geração do Arquivo"//'Termino da montagem do arquivo '##OK
			
			Else
				
				Aviso( STR0026,STR0027+Str(FERROR())+STR0028, { STR0025 },3)//"Não Geração do Arquivo"##Ocorreu um erro no fechamento do arquivo (##'). Informe ao departamento de TI'
				
			EndIf
	
		EndIf
	
Return
