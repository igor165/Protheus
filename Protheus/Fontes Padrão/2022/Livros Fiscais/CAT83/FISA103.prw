#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA103

Fun��o principal da Cat83

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------

/*Rotina de gera��o do arquivo texto da CAT83*/
Function FISA103()
    
    Local oProcess
    Local aSM0      := {}
    Local lCancel   := .F.
    Local cValid    := ''
    Local nX        := 0
    Local lEnd      := .F.
    Local lDicion	:= AliasIndic('CDU') .And. AliasIndic('CDZ') .And. AliasIndic('CLP') .And. AliasIndic('CLQ') .And. AliasIndic('CLR') .And. AliasIndic('CLT') .And. ;
					AliasIndic('CLU') .And. AliasIndic('CLV') .And. AliasIndic('CLW') .And. AliasIndic('CLX') .And. AliasIndic('CLZ') .And. AliasIndic('F01') .And. ;
					AliasIndic('F04') .And. AliasIndic('F06') .And. AliasIndic('F0H') 
    Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)
    
    Private lAutomato   := IiF(IsBlind(),.T.,.F.)
   
   	If lVerpesssen
        IF lDicion 
            If !lAutomato
            
                IF pergunte('FSA103',.T.,'Par�metros de gera��o do arquivo')
                    /*Busca as filiais selecionadas pelo usu�rio*/
                    
                    oProcess := FISProgress():New({|lEnd| lEnd :=ProcCAT83(oProcess,@lCancel)},'Processando arquivo da Cat83')
                    oProcess:Activate()
                    
                    IF lCancel
                        Alert("Opera��o Cancelada pelo usu�rio",'Cat83')
                        
                    ENDIF
                ENDIF
            
            Else
                ProcCAT83()
            EndIF
        Else
            Alert('Dicion�rio est� desatualizado, por favor verifique atualiza��o das tabelas')
        EndIf    
    EndIf

RETURN


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcCAT83

Rotina que chama as fun��es de cada registro

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function ProcCAT83(oProcess,lCancel)
    
    Local oTabela
    Local oBloco0       := BLOCO0():New()
    Local oBloco5       := BLOCO5():New()
    Local TimeInicio    := ""
    Local TimeFim       := ""
    Local aNumeracao    := {}
    Local cChave0001    := '0001000000001'
    Local cChaveBlc5    := '5001000000001'
    Local dDataDe       := Dtos(MV_PAR01)
    Local dDataAte      := Dtos(MV_PAR02)
    Local aSM0          := FSA008Fil(MV_PAR09 == 1)
    Local nX            := 0
    Local nQtdProc      := Len(aSM0)
    Local aAreaSM0 := {}
    
    Default lCancel := .F.
   
    If !lAutomato
    	oProcess:Set1Progress((6*nQtdProc))
    	TimeInicio := Time()
    	oProcess:Inc1Progress('Iniciando Processamento')
    EndIf
    
    aAreaSM0 := SM0->(GetArea())
	For nX := 1 to Len(aSM0)
	   
        SM0->(DbGoTop ())
        SM0->(MsSeek (aSM0[nX][1]+aSM0[nX][2], .T.))    //Pego a filial mais proxima
       
		cFilAnt := aSM0[nX][02]
		
		If !lAutomato
			oProcess:Inc1Progress('Processando Filial : ' + cFilAnt)
			oProcess:SetDetProgress('Inicio do processamento',TimeInicio,;
				'Fim do Processamento',"" ,;
				'Tempo de processamento',"" ,;
				"","")
		EndIf
		
		oTabela	:= TabTemp()
		
		Reg0000 (oProcess,oBloco0,oTabela,@aNumeracao,@lCancel)
		
		If !lAutomato
			If oProcess:Cancel()
				ProcCancel(@lCancel,oTabela)
				Return
			EndIf
		EndIf
		
		Reg0150 (oProcess,oBloco0,oTabela,@aNumeracao,cChave0001,dDataDe,dDataAte,@lCancel)
		
		If !lAutomato
			If oProcess:Cancel()
				ProcCancel(@lCancel,oTabela)
				Return
			EndIf
		EndIf
		
		Reg0200 (oProcess,oBloco0,oTabela,@aNumeracao,cChave0001,dDataDe,dDataAte,@lCancel)
		
		If !lAutomato
			If oProcess:Cancel()
				ProcCancel(@lCancel,oTabela)
				Return
			EndIf
		EndIf
		
		Reg0300 (oProcess,oBloco0,oTabela,@aNumeracao,cChave0001,dDataDe,dDataAte,@lCancel)
		
		If !lAutomato
			If oProcess:Cancel()
				ProcCancel(@lCancel,oTabela)
				Return
			EndIf
		EndIf
		
		Reg0400 (oProcess,oBloco0,oTabela,@aNumeracao,cChave0001,dDataDe,dDataAte,@lCancel)
		
		If !lAutomato
			If oProcess:Cancel()
				ProcCancel(@lCancel,oTabela)
				Return
			EndIf
		EndIF
		
		Processa(oProcess,oBloco5,oTabela,@aNumeracao,cChaveBlc5,dDataDe,dDataAte,@lCancel)
		
		If !lAutomato
			If oProcess:Cancel()
				ProcCancel(@lCancel,oTabela)
				Return
			EndIf
		EndIf
		
		Cat83Bloc9(oTabela,oBloco0,oBloco5)
		
		/*Grava o Arquivo TXT*/
		otabela:GravaTXT()
		If !lAutomato
			oProcess:Inc2Progress('Gravando arquivo texto')
		EndIf
		/*Chama a Classe que fecha a tabela tempor�ria*/
		oTabela:DelTabela()
		
	Next nX

   RestArea (aAreaSM0)
	cFilAnt := FwCodFil()
	
	/*Elimina da mem�ria a inst�ncia do objeto informado como par�metro.*/
	FreeObj(oBloco0)
	oBloco0:= nil
	
	If !lAutomato
		oProcess:Set1Progress(1)
		oProcess:Set2Progress(1)
		oProcess:Inc1Progress('Conclu�do')
		oProcess:Inc2Progress('Conclu�do')
		
		/*Hora de T�rmino*/
		TimeFim := Time()
		oProcess:Inc2Progress('Conclu�do' )
		oProcess:SetDetProgress('Inicio do processamento',TimeInicio,;
			'Fim do Processamento',TimeFim ,;
			'Tempo de processamento',ELAPTIME(TimeInicio,TimeFim) ,;
			"","")
	EndIf
	
	IF !lCancel
		MsgInfo("Arquivo gerado com Sucesso",'Cat83')
	Else
		MsgInfo("Cancelado pelo usu�rio",'Cat83')
	EndIf

RETURN


//-------------------------------------------------------------------
/*/{Protheus.doc} Cat83Bloc9

Fun��o que ir� realizar contagem dos registros gerados e levar informa��es para o bloco 9

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function Cat83Bloc9(oTabela, oBloco0, oBloco5)
    
    Local aRetCont      := {}
    Local aContReg      := {}
    Local aContBloco    := {}
    Local nCont         := 0
    Local nTotArqTxt    := 0
    Local nTotBloco9    := 0
    
    /*Chama fun��o ContReg que busca da tabela tempor�ria os registros gravados e seus respctivos totais*/
    aRetCont        := ContReg(oTabela)
    /*Contagem do Registro*/
    aContReg        := aRetCont[1]
    /*Contagem do Bloco*/
    aContBloco      := aRetCont[2]
    
    /*Faz la�o no array de contador por registro para gerar registro 9900 para cada registro gerado*/
    For nCont   := 1 To len(aContReg)
        CatReg9900(oBloco0, aContReg[nCont][1], Alltrim(Str(aContReg[nCont][2])))
        /*Soma cada registro a variavel nTotArqTxt que contem o contador do registro 9999*/
        nTotArqTxt += aContReg[nCont][2]
    Next nCont
    
    /*Atualiza contadores do bloco 9 e do arquivo*/
    nTotArqTxt  +=  Len(aContReg) /*Somo aqui a quantidade de registro do bloco 9*/
    nTotBloco9 := Len(aContReg)
    
    /*La�o para gerar registro e abertura e fechamento de cada bloco.*/
    For nCont   := 1  to Len(aContBloco)
        Do Case
        Case nCont   == 1
            
            /*BLOCO ZERO*/
            CatAbreBlc('', oBloco0, '0001', IIF(aContBloco[nCont] == '0' ,'1' ,'0' ),oTabela)
            CatEncBlc('', oBloco0, '0990', AllTrim(STR(Val( aContBloco[nCont] )+2)),oTabela)
            CatReg9900(oBloco0, '0001', '1') /*Registro 9900 da abertura do bloco*/
            CatReg9900(oBloco0, '0990', '1') /*Registro 9900 do encerramento do bloco*/
            nTotBloco9      += 2
            nTotArqTxt  += 4
            
        Case nCont   == 2
            
            /*BLOCO CINCO*/
            CatAbreBlc('', oBloco0, '5001', IIF(aContBloco[nCont] == '0' ,'1' ,'0' ),oTabela)
            CatEncBlc('', oBloco0, '5990', AllTrim(STR(Val( aContBloco[nCont] )+2)),oTabela)
            CatReg9900(oBloco0, '5001', '1') /*Registro 9900 da abertura do bloco*/
            CatReg9900(oBloco0, '5990', '1') /*Registro 9900 do encerramento do bloco*/
            nTotBloco9      += 2
            nTotArqTxt  += 4
        EndCase
    Next nCont
    
    /*Gera os �ltimos totalizadores do arquivo*/
    
    /*Contadores Bloco 9990*/
    /*Somo 7, pois falta considerar os registros 9001,9900, 9999 e os contadores 9901,9900,9990 e 9999*/
    nTotBloco9 += 7
    
    
    /*Abertura e encerramento do bloco 9*/
    CatAbreBlc('', oBloco0, '9001', '0',oTabela)
    CatEncBlc('', oBloco0, '9990', AllTrim(STR( nTotBloco9)),oTabela)
    
    /*Adiciona os registros 9001,9900,9900,9999 no*/
    CatReg9900(oBloco0, '9001', '1')
    CatReg9900(oBloco0, '9900', AllTrim(STR( nTotBloco9-3)))
    CatReg9900(oBloco0, '9990', '1')
    CatReg9900(oBloco0, '9999', '1')
    
    oTabela:GrvReg(oBloco0:get9900())
    
    /*Procesa �ltimo registro do arquivo.*/
    nTotArqTxt += 7
    CatEncBlc('', oBloco0, '9999', AllTrim(STR( nTotArqTxt)),oTabela)
    
RETURN


//-------------------------------------------------------------------
/*/{Protheus.doc} ContReg

Esta fun��o efetua a contagem dos registros por blocos - Considerados o Bloco 0 e Bloco 5

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function ContReg(oTabela)
    
    Local cAliasTRB	:= oTabela:GetAlias()
    Local aQtdReg		:= {} /*Quantidade por registro*/
    Local aQtdBloco	:= {} /*Quantidade por Bloco*/
    Local cCont0		:= 0
    Local cCont5		:= 0
    Local cBloco		:= ''
    
    (cAliasTRB)->(DBSetOrder(1))
    (cAliasTRB)->(DbGoTop ())
    
    /*Passa por todo arquivo tempor�rio*/
    Do While !(cAliasTRB)->(Eof ())
        /*VerIFica se o registro j� existe em aQtdREg, se n�o ir� incluir, caso contr�rio ir� incrementar contador*/
        IF (nPos := aScan (aQtdREg, {|aX| aX[1]==(cAliasTRB)->REGISTRO}))==0
            aAdd (aQtdREg, {(cAliasTRB)->REGISTRO,1})
        ELSE
            aQtdREg[nPos][2] += 1
        ENDIF
        
        cBloco	:= Left((cAliasTRB)->REGISTRO,1)
        
        /*Abaixo verifica de qual bloco registro pertence, para incrementar contador do bloco*/
        Do Case
        Case cBloco == '0'
            cCont0 ++
            
        Case cBloco == '5'
            cCont5 ++
        EndCAse
        
        (cAliasTRB)->(DbSkip ())
    EndDo
    
    /*Adiciona no aQtdBloco o total de contadores por bloco*/
    aAdd(aQtdBloco,AllTrim(Str(cCont0)))
    aAdd(aQtdBloco,AllTrim(Str(cCont5)))
    
    
RETURN {aQtdReg,aQtdBloco}


//-------------------------------------------------------------------
/*/{Protheus.doc} CatAbreBlc

Esta fun��o faz a abertura dos Blocos

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function CatAbreBlc(cChave, oAbertura, cReg, cIndMovto,oTabela)
    oAbertura:setRelac(cChave)
    Do case
    Case cReg == '0001'
        oTabela:GrvReg(oAbertura:Add0001(cIndMovto))
    Case cReg == '5001'
        oTabela:GrvReg(oAbertura:Add5001(cIndMovto))
    Case cReg == '9001'
        oTabela:GrvReg(oAbertura:Add9001(cIndMovto))
    EndCase
RETURN


//-------------------------------------------------------------------
/*/{Protheus.doc} CatEncBlc

Fun��o que faz o Encerramento dos Bloco

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function CatEncBlc(cChave, oEncerra, cReg, nQtd,otabela)
    oEncerra:setRelac(cChave)
    
    Do case
    Case cReg == '5990'
        oTabela:GrvReg(oEncerra:Add5990(nQtd))
    Case cReg == '0990'
        oTabela:GrvReg(oEncerra:Add0990(nQtd))
    Case cReg == '9990'
        oTabela:GrvReg(oEncerra:Add9990(nQtd))
    Case cReg == '9999'
        oTabela:GrvReg(oEncerra:Add9999(nQtd))
    EndCase
RETURN


//-------------------------------------------------------------------
/*/{Protheus.doc} SeqCat83

Fun��o que monta o Grupo do Registro

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Function SeqCat83(aGrupoReg, cGrupoPai, cReg)
    Local nPos      := 0
    Local cGrupoReg := ''
    
    nPos := aScan (aGrupoReg, {|aX| aX[1] == cReg })
    
    IF nPos > 0
        /*Se encontrar o registro ent�o ir� adicionar*/
        aGrupoReg[nPos][2] ++
    ELSE
        /*Caso contr�rio ir� incluir registro no controle*/
        aAdd(aGrupoReg, {})
        nPos := Len(aGrupoReg)
        aAdd (aGrupoReg[nPos], cReg)
        aAdd (aGrupoReg[nPos], 1)
    ENDIF
    
    /*Aqui processa o valor do grupo do registro, que ser� retornado para grava��o.*/
    cGrupoReg	:=Cat83GReg(cGrupoPai,cReg,aGrupoReg[nPos][2])
RETURN cGrupoReg



/*Fun��o que ir� gerar o grupo do registro, considerando o grupo do registro pai j� gerado, o registro e seu contador*/
Function Cat83GReg(cGrupoPai,cReg,nCont)
    Local cGrupo	:= ''
    
    cGrupo:=cGrupoPai+cReg+Strzero(nCont,9)
RETURN cGrupo


Static Function CatReg9900(oObj9900, cReg, cQtd)
    oObj9900:Add9900(cReg,cQtd)
RETURN


/*REGISTROS BLOCO 0*/
//-------------------------------------------------------------------
/*/{Protheus.doc} Reg0000

Fun��o que gera o Registro 0000

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function Reg0000 (oProcess, oBloco0, oTabela,aNumeracao,lCancel)
    
    
    Local	aReg0000	:= {}
    Local cFinal     := ""
    
    If !lAutomato
    	oProcess:Set2Progress(1)
    	oProcess:Inc2Progress('Processando Registro 0000 - Gerando Registro 1 de 1')
    EndIf
    
    IF MV_PAR04 == 1
        cFinal := "00"
    ELSEIF MV_PAR04 == 2
        cFinal := "01"
    ELSEIF MV_PAR04 == 3
        cFinal := "02"
    ELSEIF MV_PAR04 == 4
        cFinal := "03"
    ELSEIF MV_PAR04 == 5
        cFinal := "04"
    ENDIF
    
    
    /*Preenche Array com os dados do Registro 0000*/
    aAdd(aReg0000,"0000")								/*01-Texto Fixo Contendo "0000"*/
    aAdd(aReg0000,"LADCA")								/*02-Texto Fixo Contendo "LADCA"*/
    aAdd(aReg0000,ALLTRIM(MV_PAR03))					/*03-C�digo da Vers�o do Layout conforme tabela 3.1*/
    aAdd(aReg0000,cFinal)					          /*04-C�digo da Finalidade do arquivo*/
    aAdd(aReg0000,SubStr (DTOS(MV_PAR01), 5, 2)+SubStr (DTOS(MV_PAR01), 1, 4))	/*05-Per�odo das Informa��es contidas no arquivo*/
    aAdd(aReg0000, SM0->M0_NOMECOM)					/*06-Nome empresarial do estabelecimento informante*/
    aAdd(aReg0000,SM0->M0_CGC)							/*07-CNPJ do Estabelecimento Informante*/
    aAdd(aReg0000,SM0->M0_INSC)							/*07-CNPJ do Estabelecimento Informante*/
    aAdd(aReg0000,SM0->M0_CNAE)							/*07-CNPJ do Estabelecimento Informante*/
    aAdd(aReg0000,IIF (Upper(SM0->M0_ESTENT) == "EX","",IIF(Len(Alltrim(SM0->M0_CODMUN))<=5,UFCODIBGE(SM0->M0_ESTENT),"")+SM0->M0_CODMUN)) /*10-C�digo do Municipio do Estabelecimento Informante*/
    /*Este campo deve ser preenchido por Prestador de Servi�o de Transporte Rodoviario, responsabilidade do usu�rio preencher ou n�o na Wizard*/
    aAdd(aReg0000, ALLTRIM(MV_PAR07))					/*11-Op��o de Cr�dito Outorgado*/
    /*Este campos ser� preenchio quando o estabelecimenro gerador de cr�dito acumulado for intimado a entregar arquivo de custo de outro estabelecimento, responsabilidade do usu�rio preencher ou n�o na Wizard*/
    aAdd(aReg0000, ALLTRIM(MV_PAR08))					/*12-IE em caso de Intima��o*/
    oBloco0:setaNumer(aNumeracao)
    /*Fun��o para gravar Registro 0000*/
    Proc0000(oBloco0, aReg0000, oTabela)
    
    If !lAutomato
    	oProcess:Inc2Progress(' ')
    EndIf
    
RETURN


