#Include "FISA194.ch"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA194

Função para geração do arquivo da CAT42/2018.

@author Eduardo Vicente da Silva
@since 07/11/2018

/*/
//-------------------------------------------------------------------

/*Rotina de geração do arquivo texto da CAT42/2018*/
Function FISA194() 

Private lAutomato   := IiF(IsBlind(),.T.,.F.)
       
If AliasIndic("F2V")
	    
    If !lAutomato
        If pergunte('FISA194',.T.,STR0001) //STR0001 //"Parâmetros de geração do arquivo"
                
            FwMsgRun(,{|oSay| ProcArq(oSay) },STR0002,"")	 //"Processando do arquivo"
            
        EndIf
    Else
        ProcArq()
    EndIf

Else
    Alert(STR0003) //'Dicionário está desatualizado, por favor verifique atualização das tabelas'
EndIf
            
Return

/*/{Protheus.doc} ProcArq

Rotina que chama as funções de cada registro

@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//-------------------------------------------------------------------
Static Function ProcArq(oSay)
    
Local oTabela
Local oBloco0     := BLOCOREG():New()
Local aNumeracao  := {}
Local cChave0001  := '0001000000001'
Local cAnoMes     := AllTrim(MV_PAR01)
Local lConcFil	  := SUPERGETMV('MV_COFLSPD', .F., .T.)
Local lGeraHist   := Iif(MV_PAR06==1,.T.,.F.)

AtualizaMsg( oSay, STR0004 ) //"Selecionando os registros"

oTabela	:= TabTemp()
		
Reg0000(oSay,oBloco0,oTabela,@aNumeracao,cAnoMes)
		
Reg0150(oSay,oBloco0,oTabela,@aNumeracao,cChave0001,cAnoMes,lConcFil)
			
Reg0200(oSay,oBloco0,oTabela,@aNumeracao,cChave0001,cAnoMes,lConcFil,lGeraHist)
				
Reg1100(oSay,oBloco0,oTabela,@aNumeracao,cChave0001,cAnoMes,lConcFil)
						
/*Grava o Arquivo TXT*/
otabela:GravaTXT()

AtualizaMsg( oSay, STR0005 ) //"Gravando arquivo texto"

/*Chama a Classe que fecha a tabela temporária*/
oTabela:DelTabela()
		
/*Elimina da memória a instância do objeto informado como parâmetro.*/
FreeObj(oBloco0)
oBloco0:= nil
	
AtualizaMsg( oSay, STR0006 ) //"Processamento Concluído"

If !lAutomato
    MsgInfo(STR0008,STR0007) //'Atenção' //"Arquivo gerado com Sucesso"
EndIf

Return

/*REGISTROS BLOCO 0*/
//-------------------------------------------------------------------
/*/{Protheus.doc} Reg0000

Função que gera o Registro 0000

@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//-------------------------------------------------------------------
Static Function Reg0000 (oSay, oBloco0, oTabela,aNumeracao,cAnoMes)  
Local aReg0000	:= {}
Local cCodMun   := Iif(Upper(SM0->M0_ESTENT) == "EX","",Iif(Len(Alltrim(SM0->M0_CODMUN))<=5,UfCodIBGE(SM0->M0_ESTENT),"")+SM0->M0_CODMUN)
Local cMesAno   := Substr(MV_PAR01,5,2) + Substr(MV_PAR01,1,4)
Local cLayout   := StrZero(Val(ALLTRIM(MV_PAR02)),2)
Local cFinArq   := ""

AtualizaMsg( oSay, STR0009 ) //"Processando Registro 0000"

If MV_PAR03 == 1
    cFinArq := "00"
ElseIf MV_PAR03 == 2
    cFinArq := "01"
ElseIf MV_PAR03 == 3
    cFinArq := "02"
EndIf

/*Preenche Array com os dados do Registro 0000*/
aAdd(aReg0000, "0000")				/*01-Texto Fixo Contendo "0000"*/
aAdd(aReg0000, cMesAno)				/*02-Mês e Ano do período processado*/
aAdd(aReg0000, SM0->M0_NOMECOM)		/*03-Nome empresarial do estabelecimento informante*/
aAdd(aReg0000, SM0->M0_CGC)			/*04-CNPJ do Estabelecimento Informante*/
aAdd(aReg0000, SM0->M0_INSC)		/*05-CNPJ do Estabelecimento Informante*/
aAdd(aReg0000, cCodMun)             /*06-Código do Municipio do Estabelecimento Informante*/
aAdd(aReg0000, ALLTRIM(cLayout))	/*07-Código da Versão do Layout conforme tabela 3.1*/
aAdd(aReg0000, ALLTRIM(cFinArq))	/*08-Código da Finalidade de entrega do arquivo*/

Proc0000(oBloco0, aReg0000, oTabela)
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc0000

Função para gravar Registro 0000, passando os dados do array para o Objeto

@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//-------------------------------------------------------------------
Static Function Proc0000(o0000, aReg0000, oTabela)

