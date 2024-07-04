#INCLUDE "PROTHEUS.CH"
#INCLUDE "RMIXFUNB.CH"
#INCLUDE "TRYEXCEPTION.CH"

Static cNroItem := "" //Guarda o numero do proximo item

//--------------------------------------------------------
/*/{Protheus.doc} RmiGrvCli
Função para chamar o ExecAuto do cadastro de cliente

@param 		aCli    -> Array com os campos obrigatorios e dados do cliente
@author  	Varejo
@version 	1.0
@since      12/05/2020
@return	    aRet    -> Retorna com a informação se foi sucesso ou nao o cad do cliente
/*/
//--------------------------------------------------------
Function RmiGrvCli(aCli)
Local Chave := "" //Monta chave para pesquisar se existe cliente com CPF
Local cOpCli:= 3 // Tipo de operação Inclusão
Local aRet  := Array(2) //Variavel de retorno
Local nPos  := 0// Posição do AScan de retorno

Default aCli := {}

Private lMsErroAuto := .F. //Variavel que informa a ocorrência de erros no ExecAuto

aCli := RmiMontVar(aCli)

nPos := aScan(aCli,{|x| Valtype(x[2]) == "U"})
If nPos <= 0
    If Len(aCli) > 0
        nPos := aScan(aCli,{|x| AllTrim(x[1]) == "A1_FILIAL"})
        Chave+= PadR(aCli[nPos][2],TamSX3("A1_FILIAL")[1])
        nPos := aScan(aCli,{|x| AllTrim(x[1]) == "A1_CGC"})
        Chave+= PadR(aCli[nPos][2],TamSX3("A1_CGC")[1])
        dbSelectArea("SA1")
        SA1->(dbSetOrder(3)) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
        LjGrvLog("RMIXFUNB", "RmiGrvCli valida se o cliente existe pelo CPF ",Chave)
        
        If SA1->(dbSeek(Chave))  
            cOpCli := 4    

            //Adiciona o campo A1_COD/A1_LOJA para nao dar erro na alteração 
            aAdd(aCli,{"A1_COD",SA1->A1_COD,Nil})
            
            If ( nPos := aScan(aCli, {|x| AllTrim(x[1]) == "A1_LOJA"}) ) > 0 
                aCli[nPos][2] := SA1->A1_LOJA
            Else
                aAdd(aCli, {"A1_LOJA", SA1->A1_LOJA, Nil} )
            EndIf
            
            LjGrvLog("RMIXFUNB", "RmiGrvCli -> Cliente existe alteração do cliente FILIAL+CPF+CODIGO  ", Chave+"|"+SA1->A1_COD)
        EndIf        
        
        MSExecAuto({|a,b| CRMA980(a,b)}, aCli, cOpCli)

        If lMsErroAuto  
            aRet[1] := .F.
            aRet[2] := MostraErro("\")
            LjGrvLog("RMIXFUNB", "RmiGrvCli -> Ocorreu erro no ExecAuto -> ", aRet[2])
        Else
            aRet[1] := .T.
            aRet[2] := ""
            
            SA1->(dbSeek(Chave))//Posiciona inclusão  
            RecLock("SA1",.F.)
                SA1->A1_MSEXP := DTOS(Date())
                SA1->A1_HREXP := Time()
            SA1->(MsUnLock())
            
            LjGrvLog("RMIXFUNB", "RmiGrvCli -> ExecAuto Sucesso! -> ")
        EndIf
    Else
        aRet[1] := .F.
        aRet[2] := STR0001 //"O array aCli esta vazio, não é possivel realizar a inclusão do cliente!"
        LjGrvLog("RMIXFUNB", "RmiGrvCli -> ",aRet[2])
    EndIf
else
    nPos := aScan(aCli,{|x| AllTrim(x[1]) == "A1_CGC"})
    Chave+= PadR(aCli[nPos][2],TamSX3("A1_CGC")[1])
    aRet[1] := .F.
    aRet[2] := STR0004+Chave  //"Existem valores null no Json da Tabela MHQ e os Tipos permitidos: STRING, DATE, NUMERIC, LOGICAL MHQ_CHVUNI" 
    LjGrvLog("RMIXFUNB", "RmiGrvCli -> ",aRet[2]) 
EndIf    


Return aRet


//--------------------------------------------------------
/*/{Protheus.doc} RmiMontVar
Função para colocar o array no padrão do ExecAuto do MATA030 e/ou LOJA070

@param 		aClientes   -> Array com os campos obrigatorios e dados do cliente
@param 		aAdm        -> Array com os campos obrigatorios e dados da adm financeira
@author  	Varejo
@version 	1.0
@since      12/05/2020
@return	    aRet       -> Retorna o array no formato esperado pelo ExecAuto
/*/
//--------------------------------------------------------
Static Function RmiMontVar(aClientes, aSae, aMen)

Local nI := 0 //Variavel de loop
Local aRet := {} //Variavel de retorno
Local nX := 0 //Variavel de loop
Local nPosItem := 0 //Posicao do campo MEN_ITEM  

Default aClientes   := {}
Default aSae        := {}
Default aMen        := {}

If Len(aClientes) > 0
    For nI := 1 To Len(aClientes[1])

        If ValType( aClientes[1][nI][2] ) == "C"
            aAdd(aRet,{aClientes[1][nI][1],PADR(aClientes[1][nI][2],TamSX3(aClientes[1][nI][1])[1]),Nil})
        Else
            aAdd( aRet, {aClientes[1][nI][1], aClientes[1][nI][2], Nil} )
        EndIF

    Next nI
ElseIf Len(aSae) > 0
    For nI := 1 To Len(aSae)
        If AllTrim(aSae[nI][1]) <> "AE_COD"
            aAdd(aRet,{aSae[nI][1],aSae[nI][2],Nil})
        EndIf
    Next nI
ElseIf Len(aMen) > 0
    For nI := 1 To Len(aMen)
        
        aAdd( aRet, {} )
        
        For nX := 1 To Len(aMen[nI])
            If AllTrim(aMen[nI][nX][1]) <> "MEN_CODADM"
                aAdd(aRet[nI],{aMen[nI][nX][1],aMen[nI][nX][2],Nil})
            EndIf
        Next nX

        nPosItem := aScan(aRet[nI],{|x| AllTrim(x[1]) == "MEN_ITEM"})

        If nPosItem > 0
            aRet[nI][nPosItem][1] := PadL(AllTrim(Str(nI)),TamSx3("MEN_ITEM")[1],"0")
        Else
            aAdd(aRet[nI],{"MEN_ITEM",PadL(AllTrim(Str(nI)),TamSx3("MEN_ITEM")[1],"0"),Nil})
        EndIf

    Next nI
EndIf

Return aRet


//--------------------------------------------------------
/*/{Protheus.doc} RmiGrvOpe
Função para chamar o ExecAuto do cadastro de operador de caixa

@param 		aOpe    -> Array com os campos obrigatorios e dados do operador de caixa
@param 		cOrigem -> Sistema de origem da informação
@author  	Varejo
@version 	1.0
@since      14/05/2020
@return	    aRet    -> Retorna com a informação se foi sucesso ou nao o cad do operador de caixa
/*/
//--------------------------------------------------------
Function RmiGrvOpe(aOpe, cOrigem)

Local aRet := Array(2) //Variavel de retorno
Local cChave := "" //Chave da SA6
Local nPosNome := 0 //Posição no array do campo A6_NOME
Local nPosCod := 0 //Posição no array do campo A6_COD 
Local cRetDePara := "" //Retorno da função RmiDePaRet
Local aRetDP := "" //Array com o retorno da função RmiDePaRet 
Local aArea := GetArea() //Guarda a area das tabelas

Default cOrigem := ""

aOpe := RmiMontVar(aOpe)

If Len(aOpe) > 0 .AND. !Empty(cOrigem)
    
    //Acha a posição onde encontra-se o campo A6_NOME
    nPosNome := aScan(aOpe,{|x| AllTrim(x[1]) == "A6_NOME"})
    nPosCod := aScan(aOpe,{|x| AllTrim(x[1]) == "A6_COD"})

    If nPosNome > 0 .AND. nPosCod > 0

        cRetDePara := RmiDePaRet(cOrigem, "SA6", aOpe[nPosCod][2], .F.)

        If !Empty(cRetDePara)
            //Transforma em array o retorno do de/para
            aRetDP := Separa(cRetDePara,"|")

            //Verifica na SA6 se o operador ja existe cadastrado, se existe, envia a mesma chave apenas para atualizar
            dbSelectArea("SA6")
            SA6->(dbSetOrder(1)) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON

            If !SA6->(dbSeek(xFilial("SA6") + PadR(aRetDP[2],TamSX3("A6_COD")[1])))
                //Cria a chave para gravação da SA6
                cChave := RmiChvOpe()
            Else
                //Retorna a chave que já existe na SA6
                cChave := aRetDP[2]
            EndIf
        Else
            //Cria a chave para gravação da SA6
            cChave := RmiChvOpe()
        EndIf

        //Chama a função que ira gravar as informações na SA6, SX5 e SLF
        aRet := LjAtuCaixa(aOpe[nPosNome][2],,,,,cChave,,,,.F.)
    Else
        aRet[1] := .F.
        aRet[2] := STR0002 //"Não foi encontrado o campo A6_COD e/ou A6_NOME no array, operador de caixa não sera cadastrado na tabela SA6"
    EndIf
Else
    aRet[1] := .F.
    aRet[2] := STR0003 //"A variavel aOpe e/ou cOrigem esta vazia, operador de caixa não sera cadastrado na tabela SA6"
EndIf

RestArea(aArea)

Return aRet

//--------------------------------------------------------
/*/{Protheus.doc} RmiChvOpe
Função para geração da chave ao cadastrar o operador de caixa

@author  	Varejo
@version 	1.0
@since      14/05/2020
@return	    cChave    -> Retorna o código que sera a chave do operador na SA6
/*/
//--------------------------------------------------------
Static Function RmiChvOpe()

Local cDigito   := "C" //Digito da chave
Local cChave    := "01" //Codigo da chave da SA6
Local aArea    	:= GetArea() //Guarda a area das tabelas

DbSelectArea("SX5")
SX5->( DbSetOrder(1) ) //X5_FILIAL+X5_TABELA+X5_CHAVE

DbSelectArea("SA6")
SA6->( DbSetOrder(1) ) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON

DbSelectArea("SLF")
SLF->( DbSetOrder(1) ) //LF_FILIAL+LF_COD

//Busca um código que não existe
While   SX5->( DbSeek(xFilial("SX5") + "23" + cDigito + cChave) ) .Or.;
        SA6->( DbSeek(xFilial("SA6") + cDigito + cChave) )  	  .Or.;
        SLF->( DbSeek(xFilial("SLF") + cDigito + cChave) )

    If cChave == "ZZ"
        cDigito := Soma1(cDigito)
        cChave  := "00"
    Else
        cChave  := Soma1(cChave)
    EndIf
End

cChave := cDigito + cChave

RestArea(aArea)

Return cChave
//--------------------------------------------------------
/*/{Protheus.doc} RmiGrvInv
Função para chamar o ExecAuto do  MATA270

@param 		aOpe    -> Array com os campos obrigatorios e dados do operador de caixa
@param 		cOrigem -> Sistema de origem da informação
@author  	Varejo
@version 	1.0
@since      14/05/2020
@return	    aRet    -> Retorna com a informação se foi sucesso ou nao o cad do operador de caixa
/*/
//--------------------------------------------------------
Function RmiGrvInv(aInv, cOrigem)

Local aRet := Array(2) //Variavel de retorno
Local aArea := GetArea() //Guarda a area das tabelas
Local nX    := 0

PRIVATE lMsErroAuto := .F.

Default cOrigem := ""
Default aInv    := {}

aInv := RmiMontInv(aInv)

If Len(aInv) > 0 .AND. !Empty(cOrigem)
    Begin Transaction
        For nX:= 1 To Len(aInv)
            MSExecAuto({|x,y,z| mata270(x,y,z)},aInv[nX][1],.T.,3)
            If lMsErroAuto
                DisarmTransaction()
                exit
            EndIf
        Next    
    End Transaction
EndIf

If lMsErroAuto  
    aRet[1] := .F.
    aRet[2] := MostraErro("\")
Else
    aRet[1] := .T.
    aRet[2] := ""
EndIf

RestArea(aArea)
Return aRet
//--------------------------------------------------------
/*/{Protheus.doc} RmiMontInv
Função para colocar o array no padrão do ExecAuto do MATA270

@param 		aInv  -> Array com os campos obrigatorios e dados
@author  	Varejo
@version 	1.0
@since      12/05/2020
@return	    aRet       -> Retorna o array no formato esperado pelo ExecAuto
/*/
//--------------------------------------------------------
Static Function RmiMontInv(aInv)

Local nI,nY      := 0 //Variavel de loop
Local nX         := 0 //Variavel de loop
Local aRet       := {} //Variavel de retorno
Local aLayout    := {}

Default aInv     := {}

If Len(aInv) > 0
    For nI := 1 To Len(aInv[2])
        For nX := 1 to Len(aInv[2][nI])
            aAdd(aLayout,{aInv[2][nI][nX][1],aInv[2][nI][nX][2],Nil})
        Next
        For nY:= 1 To Len(aInv[1])
            aAdd(aLayout,{aInv[1][nY][1],aInv[1][nY][2],Nil})    
        next    
        aAdd(aRet,{aLayout})
        aLayout := {}     
    Next
EndIf

Return aRet             

//--------------------------------------------------------
/*/{Protheus.doc} RmiGrvAdm
Realiza a gravação da informação nas tabelas SAE e MEN

@param 		aAdm        -> Array com os campos obrigatorios e dados da adm financeira
@author  	Varejo
@version 	1.0
@since      19/06/2020
@return	    aRet        -> Retorna com a informação se foi sucesso ou nao o cad da adm financeira
/*/
//--------------------------------------------------------
Function RmiGrvAdm(aAdm, cChvUni)

Local aSae  := {} //Guarda os dados da SAE para enviar ao ExecAuto
Local aMen  := {} //Guarda os dados da MEN para enviar ao ExecAuto
Local aRet  := Array(2) //Variavel de retorno
Local nOpe  := 4 //Operacao do execauto
Local xDePa := "" //Retorno do de/para

Private lMsErroAuto := .F. //Variavel que informa a ocorrência de erros no ExecAuto

Default aAdm    := {}
Default cChvUni := ""

If Len(aAdm) > 0 .AND. !Empty(cChvUni)

    aSae := RmiMontVar(,aAdm[1])

    If Len(aAdm) > 1
        aMen := RmiMontVar(,,aAdm[2])
    EndIf

    //Verifica se o registro já existe, para então realizar a alteração
    xDePa := RmiDePaRet("LIVE", "SAE", cChvUni, .F.)
    If !Empty(xDePa)
        xDePa := Separa(xDePa,"|")
        If ValType(xDePa) == "A" .AND. Len(xDePa) >= 2
            aRet := RmiAtlzAdm(xDePa, aAdm)
        EndIf
    Else
        nOpe := 3
    EndIf    

    If nOpe == 3 .AND. Len(aSae) > 0

        MSExecAuto({|a,b,c| LojA070(a,b,c)}, aSae, aMen, nOpe)

        If lMsErroAuto  
            aRet[1] := .F.
            aRet[2] := MostraErro("\")
            LjGrvLog("RMIXFUNB", "RmiGrvAdm -> Ocorreu erro no ExecAuto -> ", aRet[2])
        Else
            aRet[1] := .T.
            aRet[2] := ""
            LjGrvLog("RMIXFUNB", "RmiGrvAdm -> ExecAuto Sucesso! -> ")
        EndIf
    EndIf
Else
    aRet[1] := .F.
    aRet[2] := STR0005 //"O array aAdm esta em branco, não foi possivel cadastrar a Adm Financeira"
    LjGrvLog("RMIXFUNB", "RmiGrvAdm -> O array aAdm esta em branco, não foi possivel cadastrar a Adm Financeira -> ", aRet[2])
EndIf

Return aRet

//--------------------------------------------------------
/*/{Protheus.doc} RmiAtlzAdm
Função responsavel em realizar a atualização da Adm Financeira

@param 		aAdm        -> Array com os campos de filial e cod adm
@author  	Varejo
@version 	1.0
@since      14/07/2020
@return	    aRet        -> Retorna com a informação se foi sucesso ou nao a alteração da adm financeira
/*/
//--------------------------------------------------------
Static Function RmiAtlzAdm(aDePa, aAdm)

Local aRet      := Array(2) //Array de retorno da função
Local cQuery    := "" //Armazena a query
Local cTabela   := "" //Tabela temporaria
Local aSae      := {} //Tabela SAE
Local aMen      := {} //Tabela MEN
Local nI        := 0 //Variavel de loop
Local nPosIni   := 0 //Posição do campo MHN_PARINI
Local nPosFin   := 0 //Posição do campo MHN_PARFIN
Local nX        := 0 //Variavel de loop
Local oError    := Nil //Objeto que guarda o erro

Default aAdm := {}

TRY EXCEPTION

    If Len(aAdm) > 0

        //Add o conteudo da SAE
        aSae := aClone(aAdm[1])

        If Len(aAdm) > 1
            //Add o conteudo da MEN
            aMen := aClone(aAdm[2])
        EndIf

        cTabela := GetNextAlias()
        cQuery := "SELECT R_E_C_N_O_ REC"
        cQuery += "  FROM " + RetSqlName("SAE")
        cQuery += " WHERE AE_COD = '" + aDePa[2] + "'"
        cQuery += "   AND AE_FILIAL = '"  + aDePa[1] + "'"

        DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cTabela, .T., .F.)

        If !(cTabela)->( Eof() )
            //Move para o registro que a query encontrou
            SAE->(dbGoto((cTabela)->REC))
            RecLock("SAE",.F.)

            //Atualiza cada um dos campos do array
            For nI := 1 To Len(aSae)
                If !(AllTrim(aSae[nI][1]) $ 'AE_FILIAL|AE_COD')
                    SAE->&(aSae[nI][1]) := aSae[nI][2]
                EndIf
            Next nI

            SAE->( MsUnLock() )                
        EndIf
        (cTabela)->( DbCloseArea() )

        For nI := 1 To Len(aMen)

            nPosIni := aScan(aMen[nI], {|x| x[1] == "MEN_PARINI" })
            nPosFin := aScan(aMen[nI], {|x| x[1] == "MEN_PARFIN" })

            cTabela := GetNextAlias()
            cQuery := "SELECT R_E_C_N_O_ REC "
            cQuery += "  FROM " + RetSqlName("MEN")
            cQuery += " WHERE MEN_CODADM = '" + aDePa[2] + "'"
            cQuery += "   AND MEN_FILIAL = '" + aDePa[1] + "'"
            cQuery += "   AND MEN_PARINI = " + cValToChar(aMen[nI][nPosIni][2])
            cQuery += "   AND MEN_PARFIN = " + cValToChar(aMen[nI][nPosIni][2])

            DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cTabela, .T., .F.)

            If !(cTabela)->( Eof() )
                //Move para o registro que a query encontrou
                MEN->(dbGoto((cTabela)->REC))
                RecLock("MEN",.F.)        
                
                For nX := 1 To Len(aMen[nI])
                    If !(AllTrim(aMen[nI][nX][1]) $ 'MEN_FILIAL|MEN_CODADM|MEN_PARINI|MEN_PARFIN')
                        MEN->&(aMen[nI][nX][1]) := aMen[nI][nX][2]
                    EndIf
                Next nX                   

            Else
                RecLock("MEN",.T.) 
                For nX := 1 To Len(aMen[nI])
                    If !(AllTrim(aMen[nI][nX][1]) $ 'MEN_FILIAL|MEN_CODADM')
                        MEN->&(aMen[nI][nX][1]) := aMen[nI][nX][2]
                    Else
                        If AllTrim(aMen[nI][nX][1]) == 'MEN_FILIAL'
                            MEN->&(aMen[nI][nX][1]) := aDePa[1]
                        ElseIf AllTrim(aMen[nI][nX][1]) == 'MEN_CODADM'
                            MEN->&(aMen[nI][nX][1]) := aDePa[2]
                        EndIf
                    EndIf                     
                Next nX    
                MEN->MEN_ITEM := RmiRetNrIt(aDePa)           
            EndIf

            MEN->( MsUnLock() )
            (cTabela)->( DbCloseArea() )

        Next nI

        cNroItem := ""

        //Não ocorreu nenhum erro
        aRet[1] := .T.
        aRet[2] := ""

    EndIf

CATCH EXCEPTION USING oError
    aRet[1] := .F.
    aRet[2] := oError:Description
    LjGrvLog("RMIXFUNB", "RmiGrvAdm -> Ocorreu erro ao atualizar a Adm Financeira -> ", aRet[2])
ENDTRY

Return aRet

//--------------------------------------------------------
/*/{Protheus.doc} RmiRetNrIt
Função para retornar o numero do proximo item MEN_ITEM

@param 		aAdm        -> Array com os campos de filial e cod adm
@author  	Varejo
@version 	1.0
@since      14/07/2020
@return	    aRet        -> Retorna com a informação se foi sucesso ou nao a alteração da adm financeira
/*/
//--------------------------------------------------------
Static Function RmiRetNrIt(aDePa)

Local aArea     := GetArea()
Local cRet      := ""               //Variavel de retorno
Local cTab      := GetNextAlias()   //Proximo alias
Local cQuery    := ""               //Armazena a query

If Empty(cNroItem)
    cQuery := "SELECT MEN_ITEM ITEM "
    cQuery += "  FROM " + RetSqlName("MEN")
    cQuery += " WHERE MEN_CODADM = '" + aDePa[2] + "'"
    cQuery += "   AND MEN_FILIAL = '" + aDePa[1] + "'"
    cQuery += " ORDER BY ITEM DESC"

    DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cTab, .T., .F.)

    If !(cTab)->( Eof() )
        cNroItem := Soma1((cTab)->ITEM)
    Else
        cNroItem := '001'
    EndIf
    (cTab)->( DbCloseArea() )