//-------------------------------------------------------------------
/*/{Protheus.doc} Proc0000

Fun��o para gravar Registro 0000, passando os dados do array para o Objeto

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function Proc0000(o0000, aReg0000, oTabela)
    o0000:setRelac()
    o0000:SetcReg(aReg0000[1])
    o0000:SetcLadca(aReg0000[2])
    o0000:SetcVersao(aReg0000[3])
    o0000:SetcFinalid(aReg0000[4])
    o0000:SetcPeriodo(aReg0000[5])
    o0000:SetcNome(aReg0000[6])
    o0000:SetnCNPJ(aReg0000[7])
    o0000:SetcIE(aReg0000[8])
    o0000:SetcCnae(aReg0000[9])
    o0000:SetsetUF(aReg0000[10])
    o0000:SetcCredOut(aReg0000[11])
    o0000:SetcIEIntim(aReg0000[12])
    oTabela:GrvReg(o0000:Add0000(aReg0000[1]))
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg0150

Fun��o para buscar dados do Registro 0150 - Cadastro de Participantes de opera��es e presta��es

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function Reg0150 (oProcess,oBloco0,oTabela, aNumeracao, cChavePai,dDataDe,dDataAte,lCancel)
    Local aReg0150	:= {}
    Local cAliasCLP	:= ""
    Local cChave		:= ''
    Local lExterior  := .F.
    Local nTot       := 0
    Local nQtd       := 0
    Local   nTamCli     :=  TAMSX3("A1_COD")[1]
    Local   nTamLoja    :=  TAMSX3("A1_LOJA")[1]
    Local   nTamIDPart	:= 1 + nTamCli + nTamLoja
    
    nTot:= Qtd0150(dDataDe, dDataAte)
    
	If !lAutomato
		oProcess:Set2Progress((nTot))
	EndIf

    cChave:= oBloco0:getGrupo()
    cAliasCLP	:=	GetNextAlias()
    
    BeginSql Alias cAliasCLP
        
        SELECT CLP_FILIAL,
        CLP_PERIOD,
        CLP_IDPART,
        CLP_FLPART,
        CLP_COD,
        CLP_LOJA,
        CLP_TPPART,
        CLP_CNPJ
        FROM 	%TABLE:CLP% CLP
        WHERE  CLP.CLP_FILIAL=%XFILIAL:CLP%
        AND CLP.CLP_PERIOD >= %EXP:dDataDe%
        AND CLP.CLP_PERIOD <=%EXP:dDataAte%
        AND CLP.%NOTDEL%
        ORDER BY CLP_FILIAL,CLP_PERIOD, CLP_IDPART
        
    EndSql
    DbSelectArea (cAliasCLP)
    
    Do While !(cAliasCLP)->(Eof ())
        
        nQtd++
        
        If !lAutomato
	        oProcess:Inc2Progress('Processando Registro 0150 - Processando ' +Alltrim(STR(nQtd)) + ' de ' +Alltrim(STR(nTot) ))
	        
	        If oProcess:Cancel()
	            ProcCancel(@lCancel,oTabela)
	            Return
	        EndIf
        EndIF
        
        aReg0150:= {}
        
        IF EMPTY((cAliasCLP)->CLP_CNPJ)
            SA1->(DbSetOrder(1))
            IF (SA1->(dbSeek(xFilial("SA1")+(cAliasCLP)->CLP_COD+(cAliasCLP)->CLP_LOJA))) .And. (cAliasCLP)->CLP_TPPART == "2"
                lExterior := SA1->A1_EST == "EX"
                aAdd(aReg0150,"0150")
                aAdd(aReg0150,(cAliasCLP)->CLP_IDPART)
                aAdd(aReg0150,SA1->A1_NOME)
                aAdd(aReg0150,SA1->A1_CODPAIS)
                aAdd(aReg0150,IIF(lExterior,"",StrZero(Val (SA1->A1_CGC), 14)))
                aAdd(aReg0150,IIF(lExterior,"",SPEDConType(SPEDVldIE(SA1->A1_INSCR))))
                aAdd(aReg0150,IIF(lExterior,"",SA1->A1_EST))
                aAdd(aReg0150,IIF(lExterior,"",SA1->A1_CEP))
                aAdd(aReg0150,IIF(lExterior,"",ALLTRIM(FisGetEnd(SA1->A1_END)[1])))
                aAdd(aReg0150,IIF(lExterior,"",ALLTRIM(FisGetEnd(SA1->A1_END)[3])))
                aAdd(aReg0150,IIF(lExterior,"",ALLTRIM(FisGetEnd(SA1->A1_END)[4])))
                aAdd(aReg0150,IIF(lExterior,"",SA1->A1_BAIRRO))
                aAdd(aReg0150,IIF(lExterior,"",ALLTRIM(UfCodIBGE(SA1->A1_EST)+SA1->A1_COD_MUN) ))
                aAdd(aReg0150,IIF(lExterior,"",SA1->A1_TEL))
            ELSE
                SA2->(DbSetOrder(1))
                IF (SA2->(dbSeek(xFilial("SA2")+(cAliasCLP)->CLP_COD+(cAliasCLP)->CLP_LOJA)))
                    lExterior := SA2->A2_EST == "EX"
                    aAdd(aReg0150,"0150")
                    aAdd(aReg0150,(cAliasCLP)->CLP_IDPART)
                    aAdd(aReg0150,SA2->A2_NOME)
                    aAdd(aReg0150,SA2->A2_CODPAIS)
                    aAdd(aReg0150,IIF(lExterior,"",StrZero (Val (SA2->A2_CGC), 14)))
                    aAdd(aReg0150,IIF(lExterior,"",SPEDConType(SPEDVldIE(SA2->A2_INSCR))))
                    aAdd(aReg0150,IIF(lExterior,"",SA2->A2_EST))
                    aAdd(aReg0150,IIF(lExterior,"",SA2->A2_CEP))
                    aAdd(aReg0150,IIF(lExterior,"",ALLTRIM(FisGetEnd(SA2->A2_END)[1])))
                    aAdd(aReg0150,IIF(lExterior,"",ALLTRIM(FisGetEnd(SA2->A2_END)[3])))
                    aAdd(aReg0150,IIF(lExterior,"",ALLTRIM(FisGetEnd(SA2->A2_END)[4])))
                    aAdd(aReg0150,IIF(lExterior,"",SA2->A2_BAIRRO))
                    aAdd(aReg0150,IIF(lExterior,"",ALLTRIM(UfCodIBGE(SA2->A2_EST)+SA2->A2_COD_MUN)))
                    aAdd(aReg0150,IIF(lExterior,"",SA2->A2_TEL))
                EndIf
            EndIf
        ELSE
            SA1->(DbSetOrder(3))
            IF (SA1->(dbSeek(xFilial("SA1")+(cAliasCLP)->CLP_CNPJ))) .And. (cAliasCLP)->CLP_TPPART == "2"
                lExterior := SA1->A1_EST == "EX"
                aAdd(aReg0150,"0150")
                aAdd(aReg0150,(cAliasCLP)->CLP_CNPJ)
                aAdd(aReg0150,SA1->A1_NOME)
                aAdd(aReg0150,SA1->A1_CODPAIS)
                aAdd(aReg0150,IIF(lExterior,"",StrZero(Val (SA1->A1_CGC), 14)))
                aAdd(aReg0150,IIF(lExterior,"",SPEDConType(SPEDVldIE(SA1->A1_INSCR))))
                aAdd(aReg0150,IIF(lExterior,"",SA1->A1_EST))
                aAdd(aReg0150,IIF(lExterior,"",SA1->A1_CEP))
                aAdd(aReg0150,IIF(lExterior,"",ALLTRIM(FisGetEnd(SA1->A1_END)[1])))
                aAdd(aReg0150,IIF(lExterior,"",ALLTRIM(FisGetEnd(SA1->A1_END)[3])))
                aAdd(aReg0150,IIF(lExterior,"",ALLTRIM(FisGetEnd(SA1->A1_END)[4])))
                aAdd(aReg0150,IIF(lExterior,"",SA1->A1_BAIRRO))
                aAdd(aReg0150,IIF(lExterior,"",ALLTRIM(UfCodIBGE(SA1->A1_EST)+SA1->A1_COD_MUN) ))
                aAdd(aReg0150,IIF(lExterior,"",SA1->A1_TEL))
            ELSE
                SA2->(DbSetOrder(3))
                IF (SA2->(dbSeek(xFilial("SA2")+(cAliasCLP)->CLP_CNPJ))) .And. (cAliasCLP)->CLP_TPPART == "1"
                    lExterior := SA2->A2_EST == "EX"
                    aAdd(aReg0150,"0150")
                    aAdd(aReg0150,(cAliasCLP)->CLP_CNPJ)
                    aAdd(aReg0150,SA2->A2_NOME)
                    aAdd(aReg0150,SA2->A2_CODPAIS)
                    aAdd(aReg0150,IIF(lExterior,"",StrZero (Val (SA2->A2_CGC), 14)))
                    aAdd(aReg0150,IIF(lExterior,"",SPEDConType(SPEDVldIE(SA2->A2_INSCR))))
                    aAdd(aReg0150,IIF(lExterior,"",SA2->A2_EST))
                    aAdd(aReg0150,IIF(lExterior,"",SA2->A2_CEP))
                    aAdd(aReg0150,IIF(lExterior,"",ALLTRIM(FisGetEnd(SA2->A2_END)[1])))
                    aAdd(aReg0150,IIF(lExterior,"",ALLTRIM(FisGetEnd(SA2->A2_END)[3])))
                    aAdd(aReg0150,IIF(lExterior,"",ALLTRIM(FisGetEnd(SA2->A2_END)[4])))
                    aAdd(aReg0150,IIF(lExterior,"",SA2->A2_BAIRRO))
                    aAdd(aReg0150,IIF(lExterior,"",ALLTRIM(UfCodIBGE(SA2->A2_EST)+SA2->A2_COD_MUN)))
                    aAdd(aReg0150,IIF(lExterior,"",SA2->A2_TEL))
                EndIf
                
            EndIf
        ENDIF
        oBloco0:setaNumer(aNumeracao)
        IF Len(aReg0150) > 0
            Proc0150(oBloco0,oTabela, aReg0150, cChavePai)
        Endif
        (cAliasCLP)->(DbSkip())
    EndDo
    (cAliasCLP)->(DbCloseArea())
	
	If !lAutomato
		oProcess:Inc2Progress(' ')
	EndIf

RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc0150

Fun��o para gravar Registro 0150, passando os dados do array para o Objeto

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function Proc0150(o0150, oTabela,aReg0150,cChavePai)
    o0150:setRelac(cChavePai)
    o0150:SetcReg(aReg0150[1])
    o0150:SetcCodPar(aReg0150[2])
    o0150:SetcNome(aReg0150[3])
    o0150:SetnPais(aReg0150[4])
    o0150:SetnCNPJ(aReg0150[5])
    o0150:SetcIE(aReg0150[6])
    o0150:SetcUF(aReg0150[7])
    o0150:SetnCep(aReg0150[8])
    o0150:SetcEnd(aReg0150[9])
    o0150:SetcNum(aReg0150[10])
    o0150:SetcComp(aReg0150[11])
    o0150:SetcBairro(aReg0150[12])
    o0150:SetnCodMun(aReg0150[13])
    o0150:SetnFone(aReg0150[14])
    oTabela:GrvReg(o0150:Add0150(aReg0150[1]))
    o0150:Clear(aReg0150[1])
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg0200

Fun��o para buscar dados do Registro 0200 - IdentIFica��o do Item

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function Reg0200 (oProcess,oBloco0,oTabela, aNumeracao, cChavePai, dDataDe,dDataAte,lCancel)
    Local cAliasSB1	:= ""
    Local aReg0200	:= {}
    Local lHistTab	:= SuperGetMv("MV_HISTTAB",,.F.) .And. AliasIndic("AIF")
    Local nDPcat83   := SuperGetMv("MV_DPCAT83",,0)
    Local cDescr     := ""
    Local nTot       := 0
    Local nQtd       := 0
    
    nTot:= Qtd0200(dDataDe, dDataAte, MV_PAR11)
    
    If !lAutomato
    	oProcess:Set2Progress(nTot)
    EndIf
    
    cSelect := "DISTINCT SB1.B1_FILIAL,SB1.B1_COD, SB1.B1_DESC, SB1.B1_UM, SB1.B1_POSIPI, SB1.B1_CODANT, SB1.B1_DATREF "
    cWhere  := "SB1.B1_FILIAL ='"+xFilial("SB1")+"' AND "
    
    IF MV_PAR11 == 1
        cJoin   := "LEFT JOIN "  +RetSqlName("F04")+" F04 ON( F04.F04_PROD = SB1.B1_COD AND F04.F04_FILIAL='"+xFilial("F04")+"'AND "
        cJoin   += "F04.F04_PERIOD >='"+dDataDe+"' AND F04.F04_PERIOD <='"+dDataAte+"' AND F04.D_E_L_E_T_ = ' ' )  "
    ELSE
        cJoin   := "JOIN "  +RetSqlName("F04")+" F04 ON( F04.F04_PROD = SB1.B1_COD AND F04.F04_FILIAL='"+xFilial("F04")+"'AND "
        cJoin   += "F04.F04_PERIOD >='"+dDataDe+"' AND F04.F04_PERIOD <='"+dDataAte+"' AND F04.D_E_L_E_T_ = ' ' )  "
    ENDIF
    
    cOrder  := " ORDER BY SB1.B1_FILIAL,SB1.B1_COD"
    
    cSelect := '%'+cSelect+'%'
    cWhere  := '%'+cWhere+'%'
    cJoin   := '%'+cJoin+'%'
    cOrder  := '%'+cOrder+'%'
    
    cAliasSB1	:=	GetNextAlias()
    
    BeginSql Alias cAliasSB1
        
        
        SELECT
        %Exp:cSelect%
        
        FROM
        %Table:SB1% SB1
        %Exp:cJoin%
        WHERE
        %Exp:cWhere%
        SB1.%NotDel%
        %Exp:cOrder%
        
        
    EndSql
    DbSelectArea (cAliasSB1)
    
    Do While !(cAliasSB1)->(Eof ())
        nQtd++
        
		 If !lAutomato
			 oProcess:Inc2Progress('Processando Registro 0200 - Processando ' +Alltrim(STR(nQtd)) + ' de ' +Alltrim(STR(nTot) ))
			
			 If oProcess:Cancel()
				 ProcCancel(@lCancel,oTabela)
				 Return
			 EndIf
			
		 EndIF

        IF nDPcat83 == 0
            cDescr := (cAliasSB1)->B1_DESC
        ElseIf nDPcat83 == 1
            cDescr := Alltrim((cAliasSB1)->B1_COD) + " " + Alltrim((cAliasSB1)->B1_DESC)
        ElseIf nDPcat83 == 2
            cDescr :=   Alltrim((cAliasSB1)->B1_DESC) + " " + Alltrim((cAliasSB1)->B1_COD)
        Endif
        
        aReg0200:= {}
        aAdd(aReg0200,"0200")
        aAdd(aReg0200,(cAliasSB1)->B1_COD)
        aAdd(aReg0200, Alltrim(cDescr))
        aAdd(aReg0200,(cAliasSB1)->B1_UM)
        aAdd(aReg0200,Left((cAliasSB1)->B1_POSIPI,2))
        
        oBloco0:setaNumer(aNumeracao)
        Proc0200(oBloco0, oTabela, aReg0200 , cChavePai)
        
        /*N�o gerar por enquanto, pois � altera��o de c�digo de produto e no protheus n�o pode alterar o c�digo
        IF lHistTab
        cChave0200:= oBloco0:getGrupo()
        Reg0205(oBloco0,oTabela, aNumeracao, cChave0200,(cAliasSB1)->B1_COD, (cAliasSB1)->B1_CODANT,(cAliasSB1)->B1_DATREF, (cAliasSB1)->B1_CODANT, dDataDe,dDataAte)
        ENDIF*/
    
    (cAliasSB1)->(DbSkip())
EndDo
(cAliasSB1)->(DbCloseArea())

If !lAutomato
	oProcess:Inc2Progress(' ')
EndIf

RETURN


//-------------------------------------------------------------------
/*/{Protheus.doc} Proc0200
 
Fun��o para gravar Registro 0200, passando os dados do array para o Objeto
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function Proc0200(o0200,oTabela,aReg0200,cChavePai)
    o0200:setRelac(cChavePai)
    o0200:SetcReg(aReg0200[1])
    o0200:SetcCodItem(aReg0200[2])
    o0200:SetcDescItem(aReg0200[3])
    o0200:SetcUn(aReg0200[4])
    o0200:SetcCodGen(aReg0200[5])
    oTabela:GrvReg(o0200:Add0200(aReg0200[1]))
    o0200:Clear(aReg0200[1])
    
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg0205

Fun��o para buscar dados do Registro 0205 - IdentIFica��o do Item

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function Reg0205(oBloco0,oTabela,aNumeracao,cChave0200,cProd,cCodAnt,dDtRef,cCodAnt,dDataDe,dDataAte)
    Local aReg0205	:= {}
    Local aHist := MsConHist("SB1","","",SToD(dDataDe),SToD(dDataAte),Substr(cProd,1,TamSx3("B1_COD")[1]))
    Local	nX			:=	0
    
    /*VerIFica se a fun��o retornou informa��es*/
    IF Len(aHist) > 0
        /*Exclui alteracoes de "B1_DESC" que sejam do mesmo dia com horarios menores, deixa a ultima*/
        nY := 1
        While nY <= Len(aHist)
            For nX := 1 To Len(aHist)
                IF Len(aHist)>1 .And. nX<=Len(aHist)
                    IF nX > 1 .And. nX<Len(aHist)
                        IF (aHist[nX][3]=aHist[nX-1][3]) .And. (aHist[nX][4]>=aHist[nX-1][4])
                            aDel(aHist, nX-1)
                            aSize(aHist, Len(aHist) - 1)
                            nX := 0
                        ELSEIF (aHist[nX][3]=aHist[nX+1][3]) .And. (aHist[nX][4]<=aHist[nX+1][4])
                            aDel(aHist, nX+1)
                            aSize(aHist, Len(aHist) - 1)
                            nX := 0
                        ENDIF
                    ELSEIF nX > 1 .And. nX=Len(aHist)
                        IF (aHist[nX][3]=aHist[nX-1][3]) .And. (aHist[nX][4]>=aHist[nX-1][4])
                            aDel(aHist, nX-1)
                            aSize(aHist, Len(aHist) - 1)
                            nX := 0
                        ENDIF
                    ENDIF
                ELSE
                    Exit
                ENDIF
            Next nX
            nY++
        Enddo
        //Passando para um array auxiliar os arrays que s�o do campo B1_DESC, para ordenar corretamente por DATA e HORA de altera��o
        For nX := 1 To Len(aHist)
            //Atribuindo a variavel cDescProd o valor da 'DESCRI��O ANTERIOR DO PRODUTO' da ultima altera��o
            cDescProd := aHist[nX][2]
            
            //Atribuindo a ultima data de altera��o a variavel dDataFinal
            dDataFinal := aHist[nX][3]-1
            IF nX==1
                
                dDataInici := dDtRef
                
                IF Empty(dDataInici)
                    dDataInici := aHist[nX][3]
                ENDIF
            ELSE
                //Atribuindo a penultima data de altera��o a variavel dDataInici independente se houve alteracao ou n�o no mesmo dia
                dDataInici := aHist[nX-1][3]
                
                //Este tratamento abaixo foi efetuado para tratar alteracoes de produto validas por um dia
                //Neste caso, leva a data fim como sendo a data contida no historico
                //Devido a restricoes no layout
                IF nX = Len(aHist) .And. dDataFinal = dDataInici
                    dDataFinal := aHist[nX][3]
                ENDIF
            ENDIF
            
            IF dDataFinal <= Stod(dDataAte) .And. Alltrim(aHist[nX][1])$"B1_DESC"
                IF Stod(dDataInici) < dDataFinal
                    aAdd(aReg0205,"0205")
                    aAdd(aReg0205,IIF(Empty(cCodAnt), cProd, cCodAnt))
                    aAdd(aReg0205,cDescProd)
                    aAdd(aReg0205,StrZero(Month(Stod(dDataInici)),2) + StrZero(Year(Stod(dDataInici)),4))
                    aAdd(aReg0205,StrZero(Month(dDataFinal),2) + StrZero(Year(dDataFinal),4) )
                    oBloco0:setaNumer(aNumeracao)
                    Proc0205(oBloco0, oTabela, aReg0205,cChave0200 )
                    
                    
                ENDIF
            ENDIF
        Next nX
    ENDIF
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc0205