o0000:setRelac()
o0000:SetcReg(aReg0000[1])
o0000:SetcPeriodo(aReg0000[2])
o0000:SetcNome(aReg0000[3])
o0000:SetnCNPJ(aReg0000[4])
o0000:SetcIE(aReg0000[5])
o0000:SetsetUF(aReg0000[6])
o0000:SetcVersao(aReg0000[7])
o0000:SetcFinalid(aReg0000[8])

oTabela:GrvReg(o0000:Add0000(aReg0000[1]))

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg0150

Função para buscar dados do Registro 0150 - Cadastro de Participantes de operações e prestações

@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//-------------------------------------------------------------------
Static Function Reg0150 (oSay,oBloco0,oTabela, aNumeracao, cChavePai,cAnoMes,lConcFil)
Local aReg0150	  := {}
Local cCodMun     := Iif(Upper(SM0->M0_ESTENT) == "EX","",Iif(Len(Alltrim(SM0->M0_CODMUN))<=5,UfCodIBGE(SM0->M0_ESTENT),"")+SM0->M0_CODMUN)
Local cCnpjEmp    := SM0->M0_CGC
Local cAliasPTC	  := ""
Local cChave	  := ''
Local lExterior   := .F.
Local cAlias      := ""
Local cPartic     := ""
Local cCodPart    := ""
Local cLojPart    := ""
Local cCnpj       := ""
Local cIe         := ""
Local nTamPartic  := TamSx3("F2U_PARTIC")[1]
Local nTamLoja    := TamSx3("F2U_LOJA")[1]



cChave:= oBloco0:getGrupo()

AtualizaMsg( oSay, STR0010 ) //"Processando Registro 0150"

cAlias      := GetNextAlias()

SelMovto(cAlias, cAnoMes, "0150")

dbSelectArea (cAlias)

While !(cAlias)->(EOF())

    cAliasPTC	:= GetNextAlias()

    cCodPart := (cAlias)->(SubStr((cAlias)->F2U_ALIAS, 4, nTamPartic))
    cLojPart := (cAlias)->(SubStr((cAlias)->F2U_ALIAS, (nTamPartic + 4), nTamLoja))

    cPartic  := SubStr((cAlias)->F2U_ALIAS, 1, 3) + Iif(lConcFil, cFilAnt, "") + SubStr((cAlias)->F2U_ALIAS, 4)

    If (SubStr((cAlias)->F2U_ALIAS, 1, 3)) == "SA2"

        BeginSql Alias cAliasPTC
        
            SELECT  A2_NOME NOME,
                    A2_CODPAIS CODPAIS,
                    A2_CGC CGC,
                    A2_INSCR INSCR,
                    A2_COD_MUN COD_MUN,
                    A2_EST EST,
                    A2_TIPO TIPO
            FROM 	%TABLE:SA2% SA2
            WHERE  SA2.A2_FILIAL=%XFILIAL:SA2%
            AND SA2.A2_COD  = %EXP:cCodPart%
            AND SA2.A2_LOJA = %EXP:cLojPart%
            AND SA2.%NOTDEL%
            AND SA2.A2_CGC != %EXP:cCnpjEmp%
            
        EndSql

    Else

        BeginSql Alias cAliasPTC
        
            SELECT  A1_NOME NOME,
                    A1_CODPAIS CODPAIS,
                    A1_CGC CGC,
                    A1_INSCR INSCR,
                    A1_COD_MUN COD_MUN,
                    A1_EST EST,
                    A1_PESSOA TIPO
            FROM 	%TABLE:SA1% SA1
            WHERE  SA1.A1_FILIAL=%XFILIAL:SA1%
            AND SA1.A1_COD  = %EXP:cCodPart%
            AND SA1.A1_LOJA = %EXP:cLojPart%
            AND SA1.%NOTDEL%
            AND SA1.A1_CGC != %EXP:cCnpjEmp%
            
        EndSql

    EndIf

    dbSelectArea (cAliasPTC)

    If !(cAliasPTC)->(EOF())

        aReg0150:= {}

        lExterior := (cAliasPTC)->EST == "EX"
        cCnpj     := AllTrim((cAliasPTC)->CGC)
        cIe       := AllTrim((cAliasPTC)->INSCR)

        aAdd(aReg0150,"0150")
        aAdd(aReg0150,cPartic)
        aAdd(aReg0150,(cAliasPTC)->NOME)
        aAdd(aReg0150,Iif(Len((cAliasPTC)->CODPAIS) == 5, SubStr((cAliasPTC)->CODPAIS, 2, 4), (cAliasPTC)->CODPAIS))
        aAdd(aReg0150,IIF(lExterior .Or. (cAliasPTC)->TIPO == "F", "", cCnpj))
        aAdd(aReg0150,IIF(lExterior .Or. (cAliasPTC)->TIPO == "J", "", cCnpj))
        aAdd(aReg0150,IIF(lExterior,"",Iif(Empty(cIe),"ISENTO",cIe)))
        aAdd(aReg0150,IIF(lExterior .Or. Empty(AllTrim((cAliasPTC)->COD_MUN)),"",ALLTRIM(UfCodIBGE((cAliasPTC)->EST)+(cAliasPTC)->COD_MUN) ))

        oBloco0:setaNumer(aNumeracao)
        Proc0150(oBloco0, oTabela, aReg0150, cChavePai)

    EndIf

    (cAliasPTC)->(dbCloseArea())

    (cAlias)->(dbSkip())