Else
    cNroItem := Soma1(cNroItem)
EndIf

cRet := cNroItem

RestArea(aArea)

Return cRet

//--------------------------------------------------------
/*/{Protheus.doc} GrvCXSan
Função para chamar o ExecAuto do  FinA100

@param 		aAuto    -> Array com os campos obrigatorios e dados do operador de caixa
@author  	Varejo
@version 	1.0
@since      16/07/2020
@return	    aRet    -> Retorna com a informação se foi sucesso ou nao o cad do operador de caixa
/*/
//--------------------------------------------------------
Function GrvCXSan(aAuto)

Local aRet := Array(2) //Variavel de retorno
Local aArea := GetArea() //Guarda a area das tabelas
Local aDest := {} //Array do caixa central
Local nPos  := 0
PRIVATE lMsErroAuto := .F.

Default aAuto    := {}
nPos := aScan(aAuto[1],{|x| AllTrim(x[1]) == "E5_VALOR"})

If Len(aAuto) > 0 .AND. nPos > 0 .AND. aAuto[1][nPos][2] > 0
    Begin Transaction
        //MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aAuto[1],3)
        If !lMsErroAuto
            MovTrans(aAuto[1], @aDest)
            MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aDest,7)
        EndIf    
        If lMsErroAuto
            DisarmTransaction()
        EndIf
    End Transaction

    If lMsErroAuto  
        aRet[1] := .F.
        aRet[2] := MostraErro("\")
    Else
        aRet[1] := .T.
        aRet[2] := ""
    EndIf
Else
    aRet[1] := .F.
    aRet[2] := "O Valor conferido é igual a Zero no campo E5_VALOR"
    LjGrvLog("RMIXFUNB", "O Valor conferido é igual a Zero", aAuto[1])
EndIf

RestArea(aArea)
Return aRet

//--------------------------------------------------------
/*/{Protheus.doc} MontaMov
Função para gera movimento no caixa central

@param 		aDest    -> Array com os campos obrigatorios e dados do operador de caixa
@author  	Varejo
@version 	1.0
@since      16/07/2020
/*/
//--------------------------------------------------------
Function MovTrans(aAuto,aDest)

Local aCxLoja	:= Separa(SuperGetMV("MV_CXLOJA",.F.,""),"/")
Local nTamCod   := TamSX3("A6_COD")[1]		                    //Tamanho do campo A6_COD
Local nTamAg   	:= TamSX3("A6_AGENCIA")[1]	                    //Tamanho do campo A6_AGENCIA
Local nTamConta	:= TamSX3("A6_NUMCON")[1]	                    //Tamanho do campo A6_NUMCON
Local cCodBanco := ""						                    //Codigo do banco		
Local cCodAgen  := ""						                    //Codigo do agencia
Local cNumCon   := "" 						                    //Numero do conta
Local cHistor   := "SANGRIA DO CAIXA"
Local cBenef    := "INTEGRACAO"

Default aDest   := {}

If Len(aCxLoja) >= 3
	cCodBanco   	:= PADR(aCxLoja[1],nTamCod) //Codigo do banco		
	cCodAgen   		:= PADR(aCxLoja[2],nTamAg) //Codigo do agencia
	cNumCon       	:= PADR(aCxLoja[3],nTamConta) //Numero do conta	
EndIf

nPos     := aScan(aAuto,{|x| AllTrim(x[1]) == "E5_BANCO"})
CBCOORIG := PadR(aAuto[nPos][2],TamSX3("E5_BANCO")[1])

nPos     := aScan(aAuto,{|x| AllTrim(x[1]) == "E5_AGENCIA"})
CAGENORIG := PadR(aAuto[nPos][2],TamSX3("E5_AGENCIA")[1])

nPos     := aScan(aAuto,{|x| AllTrim(x[1]) == "E5_CONTA"})
CCTAORIG := PadR(aAuto[nPos][2],TamSX3("E5_CONTA")[1])

nPos     := aScan(aAuto,{|x| AllTrim(x[1]) == "E5_MOEDA"})
CTIPOTRAN := PadR(aAuto[nPos][2],TamSX3("E5_MOEDA")[1])

nPos     := aScan(aAuto,{|x| AllTrim(x[1]) == "E5_VALOR"})
NVALORTRAN := Val(PadR(aAuto[nPos][2],TamSX3("E5_VALOR")[1]))

nPos     := aScan(aAuto,{|x| AllTrim(x[1]) == "E5_NATUREZ"})
cNaturOri := PadR(aAuto[nPos][2],TamSX3("E5_NATUREZ")[1])

nPos     := aScan(aAuto,{|x| AllTrim(x[1]) == "E5_HISTOR"}  )
cHistor  := IIF(nPos > 0, aAuto[nPos][2], cHistor)

nPos     := aScan(aAuto,{|x| AllTrim(x[1]) == "E5_BENEF"}   )
cBenef   := IIF(nPos > 0, aAuto[nPos][2], cBenef)

If cNaturOri == "SANGRIA"

    aAdd(aDest,{"CBCOORIG"  , CBCOORIG  , Nil})
    aAdd(aDest,{"CAGENORIG" , CAGENORIG , Nil})
    aAdd(aDest,{"CCTAORIG"  , CCTAORIG  , Nil})

    aAdd(aDest,{"CBCODEST"  , cCodBanco , Nil})
    aAdd(aDest,{"CAGENDEST" , cCodAgen  , Nil})
    aAdd(aDest,{"CCTADEST"  , cNumCon   , Nil})

//SUPRIMENTO
Else

    aAdd(aDest,{"CBCOORIG"  , cCodBanco , Nil})
    aAdd(aDest,{"CAGENORIG" , cCodAgen  , Nil})
    aAdd(aDest,{"CCTAORIG"  , cNumCon   , Nil})

    aAdd(aDest,{"CBCODEST"  , CBCOORIG  , Nil})
    aAdd(aDest,{"CAGENDEST" , CAGENORIG , Nil})
    aAdd(aDest,{"CCTADEST"  , CCTAORIG  , Nil})
EndIf

aAdd(aDest,{"CNATURORI" , cNaturOri , Nil})
aAdd(aDest,{"CNATURDES" , cNaturOri , Nil})
aAdd(aDest,{"CTIPOTRAN" , CTIPOTRAN , Nil})
aAdd(aDest,{"CDOCTRAN"  , GETSXENUM("SE5","E5_NUMCHEQ"),Nil})
ConfirmSx8()
aAdd(aDest,{"NVALORTRAN", NVALORTRAN, Nil})
aAdd(aDest,{"CHIST100"  , cHistor   , Nil})
aAdd(aDest,{"CBENEF100" , cBenef    , Nil})

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} GetMarcas
Função para consultar a SB5 e retornar as marcas