Fun��o para gravar Registro 0205, passando os dados do array para o Objeto

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function Proc0205(o0205, oTabela, aReg0205, cChave0200)
    
    o0205:setRelac(cChave0200)
    o0205:SetcReg(aReg0205[1])
    o0205:SetcCodAnt(aReg0205[2])
    o0205:SetcDescAnt(aReg0205[3])
    o0205:SetcPEIni(aReg0205[4])
    o0205:SetcPEFim(aReg0205[5])
    oTabela:GrvReg(o0205:Add0205(aReg0205[1]))
    o0205:Clear(aReg0205[1])
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg0300

Fun��o para buscar dados do Registro 0300 - IdentIFica��o do Item

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function Reg0300 (oProcess,oBloco0,oTabela,aNumeracao,cChave0001,dDataDe,dDataAte,lCancel)
    Local cAliasCCV := ""
    Local aReg0300  := {}
    Local nTot       := 0
    Local nQtd       := 0
    
    nTot:= Qtd0300(dDataDe, dDataAte)
    
	 If !lAutomato
		oProcess:Set2Progress((nTot))
	 EndIf

    cAliasCCV	:=	GetNextAlias()
    
    BeginSql Alias cAliasCCV
        
        SELECT DISTINCT CCV.CCV_FILIAL,
        CCV.CCV_CODLEG,
        CCV.CCV_CODDES,
        CCV.CCV_ANEXO,
        CCV.CCV_ARTIG,
        CCV.CCV_INCIS,
        CCV.CCV_ALIN,
        CCV.CCV_PARAG,
        CCV.CCV_ITEM,
        CCV.CCV_LETRA,
        CCV.CCV_OBSER
        FROM   %TABLE:CCV% CCV
        INNER JOIN %TABLE:CLR% CLR ON(CCV.CCV_CODLEG = CLR.CLR_ENQLEG
        AND CCV.%NOTDEL%
        AND CCV.CCV_FILIAL=%XFILIAL:CCV%)
        WHERE CLR.CLR_FILIAL=%XFILIAL:CLR%
        AND CLR.%NOTDEL%
        AND CLR.CLR_PERIOD >= %EXP:dDataDe%
        AND CLR.CLR_PERIOD <= %EXP:dDataAte%
        ORDER BY
        CCV.CCV_FILIAL,
        CCV.CCV_CODLEG
        
    EndSql
    DbSelectArea (cAliasCCV)
    
    
    Do While !(cAliasCCV)->(Eof ())
        nQtd++
        
        If !lAutomato
	        oProcess:Set2Progress(nQtd)
	        oProcess:Inc2Progress('Processando Registro 0300 - Processando ' +Alltrim(STR(nQtd)) + ' de ' +Alltrim(STR(nTot) ))
	        
	        If oProcess:Cancel()
	            ProcCancel(@lCancel,oTabela)
	            Return
	        EndIf
        EndIF
        
        aReg0300:= {}
        aAdd(aReg0300,"0300")
        aAdd(aReg0300,(cAliasCCV)->CCV_CODLEG)
        aAdd(aReg0300,(cAliasCCV)->CCV_CODDES)
        aAdd(aReg0300,(cAliasCCV)->CCV_ANEXO)
        aAdd(aReg0300,(cAliasCCV)->CCV_ARTIG)
        aAdd(aReg0300,(cAliasCCV)->CCV_INCIS)
        aAdd(aReg0300,(cAliasCCV)->CCV_ALIN)
        aAdd(aReg0300,(cAliasCCV)->CCV_PARAG)
        aAdd(aReg0300,(cAliasCCV)->CCV_ITEM)
        aAdd(aReg0300,(cAliasCCV)->CCV_LETRA)
        aAdd(aReg0300,(cAliasCCV)->CCV_OBSER)
        oBloco0:setaNumer(aNumeracao)
        Proc0300(oBloco0, oTabela, aReg0300,cChave0001 )
        (cAliasCCV)->(DbSkip())
    EndDo
    (cAliasCCV)->(DbCloseArea())
    
    If !lAutomato
    	oProcess:Inc2Progress(' ')
    EndIf

RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc0300

Fun��o para gravar Registro 0300, passando os dados do array para o Objeto

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function Proc0300(o0300,oTabela,aReg0300,cChave0001)
    o0300:setRelac(cChave0001)
    o0300:SetcReg(aReg0300[1])
    o0300:SetnCodLeg(aReg0300[2])
    o0300:SetnDesc(aReg0300[3])
    o0300:SetcAnex(aReg0300[4])
    o0300:SetcArt(aReg0300[5])
    o0300:SetcInc(aReg0300[6])
    o0300:SetcAlin(aReg0300[7])
    o0300:SetcPrg(aReg0300[8])
    o0300:SetcItm(aReg0300[9])
    o0300:SetcLtr(aReg0300[10])
    o0300:SetcObs(aReg0300[11])
    oTabela:GrvReg(o0300:Add0300(aReg0300[1]))
    o0300:Clear(aReg0300[1])
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg0400

Fun��o para buscar dados do Registro 0400 - IdentIFica��o do Item

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function Reg0400 (oProcess,oBloco0,oTabela,aNumeracao,cChave0001,dDataDe,dDataAte,lCancel)
    
    Local cAliasCLZ := ""
    Local aReg0400      := {}
    Local nTot       := 0
    Local nQtd       := 0
    Local nCont         := 0
    
    nTot := Qtd0400(dDataDe, dDataAte)
    
	 If !lAutomato
		oProcess:Set2Progress((nTot))
	 EndIF

    cAliasCLZ     :=    GetNextAlias()
    
    BeginSql Alias cAliasCLZ
        
        SELECT DISTINCT CLZ.CLZ_FILIAL,
        CLZ.CLZ_CODIGO,
        CLZ.CLZ_DESC,
        CLZ.CLZ_TM,
        CLZ.CLZ_CF
        FROM %TABLE:CLZ% CLZ
        INNER JOIN %TABLE:CLR% CLR ON(CLZ.CLZ_CODIGO = CLR.CLR_TPDOC
        AND CLZ.CLZ_FILIAL=%XFILIAL:CLZ%
        AND CLZ.%NOTDEL%)
        WHERE CLR.CLR_FILIAL=%XFILIAL:CLR%
        AND CLR.%NOTDEL%
        AND CLR.CLR_PERIOD >= %EXP:dDataDe%
        AND CLR.CLR_PERIOD <= %EXP:dDataAte%
        ORDER BY
        CLZ.CLZ_FILIAL,
        CLZ.CLZ_CODIGO,
        CLZ.CLZ_DESC,
        CLZ.CLZ_TM,
        CLZ.CLZ_CF
        
    EndSql
    DbSelectArea (cAliasCLZ)
    
    
    Do While !(cAliasCLZ)->(Eof ())
        nQtd++
        
        If !lAutomato
	        oProcess:Set2Progress(nQtd)
	        oProcess:Inc2Progress('Processando Registro 0400 - Processando ' +Alltrim(STR(nQtd)) + ' de ' +Alltrim(STR(nTot) ))
	        
	        If oProcess:Cancel()
	            ProcCancel(@lCancel,oTabela)
	            Return
	        EndIf
        EndIf
        
        aReg0400:= {}
        aAdd(aReg0400,"0400")
        aAdd(aReg0400,(cAliasCLZ)->CLZ_CODIGO)
        aAdd(aReg0400,(cAliasCLZ)->CLZ_DESC)
        aAdd(aReg0400,"")

        oBloco0:setaNumer(aNumeracao)
        Proc0400(oBloco0, oTabela, aReg0400,cChave0001 )

        (cAliasCLZ)->(DbSkip())
    EndDo
    (cAliasCLZ)->(DbCloseArea())

    If !lAutomato
    	oProcess:Inc2Progress(' ')
    EndIF
    
RETURN