EndDo

//Gera Registro 150 referente a própria empresa
aReg0150:= {}

cPartic := "SM0" + cFilAnt

aAdd(aReg0150,"0150"                 )
aAdd(aReg0150,cPartic                )
aAdd(aReg0150,SM0->M0_NOMECOM        )
aAdd(aReg0150,"1058"                 )
aAdd(aReg0150,SM0->M0_CGC            )
aAdd(aReg0150,""                     )
aAdd(aReg0150,SM0->M0_INSC           )
aAdd(aReg0150,cCodMun                )

oBloco0:setaNumer(aNumeracao)
Proc0150(oBloco0, oTabela, aReg0150, cChavePai)


(cAlias)->(dbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc0150

Função para gravar Registro 0150, passando os dados do array para o Objeto

@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//-------------------------------------------------------------------
Static Function Proc0150(o0150, oTabela, aReg0150, cChavePai)
    o0150:setRelac(cChavePai)
    o0150:SetcReg(aReg0150[1])
    o0150:SetcCodPar(aReg0150[2])
    o0150:SetcNome(aReg0150[3])
    o0150:SetnPais(aReg0150[4])
    o0150:SetnCNPJ(aReg0150[5])
    o0150:SetnCPF(aReg0150[6])
    o0150:SetcIE(aReg0150[7])
    o0150:SetnCodMun(aReg0150[8])
    
    oTabela:GrvReg(o0150:Add0150(aReg0150[1]))
    o0150:Clear(aReg0150[1])
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg0200

Função para buscar dados do Registro 0200 - Cadastro de Participantes de operações e prestações

@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//-------------------------------------------------------------------
Static Function Reg0200 (oSay,oBloco0,oTabela, aNumeracao, cChavePai,cAnoMes,lConcFil,lGeraHist)
Local aReg0200	  := {}
Local cAliasPRD	  := ""
Local cChave	  := ''
Local cAlias      := ""
Local cProduto    := ""
Local cCodItem    := ""
Local nAliqICMS   := 0
Local dDataDe     := StoD(cAnoMes+"01")
Local dDataAte    := LastDay(dDataDe)
Local cCodAnt     := ""
Local dDataRef    := CtoD("  /  /    ")
Local cFilProd    := Iif(lConcFil,xFilial("SB1"),"")
Local nMVICMPAD   := SuperGetMV('MV_ICMPAD')

cChave:= oBloco0:getGrupo()

AtualizaMsg( oSay, STR0011 ) //"Processando Registro 0200"

cAlias      := GetNextAlias()

SelMovto(cAlias, cAnoMes, "0200")

dbSelectArea (cAlias)

While !(cAlias)->(EOF())

    cProduto  := (cAlias)->F2V_PRODUT
    cCodItem  := (cAlias)->F2V_PRODUT + cFilProd

    cAliasPRD :=	GetNextAlias()

    BeginSql Alias cAliasPRD
    
        COLUMN B1_DATREF AS DATE

        SELECT  B1_DESC,
                B1_CODBAR,
                B1_UM,
                B1_POSIPI,
                B1_CEST,
                B1_CODANT,
                B1_DATREF,
                B1_PICM
        FROM 	%TABLE:SB1% SB1
        WHERE  SB1.B1_FILIAL=%XFILIAL:SB1%
        AND SB1.B1_COD  = %EXP:cProduto%
        AND SB1.%NOTDEL%
        
    EndSql

    dbSelectArea (cAliasPRD)

    If !(cAliasPRD)->(EOF())
                
        aReg0200:= {}

        //Define a alíquota interna do ICMS para o produto
        nAliqICMS := Iif((cAliasPRD)->B1_PICM>0, (cAliasPRD)->B1_PICM, nMVICMPAD)

        aAdd(aReg0200,"0200")
        aAdd(aReg0200,cCodItem)
        aAdd(aReg0200,(cAliasPRD)->B1_DESC)
        aAdd(aReg0200,(cAliasPRD)->B1_CODBAR)
        aAdd(aReg0200,(cAliasPRD)->B1_UM)
        aAdd(aReg0200,(cAliasPRD)->B1_POSIPI)
        aAdd(aReg0200,nAliqICMS)
        aAdd(aReg0200,(cAliasPRD)->B1_CEST)

        oBloco0:setaNumer(aNumeracao)
        
        Proc0200(oBloco0,oTabela, aReg0200, cChavePai)

        //Gera registro de alteração do produto.
        If lGeraHist
            cCodAnt  := (cAliasPRD)->B1_CODANT
            dDataRef := (cAliasPRD)->B1_DATREF
            
            Reg0205(oSay, oBloco0, oTabela, aNumeracao, cChavePai, cProduto, cCodAnt, dDataRef, dDataDe, dDataAte, cCodItem, lConcFil)
        EndIf
        
        //Gera registro de saldo em estoque.
        Reg1050(oSay, oBloco0, oTabela, aNumeracao, cChavePai, cAnoMes, cProduto, cCodItem)

    EndIf

    (cAliasPRD)->(dbCloseArea())

    (cAlias)->(dbSkip())

EndDo

(cAlias)->(dbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc0200

Função para gravar Registro 0200, passando os dados do array para o Objeto

@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//-------------------------------------------------------------------
Static Function Proc0200(o0200,oTabela,aReg0200,cChavePai)
    o0200:setRelac(cChavePai)
    o0200:SetcReg(aReg0200[1])
    o0200:SetcCodItem(aReg0200[2])
    o0200:SetcDescItem(aReg0200[3])
    o0200:SetcCodBar(aReg0200[4])
    o0200:SetcUn(aReg0200[5])
    o0200:SetcNcm(aReg0200[6])
    o0200:SetnAliqIcms(aReg0200[7])
    o0200:SetcCest(aReg0200[8])
    
    oTabela:GrvReg(o0200:Add0200(aReg0200[1]))
    o0200:Clear(aReg0200[1])
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg0205

Função para buscar dados do Registro 0205 - IdentIFicação do Item

@author Eduardo Vicente da Silva
@since 14/11/2018

/*/
//-------------------------------------------------------------------
Static Function Reg0205(oSay,oBloco0,oTabela,aNumeracao,cChave0200,cProd,cCodAnt,dDtRef,dDataDe,dDataAte,cCodItem,lConcFil)
Local aReg0205	:= {}
Local aHist := MsConHist("SB1","","",dDataDe,dDataAte,Substr(cProd,1,TamSx3("B1_COD")[1]))
Local	nX			:=	0

AtualizaMsg( oSay, STR0012 ) //"Processando Registro 0205"

/*VerIFica se a função retornou informações*/
If Len(aHist) > 0
    /*Exclui alteracoes de "B1_DESC" que sejam do mesmo dia com horarios menores, deixa a ultima*/
    nY := 1
    While nY <= Len(aHist)
        For nX := 1 To Len(aHist)
            If Len(aHist)>1 .And. nX<=Len(aHist)
                If nX > 1 .And. nX<Len(aHist)
                    If (aHist[nX][3]=aHist[nX-1][3]) .And. (aHist[nX][4]>=aHist[nX-1][4])
                        aDel(aHist, nX-1)
                        aSize(aHist, Len(aHist) - 1)
                        nX := 0
                    ElseIf (aHist[nX][3]=aHist[nX+1][3]) .And. (aHist[nX][4]<=aHist[nX+1][4])
                        aDel(aHist, nX+1)
                        aSize(aHist, Len(aHist) - 1)
                        nX := 0
                    EndIf
                ElseIf nX > 1 .And. nX=Len(aHist)
                    If (aHist[nX][3]=aHist[nX-1][3]) .And. (aHist[nX][4]>=aHist[nX-1][4])
                        aDel(aHist, nX-1)
                        aSize(aHist, Len(aHist) - 1)
                        nX := 0
                    EndIf
                EndIf
            Else
                Exit
            EndIf
        Next nX
        nY++
    Enddo
    //Passando para um array auxiliar os arrays que são do campo B1_DESC, para ordenar corretamente por DATA e HORA de alteração
    For nX := 1 To Len(aHist)
        //Atribuindo a variavel cDescProd o valor da 'DESCRIçãO ANTERIOR DO PRODUTO' da ultima alteração
        cDescProd := aHist[nX][2]
        
        //Atribuindo a ultima data de alteração a variavel dDataFinal
        dDataFinal := aHist[nX][3]-1
        If nX==1
            
            dDataInici := dDtRef
            
            If Empty(dDataInici)
                dDataInici := aHist[nX][3]
            EndIf
        Else
            //Atribuindo a penultima data de alteração a variavel dDataInici independente se houve alteracao ou não no mesmo dia
            dDataInici := aHist[nX-1][3]
            
            //Este tratamento abaixo foi efetuado para tratar alteracoes de produto validas por um dia
            //Neste caso, leva a data fim como sendo a data contida no historico
            //Devido a restricoes no layout
            If nX = Len(aHist) .And. dDataFinal = dDataInici
                dDataFinal := aHist[nX][3]
            EndIf
        EndIf
        
        If dDataFinal <= dDataAte .And. Alltrim(aHist[nX][1])$"B1_DESC"
            If dDataInici < dDataFinal

                aReg0205 := {}

                aAdd(aReg0205,"0205")
                aAdd(aReg0205,cCodItem)
                aAdd(aReg0205,Iif( Empty(AllTrim(cCodAnt)), cCodItem, cCodAnt + Iif(lConcFil,xFilial("SB1"),"")))
                aAdd(aReg0205,cDescProd)
                
                oBloco0:setaNumer(aNumeracao)
                Proc0205(oBloco0, oTabela, aReg0205,cChave0200 )
                
            EndIf
        EndIf
    Next nX
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc0205

Função para gravar Registro 0205, passando os dados do array para o Objeto

@author Eduardo Vicente da Silva
@since 14/11/2018

/*/
//-------------------------------------------------------------------
Static Function Proc0205(o0205, oTabela, aReg0205, cChave0200)
    
    o0205:setRelac(cChave0200)
    o0205:SetcReg(aReg0205[1])
    o0205:SetcCodItem(aReg0205[2])
    o0205:SetcCodAnt(aReg0205[3])
    o0205:SetcDescAnt(aReg0205[4])
    
    oTabela:GrvReg(o0205:Add0205(aReg0205[1]))
    o0205:Clear(aReg0205[1])

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg1050

Função para buscar dados do Registro 1050 - Saldo de produtos

@author Eduardo Vicente da Silva
@since 12/11/2018

/*/
//-------------------------------------------------------------------
Static Function Reg1050(oSay,oBloco0,oTabela, aNumeracao, cChavePai,cAnoMes,cProduto,cCodItem)
Local aReg1050	  := {}
Local cAliasSLD	  := ""
Local cChave	  := ''

cChave:= oBloco0:getGrupo()

cAliasSLD	:=	GetNextAlias()

AtualizaMsg( oSay, STR0013 ) //"Processando Registro 1050"

BeginSql Alias cAliasSLD
    
    SELECT  F2V.F2V_QTDSLD,
            F2V.F2V_VTOSLD,
            F2V.F2V_QTDFIM,
            F2V.F2V_VTOFIM

    FROM %TABLE:F2V% F2V
    
    WHERE  F2V.F2V_FILIAL=%XFILIAL:F2V%
    AND F2V.%NOTDEL%
    AND F2V.F2V_ANOMES = %EXP:cAnoMes%
    AND F2V.F2V_PRODUT = %EXP:cProduto%
    
    ORDER BY  F2V.F2V_PRODUT
    
EndSql

dbSelectArea (cAliasSLD)

If !(cAliasSLD)->(EOF())
            
    aReg1050:= {}

    aAdd(aReg1050,"1050")
    aAdd(aReg1050,cCodItem)
    aAdd(aReg1050,{(cAliasSLD)->F2V_QTDSLD,3})
    aAdd(aReg1050,(cAliasSLD)->F2V_VTOSLD)
    aAdd(aReg1050,{(cAliasSLD)->F2V_QTDFIM,3})
    aAdd(aReg1050,(cAliasSLD)->F2V_VTOFIM)

    oBloco0:setaNumer(aNumeracao)
    If Len(aReg1050) > 0
        Proc1050(oBloco0,oTabela, aReg1050, cChavePai)
    Endif

EndIf

(cAliasSLD)->(dbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc1050

Função para gravar Registro 1050, passando os dados do array para o Objeto

@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//-------------------------------------------------------------------
Static Function Proc1050(o1050, oTabela,aReg1050,cChavePai)
    o1050:setRelac(cChavePai)
    o1050:SetcReg(aReg1050[1])
    o1050:SetcCodItem(aReg1050[2])
    o1050:SetnQtdeIni(aReg1050[3])
    o1050:SetnValorIni(aReg1050[4])
    o1050:SetnQtdeFim(aReg1050[5])
    o1050:SetnValorFim(aReg1050[6])
    
    oTabela:GrvReg(o1050:Add1050(aReg1050[1]))
    o1050:Clear(aReg1050[1])
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Reg1100

Função para buscar dados do Registro 1100 - Movimentos Nota fiscal eletrônica e
1200 - Movimentos Nota fiscal não eletrônica.

@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//-------------------------------------------------------------------
Static Function Reg1100 (oSay,oBloco0,oTabela, aNumeracao, cChavePai,cAnoMes,lConcFil)
Local aReg1100  := {}
Local aReg1200	:= {}
Local cChave	:= ''
Local cAlias    := ""
Local cTpOper   := "0"
Local nVlrSup   := 0
Local nVlrConf  := 0
Local cCodPart  := ""
Local cModNota  := ""
Local cCodItem  := ""
Local cNFiscal  := ""
Local cItemDoc  := ""
Local cTpMov    := ""
Local cTipo     := ""

cChave:= oBloco0:getGrupo()

AtualizaMsg( oSay, STR0014 ) //"Processando Registro 1100"

cAlias := GetNextAlias()

SelMovto(cAlias, cAnoMes, "1100")

dbSelectArea (cAlias)

While !(cAlias)->(EOF())

    cCodItem  := (cAlias)->F2U_PRODUT + Iif(lConcFil,xFilial("SB1"),"")
    cItemDoc  := StrZero(Val((cAlias)->F2U_ITEM),3) 
    cTpMov    := (cAlias)->F2U_TPMOV
    cTipo     := (cAlias)->F2U_TIPO
    nVlrSup   := 0
    nVlrConf  := 0

    //Tipo de operação, 0-Entrada ou 1-Saída
    cTpOper  := Iif((cAlias)->F2U_TPMOV == 'E',"0","1")

    //Coluna ICMS_TOT deve preenchida nas movimentações de Entrada ou Devolução de Entrada ou Devolução de Saída
    If cTpMov == 'E' .Or. (cTpMov == 'S' .And. cTipo == 'D')
        nVlrSup  := (cAlias)->F2U_VTISUP
    EndIf

    //Coluna VL_CONFR deve ser preenchida na movimentações de Saída ou Devolução de Saída e com código de enquadramento legal diferente de 0(zero).
    If ((cTpMov == 'S' .And. cTipo != 'D') .Or. (cTpMov == 'E' .And. cTipo == 'D')) .And. (cAlias)->F2U_ENQLEG != "0"
        nVlrConf := Iif((cAlias)->F2U_ICMEFS > 0, (cAlias)->F2U_ICMEFS, (cAlias)->F2U_ICMEFE)
    EndIf 

    //De acordo com o pós validação do arquvivo devemos enviar o campo em branco quando o valor for igual a zero.
    nVlrSup  := Iif(nVlrSup  == 0, "", nVlrSup)
    nVlrConf := Iif(nVlrConf == 0, "", nVlrConf)
            
    If !Empty(AllTrim((cAlias)->F2U_CHVDOC))
    
        aReg1100:= {}

        aAdd(aReg1100,"1100")
        aAdd(aReg1100,(cAlias)->F2U_CHVDOC)
        aAdd(aReg1100,(cAlias)->F2U_DTMOV)
        aAdd(aReg1100,cItemDoc)
        aAdd(aReg1100,cTpOper)
        aAdd(aReg1100,cCodItem)
        aAdd(aReg1100,(cAlias)->F2U_CFOP)
        aAdd(aReg1100,{(cAlias)->F2U_QTDMOV,3})
        aAdd(aReg1100,nVlrSup)
        aAdd(aReg1100,nVlrConf)
        aAdd(aReg1100,(cAlias)->F2U_ENQLEG)

        oBloco0:setaNumer(aNumeracao)
        If Len(aReg1100) > 0
            Proc1100(oBloco0,oTabela, aReg1100, cChavePai)
        Endif

    Else
        aReg1200:= {}

        If (cTpMov == 'E' .And. !cTipo $ 'D/B') .Or. (cTpMov == 'S' .And. cTipo $ 'D/B')
            cCodPart := "SA2" + Iif(lConcFil, cFilAnt, "") + (cAlias)->F2U_PARTIC + (cAlias)->F2U_LOJA
        Else
            cCodPart := "SA1" + Iif(lConcFil, cFilAnt, "") + (cAlias)->F2U_PARTIC + (cAlias)->F2U_LOJA
        EndIf

        If PADR(AllTrim((cAlias)->F2U_ESPECI),5," ") $ 'NFCF /CF   /ECF  /SATCE/NFCE '
            cCodPart := ""
        EndIf

        cModNota := aMODNOT((cAlias)->F2U_ESPECI)
        cNFiscal := StrZero(Val((cAlias)->F2U_NFISCA),9)

        aAdd(aReg1200,"1200")
        aAdd(aReg1200,cCodPart)
        aAdd(aReg1200,cModNota)
        aAdd(aReg1200,(cAlias)->F2U_SERECF)
        aAdd(aReg1200,(cAlias)->F2U_SERIE)
        aAdd(aReg1200,cNFiscal)
        aAdd(aReg1200,cItemDoc)
        aAdd(aReg1200,cTpOper)
        aAdd(aReg1200,(cAlias)->F2U_DTMOV)
        aAdd(aReg1200,(cAlias)->F2U_CFOP)
        aAdd(aReg1200,cCodItem)
        aAdd(aReg1200,{(cAlias)->F2U_QTDMOV,3})
        aAdd(aReg1200,nVlrSup)
        aAdd(aReg1200,nVlrConf)
        aAdd(aReg1200,(cAlias)->F2U_ENQLEG)

        oBloco0:setaNumer(aNumeracao)
        If Len(aReg1200) > 0
            Proc1200(oBloco0,oTabela, aReg1200, cChavePai)
        Endif

    EndIf

    (cAlias)->(dbSkip())

EndDo

(cAlias)->(dbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc1100

Função para gravar Registro 1100, passando os dados do array para o Objeto

@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//-------------------------------------------------------------------
Static Function Proc1100(o1100, oTabela,aReg1100,cChavePai)
    o1100:setRelac(cChavePai)
    o1100:SetcReg(aReg1100[1])
    o1100:SetcChave(aReg1100[2])
    o1100:SetdDataDigit(aReg1100[3])
    o1100:SetnItem(aReg1100[4])
    o1100:SetnOperacao(aReg1100[5])
    o1100:SetcCodItem(aReg1100[6])
    o1100:SetnCFOP(aReg1100[7])
    o1100:SetnQtde(aReg1100[8])
    o1100:SetnICMSSup(aReg1100[9])
    o1100:SetnVlrConf(aReg1100[10])
    o1100:SetnCodEnquad(aReg1100[11])
    
    oTabela:GrvReg(o1100:Add1100(aReg1100[1]))
    o1100:Clear(aReg1100[1])
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc1200

Função para gravar Registro 1200, passando os dados do array para o Objeto

@author Eduardo Vicente da Silva
@since 08/11/2018

/*/
//-------------------------------------------------------------------
Static Function Proc1200(o1200, oTabela,aReg1200,cChavePai)
    o1200:setRelac(cChavePai)
    o1200:SetcReg(aReg1200[1])
    o1200:SetcCodPar(aReg1200[2])
    o1200:SetcEspecie(aReg1200[3])
    o1200:SetcNumSerEcf(aReg1200[4])
    o1200:SetcSerie(aReg1200[5])
    o1200:SetcNumDoc(aReg1200[6])
    o1200:SetnItem(aReg1200[7])
    o1200:SetnOperacao(aReg1200[8])
    o1200:SetdDataDigit(aReg1200[9])
    o1200:SetnCFOP(aReg1200[10])
    o1200:SetcCodItem(aReg1200[11])
    o1200:SetnQtde(aReg1200[12])
    o1200:SetnICMSSup(aReg1200[13])
    o1200:SetnVlrConf(aReg1200[14])
    o1200:SetnCodEnquad(aReg1200[15])
    
    oTabela:GrvReg(o1200:Add1200(aReg1200[1]))
    o1200:Clear(aReg1200[1])
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SelMovto

Função para buscar os movimentos 

@author Eduardo Vicente da Silva
@since 09/11/2018

/*/
//-------------------------------------------------------------------
Static Function SelMovto(cAlias, cAnoMes, cTpQry)
Local cGroup := ''
Local cSGBD  := TCGetDB()

If cTpQry == '0150'

	//---Ajustes na Query para BD Informix---//
    If AllTrim(cSGBD) == 'INFORMIX' 
        cGroup := "1"
    Else
        cGroup := "CASE "
        cGroup += "WHEN ((F2U.F2U_TPMOV = 'S' AND F2U.F2U_TIPO NOT IN ('D','B')) OR (F2U.F2U_TPMOV = 'E' AND F2U.F2U_TIPO IN ('D','B'))) "
        cGroup += "    THEN SA1.A1_CGC "
        cGroup += "    ELSE SA2.A2_CGC "
        cGroup += "END "
    EndIf
    cGroup := "%" + cGroup + "%"

    BeginSql Alias cAlias

        SELECT CASE
          WHEN ((F2U.F2U_TPMOV = 'S' AND F2U.F2U_TIPO NOT IN ('D','B')) OR (F2U.F2U_TPMOV = 'E' AND F2U.F2U_TIPO IN ('D','B')))
          THEN SA1.A1_CGC
          ELSE SA2.A2_CGC
          END F2U_CNPJ, 
        MIN(CASE
            WHEN ((F2U.F2U_TPMOV = 'S' AND F2U.F2U_TIPO NOT IN ('D','B')) OR (F2U.F2U_TPMOV = 'E' AND F2U.F2U_TIPO IN ('D','B')))
            THEN 'SA1' || F2U.F2U_PARTIC || F2U.F2U_LOJA
            ELSE 'SA2' || F2U.F2U_PARTIC || F2U.F2U_LOJA
            END) F2U_ALIAS
        FROM  %TABLE:F2U% F2U LEFT OUTER JOIN %TABLE:SA1% SA1 ON (SA1.A1_FILIAL  = %xFilial:SA1% AND SA1.A1_COD = F2U.F2U_PARTIC  AND SA1.A1_LOJA = F2U.F2U_LOJA AND ((F2U.F2U_TPMOV = 'S' AND F2U.F2U_TIPO NOT IN ('D','B')) OR (F2U.F2U_TPMOV = 'E' AND F2U.F2U_TIPO IN ('D','B')))  AND SA1.%NOTDEL% )
                LEFT OUTER JOIN %TABLE:SA2% SA2 ON (SA2.A2_FILIAL  = %xFilial:SA2% AND SA2.A2_COD = F2U.F2U_PARTIC  AND SA2.A2_LOJA = F2U.F2U_LOJA AND ((F2U.F2U_TPMOV = 'E' AND F2U.F2U_TIPO NOT IN ('D','B')) OR (F2U.F2U_TPMOV = 'S' AND F2U.F2U_TIPO IN ('D','B')))  AND SA2.%NOTDEL% ) 
        WHERE F2U.F2U_FILIAL = %XFILIAL:F2U%   AND 
            F2U.F2U_ANOMES   = %EXP:cAnoMes%   AND 
            F2U.F2U_TPREG    = ''              AND 
            F2U.F2U_ESPECI NOT IN ('CF', 'ECF', 'SATCE', 'NFCE', 'NFCF') AND
            F2U.%NOTDEL%
        GROUP BY %EXP:cGroup%
        ORDER BY F2U_ALIAS
        
    EndSql
EndIf

If cTpQry == '0200'
    BeginSql Alias cAlias
        
        SELECT F2V.F2V_PRODUT
            FROM %TABLE:F2V% F2V LEFT OUTER JOIN (SELECT F2U.F2U_FILIAL, F2U.F2U_ANOMES, F2U.F2U_PRODUT, MAX(F2U.F2U_ORDEM) F2U_ORDEM
                                                  FROM %TABLE:F2U% F2U
                                                  WHERE F2U.F2U_FILIAL = %XFILIAL:F2U%  AND 
                                                        F2U.F2U_ANOMES = %EXP:cAnoMes%  AND
                                                        F2U_TPREG      = ' '            AND
                                                        F2U.%NOTDEL%
                                                  GROUP BY F2U.F2U_FILIAL, F2U.F2U_ANOMES, F2U.F2U_PRODUT) F2U_ 
                                                  ON (F2U_.F2U_FILIAL = %XFILIAL:F2U% AND 
                                                      F2U_.F2U_ANOMES = %EXP:cAnoMes% AND 
                                                      F2U_.F2U_PRODUT = F2V.F2V_PRODUT)
            WHERE F2V.F2V_FILIAL = %XFILIAL:F2V%                             AND 
                  F2V.F2V_ANOMES = %EXP:cAnoMes%                             AND
                  (F2V.F2V_QTDFIM > 0 OR ISNULL(F2U_.F2U_ORDEM,'') <> '')    AND
            	  F2V.%NOTDEL%                    
            ORDER BY F2V.F2V_PRODUT
    EndSql
EndIf

If cTpQry == '1100'
    BeginSql Alias cAlias
        
        COLUMN F2U_DTMOV AS DATE

        SELECT  F2U.F2U_TPMOV,
                F2U.F2U_PARTIC,
                F2U.F2U_LOJA,
                F2U.F2U_SERIE,
                F2U.F2U_NFISCA,
                F2U.F2U_ITEM,
                F2U.F2U_CHVDOC,
                F2U.F2U_CFOP,
                F2U.F2U_DTMOV,
                F2U.F2U_ENQLEG,
                F2U.F2U_ESPECI,
                F2U.F2U_PRODUT,
                F2U.F2U_QTDMOV,
                F2U.F2U_TPREG,
                F2U.F2U_VTISUP,
                F2U.F2U_ICMEFS,
                F2U.F2U_ICMEFE,
                F2U.F2U_SERECF,
                F2U.F2U_TIPO,
                CASE F2U.F2U_TPMOV
                   WHEN 'E' THEN 
		               CASE F2U_TIPO
		        	       WHEN 'D' THEN '2'
		        		   ELSE          '1'
                       END
                   ELSE 
		               CASE F2U_TIPO
		        	       WHEN 'D' THEN '3'
		        		   ELSE          '4'
                       END
               END  F2U_ORDEM

        FROM %TABLE:F2U% F2U
        WHERE  F2U.F2U_FILIAL=%XFILIAL:F2U%
        AND F2U.%NOTDEL%
        AND F2U.F2U_ANOMES = %EXP:cAnoMes%
        AND F2U.F2U_TPREG  = ''
        
        ORDER BY  F2U.F2U_ANOMES, F2U.F2U_PRODUT,F2U_DTMOV,F2U_ORDEM,F2U_PARTIC,F2U_LOJA,F2U_NFISCA,F2U_ITEM,F2U_SERIE 
    EndSql
EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} TabTemp

Esta função passa as informações necessárias para a criação da tabela Temporaria

@author Eduardo Vicente da Silva
@since 13/11/2018

/*/
//-------------------------------------------------------------------
Static Function TabTemp()
    Local oTabTemp  := TABTEMPCAT42():New()
    Local cNomeArq  := Alltrim(MV_PAR05) /*Nome do arquivo*/
    Local nRemType  := GetRemoteType() /*IdentIFica a tipo e versão do Smart Client em execução.*/
    Local cDir      := Alltrim(MV_PAR04)
    
    /*Cria o Diretório*/
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
    
    /*Cria tabela temporária*/
    oTabTemp:CriaTabela()
    
RETURN oTabTemp

//-------------------------------------------------------------------
/*/{Protheus.doc} SeqCat42

Função que monta o Grupo do Registro

@author Eduardo Vicente da Silva
@since 13/11/2018

/*/
//-------------------------------------------------------------------
Function SeqCat42(aGrupoReg, cGrupoPai, cReg)
Local nPos      := 0
Local cGrupoReg := ''

nPos := aScan (aGrupoReg, {|aX| aX[1] == cReg })

If nPos > 0
    /*Se encontrar o registro então irá adicionar*/
    aGrupoReg[nPos][2] ++
Else
    /*Caso contrário irá incluir registro no controle*/
    aAdd(aGrupoReg, {})
    nPos := Len(aGrupoReg)
    aAdd (aGrupoReg[nPos], cReg)
    aAdd (aGrupoReg[nPos], 1)
EndIf

/*Aqui processa o valor do grupo do registro, que será retornado para gravação.*/
cGrupoReg	:=Cat42GReg(cGrupoPai,cReg,aGrupoReg[nPos][2])

Return cGrupoReg

/*Função que irá gerar o grupo do registro, considerando o grupo do registro pai já gerado, o registro e seu contador*/
Function Cat42GReg(cGrupoPai,cReg,nCont)
Local cGrupo	:= ''
    
cGrupo:=cGrupoPai+cReg+Strzero(nCont,9)

Return cGrupo

//------------------------------------------------------------------
/*/{Protheus.doc} AtualizaMsg

Função que será chamada para atualizar descrição da barra de status

@author Eduardo Vicente da Silva
@since 22/11/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function AtualizaMsg( oSay, cMsg )
If !lAutomato
    oSay:cCaption := (cMsg)
    ProcessMessages()
EndIf
Return