@param 		aMarcas    -> Array com as marcas
@author  	Bruno Almeida
@version 	1.0
@since      25/11/2021
/*/
//--------------------------------------------------------
Function GetMarcas(cFilCons)

    Local aMarcas   := {} //Armazena as marcas
    Local cQuery    := "" //Query para consulta das marcas
    Local cAlias    := GetNextAlias() //Proximo Alias

    cQuery := "SELECT B5_MARCA "
    cQuery += "  FROM  " + RetSqlName("SB5")
    cQuery += " WHERE B5_FILIAL = '" + cFilCons + "'"
    cQuery += "   AND B5_MARCA <> ''"
    cQuery += " GROUP BY B5_MARCA"

    LjGrvLog("GetMarcas", "Consultando as marcas da filial " + AllTrim(cFilCons) + ". Query -> " + AllTrim(cQuery))
    DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)

    While !(cAlias)->( Eof() )
        Aadd(aMarcas,(cAlias)->B5_MARCA)
        (cAlias)->( DbSkip() )
    EndDo

    (cAlias)->( DbCloseArea() )

Return aMarcas

//--------------------------------------------------------
/*/{Protheus.doc} RmiSeTDtPrc
A cada reprocessamento, entra nessa função para atualizar o Json
de envio com a nova data de processamento que é gravada no layout
de envia através da TAG DataPeriodo