/*/{Protheus.doc} Proc0400

Fun��o para gravar Registro 0400, passando os dados do array para o Objeto

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function Proc0400(o0400,oTabela,aReg0400,cChave0001)
    o0400:setRelac(cChave0001)
    o0400:SetcReg(aReg0400[1])
    o0400:SetcChave(aReg0400[2])
    o0400:SetcDescr(aReg0400[3])
    o0400:SetcCodDoc(aReg0400[4])
    oTabela:GrvReg(o0400:Add0400(aReg0400[1]))
    o0400:Clear(aReg0400[1])
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} Processa
 
Fun��o para buscar os registros do Bloco 5 - Todas as movimenta��es
            
@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------

Static Function Processa(oProcess, oBloco5,oTabela,aNumeracao,cChaveBlc5,dDataDe,dDataAte,lCancel )
    
    Local cAlias        := ""
    /*Declara��o das variaveis que ir�o guardar o registro*/
    Local cRegist       := ""
    Local cRegistAp     := ""
    Local cRegAlcCus    := ""
    Local cRegInvent    := ""
    Local cRegistDev    := ""
    Local cRegistIPI    := ""
    Local cRegCredAc    := ""
    Local cReg6A6B      := ""
    Local cReg6C6D      := ""
    Local cRegExpInd    := ""
    Local cNGerCred     := ""
    /*Declara��o dos arrays de cada registro*/
    Local aReg          := {} /*Array Auxiliar*/
    Local aRegAbert     := {}
    Local aRegApur      := {}
    Local aApur         := {}
    Local aAlocCust     := {}
    Local a5235         := {}
    Local aInvent       := {}
    Local aRegMov       := {}
    Local aDevSai       := {}
    Local aRegIpiOut    := {}
    Local aCredAcu      := {}
    Local a6A6B         := {}
    Local a6C6D         := {}
    Local aExpInd       := {}
    Local aNGerCred     := {}
    Local aServTran     := {}
    Local aVeicul       := {}
    /*Declara��o das variaveis que ir�o guardar a chave de cada registro*/
    Local cChvAb        := ""
    Local cChvApur      := ""
    Local cChvInven     := ""
    Local cChvMov       := ""
    Local cChvDevSai    := ""
    Local cChvIPIOut    := ""
    Local cChv6ABCD     := ""
    /*Variaveis auxiliares*/
    Local nPos          := 0
    Local nPosAb        := 0
    Local nPos2         := 0
    Local nTot          := 0
    Local nQtd          := 0
    Local nX            := 0
    Local lDevSai       := .F.
    Local cBusca        := ""
    Local aTeste        := {}
    Local lFimper       := Month(MV_PAR01) == 12 .and. Month(MV_PAR02) == 12
    //---Vari�veis para controle de HashMaps---//
    Local cNew          := "HMNew()"
    Local cChvRegAb     := ''
    Local cChvRegist    := ''
    Private oRegAbert   := Nil
    Private oRegistro   := Nil
    Private lBuild    	:= GetBuild() >= "7.00.131227A"

    If lBuild
        oRegAbert := &cNew
        oRegistro := &cNew
    EndIf
    
    /*Gera registros de abertura*/
    aRegAbert := ProcAbert(oProcess, dDataDe,dDataAte)
    /*Gera registros de apura��o*/
    aRegApur  := ProcApur(oProcess, dDataDe,dDataAte)
    /* Gera registro 5235*/
    aAlocCust := PrcAlcCust(oProcess, dDataDe,dDataAte)
    
    /*Gera o Registro de Invent�rio*/
    IF MV_PAR10 == 1 .Or. lFimper
        ProInvent(oProcess,oBloco5,oTabela,dDataDe,dDataAte,lFimper)
    ENDIF
    
    nTot:= QtdRegMov(dDataDe,dDataAte)
    
    If !lAutomato
    	oProcess:Set2Progress((nTot))
    EndIf
    
    cAlias	:=	GetNextAlias()
    
    BeginSql Alias cAlias
        
        COLUMN CLQ_DATA AS DATE
        
        SELECT   F04.F04_FILIAL,
        F04.F04_PERIOD,
        F04.F04_PROD,
        F04.F04_FICHA,
        F04.F04_FATORI,
        F04.F04_FATORC,
        F04.F04_QTDE,
        CLQ.CLQ_DATA,
        CLQ.CLQ_TPDOC,
        CLQ.CLQ_SERIE,
        CLQ.CLQ_NRDOC,
        CLQ.CLQ_CFOP,
        CLQ.CLQ_TPMOV,
        CLQ.CLQ_DTORI,
        CLQ.CLQ_TPDCOR,
        CLQ.CLQ_SERORI,
        CLQ.CLQ_DOCORI,
        CLR.CLR_TPMOV,
        CLR.CLR_FICHA,
        CLR.CLR_PART,
        CLR.CLR_NRLAN,
        CLR.CLR_CODLAN,
        CLR.CLR_PERIOD,
        CLR.CLR_HIST,
        CLR.CLR_NRDI,
        CLR.CLR_PROD,
        CLR.CLR_PRDMOV,
        CLR.CLR_CODREM,
        CLR.CLR_CODDST,
        CLR.CLR_UFINI,
        CLR.CLR_UFDST,
        CLR.CLR_UNID,
        CLR.CLR_ENQLEG,
        CLR.CLR_COMOPE,
        CLR.CLR_VEICUL,
        CLR.CLR_KM,
        CLR.CLR_ENQLEG,
        CLR.CLR_INDRAT,
        CLR.CLR_NRORD,
        CLR.CLR_TPDOC,
        CLR.CLR_QTDE,
        CLR.CLR_CUSTO,
        CLR.CLR_ICMS,
        CLR.CLR_PERRAT,
        CLR.CLR_IPI,
        CLR.CLR_OUTROS,
        CLR.CLR_ALIQ,
        CLR.CLR_PCROUT,
        CLR.CLR_VCROUT,
        CLR.CLR_VCRDSP,
        CLR.CLR_VALBC,
        CLR.CLR_ICMDEB,
        CLR.CLR_ICMSDE,
        CLR.CLR_VPRENG,
        CLR.CLR_ICMDEB,
        CLR.CLR_VPREGE,
        CLR.CLR_ICMST,
        CLR.CLR_VCROUT,
        CLR.CLR_CROUST,
        CLR.CLR_CREDAC,
        CLR.CLR_ICMSDE,
        CLR.CLR_UCUSTO,
        CLR.CLR_UICMS,
        CLR.CLR_SAIDA,
        CLR.CLR_CODORI,
        CLR.CLR_DESPAC,
        CLR.CLR_EXPIND,
        CLX.CLX_PERIOD,
        CLX.CLX_CODVCL,
        CLX.CLX_PLACA,
        CLX.CLX_CNPJ,
        CLX.CLX_UF,
        CLX.CLX_MUN,
        CLX.CLX_RENAV,
        CLX.CLX_MARCA,
        CLX.CLX_MOD,
        CLX.CLX_ANO,
        CLX.CLX_RCOMB,
        CLW.CLW_PERIOD,
        CLW.CLW_PROD,
        CLW.CLW_NRLAN,
        CLW.CLW_NRDOC,
        CLW.CLW_SERIE,
        CLW.CLW_DTDCEX,
        CLW.CLW_NRDCEX,
        CLW.CLW_SRDCEX,
        CLW.CLW_NRDESP
        FROM       %TABLE:CLR% CLR
        LEFT JOIN %TABLE:CLQ% CLQ ON ( CLQ.CLQ_IDNF = CLR.CLR_IDNF
        AND CLQ.CLQ_FILIAL= %XFILIAL:CLQ%
        AND CLQ.%NOTDEL%
        AND CLQ.CLQ_DATA >= %EXP:DDATADE%
        AND CLQ.CLQ_DATA <= %EXP:DDATAATE%)
        INNER JOIN %TABLE:F04% F04 ON (F04.F04_ID = CLR.CLR_IDCAB
        AND F04.F04_FICHA = CLR.CLR_FICHA
        AND F04.F04_FILIAL = %XFILIAL:F04%
        AND F04.%NOTDEL%
        AND F04.F04_PERIOD >= %EXP:DDATADE%
        AND F04.F04_PERIOD <= %EXP:DDATAATE%)
        LEFT  JOIN %TABLE:CLW% CLW ON(CLW.CLW_FILIAL = %XFILIAL:CLW% AND CLW.CLW_NRLAN = CLR.CLR_NRLAN AND CLW.%NOTDEL%)
        LEFT  JOIN %TABLE:CLX% CLX ON(CLX.CLX_FILIAL = %XFILIAL:CLX% AND CLX.CLX_CODVCL = CLR.CLR_VEICUL AND CLX.%NOTDEL%)
        WHERE  CLR.CLR_FILIAL=%XFILIAL:CLR%
        AND CLR.%NOTDEL%
        AND CLR.CLR_PERIOD >= %EXP:DDATADE%
        AND CLR.CLR_PERIOD <= %EXP:DDATAATE%
        ORDER BY  CLR.CLR_PERIOD,CLR.CLR_NRLAN, CLR.CLR_FICHA
        
    EndSql
    DbSelectArea (cAlias)
    
    Do While !(cAlias)->(Eof ())
        nQtd++
        
		 If !lAutomato
			 oProcess:Inc2Progress('Processando Movimenta��es - Processando ' +Alltrim(STR(nQtd)) + ' de ' +Alltrim(STR(nTot) ))
			
			 If oProcess:Cancel()
				 ProcCancel(@lCancel,oTabela)
				 Return
			 EndIf
		 EndIf
   
        lDevSai     := ((cAlias)->CLR_TPMOV $ "G|Z" .And. SUBSTR((cAlias)->CLR_CODLAN,3,2)$'31|32|33')
        
        aInvent     := {}
        aRegMov     := {}
        aCredAcu    := {}
        aRegMov     := {}
        aDevSai     := {}
        aRegIpiOut  := {}
        a6A6B       := {}
        a6C6D       := {}
        aExpInd     := {}
        aNGerCred   := {}
        aServTran   := {}
        aVeicul     := {}
        /*Registros de Abertura*/
        IF !(cAlias)->CLR_FICHA$"67|68"
            
            cRegist := CodFicha((cAlias)->CLR_FICHA, "1")
            
            If lBuild
                cChvRegAb := (cAlias)->CLR_FICHA + (cAlias)->F04_PROD
                nPosAb    := FisFindHash(oRegAbert, cChvRegAb)
            Else
                nPosAb    := aScan(aRegAbert,{|X| X[2] == (cAlias)->CLR_FICHA .AND. X[3] == (cAlias)->F04_PROD})
            EndIf

            // Verifica se o cRegist foi preenchido e se existe no array de abertura
            IF !Empty(cRegist) .And. nPosAb > 0
                
                //Verifica se os dados ja existe no array
                If lBuild
                    cChvRegist := (cAlias)->CLR_FICHA + (cAlias)->F04_PROD
                    cCont      := FisFindHash(oRegistro, cChvRegist)
                Else
                    cCont      := aScan(aReg,{|X| X[2] == (cAlias)->CLR_FICHA .AND. X[3] == (cAlias)->F04_PROD})
                EndIf

                IF cCont == 0
                    //Adiciona as informa��es no Novo Array
                    aAdd(aReg,{})
                    nPos := Len (aReg)
                    aReg[nPos]:= aRegAbert[nPosAb]
                    oBloco5:setaNumer(aNumeracao)
                    //Atualiza o registro
                    aReg[nPos][1] :=  cRegist
                    
                    ProcObjAb(oBloco5, oTabela, aReg[nPos],cChaveBlc5, cRegist)
                    cChvAb:= oBloco5:getGrupo()
                    //Adiciono a chave no array, � necess�rio pois nas movimenta��es preciso saber qual � o registro pai correto
                    aAdd(aReg[nPos],cChvAb)

                    If lBuild
                        cChvRegist := aReg[nPos][2] + aReg[nPos][3]
                        FisAddHash(oRegistro,cChvRegist,nPos)
                    EndIf
                    
                    IF cRegist$"5260"
                        aAdd(aReg,{})
                        nPos := Len (aReg)
                        aReg[nPos]:= aRegAbert[nPosAb]
                        oBloco5:setaNumer(aNumeracao)
                        //Atualiza o registro
                        aReg[nPos][1] :=  "5265"
                        ProcObjAb(oBloco5, oTabela, aReg[nPos],cChvAb, "5265")
                        cChvAb:= oBloco5:getGrupo()
                        //Adiciono a chave no array, � necess�rio pois nas movimenta��es preciso saber qual � o registro pai correto
                        aAdd(aReg[nPos],cChvAb)
                    ENDIF
                ELSE
                    cChvAb:= aReg[cCont][Len(aReg[cCont])]
                ENDIF
            ENDIF
            
            /*Registro de Apura��o do Custo*/
            IF cRegist$"5150|5165|5260"
                /*Gerar apenas para movimenta��o de sa�da*/
                IF (cAlias)->CLR_TPMOV == "S"
                    cRegistAp := CodFicha((cAlias)->CLR_FICHA, "4")
                    
                    IF !Empty(cRegistAp)
                        
                        For nX:=1 To Len(aRegApur)
                            IF (aRegApur[nX][2] == (cAlias)->F04_PROD .And. aRegApur[nX][9] == (cAlias)->F04_FICHA) .And.  (aScan(aApur,{|X| X[2] == aRegApur[nX][2] .AND. X[3] == aRegApur[nX][3] .AND. X[9] == aRegApur[nX][9] .AND. X[1] == cRegistAp})) == 0 
                                
                                
                                aAdd(aApur,{})
                                nPos := Len (aApur)
                                aAdd(aApur[nPos],cRegistAp)                             //1-Texto Fixo contendo o n�mero do Registro
                                aAdd(aApur[nPos],aRegApur[nX][2])                       //2-
                                aAdd(aApur[nPos],aRegApur[nX][3])                       //3-C�digo do Insumo, conforme registro 0200
                                aAdd(aApur[nPos],aRegApur[nX][4])                       //4-Quantidade do Insumo Utilizada
                                aAdd(aApur[nPos],aRegApur[nX][5])                       //5-Custo Unit�rio do Insumo por Unidade de produto
                                aAdd(aApur[nPos],aRegApur[nX][6])                       //6-Valor Unit�rio do ICMS do Insumo por Unidade de Produto
                                aAdd(aApur[nPos],aRegApur[nX][7])                       //7-Quantidade dePerda Normal no Processo produtivo
                                aAdd(aApur[nPos],aRegApur[nX][8])                       //8-Quantidade de Ganho Normal no Processo produtivo
                                aAdd(aApur[nPos],aRegApur[nX][9])                       //9-Ficha
                                
                                ProcObjApu(oBloco5, oTabela, aApur[nPos],cChvAb, aApur[nPos][1])
                                oBloco5:setaNumer(aNumeracao)
                                cChvApur:= oBloco5:getGrupo()
                            ENDIF
                        Next
                    ENDIF
                ENDIF
            ENDIF

            /*Registro de Aloca��o do Custo*/
            If cRegist$"5230"
                /*Gerar apenas para movimenta��o de sa�da*/
                If (cAlias)->CLR_TPMOV == "S"
                    cRegAlcCus := CodFicha((cAlias)->CLR_FICHA, "4")
                    If !Empty(cRegAlcCus)
                        For nX:=1 To Len(aAlocCust)
                            If aAlocCust[nX][2]+aAlocCust[nX][7] == (cAlias)->(CLR_PRDMOV+CLR_PROD) .And. aAlocCust[nX][8]
                                aAdd(a5235,{})
                                nPos := Len(a5235)
                                aAdd(a5235[nPos],cRegAlcCus)                        //1-Texto Fixo contendo o n�mero do Registro
                                aAdd(a5235[nPos],aAlocCust[nX][7])                  //2-C�digo do co-produto, conforme Registro 0200
                                aAdd(a5235[nPos],aAlocCust[nX][3])                  //3-Quantidade de Co-Produto resultante do Insumo conjunto no per�odo.
                                aAdd(a5235[nPos],aAlocCust[nX][4])                  //4-Pre�o M�dio de Sa�da do Co-Produto
                                aAdd(a5235[nPos],aAlocCust[nX][5])                  //5-Valor Projetado das Sa�das
                                aAdd(a5235[nPos],aAlocCust[nX][6])                  //6-Percentual de aloca��o do custo e ICMS do insumo-conjunto para o co-produto obtido na coluna 5 da Ficha 4B
                                PrcObApCus(oBloco5,oTabela,a5235[nPos],cChvAb,a5235[nPos][1])
                                oBloco5:setaNumer(aNumeracao)
                                cChvApur:= oBloco5:getGrupo()
                                aAlocCust[nX][8] := .F.
                            EndIf
                        Next
                    EndIf
                EndIf
            EndIf

            IF UPPER(ALLTRIM((cAlias)->(CLR_CODLAN))) <> 'SALDO'
                /*Registros de Movimenta��o dos itens das Ficha*/
                cRegistMov := CodFicha((cAlias)->CLR_FICHA,"2")
                IF /*!Empty(cRegistMov) .And.*/  Len(aRegAbert) > 0
                    aAdd(aRegMov,{})
                    nPos := Len (aRegMov)
                    aAdd(aRegMov[nPos],cRegistMov)                                  //1-Texto Fixo contendo o n�mero do Registro
                    aAdd(aRegMov[nPos],cValToChar((cAlias)->CLR_NRLAN))             //2-N�mero do lan�amento
                    aAdd(aRegMov[nPos],(cAlias)->CLQ_DATA)                          //3-Data de movimenta��o
                    aAdd(aRegMov[nPos],(cAlias)->CLR_HIST)                          //4-Hist�rico
                    aAdd(aRegMov[nPos],(cAlias)->CLR_TPDOC)                         //5-Tipo do documento conforme a coluna C�digo chave da tabela 4.
                    aAdd(aRegMov[nPos],(cAlias)->CLQ_SERIE)                         //6-S�rie do Documento
                    aAdd(aRegMov[nPos],(cAlias)->CLQ_NRDOC)                         //7-N�mero do documento
                    aAdd(aRegMov[nPos],(cAlias)->CLQ_CFOP)                          //8-CFOP da Opera��o
                    aAdd(aRegMov[nPos],(cAlias)->CLR_PART)                          //9-C�digo do Participante, conforme registro 0150
                    aAdd(aRegMov[nPos],(cAlias)->CLR_CODLAN)                        //10-C�digo de lan�amento
                    aAdd(aRegMov[nPos],IIF((cAlias)->CLR_TPMOV$'E|G|Z','0','1'))    //11-Indicador de movimento
                    aAdd(aRegMov[nPos],AllTrim(STR(Val((cAlias)->CLR_NRDI))))                          //12-N�mero da DI ou DSI
                    aAdd(aRegMov[nPos],IIF((cAlias)->CLR_TPMOV$'F|G|Z|J|I',(cAlias)->CLR_QTDE*-1,(cAlias)->CLR_QTDE))                          //13-Quantidade do item
                    aAdd(aRegMov[nPos],IIF((cAlias)->CLR_TPMOV$'F|G|Z|J|I',(cAlias)->CLR_CUSTO*-1,(cAlias)->CLR_CUSTO))                        //14-Custo do item
                    aAdd(aRegMov[nPos],(cAlias)->CLR_OUTROS)                        //15-Valor de outros tributos e contribui��es n�o-cumulativos
                    aAdd(aRegMov[nPos],IIF((cAlias)->CLR_TPMOV$'F|G|Z|J|I',(cAlias)->CLR_ICMS*-1,(cAlias)->CLR_ICMS))                          //16-Valor do ICMS
                    aAdd(aRegMov[nPos],(cAlias)->CLR_PROD)                          //17-C�digo do Item
                    aAdd(aRegMov[nPos],(cAlias)->CLR_PERRAT/100)                    //18-Percentual Rateio
                    aAdd(aRegMov[nPos],(cAlias)->CLR_CODREM)                        //19-C�digo do Remetente conforme registro 0150
                    aAdd(aRegMov[nPos],(cAlias)->CLR_CODDST)                        //20-C�digo do destinat�rio conforme registro 0150
                    aAdd(aRegMov[nPos],(cAlias)->CLR_UFINI)                         //21-UF de inicio do servi�o de transporte
                    aAdd(aRegMov[nPos],(cAlias)->CLR_UFDST)                         //22-UF de destino do servi�o de transporte
                    aAdd(aRegMov[nPos],(cAlias)->CLR_PART)                          //23-C�digo do tomador de servi�o de transporte conforme registro 0150
                    aAdd(aRegMov[nPos],(cAlias)->CLR_ALIQ)                          //24-Al�quota de ICMS aplicado
                    aAdd(aRegMov[nPos],(cAlias)->CLR_PCROUT)                        //25-Percentual de Cr�dito Outorgado relativo ao item
                    aAdd(aRegMov[nPos],(cAlias)->CLR_VCROUT)                        //26-Valor de Cr�dito Outorgado relativo ao item
                    aAdd(aRegMov[nPos],(cAlias)->CLR_VCRDSP)                        //27-Valor de Cr�dito - Despesas Operacionais
                    aAdd(aRegMov[nPos],(cAlias)->CLR_QTDE)                          //28-Quantidade de Material Resultante
                    aAdd(aRegMov[nPos],(cAlias)->CLR_SAIDA)                         //29-Valor de Sa�da do Material resultante
                    aAdd(aRegMov[nPos],(cAlias)->CLR_PRDMOV)                        //30-C�digo do Item Movimentado
                    
                    oBloco5:setaNumer(aNumeracao)
                    /*Neste caso passo como chave o registro de abertura(cChvAb), pois os registro de movimenta��o s�o filhos do registro de abertura */
                    ProcObjMv(oBloco5, oTabela, aRegMov[nPos],cChvAb, aRegMov[nPos][1])
                    cChvMov:= oBloco5:getGrupo()
                    
                    /*Registros de Devolu��o de Sa�da*/
                    cRegistDev := CodFicha((cAlias)->CLR_FICHA, "5")
                    IF /*!Empty(cRegistDev) .And.*/ (cAlias)->CLR_TPMOV$"G|Z"
                        aAdd(aDevSai,{})
                        nPos := Len (aDevSai)
                        aAdd(aDevSai[nPos],cRegistDev)                                  //1-Texto Fixo contendo o n�mero do Registro
                        aAdd(aDevSai[nPos],STOD((cAlias)->CLQ_DTORI))                    //2-Data da emiss�o do documento fiscal que acobertou a opera��o original do item devolvido
                        aAdd(aDevSai[nPos],(cAlias)->CLR_TPDOC)                         //3-Tipo do documento conforme a coluna C�digo chave da tabela 4.2 ou campo 02 do registro 0400
                        aAdd(aDevSai[nPos],(cAlias)->CLQ_SERORI)                         //4-S�rie do documento que acobertou a opera��o original
                        aAdd(aDevSai[nPos],(cAlias)->CLQ_DOCORI)                         //5-N�mero do documento que acobertou a opera��o original
                        oBloco5:setaNumer(aNumeracao)
                        /*Neste caso passo como chave o registro de movimenta��o(cChvMov), pois as devolu��es de sa�da � filho da movimenta��o */
                        ProcObjDev(oBloco5, oTabela, aDevSai[nPos],cChvMov, aDevSai[nPos][1])
                        cChvDevSai := oBloco5:getGrupo()
                    EndIf
                    
                    /*Registro IPI e Outros Tributos na Entrada*/
                    cRegistIPI := CodFicha((cAlias)->CLR_FICHA, "3")
                    IF /*!Empty(cRegistIPI) .And.*/ (cAlias)->CLR_TPMOV $ "E|G|Z"
                        aAdd(aRegIpiOut,{})
                        nPos := Len (aRegIpiOut)
                        aAdd(aRegIpiOut[nPos],cRegistIPI)                           //1-Texto Fixo contendo o n�mero do Registro
                        aAdd(aRegIpiOut[nPos],IIF (lDevSai,(cAlias)->CLR_IPI * -1,(cAlias)->CLR_IPI))                     //2-Valor do IPI, quando recuper�vel
                        aAdd(aRegIpiOut[nPos],IIF (lDevSai,(cAlias)->CLR_OUTROS * -1,(cAlias)->CLR_OUTROS))                 //3-Valor de Outros Tributos e Contribui��es n�o-cumulativos
                        oBloco5:setaNumer(aNumeracao)
                        /*Neste caso passo como chave o registro de movimenta��o(cChvMov), pois Ipi e Outros � filho da movimenta��o */
                        ProcObjIpi(oBloco5, oTabela, aRegIpiOut[nPos],cChvMov, aRegIpiOut[nPos][1])
                        cChvIPIOut := oBloco5:getGrupo()
                    ENDIF
                    
                    /*Opera��es Geradoras de Cr�dito Acumulado*/
                    cRegCredAc := CodFicha((cAlias)->CLR_FICHA, "6", SUBSTR((cAlias)->CLR_CODLAN,1,2))
                    IF  ((SUBSTR((cAlias)->CLR_CODLAN,1,2)$'31|32|33' .And. SUBSTR((cAlias)->CLR_CODLAN,3,2) == "77") .Or. (lDevSai .And. (cAlias)->CLQ_DTORI >= DDATADE .AND. (cAlias)->CLQ_DTORI <= DDATAATE))
                        IF (cAlias)->CLR_CREDAC > 0
                            
                            aAdd(aCredAcu,{})
                            nPos := Len (aCredAcu)
                            aAdd(aCredAcu[nPos],cRegCredAc)                             //1-Texto Fixo contendo o n�mero do Registro
                            aAdd(aCredAcu[nPos],(cAlias)->CLR_ENQLEG)                   //2-C�digo do Enquadramento Legal
                            aAdd(aCredAcu[nPos],IIF (lDevSai,(cAlias)->CLR_SAIDA * -1,(cAlias)->CLR_SAIDA))                     //3-Valor Total da Opera��o relativo ao Item
                            aAdd(aCredAcu[nPos],IIF (lDevSai,(cAlias)->CLR_CREDAC * -1,(cAlias)->CLR_CREDAC))                  //4-Credito acumulado Gerado na Opera��o com o Item
                            oBloco5:setaNumer(aNumeracao)
                            /*Neste caso passo como chave o registro de movimenta��o(cChvMov), pois Credito Acumulado � filho da movimenta��o */
                            ProcObjCrd(oBloco5, oTabela, aCredAcu[nPos],cChvMov, aCredAcu[nPos][1])
                            cCvCredAc := oBloco5:getGrupo()
                            
                            /*Opera��es Geradoras apuradas nas fichas 6A/6B*/
                            IF lDevSai
                                cReg6A6B := CodFicha(Alltrim((cAlias)->CLR_CODORI), "7",SUBSTR((cAlias)->CLR_CODLAN,3,2))
                            Else
                                cReg6A6B := CodFicha(Alltrim((cAlias)->CLR_FICHA), "7",SUBSTR((cAlias)->CLR_CODLAN,1,2))
                            EndIf
                            
                            IF ((cAlias)->CLR_FICHA$"61|62") .Or. lDevSai
                                aAdd(a6A6B,{})
                                nPos := Len (a6A6B)
                                aAdd(a6A6B[nPos],cReg6A6B)                                  //1-Texto Fixo contendo o n�mero do Registro
                                aAdd(a6A6B[nPos],IIF (lDevSai,((cAlias)->CLR_VALBC * -1),(cAlias)->CLR_VALBC))                     //2-Base de C�lculo da Opera��o de sa�da relativa ao item
                                aAdd(a6A6B[nPos],(cAlias)->CLR_ALIQ)                        //3-Al�quota de ICMS da Opera��o de sa�da relativa ao Item
                                aAdd(a6A6B[nPos],IIF (lDevSai,((cAlias)->CLR_ICMDEB * -1),(cAlias)->CLR_ICMDEB))                      //4-Icms debitado na opera��o de sa�da do item
                                oBloco5:setaNumer(aNumeracao)
                                /*Neste caso passo como chave o registro de credito acumulado(cCvCredAc), pois o 6A6B � filho do credito acumulado*/
                                PrcObj6A6B(oBloco5, oTabela, a6A6B[nPos],cCvCredAc, a6A6B[nPos][1])
                                cChv6ABCD := oBloco5:getGrupo()
                            ENDIF
                            
                            /*Opera��es Geradoras apuradas nas fichas 6C/6D*/

                            IF lDevSai
                                cReg6C6D := CodFicha(Alltrim((cAlias)->CLR_CODORI), "8", SUBSTR((cAlias)->CLR_CODLAN,3,2))
                            Else
                                cReg6C6D := CodFicha(Alltrim((cAlias)->CLR_FICHA), "8", SUBSTR((cAlias)->CLR_CODLAN,1,2))
                            EndIf
                            
                            IF  ((cAlias)->CLR_FICHA$"63|64") .Or. lDevSai
                                aAdd(a6C6D,{})
                                nPos := Len (a6C6D)
                                aAdd(a6C6D[nPos],cReg6C6D)                                                   //1-Texto Fixo contendo o n�mero do Registro
                                aAdd(a6C6D[nPos],IIF((cAlias)->CLR_FICHA == "64","",IIF((cAlias)->CLR_EXPIND == 'SIM',(cAlias)->CLR_DESPAC, (cAlias)->CLR_DESPAC)))    //2-N�mero da Declara��o para Despacho
                                aAdd(a6C6D[nPos],IIF((cAlias)->CLR_COMOPE == '1','0', '1') ) //3-Comprova��o de Opera��o
                                aAdd(a6C6D[nPos],IIF((cAlias)->CLR_FICHA == "64","",(cAlias)->CLR_CREDAC))  //4-Valor do Cr�dito de ICMS
                                oBloco5:setaNumer(aNumeracao)
                                /*Neste caso passo como chave o registro de credito acumulado(cCvCredAc), pois o 6C6D � filho do credito acumulado*/
                                PrcObj6C6D(oBloco5, oTabela, a6C6D[nPos],cCvCredAc, a6C6D[nPos][1])
                                cChv6ABCD := oBloco5:getGrupo()
                            ENDIF
                            
                            /*Exporta��o Indireta comprovada*/
                            cRegExpInd := CodFicha((cAlias)->CLR_FICHA, "9", SUBSTR((cAlias)->CLR_CODLAN,1,2))
                            
                            IF  (cAlias)->CLW_NRLAN <> 0
                                aAdd(aExpInd,{})
                                nPos := Len (aExpInd)
                                aAdd(aExpInd[nPos],cRegExpInd)                          //1-Texto Fixo contendo o n�mero do Registro
                                aAdd(aExpInd[nPos],STOD((cAlias)->CLW_DTDCEX))          //2-Data do Documento Fiscal do Exportador
                                aAdd(aExpInd[nPos],(cAlias)->CLW_NRDCEX)                //3-N�mero do Documento Fiscal do Exportador
                                aAdd(aExpInd[nPos],(cAlias)->CLW_SRDCEX)                //4-S�rie do Documento Fiscal do Exportador
                                aAdd(aExpInd[nPos],(cAlias)->CLW_NRDESP)                //5-N�mero da Declara��o para Despacho de Exporta��o do Exportador
                                oBloco5:setaNumer(aNumeracao)
                                /*Neste caso passo como chave o registro registro de 6AB ou  6CD(cChv6ABCD), pois a exporta��o indireta � filho do 6AB/6CD*/
                                PrcExpInd(oBloco5, oTabela, aExpInd[nPos],cChv6ABCD, aExpInd[nPos][1])
                            ENDIF
                        ENDIF
                    ENDIF
                    
                    IF lDevSai
                        cNGerCred := CodFicha((cAlias)->CLR_CODORI, "10", SUBSTR((cAlias)->CLR_CODLAN,3,2))
                    Else
                        cNGerCred := CodFicha((cAlias)->CLR_FICHA, "10", SUBSTR((cAlias)->CLR_CODLAN,1,2))
                    EndIf
                    
                    /*Opera��es n�o geradoras de cr�dito acumulado*/
                    IF (cAlias)->CLR_FICHA == "66"  .Or. lDevSai
                        aAdd(aNGerCred,{})
                        nPos := Len (aNGerCred)
                        aAdd(aNGerCred[nPos],cNGerCred)                             //1-Texto Fixo contendo o n�mero do Registro
                        aAdd(aNGerCred[nPos],IIF(lDevSai,(cAlias)->CLR_SAIDA * -1, (cAlias)->CLR_SAIDA ))                   //2-Valor Total da Opera��o relativo ao Item
                        aAdd(aNGerCred[nPos],IIF(lDevSai,(cAlias)->CLR_VALBC * -1,(cAlias)->CLR_VALBC ))                   //3-Base de C�lculo da Opera��o de sa�da relativa ao item
                        aAdd(aNGerCred[nPos],(cAlias)->CLR_ALIQ)                    //4-Al�quota de ICMS da Opera��o de sa�da relativa ao Item
                        aAdd(aNGerCred[nPos],IIF(lDevSai,(cAlias)->CLR_ICMDEB * -1,(cAlias)->CLR_ICMDEB))                  //5-Icms debitado na opera��o de sa�da do item
                        
                        //6-Icms devido na opera��o de sa�da relativo ao item
                        IF !lDevSai .And. (cAlias)->CLR_ICMSDE < 0
                            aAdd(aNGerCred[nPos],0)
                        ELSE
                            aAdd(aNGerCred[nPos],IIF(lDevSai,(cAlias)->CLR_ICMSDE * -1,(cAlias)->CLR_ICMSDE))
                        ENDIF
                        
                        //7-Valor do Cr�dito de ICMS
                        IF !lDevSai .And. (cAlias)->CLR_CREDAC < 0
                            aAdd(aNGerCred[nPos],0)
                        ELSE
                            aAdd(aNGerCred[nPos],IIF(lDevSai,(cAlias)->CLR_CREDAC * -1,(cAlias)->CLR_CREDAC))
                        ENDIF
                        
                        oBloco5:setaNumer(aNumeracao)
                        /*Neste caso passo como chave o registro registro de movimenta��o(cChvMov), pois n�o geradores de credito acumulado � filho da movimenta��o*/
                        PrcNCred(oBloco5, oTabela, aNGerCred[nPos],cChvMov, aNGerCred[nPos][1])
                    ENDIF
                    
                ENDIF
            ENDIF
        ELSE
            /*Presta��es de servi�o de transporte */
            cRegistMov := CodFicha((cAlias)->CLR_FICHA,"12")
            aAdd(aServTran,{})
            nPos := Len (aServTran)
            aAdd(aServTran[nPos],cRegistMov)                                //1-Texto Fixo contendo o n�mero do Registro
            aAdd(aServTran[nPos],(cAlias)->CLR_NRORD)                       //2-N�mero da Ordem
            aAdd(aServTran[nPos],(cAlias)->CLQ_DATA)                        //3-Data de movimenta��o dDtMov
            aAdd(aServTran[nPos],(cAlias)->CLR_HIST)                        //4-Hist�rico cHist
            aAdd(aServTran[nPos],(cAlias)->CLQ_CFOP)                        //5-CFOP da Opera��o  nCFOP
            aAdd(aServTran[nPos],(cAlias)->CLQ_TPDOC)                       //6-Tipo do documento conforme a coluna C�digo chave da tabela 4. nTpDoc
            aAdd(aServTran[nPos],(cAlias)->CLQ_SERIE)                       //7-S�rie do Documento cSerie
            aAdd(aServTran[nPos],(cAlias)->CLQ_NRDOC)                       //8-N�mero do documento cNumDoc
            aAdd(aServTran[nPos],(cAlias)->CLR_CODREM)                      //9-C�digo do Remetente conforme registro 0150 cCodRem
            aAdd(aServTran[nPos],(cAlias)->CLR_CODDST)                      //10-C�digo do destinat�rio conforme registro 0150 cCodDes
            aAdd(aServTran[nPos],(cAlias)->CLR_UFINI)                       //11-UF de inicio do servi�o de transporte cUFInic
            aAdd(aServTran[nPos],(cAlias)->CLR_UFDST)                       //12-UF de destino do servi�o de transporte cUFDest
            aAdd(aServTran[nPos],(cAlias)->CLR_PART)                        //13-C�digo do Tomador do Servi�o de Transporte, conforme registro 0150 cCodTom
            aAdd(aServTran[nPos],(cAlias)->CLR_ALIQ)                        //14-Al�quota de ICMS aplicado nAliq
            aAdd(aServTran[nPos],(cAlias)->CLR_VPRENG)                      //15-Valor da Presta��o Nas presta��es n�o geradoras de cr�dito acumulado, indicar oValor Total da Presta��o. nVpreng
            aAdd(aServTran[nPos],(cAlias)->CLR_ICMDEB)                      //16-Valor do ICMS debitado pelo transportador na presta��o nIcmdeb
            aAdd(aServTran[nPos],(cAlias)->CLR_VPREGE)                      //17-Nas presta��es geradoras de cr�dito acumulado, indicar o ValorTotal da Presta��o. nVprege
            aAdd(aServTran[nPos],(cAlias)->CLR_ICMST)                       //18-Indique o valor do ICMS devido pelo contribuinte substituto para fins de c�lculo do Cr�dito Outorgado (Transportadora com op��o regular). nIcmst
            aAdd(aServTran[nPos],(cAlias)->CLR_VCROUT)                      //19-Valor do Cr�dito Outorgado relativo � presta��o pr�pria. nVcrout
            aAdd(aServTran[nPos],(cAlias)->CLR_CROUST)                      //20-Valor do Cr�dito Outorgado relativo � presta��o cujo pagamento do imposto est� atribu�do ao tomador do servi�o (substitui��o tribut�ria). nCroust
            aAdd(aServTran[nPos],(cAlias)->CLR_CREDAC)                      //21-Valor do Cr�dito Acumulado gerado na presta��o nCredac
            aAdd(aServTran[nPos],(cAlias)->CLR_ICMSDE)                      //22-Valor do ICMS devido na presta��o pr�pria nIcmsde
            aAdd(aServTran[nPos],(cAlias)->CLX_CODVCL)                      //23-C�digo de IdentIFica��o do principal Ve�culo Rodovi�rio Transportador conforme registro 5725. nVeicul
            aAdd(aServTran[nPos],(cAlias)->CLR_KM)                          //24-Dist�ncia percorrida nKm
            aAdd(aServTran[nPos],(cAlias)->CLR_ENQLEG)                      //25-C�digo do Enquadramento Legal conforme registro 0300 nEnqleg
            aAdd(aServTran[nPos],(cAlias)->CLR_INDRAT)                      //26-�ndice de Rateio nIndrat
            aAdd(aServTran[nPos],(cAlias)->CLR_UCUSTO)                      //27-Valor do custo de cada servi�o de transporte prestado. nUcusto
            aAdd(aServTran[nPos],(cAlias)->CLR_UICMS)                       //28-Valor do ICMS referente ao custo de cada servi�o de transporte prestado nUicms
            oBloco5:setaNumer(aNumeracao)
            ProcServTr(oBloco5, oTabela, aServTran[nPos],cChaveBlc5, aServTran[nPos][1])
        ENDIF
        
        /*Cadastro de Veiculo transportador rodoviario*/
        IF  !Empty(AllTrim((cAlias)->CLX_CODVCL)) .And. (aScan(aVeicul,{|X| X[2] == (cAlias)->CLX_CODVCL}))== 0
            aAdd(aVeicul,{})
            nPos := Len (aVeicul)
            aAdd(aVeicul[nPos],"5725")                                      //1-Texto Fixo contendo o n�mero do Registro
            aAdd(aVeicul[nPos],(cAlias)->CLX_CODVCL)                        //2-C�digo de IndentIFica��o do Ve�culo Transportador
            aAdd(aVeicul[nPos],(cAlias)->CLX_CNPJ)                          //3-CNPJ do Propriet�rio
            aAdd(aVeicul[nPos],(cAlias)->CLX_PLACA)                         //4-Placa do Ve�culo
            aAdd(aVeicul[nPos],(cAlias)->CLX_UF)                            //5-Unidade de Federa��o de Registro do Ve�culo
            aAdd(aVeicul[nPos],(cAlias)->CLX_MUN)                           //6-Munic�pio
            aAdd(aVeicul[nPos],(cAlias)->CLX_RENAV)                         //7-N�mero do Renavan
            aAdd(aVeicul[nPos],(cAlias)->CLX_MARCA)                         //8-Marca do Ve�culo
            aAdd(aVeicul[nPos],(cAlias)->CLX_MOD)                           //9-Modelo do Ve�culo
            aAdd(aVeicul[nPos],(cAlias)->CLX_ANO)                           //10-Ano de Fabrica��o
            aAdd(aVeicul[nPos],(cAlias)->CLX_RCOMB)                         //11-Rendimento do Combust�vel
            oBloco5:setaNumer(aNumeracao)
            ProcObjVei(oBloco5, oTabela, aVeicul[nPos],cChaveBlc5)
        ENDIF
        (cAlias)->(DbSkip())
    EndDo
    (cAlias)->(DbCloseArea())
    
    If lBuild
    	FreeObj(oRegAbert)
    	oRegAbert := Nil

    	FreeObj(oRegistro)
    	oRegistro := Nil
    EndIf

    If !lAutomato
    	oProcess:Inc2Progress(' ')
    EndIf
    
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcAbert

Fun��o que retorna as informa��es referente a abertura das Fichas e Grava os dados em um Array

Registros 5010,5060,5080,5100,5110,5150,5165,5180,5190,5210,5230,5260,**5265**,5310,5360,5410,5550,5590

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------

Static Function ProcAbert(oProcess, dDataDe,dDataAte)
    Local cAliasF04 := ""
    Local aReg      := {}
    Local aRegAbert := {}
    Local cPeriodo  := AnoMes(stod(dDataDe))
    Local nPos      := 0
    Local nQtd      := 0
    Local nTot      := QtdRegAber(dDataDe,dDataAte)
    Local cChvRegAb := ''
    
    If !lAutomato
    	oProcess:Set2Progress((nTot))
    EndIf
        
    cAliasF04   :=  GetNextAlias()
    
    BeginSql Alias cAliasF04
        
        SELECT F04.F04_FILIAL,
        F04.F04_PERIOD,
        F04.F04_PROD,
        F04.F04_FICHA,
        F04.F04_FATORI,
        F04.F04_FATORC,
        F04.F04_QTDE,
        CDU.CDU_VALCUS,
        CDU.CDU_VALICM,
        CDU.CDU_QTDINI,
        CDU.CDU_QTDFIM,
        CDU.CDU_CUSINI,
        CDU.CDU_ICMINI 
        FROM  %TABLE:F04% F04
        LEFT JOIN %TABLE:CDU% CDU
        ON( CDU.CDU_PRODUT = F04.F04_PROD
        AND CDU_FICHA = F04.F04_FICHA
        AND CDU.CDU_FILIAL = %XFILIAL:CDU%
        AND CDU.%NOTDEL%
        AND CDU.CDU_PERIOD = %EXP:cPeriodo%)
        INNER JOIN  %TABLE:SB1% SB1
        ON (F04.F04_PROD = SB1.B1_COD
        AND SB1.B1_FILIAL = %XFILIAL:SB1%
        AND SB1.%NOTDEL% )
        WHERE  F04.F04_FILIAL = %XFILIAL:F04%
        AND F04.%NOTDEL%
        AND F04.F04_PERIOD >= %EXP:dDataDe%
        AND F04.F04_PERIOD <= %EXP:dDataAte%
        ORDER  BY F04.F04_FILIAL,
        F04.F04_PERIOD,
        F04.F04_PROD,
        F04.F04_FICHA
    EndSql
    DbSelectArea (cAliasF04)
    
    Do While !(cAliasF04)->(Eof ())
        nQtd ++
        
        If !lAutomato
        	oProcess:Set2Progress(nQtd)
        	oProcess:Inc2Progress('Processando Registro de Abertura - Processando ' +Alltrim(STR(nQtd)) + ' de ' +Alltrim(STR(nTot) ))
        EndIf
        
        aAdd(aReg,{})
        nPos := Len (aReg)
        aAdd(aReg[nPos],"")                                               //1-Texto Fixo contendo o n�mero do Registro
        aAdd(aReg[nPos],(cAliasF04)->F04_FICHA)                             //2-C�digo da Ficha
        aAdd(aReg[nPos],(cAliasF04)->F04_PROD)                              //3-C�digo Produto/servi�o
        aAdd(aReg[nPos],(cAliasF04)->CDU_QTDINI)                            //4-Saldo Inicial da Quantidade do Item
        aAdd(aReg[nPos],(cAliasF04)->CDU_CUSINI)                            //5-Saldo Inicial do Valor de Custo
        aAdd(aReg[nPos],(cAliasF04)->CDU_ICMINI)                            //6-Saldo Inicial do Valor de ICMS
        aAdd(aReg[nPos],(cAliasF04)->CDU_QTDFIM)                            //7-Saldo Final da Quantidade do Item
        aAdd(aReg[nPos],(cAliasF04)->CDU_VALCUS)                            //8-Saldo Final do Valor de Custo do Item
        aAdd(aReg[nPos],(cAliasF04)->CDU_VALICM)                            //9-Saldo Final do Valor de ICMS do item
        aAdd(aReg[nPos],(cAliasF04)->F04_QTDE)                              //10-Quantidade de produto concluido e transferido no periodo
        aAdd(aReg[nPos],(cAliasF04)->F04_FATORC)                            //11-Custo unit�rio do produto conclu�do
        aAdd(aReg[nPos],(cAliasF04)->F04_FATORI)                            //12-Valor Unit�rio de ICMS conclu�do/transferido no periodo
        aRegAbert := aReg[nPos]

        If lBuild
            cChvRegAb := (cAliasF04)->F04_FICHA + (cAliasF04)->F04_PROD
            FisAddHash(oRegAbert,cChvRegAb,nPos)
        EndIf

        (cAliasF04)->(DbSkip())
    EndDo
    (cAliasF04)->(DbCloseArea())
    
    If !lAutomato
    	oProcess:Inc2Progress(' ')
    EndIf