@param 		Não ha
@author  	Varejo
@version 	1.0
@since      17/01/2022
@return	    cRet = XXXX-XX-XX
/*/
//--------------------------------------------------------
Function RmiSeTDtPrc(oJson)
Local cRet := ""

Default oJson := ""

If ValType(oJson) != "C"
    cRet := Str(Year(cTod(oJson["DataPeriodo"])-1), 4) +'-'+  StrZero(Month(cTod(oJson["DataPeriodo"])-1), 2) +'-'+;
    StrZero( Day(cTod(oJson["DataPeriodo"])-1), 2)
    
    //Atualiza o objeto que contém o Json de envio
    oJson["DataPeriodo"] := dToc(cTod(oJson["DataPeriodo"])+1) //Atualiza a data para +1 
    
    //Atualiza o registro da MHP com a atualização do Json
    If cTod(oJson["DataPeriodo"]) <= dDataBase
        LjGrvLog("RMIXFUNB","RmiSeTDtPrc - RmiAtuCfg para atualizar a data para ",oJson["DataPeriodo"])
        RmiAtuCfg(oJson:ToJson()) //MHP deve esta posicionada
    EndIf    
EndIf

LjGrvLog("RMIXFUNB","RmiSeTDtPrc - Retorno da data RMISetDtPrc ",cRet)

Return cRet
//--------------------------------------------------------
/*/{Protheus.doc} RmiAtuCfg
A cada processamento, entra nessa função para atualizar o Json
da MHP_CONFIG.

@param 		Não ha
@author  	Varejo
@version 	1.0
@since      17/01/2022
@return	    Não ha
@Obs        MHP deve esta posicionada
/*/
//--------------------------------------------------------
Function RmiAtuCfg(cJson)

Local aArea := GetArea() //Guarda a area

Default cJson := ""


If RecLock("MHP",.F.)
    MHP->MHP_CONFIG := cJson
    MHP->(MsUnlock())
EndIf

RestArea(aArea)

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} RmiTesProd
Atualiza a Tes do produto no layout de integração.

@type    Function
@param   cProduto, Caractere, Código da tes
@return  cTes
@author  Everson S P Junior
@since   17/02/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function RmiTesProd(cProduto,cCodCliente,cLojCliente)
Local cTes        := ""

Default cCodCliente    := PadR(SuperGetMv('MV_CLIPAD', .F., '000001') , TamSx3("A1_COD")[1] )
Default cLojCliente    := PadR(SuperGetMv('MV_LOJAPAD', .F., '01'), TamSx3("A1_LOJA")[1])

SB1->( DbSetOrder(1) )  //B1_FILIAL+B1_COD
cProduto := PadR(cProduto , TamSx3("B1_COD")[1] )
SB1->( DbSeek(xFilial("SB1") + cProduto) )

cTes := MaTesInt(2 , "01"      , cCodCliente, cLojCliente, "C" , cProduto  , /*cCampo*/, /*cTipoCli*/    , /*cEstOrig*/    , /*cOrigem*/ )