RETURN  aReg


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcApur

Fun��o que retorna as informa��es referente a apura��o de custos e Grava os dados em um Array

Registros 5155,5170,5270

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function ProcApur(oProcess, dDataDe,dDataAte)
    Local cAlias := ""
    Local aReg   := {}
    Local nQtd   := 0
    Local nTot   := QtdRegAPur(dDataDe,dDataAte)
    Local cFiltro	:= ''
    
	 If !lAutomato
		 oProcess:Set2Progress((nTot))
	 EndIf

    cAlias  :=  GetNextAlias()
    
    IF CLU->(FieldPos("CLU_APPROD"))>0
    	cFiltro	:= "CLU.CLU_APPROD <> '2' AND"
    EndIF
    cFiltro 	:= "%" + cFiltro + "%"
    
    BeginSql Alias cAlias
        
        SELECT CLU.CLU_PROD,
               CLU.CLU_FICHA,
               CLU.CLU_PRDINS, 
               Sum(CLU.CLU_QTDINS) CLU_QTDINS,  
               Sum(CLU.CLU_UNTCUS) CLU_UNTCUS, 
               Sum(CLU.CLU_UNTICM) CLU_UNTICM, 
               Sum(CLU.CLU_PERDA)  CLU_PERDA, 
               Sum(CLU.CLU_GANHO)   CLU_GANHO
        FROM %TABLE:CLU% CLU
        WHERE CLU.CLU_FILIAL=%XFILIAL:CLU%        
        AND CLU.CLU_PERIOD >= %EXP:dDataDe%
        AND CLU.CLU_PERIOD <= %EXP:dDataAte% AND        
        %Exp:cFiltro%
        CLU.%NOTDEL%
        GROUP  BY CLU.CLU_PROD, CLU.CLU_FICHA, CLU.CLU_PRDINS 
        ORDER  BY CLU.CLU_PROD, CLU.CLU_FICHA, CLU.CLU_PRDINS 
        
    EndSql
    DbSelectArea (cAlias)
    
    Do While !(cAlias)->(Eof ())
        nQtd ++
        
        If !lAutomato
        	oProcess:Set2Progress(nQtd)
        	oProcess:Inc2Progress('Processando Registro de Apura��o - Processando ' +Alltrim(STR(nQtd)) + ' de ' +Alltrim(STR(nTot) ))
        EndIF
        
        aAdd(aReg,{})
        nPos := Len (aReg)
        aAdd(aReg[nPos],"")                                         //1-Texto Fixo contendo o n�mero do Registro
        aAdd(aReg[nPos],(cAlias)->CLU_PROD)                         //2-COLOQUEI O PRODUTO
        aAdd(aReg[nPos],(cAlias)->CLU_PRDINS)                       //3-C�digo do Insumo, conforme registro 0200
        aAdd(aReg[nPos],(cAlias)->CLU_QTDINS)                       //4-Quantidade do Insumo Utilizada
        aAdd(aReg[nPos],(cAlias)->CLU_UNTCUS)                       //5-Custo Unit�rio do Insumo por Unidade de produto
        aAdd(aReg[nPos],(cAlias)->CLU_UNTICM)                       //6-Valor Unit�rio do ICMS do Insumo por Unidade de Produto
        aAdd(aReg[nPos],(cAlias)->CLU_PERDA)                        //7-Quantidade dePerda Normal no Processo produtivo
        aAdd(aReg[nPos],(cAlias)->CLU_GANHO)                        //8-Quantidade de Ganho Normal no Processo produtivo
        aAdd(aReg[nPos],(cAlias)->CLU_FICHA)                        //9-Ficha
        
        (cAlias)->(DbSkip())
    EndDo
    (cAlias)->(DbCloseArea())
    
    If !lAutomato
    	oProcess:Inc2Progress(' ')
    EndIF
    
RETURN  aReg


//-------------------------------------------------------------------
/*/{Protheus.doc} PrcAlcCust

Fun��o que retorna as informa��es referente a aloca��o de custos e Grava os dados em um Array

Registro 5235

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function PrcAlcCust(oProcess, dDataDe,dDataAte)
    Local cAlias := ""
    Local aReg    := {}
    Local nQtd   := 0
    Local nTot   := QtdAlcCust(dDataDe,dDataAte)
    
    cAlias  :=  GetNextAlias()
    
    If !lAutomato
    	oProcess:Set2Progress((nTot))
    	oProcess:Inc2Progress('Processando Registro de Aloca��o de Custo')
    EndIF
        
    BeginSql Alias cAlias
        
        SELECT   CLT.CLT_FILIAL,
        CLT.CLT_PERIOD,
        CLT.CLT_PRDDST,
        CLT.CLT_FICHA,
        CLT.CLT_PERRAT,
        CLT.CLT_VALCUS,
        CLT.CLT_VALICM,
        CLT.CLT_INSUMO,
        CLT.CLT_QTDE,
        CLT.CLT_PRCUNI,
        CLT.CLT_VLPRJS,
        CLT.CLT_PEATIC
        FROM     %TABLE:CLT% CLT
        WHERE    CLT.CLT_FILIAL=%XFILIAL:CLT%
        AND      CLT.%NOTDEL%
        AND      CLT.CLT_PERIOD >= %EXP:DDATADE%
        AND      CLT.CLT_PERIOD <= %EXP:DDATAATE%
        ORDER BY CLT.CLT_FILIAL,
        CLT.CLT_FICHA
        
    EndSql
    DbSelectArea (cAlias)
    
    Do While !(cAlias)->(Eof ())
        nQtd ++
        
        If !lAutomato
        	oProcess:Set2Progress(nQtd)
        	oProcess:Inc2Progress('Processando Registro de Aloca��o de Custo - Processando ' +Alltrim(STR(nQtd)) + ' de ' +Alltrim(STR(nTot) ))
        EndIF
        
        aAdd(aReg,{})
        nPos := Len (aReg)
        aAdd(aReg[nPos],"")                                     //1-Texto Fixo contendo o n�mero do Registro
        aAdd(aReg[nPos],(cAlias)->CLT_PRDDST)                   //2-C�digo do co-produto, conforme Registro 0200
        aAdd(aReg[nPos],(cAlias)->CLT_QTDE)                     //3-Quantidade de Co-Produto resultante do Insumo conjunto no per�odo.
        aAdd(aReg[nPos],(cAlias)->CLT_PRCUNI)                   //4-Pre�o M�dio de Sa�da do Co-Produto
        aAdd(aReg[nPos],(cAlias)->CLT_VLPRJS)                   //5-Valor Projetado das Sa�das
        aAdd(aReg[nPos],(cAlias)->CLT_PEATIC)                   //6-Percentual de aloca��o do custo e ICMS do insumo-conjunto para o co-produto obtido na coluna 5 da Ficha 4B
        aAdd(aReg[nPos],(cAlias)->CLT_INSUMO)                   //7-Insumo
        aAdd(aReg[nPos],.T.)                                    //8-Flag se ja usado.
        (cAlias)->(DbSkip())
    EndDo
    (cAlias)->(DbCloseArea())
    
    If !lAutomato
    	oProcess:Inc2Progress(' ')
    EndIf
    
RETURN aReg

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcAlcCust

Fun��o que busca os dados referente ao Invent�rio por Material Componente - Ficha 5G e Grava os dados em um Array

Registros 5590, 5595

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------

Static Function ProInvent(oProcess,oBloco5,oTabela,dDataDe,dDataAte,lFimper)
    Local cAliasCLV := ""
    Local aRegCab   := {}
    Local aRegInv   := {}
    Local cChave    := '5001000000001'
    Local cChaveAb  := ""
    Local aNumeracao:= {}
    Local nQtd      := 0
    Local nTot      := QtdInvent(dDataDe, dDataAte)
    Local cPerDe    := ''//StrZero(Month(Stod(dDataDe))-1,2)
    Local cPerAte   := ''//StrZero(Month(Stod(dDataAte))+11,2)
    Local cPeriod   := ''

    IF lFimPer
        //Quando final do periodo utiliza datas informadas no wizard
        cPerDe   := dDataDe
        cPerAte  := dDataAte
    Else        
        cPerDe   := DToS(FirstDay(StoD(dDataDe)-1)) // Pega primeiro dia do mes anterior ao informado na wizard
        cPerAte  := DToS(StoD(dDataDe)-1)           // Pega ultimo dia do mes anterior ao informado na wizard
    EndIf 
    
    If !lAutomato
    	oProcess:Set2Progress((nTot))
    EndIf
        
    cAliasCLV  :=  GetNextAlias()
    
    BeginSql Alias cAliasCLV
        
        SELECT
        CLV.CLV_FILIAL,
        CLV.CLV_PERIOD,
        CLV.CLV_PROD,
        CLV.CLV_PRDINS,
        CLV.CLV_QUANT,
        CLV.CLV_VALCUS,
        CLV.CLV_VALICM
        FROM     %TABLE:CLV% CLV
        WHERE    CLV.CLV_FILIAL=%XFILIAL:CLV%
        AND      CLV.%NOTDEL%
        AND      CLV.CLV_PERIOD >= %exp:cPerDe%
        AND      CLV.CLV_PERIOD <= %exp:cPerAte%
        ORDER BY CLV.CLV_FILIAL,
        CLV.CLV_PERIOD,
        CLV.CLV_PROD
        
    EndSql
    DbSelectArea (cAliasCLV)
    
    
    Do While !(cAliasCLV)->(Eof ())
        
        nQtd++
        
        If !lAutomato
        	oProcess:Set2Progress(nQtd)
        	oProcess:Inc2Progress('Processando Invent�rio - Processando ' +Alltrim(STR(nQtd)) + ' de ' +Alltrim(STR(nTot) ))
        EndIF
        
        IF aScan(aRegCab,{|X| X[2] == (cAliasCLV)->CLV_PROD}) == 0
            aAdd(aRegCab,{})
            nPos := Len (aRegCab)
            aAdd(aRegCab[nPos],"5590")                                          //1-Texto Fixo contendo o n�mero do Registro
            aAdd(aRegCab[nPos],(cAliasCLV)->CLV_PROD)                           //2-C�digo do Produto em Elabora��o
            oBloco5:setaNumer(aNumeracao)
            ProcOBJInv(oBloco5,oTabela,aRegCab[nPos],cChave, "5590")
            cChaveAb:= oBloco5:getGrupo()
        ENDIF
        
        IF aScan(aRegInv,{|X| X[2] == (cAliasCLV)->CLV_PROD .AND. X[3] == (cAliasCLV)->CLV_PRDINS}) == 0
            aAdd(aRegInv,{})
            nPos := Len (aRegInv)
            aAdd(aRegInv[nPos],"5595")
            aAdd(aRegInv[nPos],(cAliasCLV)->CLV_PROD)                           //2-C�digo do Produto em Elabora��o
            aAdd(aRegInv[nPos],(cAliasCLV)->CLV_PRDINS)                        //3-C�digo do Insumo, conforme registro 0200
            aAdd(aRegInv[nPos],(cAliasCLV)->CLV_QUANT)                         //3-Quantidade do Insumo Utilizado
            aAdd(aRegInv[nPos],(cAliasCLV)->CLV_VALCUS)                        //4-Custo do Insumo
            aAdd(aRegInv[nPos],(cAliasCLV)->CLV_VALICM)                        //5-Valor do ICMS do Insumo
            oBloco5:setaNumer(aNumeracao)
            ProcOBJInv(oBloco5,oTabela,aRegInv[nPos],cChaveAb, "5595")
        ENDIF
        (cAliasCLV)->(DbSkip())
    EndDo
    (cAliasCLV)->(DbCloseArea())
    
    If !lAutomato
    	oProcess:Inc2Progress(' ')
    EndIf
    
RETURN  (aRegCab, aRegInv)

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcObjAb

Fun��o que preenche o objeto referente a abertura das fichas

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------

Static Function ProcObjAb(oBloco5,oTabela,aReg,cChave, cReg)
    oAber:=oBloco5
    oAber:setRelac(cChave)                                              //0-Chave
    oAber:SetcReg(aReg[1])                                              //1-Texto Fixo contendo o n�mero do Registro
    oAber:SetcCodItem(aReg[3])                                          //3-Condigo do Item conforme registro 0200
    oAber:SetnQtdIni(aReg[4])                                           //4-Saldo Inicial de quantidade do item
    oAber:SetnCustIni(aReg[5])                                          //5-Saldo Inicial do Valor de Custo do Item
    oAber:SetnICMSIni(aReg[6])                                          //6-Saldo Inicial do Valor de ICMS do Item
    oAber:SetnQtdFim(aReg[7])                                           //7-Saldo Final de quantidade do Item
    oAber:SetnCustFim(aReg[8])                                          //8-Saldo Final do Valor de Custo do Item
    oAber:SetnICMSFim(aReg[9])                                          //9-Saldo Final do Valor de ICMS do Item
    oAber:SetnQtdPer(aReg[10])                                          //10-Quantidade de produto concluido e transferido no periodo
    oAber:SetnCustUnt(aReg[11])                                         //11-Custo unit�rio do produto conclu�do
    oAber:SetnICMSUnt(aReg[12])                                         //12-Valor Unit�rio de ICMS conclu�do/transferido no periodo
    oTabela:GrvReg(oAber:AddAbrt(cReg))
    oAber:Clear(aReg[1])
RETURN
//-------------------------------------------------------------------
/*/{Protheus.doc} ProcObjMv

Fun��o que preenche o objeto referente a movimenta��o das fichas

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function ProcObjMv(oBloco5,oTabela,aReg,cChave, cReg)
    oMov:=oBloco5
    oMov:SetRelac(cChave)                                               //0-Chave
    oMov:SetcReg(aReg[1])                                               //1-Texto Fixo contendo o n�mero do Registro
    oMov:SetnNumLan(aReg[2])                                            //2-N�mero do lan�amento
    oMov:SetdDtMov(aReg[3])                                             //3-Data de movimenta��o
    oMov:SetcHist(aReg[4])                                              //4-Hist�rico
    oMov:SetnTpDoc(aReg[5])                                             //5-Tipo do documento conforme a coluna C�digo chave da tabela 4.
    oMov:SetcSerie(aReg[6])                                             //6-S�rie do Documento
    oMov:SetcNumDoc(aReg[7])                                            //7-N�mero do documento
    oMov:SetnCFOP(aReg[8])                                              //8-CFOP da Opera��o
    oMov:SetcCodPar(aReg[9])                                            //9-C�digo do Participante, conforme registro 0150
    oMov:SetnCodLan(aReg[10])                                           //10-C�digo de lan�amento
    oMov:SetnIndMov(aReg[11])                                           //11-Indicador de movimento
    oMov:SetcNumDI(aReg[12])                                            //12-N�mero da DI ou DSI
    oMov:SetnQuant(aReg[13])                                            //13-Quantidade do item
    oMov:SetnCusto(aReg[14])                                            //14-Custo do item
    oMov:SetnValTri(aReg[15])                                           //15-Valor de outros tributos e contribui��es n�o-cumulativos
    oMov:SetnValICMS(aReg[16])                                          //16-Valor do ICMS
    oMov:SetcCodItem(aReg[17])                                         //17-C�digo do Item Origem ou Destino
    oMov:SetnPercRat(aReg[18])                                          //18-Percentual Rateio
    oMov:SetcCodRem(aReg[19])                                           //19-C�digo do Remetente conforme registro 0150
    oMov:SetcCodDes(aReg[20])                                           //20-C�digo do destinat�rio conforme registro 0150
    oMov:SetcUFInic(aReg[21])                                           //21-UF de inicio do servi�o de transporte
    oMov:SetcUFDest(aReg[22])                                           //22-UF de destino do servi�o de transporte
    oMov:SetcCodTom(aReg[23])                                           //23-C�digo do tomador de servi�o de transporte conforme registro 0150
    oMov:SetnAliq(aReg[24])                                             //24-Al�quota de ICMS aplicado
    oMov:SetnPerCO(aReg[25])                                            //25-Percentual de Cr�dito Outorgado relativo ao item
    oMov:SetnValCO(aReg[26])                                            //26-Valor de Cr�dito Outorgado relativo ao item
    oMov:SetnValDesp(aReg[27])                                          //27-Valor de Cr�dito - Despesas Operacionais
    oMov:SetnQTDMatRes(aReg[28])                                        //28-Quantidade de Material Resultante
    oMov:SetnValMatRes(aReg[29])                                        //29-Valor de Sa�da do Material resultante
    oMov:SetcProdMov(aReg[30])                                          //30-C�digo do Insumo
    oTabela:GrvReg(oMov:AddMov(cReg))
    oMov:Clear(aReg[1])
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcServTr

Fun��o que preenche o objeto referente as Presta��es de Servi�os de Transporte

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function ProcServTr(oBloco5,oTabela,aReg,cChave, cReg)
    oServTran:=oBloco5
    oServTran:SetRelac(cChave)                                                  //0-Chave
    oServTran:SetcReg(aReg[1])                                                  //1-Texto Fixo contendo o n�mero do Registro
    oServTran:SetnOrdem(aReg[2])                                                //2-N�mero da Ordem
    oServTran:SetdDtMov(aReg[3])                                                //3-Data de movimenta��o
    oServTran:SetcHist(aReg[4])                                                 //4-Hist�rico
    oServTran:SetnCFOP(aReg[5])                                                 //5-CFOP da Opera��o
    oServTran:SetnTpDoc(aReg[6])                                                //6-Tipo do documento conforme a coluna C�digo chave da tabela 4.
    oServTran:SetcSerie(aReg[7])                                                //7-S�rie do Documento
    oServTran:SetcNumDoc(aReg[8])                                               //8-N�mero do documento
    oServTran:SetcCodRem(aReg[9])                                               //9-C�digo do Remetente conforme registro 0150
    oServTran:SetcCodDes(aReg[10])                                              //10-C�digo do destinat�rio conforme registro 0150
    oServTran:SetcUFInic(aReg[11])                                              //11-UF de inicio do servi�o de transporte
    oServTran:SetcUFDest(aReg[12])                                              //12-UF de destino do servi�o de transporte
    oServTran:SetcCodTom(aReg[13])                                              //13-C�digo do Tomador do Servi�o de Transporte, conforme registro 0150
    oServTran:SetnAliq(aReg[14])                                                //14-Al�quota de ICMS aplicado
    oServTran:SetnVpreng(aReg[15])                                              //15-Valor da Presta��o Nas presta��es n�o geradoras de cr�dito acumulado, indicar oValor Total da Presta��o.
    oServTran:SetnIcmdeb(aReg[16])                                              //16-Valor do ICMS debitado pelo transportador na presta��o
    oServTran:SetnVprege(aReg[17])                                              //17-Nas presta��es geradoras de cr�dito acumulado, indicar o ValorTotal da Presta��o.
    oServTran:SetnIcmst(aReg[18])                                               //18-Indique o valor do ICMS devido pelo contribuinte substituto para fins de c�lculo do Cr�dito Outorgado (Transportadora com op��o regular).
    oServTran:SetnVcrout(aReg[19])                                              //19-Valor do Cr�dito Outorgado relativo � presta��o pr�pria.
    oServTran:SetnCroust(aReg[20])                                              //20-Valor do Cr�dito Outorgado relativo � presta��o cujo pagamento do imposto est� atribu�do ao tomador do servi�o (substitui��o tribut�ria).
    oServTran:SetnCredac(aReg[21])                                              //21-Valor do Cr�dito Acumulado gerado na presta��o
    oServTran:SetnIcmsde(aReg[22])                                              //22-Valor do ICMS devido na presta��o pr�pria
    oServTran:SetnVeicul(aReg[23])                                              //23-C�digo de IdentIFica��o do principal Ve�culo Rodovi�rio Transportador conforme registro 5725.
    oServTran:SetnKm(aReg[24])                                                  //24-Dist�ncia percorrida
    oServTran:SetnEnqleg(aReg[25])                                              //25-C�digo do Enquadramento Legal conforme registro 0300
    oServTran:SetnIndrat(aReg[26])                                              //26-�ndice de Rateio
    oServTran:SetnUcusto(aReg[27])                                              //27-Valor do custo de cada servi�o de transporte prestado.
    oServTran:SetnUicms(aReg[28])                                               //28-Valor do ICMS referente ao custo de cada servi�o de transporte prestado
    oTabela:GrvReg(oServTran:AddMov(cReg))
    oServTran:Clear(aReg[1])
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcObjIpi

Fun��o que preenche o objeto referente ao IPI e Outros tributos na Entrada

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function ProcObjIpi(oBloco5,oTabela,aReg,cChave, cReg)
    oIPIOut:=oBloco5
    oIPIOut:SetRelac(cChave)                                                    //0-Chave
    oIPIOut:SetcReg(aReg[1])                                                    //1-Texto Fixo contendo o n�mero do Registro
    oIPIOut:SetnValIpi(aReg[2])                                                 //2-Valor de do Ipi Quanto Recuperavel
    oIPIOut:SetnValTri(aReg[3])                                                //3-Valor de outros tributos e contribui��es n�o-cumulativos
    oTabela:GrvReg(oIPIOut:AddIpiOut(cReg))
    oIPIOut:Clear(aReg[1])
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcObjCrd

Fun��o que preenche o objeto referente as Opera��es Geradoras de Cr�dito Acumulado

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function ProcObjCrd(oBloco5,oTabela,aReg,cChave, cReg)
    oCredAc:=oBloco5
    oCredAc:SetRelac(cChave)                                                      //0-Chave
    oCredAc:SetcReg(aReg[1])                                                      //1-Texto Fixo contendo o n�mero do Registro
    oCredAc:SetnCodLeg(aReg[2])                                                   //2-C�digo do Enquadramento Legal
    oCredAc:SetnVlOpIt(aReg[3])                                                   //3-Valor Total da Opera��o relativo ao Item
    oCredAc:SetnCredAc(aReg[4])                                                   //4-Credito acumulado Gerado na Opera��o com o Item
    oTabela:GrvReg(oCredAc:AddOpCrdAc(cReg))
    oCredAc:Clear(aReg[1])
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcObj6A6B

Fun��o que preenche o objeto  opera��es geradoras apuradas nas fichas 6A/6B

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function PrcObj6A6B(oBloco5,oTabela,aReg,cChave, cReg)
    o6A6B:=oBloco5
    o6A6B:SetRelac(cChave)                                                          //0-Chave
    o6A6B:SetcReg(aReg[1])                                                          //1-Texto Fixo contendo o n�mero do Registro
    o6A6B:SetnBCIt(aReg[2])                                                         //2-Base de C�lculo da Opera��o de sa�da relativa ao item
    o6A6B:SetnAlqIt(aReg[3])                                                        //3-Al�quota de ICMS da Opera��o de sa�da relativa ao Item
    o6A6B:SetnICMDeb(aReg[4])                                                       //4-Icms debitado na opera��o de sa�da do item
    oTabela:GrvReg(o6A6B:AddOp6A6B(cReg))
    o6A6B:Clear(aReg[1])
RETURN


//-------------------------------------------------------------------
/*/{Protheus.doc} PrcObj6C6D

Fun��o que preenche o objeto  opera��es geradoras apuradas nas fichas 6C/6D

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function PrcObj6C6D(oBloco5,oTabela,aReg,cChave, cReg)
    o6C6D:=oBloco5
    o6C6D:SetRelac(cChave)                                                          //0-Chave
    o6C6D:SetcReg(aReg[1])                                                          //1-Texto Fixo contendo o n�mero do Registro
    o6C6D:SetnDecEx(aReg[2])                                                        //2-N�mero da Declara��o para Despacho
    o6C6D:SetnCompOp(aReg[3])                                                       //3-Comprova��o de Opera��o
    o6C6D:SetnVlCrICM(aReg[4])                                                      //4-Valor do Cr�dito de ICMS
    oTabela:GrvReg(o6C6D:AddOp6C6D(cReg))
    o6C6D:Clear(aReg[1])
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcExpInd

Fun��o que preenche o objeto com dados da exporta��o Indireta comprovada

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function PrcExpInd(oBloco5,oTabela,aReg,cChave, cReg)
    oExpInd:=oBloco5
    oExpInd:SetRelac(cChave)                                                        //0-Chave
    oExpInd:SetcReg(aReg[1])                                                        //1-Texto Fixo contendo o n�mero do Registro
    oExpInd:SetdDtExp(aReg[2])                                                      //2-Data do Documento Fiscal do Exportador
    oExpInd:SetcDocExp(aReg[3])                                                     //3-N�mero do Documento Fiscal do Exportador
    oExpInd:SetcSerExp(aReg[4])                                                     //4-S�rie do Documento Fiscal do Exportador
    oExpInd:SetcDeclaEx(aReg[5])                                                    //5-N�mero da Declara��o para Despacho de Exporta��o do Exportador
    oTabela:GrvReg(oExpInd:AddExpInd(cReg))
    oExpInd:Clear(aReg[1])
RETURN


//-------------------------------------------------------------------
/*/{Protheus.doc} PrcNCred

Fun��o que preenche o objeto com dados das Opera��es n�o geradoras de Cr�dito Acumulado

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function PrcNCred(oBloco5,oTabela,aReg,cChave, cReg)
    oNGerCr:=oBloco5
    oNGerCr:SetRelac(cChave)                                                        //0-Chave
    oNGerCr:SetcReg(aReg[1])                                                        //1-Texto Fixo contendo o n�mero do Registro
    oNGerCr:SetnVlOpIt(aReg[2])                                                     //2-Valor Total da Opera��o relativo ao Item
    oNGerCr:SetnBCIt(aReg[3])                                                       //3-Base de C�lculo da Opera��o de sa�da relativa ao item
    oNGerCr:SetnAlqIt(aReg[4])                                                      //4-Al�quota de ICMS da Opera��o de sa�da relativa ao Item
    oNGerCr:SetnICMDeb(aReg[5])                                                     //5-Icms debitado na opera��o de sa�da do item
    oNGerCr:SetnICMDev(aReg[6])                                                     //6-Icms devido na opera��o de sa�da relativo ao item
    oNGerCr:SetnVlCrICM(aReg[7])                                                    //7-Valor do Cr�dito de ICMS
    oTabela:GrvReg(oNGerCr:AddNGer(cReg))
    oNGerCr:Clear(aReg[1])
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcObjDev

Fun��o que preenche o objeto referente Registros de Devolu��o de Sa�da

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function ProcObjDev(oBloco5,oTabela,aReg,cChave, cReg)
    oDevSai:=oBloco5
    oDevSai:SetRelac(cChave)                                                        //0-Chave
    oDevSai:SetcReg(aReg[1])                                                        //1-Texto Fixo contendo o n�mero do Registro
    oDevSai:SetdDtSai(aReg[2])                                                      //2-Data da emiss�o do documento fiscal que acobertou a opera��o original do item devolvido
    oDevSai:SetnTipDocDev(aReg[3])                                                  //3-Tipo do documento conforme a coluna C�digo chave da tabela 4.2 ou campo 02 do registro 0400
    oDevSai:SetcSerieDe(aReg[4])                                                    //4-S�rie do documento que acobertou a opera��o original
    oDevSai:SetcDocDev(aReg[5])                                                     //5-N�mero do documento que acobertou a opera��o original
    oTabela:GrvReg(oDevSai:AddDevSai(cReg))
    oDevSai:Clear(aReg[1])
RETURN
//-------------------------------------------------------------------
/*/{Protheus.doc} ProcObjApu

Fun��o que preenche o objeto referente apura��o de Custo

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------

Static Function ProcObjApu(oBloco5,oTabela,aReg,cChave, cReg)
    oApur:=oBloco5
    oApur:SetRelac(cChave)                                                          //0-Chave
    oApur:SetcReg(aReg[1])                                                          //1-Texto Fixo contendo o n�mero do Registro
    oApur:SetcProdIns(aReg[3])                                                      //2-C�digo do Insumo conforme registro 0200
    oApur:SetnQtdInsUt(aReg[4])                                                     //3-Quantidade de Insumo Utilizada
    oApur:SetnCusUntIns(aReg[5])                                                    //4-Custo Unit�rio do Insumo por Unidade de produto
    oApur:SetnVUntICMIn(aReg[6])                                                    //5-Valor Unit�rio do ICMS do Insumo por Unidade de produto
    oApur:SetnPerdaNorm(aReg[7])                                                    //6-Quantidade de Perda Normal no Processo Produtivo
    oApur:SetnGanhoNorm(aReg[8])                                                    //7-Quantidade de Ganho Normal no Processo Produtivo
    oTabela:GrvReg(oApur:AddApurCus(cReg))
    oApur:Clear(aReg[1])
RETURN


//-------------------------------------------------------------------
/*/{Protheus.doc} PrcObApCus

Fun��o que preenche o objeto referente apura��o de Custo

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function PrcObApCus(oBloco5,oTabela,aReg,cChave, cReg)
    oAlocCust:=oBloco5
    oAlocCust:SetRelac(cChave)                                                     //0-Chave
    oAlocCust:SetcReg(aReg[1])                                                     //1-Texto Fixo contendo o n�mero do Registro
    oAlocCust:SetcCoProd(aReg[2])                                                  //2-C�digo do co-produto, conforme Registro 0200
    oAlocCust:SetnQtdCoPr(aReg[3])                                                 //3-Quantidade de Co-Produto resultante do Insumo conjunto no per�odo
    oAlocCust:SetnPrcMed(aReg[4])                                                  //4-Pre�o M�dio de Sa�da do Co-Produto
    oAlocCust:SetnVlPrjS(aReg[5])                                                  //5-Valor Projetado das Sa�das
    oAlocCust:SetnPercAlc(aReg[6])                                                 //6-Percentual de aloca��o                                                  //7-Quantidade de Ganho Normal no Processo Produtivo
    oTabela:GrvReg(oAlocCust:AddApurCus(cReg))
    oAlocCust:Clear(aReg[1])
RETURN


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcOBJInv

Fun��o que preenche o objeto referente aos Invent�rio

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function ProcOBJInv(oBloco5,oTabela,aReg,cChave, cReg)
    
    IF cReg == "5590"
        oInvAb:=oBloco5
        oInvAb:SetRelac(cChave)                                                        //0-Chave
        oInvAb:SetcReg(aReg[1])                                                        //1-Texto Fixo contendo o n�mero do Registro
        oInvAb:SetcPrdInv(aReg[2])                                                     //2-C�digo do Produto em Elabora��o
        oTabela:GrvReg(oInvAb:AddInv(cReg))
        oInvAb:Clear(aReg[1])
    ELSEIF cReg == "5595"
        oInvent:=oBloco5
        oInvent:SetRelac(cChave)                                                        //0-Chave
        oInvent:SetcReg(aReg[1])
        oInvent:SetcInsInv(aReg[3])                                                     //3-C�digo do Insumo conforme registro 0200
        oInvent:SetnQTDIn(aReg[4])                                                     //4-Quantidade do Insumo Utilizado
        oInvent:SetnCust(aReg[5])                                                       //5-Custo do Insumo
        oInvent:SetnICMIns(aReg[6])                                                     //6-Valor do ICMS do Insumo
        oTabela:GrvReg(oInvent:AddInv(cReg))
        oInvent:Clear(aReg[1])
        
    ENDIF
RETURN



//-------------------------------------------------------------------
/*/{Protheus.doc} ProcObjVei

Fun��o que preenche o objeto referente aos veiculos

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function ProcObjVei(oBloco5,oTabela,aReg,cChave)
    oVeic:=oBloco5
    oVeic:SetRelac(cChave)                                                              //0-Chave
    oVeic:SetcReg(aReg[1])                                                              //1-Texto Fixo contendo o n�mero do Registro
    oVeic:SetcCodVeic(aReg[2])                                                          //2-C�digo de IndentIFica��o do Ve�culo Transportador
    oVeic:SetnCNPJ(aReg[3])                                                             //3-CNPJ do Propriet�rio
    oVeic:SetcPlc(aReg[4])                                                              //4-Placa do Ve�culo
    oVeic:SetcUFVeic(aReg[5])                                                           //5-Unidade de Federa��o de Registro do Ve�culo
    oVeic:SetcMunc(aReg[6])                                                             //6-Munic�pio
    oVeic:SetcRenav(aReg[7])                                                            //7-N�mero do Renavan
    oVeic:SetcMarc(aReg[8])                                                             //8-Marca do Ve�culo
    oVeic:SetcModel(aReg[9])                                                            //9-Modelo do Ve�culo
    oVeic:SetnAno(aReg[10])                                                             //10-Ano de Fabrica��o
    oVeic:SetnRend(aReg[11])                                                            //11-Rendimento do Combust�vel
    oTabela:GrvReg(oVeic:AddVeiculo(aReg[1]))
    oVeic:Clear(aReg[1])
RETURN

//-------------------------------------------------------------------
/*/{Protheus.doc} CodFicha

Fun��o que retorna o C�digo do registro de acordo com a ficha

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
/**/
Static Function CodFicha(cCodFicha, nTipo, cCodLan)
    
    Local cAbert    := ""
    Local cMovim    := ""
    Local cIpiOut   := ""
    Local cRet      := ""
    Local cDevSai   := ""
    Local cApur     := ""
    Local cCredAcu  := ""
    Local c6A6B     := ""
    Local c6C6D     := ""
    Local cExp      := ""
    Local cOpNG     := ""
    Local cPreSer   := ""
    Local cInvent   := ""
    /*
    1 - Registros de Abertura		- cAbert
    2 - Registros de Movimenta��o	- cMovim
    3 - Registros IPI/ Outros tributos na Entrada - cIpiOut
    4 - Apura��o de Custo - cApur
    5 - Devolu��o de sa�da - cDevSai
    6 - Credito Acumulado - cCredAcu
    7 - Opera��es Geradoras apuradas nas Fichad 6A/6B - c6A6B
    8 - Opera��es Geradoras apuradas nas Fichad 6C/6D - c6C6D
    9 - Exporta��o Indireta Comprovada	- cExp
    10 - Opera��es n�o geradoras de Cr�dito Acumulado - cOpNG
    11 - Invent�rio - cInvent
    12 - Presta��o de Servi�oes
    */
    
    Do Case
        /*M�dulo 1 - Insumos*/
        /*Ficha 1A - Controle de Materiais*/
    Case cCodFicha=="11"
        cAbert      :=  "5010"
        cMovim      :=  "5015"
        cIpiOut     :=  "5020"
        /*Ficha 1B -  Controle de Valores Agregados na Industrializa��o por Outro Estabelecimento*/
    Case cCodFicha=="12"
        cAbert      :=  "5060"
        cMovim      :=  "5065"
        cIpiOut     :=  "5070"
        /*Ficha 1C - Controle de Energia El�trica*/
    Case cCodFicha=="13"
        cAbert      :=  "5080"
        cMovim      :=  "5085"
        cIpiOut     :=  "5090"
        /*Ficha 1D - Controle de Ser�os de Comunica��es*/
    Case cCodFicha=="14"
        cAbert      :=  "5100"
        cMovim      :=  "5105"
        /*Ficha 1E - Controle de Aquisi��o de Servi�oes de Transportes Utilizados nas Presta��es da mesma naturea*/
    Case cCodFicha=="15"
        cAbert      :=  "5110"
        cMovim      :=  "5115"
        /*M�dulo 2 - Processo produtico*/
        /*Ficha 2A - Produtos em Elabora��o - Industrializa��o no Estabelecimento*/
    Case cCodFicha=="21"
        cAbert      :=  "5150"
        cApur       :=  "5155"
        cMovim      :=  "5160"
        /*Ficha 2B - Produtos em Elabora��o - Industrializa��o em outro Estabelecimento*/
    Case cCodFicha=="22"
        cAbert      :=  "5165"
        cApur       :=  "5170"
        cMovim      :=  "5175"
        /*Ficha 2C - Produtos em Elabora��o - Industrializa��o para outro Estabelecimento*/
    Case cCodFicha=="23"
        cAbert      :=  "5180"
        cMovim      :=  "5185"
        /*Ficha 2D - Apura��o de Custo dos Servi�oes de Transporte */
    Case cCodFicha=="24"
        cAbert      :=  "5190"
        cMovim      :=  "5195"
        /*Ficha 2E - Gastos Gerais de Fabrica��o*/
    Case cCodFicha=="25"
        cAbert      :=  "5210"
        cMovim      :=  "5215"
        /*Ficha 2F - Distribui��o do Custo e ICMS do Insumo Conjunto - M�todo do Pre�o de Sa�da*/
    Case cCodFicha=="26"
        cAbert      :=  "5230"
        cApur       :=  "5235"
        cMovim      :=  "5240"
        /*Ficha 2G - Produtos em Elabora��o - Produ��o Conjunta - M�todo da Ficha T�cnica*/
    Case cCodFicha=="27"
        cAbert      :=  "5260"
        cApur       :=  "5270"
        cMovim      :=  "5275"
        /*M�dulo 3 - Produtos Acabados e Mercadorias para a Revenda*/
        /*Ficha 3A - Controle de Produtos Acabados*/
    Case cCodFicha=="31"
        cAbert      :=  "5310"
        cMovim      :=  "5315"
        cDevSai     :=  "5320"
        cCredAcu    :=  "5325"
        /*Ficha 3B - Controle de Mercadorias para Revenda*/
    Case cCodFicha=="32"
        cAbert      :=  "5360"
        cMovim      :=  "5365"
        cIpiOut     :=  "5370"
        cCredAcu    :=  "5380"
        cDevSai     :=  "5375"
    
    /*Ficha 3C Controle de Custo Agregado na Industrializa��o para outro estabelecimento - */
Case cCodFicha=="33"
    cAbert      :=  "5410"
    cMovim      :=  "5415"
    cDevSai     :=  "5420"
    cCredAcu    :=  "5425"

/*Ficha 5B - Demonstrativo de Materiais Resultantes de Perdas e Sobras*/
Case cCodFicha=="52"
    cAbert      :=  "5550"
    cMovim      :=  "5555"
    /*Ficha 5G - Invent�rio de Produtos em Elabora��o por Material Componente*/
Case cCodFicha=="56"
    cAbert      :=  "5590"
    cInvent     :=  "5595"
    /*Ficha 6A - Demonstrativo das Opera��es Geradoras de Cr�dito Acumulado do ICMS
    FICHA 6B - Demonstrativo das Opera��es Geradoras de Cr�dito Acumulado do ICMS  */
Case cCodFicha$"61|62" .And. cCodLan == "31"
    c6A6B       :=  "5330"
Case cCodFicha$"61|62" .And. cCodLan == "32"
    c6A6B       :=  "5385"
Case cCodFicha$"61|62" .And. cCodLan == "33"
    c6A6B       :=  "5430"
    /*Ficha 6C - Demonstrativo das Opera��es Geradoras de Cr�dito Acumulado do ICMS
    Ficha 6D - Demonstrativo das Opera��es Geradoras de Cr�dito Acumulado do ICMS*/
Case cCodFicha$"63|64" .And. cCodLan == "31"
    c6C6D       :=  "5335"
    cExp        :=  "5340"
Case cCodFicha$"63|64" .And. cCodLan == "32"
    c6C6D       :=  "5390"
    cExp        :=  "5395"
Case cCodFicha$"63|64" .And. cCodLan == "33"
    c6C6D       :=  "5435"
    /*Ficha 6F -  Demonstrativo das Opera��es n�o Geradoras de Cr�dito Acumulado do ICMS*/
Case cCodFicha=="66" .And. cCodLan == "31"
    cOpNG       :=  "5350"
Case cCodFicha=="66" .And. cCodLan == "32"
    cOpNG       :=  "5400"
Case cCodFicha=="66" .And. cCodLan == "33"
    cOpNG       :=  "5440"
    /*Ficha 6G - Demonstrativo das Presta��es de Servi�o de Transporte - Cr�dito Outorgado*/
Case cCodFicha=="67"
    cPreSer     := "5720"
    /*Ficha 6H - Demonstratido das Presta��es de Servi�o de Transporte - Combust�vel e Redespacho*/
Case cCodFicha=="68"
    cPreSer     := "5730"
EndCase

/*nTipo 1 - Registros de Abertura*/
IF  nTipo == "1"
    cRet := cAbert
    /*nTipo 2 - Registros de Movimenta��o*/
ELSEIF nTipo == "2"
    cRet := cMovim
    /*nTipo 3 - Registros IPI/ Outros tributos na Entrada*/
ELSEIF nTipo == "3"
    cRet := cIpiOut
    /*nTipo 4 - Apura��o de Custo*/
ELSEIF nTipo == "4"
    cRet := cApur
    /*nTipo 5 - Devolu��o de sa�da*/
ELSEIF nTipo == "5"
    cRet	:= cDevSai
    /*nTipo 6 - Credito Acumulado*/
ELSEIF nTipo == "6"
    cRet	:= 	cCredAcu
    /*nTipo 7 - Opera��es Geradoras apuradas nas Fichad 6A/6B*/
ELSEIF nTipo == "7"
    cRet	:= c6A6B
    /*nTipo 8 - Opera��es Geradoras apuradas nas Fichad 6C/6D*/
ELSEIF nTipo == "8"
    cRet	:= c6C6D
    /*nTipo 9 - Exporta��o Indireta Comprovada*/
ELSEIF nTipo == "9"
    cRet	:= cExp
    /*nTipo 10 - Opera��es n�o geradoras de Cr�dito Acumulado*/
ELSEIF nTipo == "10"
    cRet	:= cOpNG
    /*nTipo 11 - Invent�rio*/
ELSEIF nTipo == "11"
    cRet  := cInvent
    /*nTipo 12 - Presta��o de Servi�oes*/
ELSEIF nTipo == "12"
    cRet  := cPreSer
ENDIF

RETURN cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} QtdRegMov

Fun��o que retorna a quantidade de registros de Movimenta��o

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function QtdRegMov(dDataDe, dDataAte)
    Local cAlias := ''
    Local nQtde     := 0
    
    cAlias  :=  GetNextAlias()
    
    BeginSql Alias cAlias
        
        COLUMN CLQ_DATA AS DATE
        
        SELECT  COUNT(0) as QUANTIDADE
        FROM       %TABLE:CLR% CLR
        WHERE  CLR.CLR_FILIAL=%XFILIAL:CLR%
        AND CLR.%NOTDEL%
        AND CLR.CLR_PERIOD >= %EXP:DDATADE%
        AND CLR.CLR_PERIOD <= %EXP:DDATAATE%
        
    EndSql
    DbSelectArea (cAlias)
    
    
    Do While !(cAlias)->(Eof ())
        
        nQtde   := (cAlias)->QUANTIDADE
        
        (cAlias)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAlias)
    (cAlias)->(DbCloseArea ())
    
Return nQtde

//-------------------------------------------------------------------
/*/{Protheus.doc} Qtd0150

Fun��o que retorna a quantidade de registros de Participantes

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------

Static Function Qtd0150(dDataDe, dDataAte)
    Local cAlias := ''
    Local nQtde     := 0
    
    
    cAlias  :=  GetNextAlias()
    
    BeginSql Alias cAlias
        
        COLUMN CLQ_DATA AS DATE
        
        SELECT COUNT(0) AS QUANTIDADE
        FROM    %TABLE:CLP% CLP
        WHERE  CLP.CLP_FILIAL=%XFILIAL:CLP%
        AND CLP.CLP_PERIOD >= %EXP:dDataDe%
        AND CLP.CLP_PERIOD <=%EXP:dDataAte%
        AND CLP.%NOTDEL%
        
    EndSql
    DbSelectArea (cAlias)
    
    
    Do While !(cAlias)->(Eof ())
        
        nQtde   := (cAlias)->QUANTIDADE
        
        (cAlias)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAlias)
    (cAlias)->(DbCloseArea ())
    
Return nQtde


//-------------------------------------------------------------------
/*/{Protheus.doc} Qtd0200

Fun��o que retorna a quantidade de registros de Produtos

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function Qtd0200(dDataDe, dDataAte, nTotal)
    Local cAlias := ''
    Local nQtde     := 0
    
    cSelect := "COUNT(0) AS QUANTIDADE "
    cFrom   := +RetSqlName("SB1")+ " SB1"
    cWhere  := "SB1.B1_FILIAL ='"+xFilial("SB1")+"' AND  SB1.D_E_L_E_T_ = ' '"
    
    IF nTotal == 2
        cFrom   += "," +RetSqlName("F04")+ " F04" "
        cWhere  += "AND SB1.B1_COD = F04.F04_PROD  AND F04.F04_FILIAL='"+xFilial("F04")+"'AND "
        cWhere  += "F04.F04_PERIOD >='"+dDataDe+"' AND F04.F04_PERIOD <='"+dDataAte+"' AND F04.D_E_L_E_T_ = ' ' "
    ENDIF
    
    cSelect := '%'+cSelect+'%'
    cFrom   := '%'+cFrom+'%'
    cWhere  := '%'+cWhere+'%'
    
    cAlias  :=  GetNextAlias()
    
    BeginSql Alias cAlias
        
        SELECT
        %Exp:cSelect%
        
        FROM
        %Exp:cFrom%
        WHERE
        %Exp:cWhere%
        
    EndSql
    DbSelectArea (cAlias)
    
    Do While !(cAlias)->(Eof ())
        
        nQtde   := (cAlias)->QUANTIDADE
        
        (cAlias)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAlias)
    (cAlias)->(DbCloseArea ())
    
Return nQtde


//-------------------------------------------------------------------
/*/{Protheus.doc} Qtd0300

Fun��o que retorna a quantidade de registros de Enquadramento Legal

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function Qtd0300(dDataDe, dDataAte)
    Local cAlias := ''
    Local nQtde     := 0
    
    
    cAlias  :=  GetNextAlias()
    
    BeginSql Alias cAlias
        
        SELECT COUNT(0) AS QUANTIDADE
        FROM   %TABLE:CCV% CCV
        INNER JOIN %TABLE:CLR% CLR ON(CCV.CCV_CODLEG = CLR.CLR_ENQLEG
        AND CCV.%NOTDEL%
        AND CCV.CCV_FILIAL=%XFILIAL:CCV%)
        WHERE CLR.CLR_FILIAL=%XFILIAL:CLR%
        AND CLR.%NOTDEL%
        AND CLR.CLR_PERIOD >= %EXP:dDataDe%
        AND CLR.CLR_PERIOD <= %EXP:dDataAte%
        
    EndSql
    DbSelectArea (cAlias)
    
    
    Do While !(cAlias)->(Eof ())
        
        nQtde   := (cAlias)->QUANTIDADE
        
        (cAlias)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAlias)
    (cAlias)->(DbCloseArea ())
    
Return nQtde


//-------------------------------------------------------------------
/*/{Protheus.doc} Qtd0400

Fun��o que retorna a quantidade de registros de Doc Interno

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function Qtd0400(dDataDe, dDataAte)
    Local cAlias := ''
    Local nQtde     := 0
    
    
    cAlias  :=  GetNextAlias()
    
    BeginSql Alias cAlias
        
        SELECT DISTINCT CLZ.CLZ_CODIGO, COUNT(CLZ.CLZ_CODIGO)
        FROM %TABLE:CLZ% CLZ
        INNER JOIN %TABLE:CLR% CLR ON(CLZ.CLZ_CODIGO = CLR.CLR_TPDOC
        AND CLZ.CLZ_FILIAL=%XFILIAL:CLZ%
        AND CLZ.%NOTDEL%)
        WHERE CLR.CLR_FILIAL=%XFILIAL:CLR%
        AND CLR.%NOTDEL%
        AND CLR.CLR_PERIOD >= %EXP:dDataDe%
        AND CLR.CLR_PERIOD <= %EXP:dDataAte%
        GROUP BY CLZ.CLZ_CODIGO
        HAVING COUNT(CLZ.CLZ_CODIGO) > 0
        
    EndSql
    DbSelectArea (cAlias)
    
    
    Do While !(cAlias)->(Eof ())
        
        nQtde   += 1
        
        (cAlias)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAlias)
    (cAlias)->(DbCloseArea ())
    
Return nQtde

//-------------------------------------------------------------------
/*/{Protheus.doc} QtdInvent

Fun��o que retorna a quantidade de registros de Doc Iventario

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function QtdInvent(dDataDe, dDataAte)
    Local cAlias := ''
    Local nQtde     := 0
    
    
    cAlias  :=  GetNextAlias()
    
    BeginSql Alias cAlias
        
        SELECT   COUNT(0) AS QUANTIDADE
        FROM     %TABLE:CLV% CLV
        WHERE    CLV.%NOTDEL%
        AND      CLV.CLV_PERIOD >= %EXP:DDATADE%
        AND      CLV.CLV_PERIOD <= %EXP:DDATAATE%
        
        
    EndSql
    DbSelectArea (cAlias)
    
    Do While !(cAlias)->(Eof ())
        
        nQtde   := (cAlias)->QUANTIDADE
        
        (cAlias)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAlias)
    (cAlias)->(DbCloseArea ())
    
Return nQtde


//-------------------------------------------------------------------
/*/{Protheus.doc} QtdRegAber

Fun��o que retorna a quantidade de registros de abertura

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------

Static Function QtdRegAber(dDataDe, dDataAte)
    Local cAlias := ''
    Local cPeriodo  := AnoMes(stod(dDataDe))
    Local nQtde     := 0
    
    
    cAlias  :=  GetNextAlias()
    
    BeginSql Alias cAlias
        
        SELECT COUNT(0) AS QUANTIDADE
        FROM  %TABLE:F04% F04
        LEFT JOIN %TABLE:CDU% CDU
        ON( CDU.CDU_PRODUT = F04.F04_PROD
        AND CDU_FICHA = F04.F04_FICHA
        AND CDU.CDU_FILIAL = %XFILIAL:CDU%
        AND CDU.%NOTDEL%
        AND CDU.CDU_PERIOD = %EXP:cPeriodo%)
        WHERE  F04.F04_FILIAL = %XFILIAL:F04%
        AND F04.%NOTDEL%
        AND F04.F04_PERIOD >= %EXP:dDataDe%
        AND F04.F04_PERIOD <= %EXP:dDataAte%
        
        
    EndSql
    DbSelectArea (cAlias)
    
    
    Do While !(cAlias)->(Eof ())
        
        nQtde   := (cAlias)->QUANTIDADE
        
        (cAlias)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAlias)
    (cAlias)->(DbCloseArea ())
    
Return nQtde

//-------------------------------------------------------------------
/*/{Protheus.doc} QtdRegAPur

Fun��o que retorna a quantidade de registros da Apura��o

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------

Static Function QtdRegAPur(dDataDe, dDataAte)
    Local cAlias := ''
    Local nQtde     := 0
    
    cAlias  :=  GetNextAlias()
    
    BeginSql Alias cAlias
        
        SELECT COUNT(0) AS QUANTIDADE
        FROM %TABLE:CLU% CLU
        WHERE CLU.CLU_FILIAL=%XFILIAL:CLU%
        AND CLU.%NOTDEL%
        AND CLU.CLU_PERIOD >= %EXP:dDataDe%
        AND CLU.CLU_PERIOD <= %EXP:dDataAte%
        
    EndSql
    DbSelectArea (cAlias)
    
    
    Do While !(cAlias)->(Eof ())
        
        nQtde   := (cAlias)->QUANTIDADE
        
        (cAlias)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAlias)
    (cAlias)->(DbCloseArea ())
    
Return nQtde

//-------------------------------------------------------------------
/*/{Protheus.doc} QtdAlcCust

Fun��o que retorna a quantidade de registros de Aloca��o de Custo

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------

Static Function QtdAlcCust(dDataDe, dDataAte)
    Local cAlias := ''
    Local nQtde     := 0
    
    cAlias  :=  GetNextAlias()
    
    BeginSql Alias cAlias
        
        SELECT COUNT(0) AS QUANTIDADE
        FROM     %TABLE:CLT% CLT
        WHERE    CLT.CLT_FILIAL=%XFILIAL:CLT%
        AND      CLT.%NOTDEL%
        AND      CLT.CLT_PERIOD >= %EXP:DDATADE%
        AND      CLT.CLT_PERIOD <= %EXP:DDATAATE%
        
    EndSql
    DbSelectArea (cAlias)
    
    
    Do While !(cAlias)->(Eof ())
        
        nQtde   := (cAlias)->QUANTIDADE
        
        (cAlias)->(DbSkip ())
    EndDo
    
    DbSelectArea (cAlias)
    (cAlias)->(DbCloseArea ())
    
Return nQtde


Static Function ProcCancel(lCancel,oTabela)
    lCancel:=.T.
    oTabela:DelTabela()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TabTemp

Esta fun��o passa as informa��es necess�rias para a cria��o da tabela Temporaria

@author Graziele Paro
@since 10/07/2015

/*/
//-------------------------------------------------------------------
Static Function TabTemp()
    Local oTabTemp  := TEMPORARIA():New()
    Local cNomeArq  := Alltrim(MV_PAR06) /*Nome do arquivo*/
    Local nRemType  := GetRemoteType() /*IdentIFica a tipo e vers�o do Smart Client em execu��o.*/
    Local cDir      := Alltrim(MV_PAR05)+ Iif(IsBlind(),"",Alltrim(cfilAnt)) 
    
    /*Cria o Diret�rio*/
    MakeDir(cDir)
    
    /*Tratamento para Linux onde a barra e invertida*/
    IF nRemType == 2  /*REMOTE_LINUX*/
        IF (SubStr (cDir, Len (cDir), 1)<>"/")
            cDir    +=  "/"
        ENDIF
    ELSE
        IF (SubStr (cDir, Len (cDir), 1)<>"\")
            cDir    +=  "\"
        ENDIF
    ENDIF
    
    /*Passa nome do arquivo para objeto*/
    oTabTemp:setcNomeArq(cNomeArq)
    
    /*Passa o diretorio para o Objeto*/
    oTabTemp:setcDireto(cDir)
    
    /*Cria tabela tempor�ria*/
    oTabTemp:CriaTabela()
    
RETURN oTabTemp

//-------------------------------------------------------------------
/*/{Protheus.doc} FisAddHash

Insere chave no objeto HashMap

@author Ulisses P. Oliveira
@since 12/09/2019

/*/
//-------------------------------------------------------------------
Static Function FisAddHash(oHash,cChave,nPos)
Local cSet := "HMSet"

&cSet.(oHash, cChave, nPos)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FisAddHash

Localiza chave no objeto HashMap, retornado sua posi��o na estrutura

@author Ulisses P. Oliveira
@since 12/09/2019

/*/
//-------------------------------------------------------------------
Static Function FisFindHash(oHash, cChave)
Local nPosRet := 0
Local cGet    := "HMGet"

&cGet.( oHash , cChave  , @nPosRet )

Return nPosRet