If Empty(cTes)
    cTes := SB1->B1_TS
EndIf    

If Empty(cTes)
    cTes := SuperGetMv("MV_TESSAI", , "501")
EndIf

Return cTes

//-------------------------------------------------------------------
/*/{Protheus.doc} SHPStatus
Função que chama a publicação do status do pedido conforme ação tomada  (Cancelamento,Faturamento, etc.)
para o processo Status Pedido.

@type    Function
@author  Evandro Luiz Barbosa Pattaro
@since   28/06/22
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function SHPStatus(cStatus)
Local oJson := Nil 
Local cMsg := ""
Local cRet := .T.

    Do Case

        Case cStatus == "packaged"
            cMsg := "Venda: #1|#2 empacotada/pronto para retirada "
        Case cStatus == "order_delivered"
            cMsg := "Venda: #1|#2 entregue."
        Case cStatus == "canceled"
            cMsg := "Venda: #1|#2 cancelada."
        Case cStatus == "billed"     
            cMsg := "Venda: #1|#2 faturada ."
        Case cStatus == "released"  
            cMsg := "Venda: #1|#2 liberada ."         
    End Case

    oJson := JsonObject():New()

    oJson["filial"]       := SL1->L1_FILIAL
    oJson["pedidoOrigem"] := Alltrim(SL1->L1_ECPEDEC)
    oJson["status"]       := cStatus
    oJson["detalhe"]      := JsonObject():New()

    oJson["detalhe"]["mensagem"] := I18n(cMsg,{SL1->L1_FILIAL,SL1->L1_NUM})

    RmiExeGat("STATUSPEDIDO", "2", {oJson})

    FwFreeObj(oJson)

Return cRet
