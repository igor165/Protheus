#INCLUDE "TOTVS.CH"
#include "TopConn.ch"
#INCLUDE "FWPrintSetup.ch"
#include "ap5mail.ch"
#INCLUDE "RPTDEF.CH"

/* 
    VARIAVEIS REGISTRO HEADER DO ARQUIVO                                
    
    C�digo do Banco: nCodBco 
    Descri��o: C�DIGO DO BCO NA COMPENSA��O
    Posi��o: 001 - 003
    CONTE�DO: 341
    Tipo: N�merico

    C�digo do Lote: nCodLt
    Descri��o: LOTE DE SERVI�O 
    Posi��o: 004 - 007
    CONTE�DO: 0000
    Tipo: N�merico

    Tipo de registro: nTpReg   
    Descri��o: REGISTRO HEADER DE ARQUIVO
    Posi��o: 008 - 008
    CONTE�DO: 0
    Tipo: N�merico

    Brancos: cBranco
    Descri��o: COMPLEMENTO DE REGISTRO
    Posi��o: 009 - 014
    CONTE�DO: Space(6)
    Tipo: Alfa

    LAYOUT DE ARQUIVO: nLayServ
    Descri��o: N� DA VERS�O DO LAYOUT DO ARQUIVO
    Posi��o: 015 - 017
    CONTE�DO: 080
    Tipo: Alfa

    EMPRESA � INSCRI��O: nEmpInc 
    Descri��o: TIPO DE INSCRI��O DA EMPRESA
    Posi��o: 018 - 018
    CONTE�DO:   1 = CPF
                2 = CNPJ
    Tipo: N�merico

    INSCRI��O N�MERO: nIncNum 
    Descri��o: CNPJ EMPRESA DEBITADA
    Posi��o: 019 - 032
    CONTE�DO: NOTA 1
    Tipo: N�merico

    BRANCOS: cBranco 
    Descri��o: COMPLEMENTO DE REGISTRO
    Posi��o: 033 - 052
    CONTE�DO: Space(20)
    Tipo: Alfa

    AG�NCIA: nAgeDeb
    Descri��o: N�MERO AG�NCIA DEBITADA
    Posi��o: 053 - 057
    CONTE�DO: NOTA 1
    Tipo: N�merico

    BRANCOS: cBranco 
    Descri��o: COMPLEMENTO DE REGISTRO 
    Posi��o: 058 - 058
    CONTE�DO: Space(1)
    Tipo: Alfa

    CONTA: nCtaDeb 
    Descri��o: N�MERO DE C/C DEBITADA
    Posi��o: 059 - 070
    CONTE�DO: NOTA 1
    Tipo: N�merico

    BRANCOS: cBranco 
    Descri��o: COMPLEMENTO DE REGISTRO 
    Posi��o: 071 - 071
    CONTE�DO: Space(1)
    Tipo: Alfa

    DAC: nDac 
    Descri��o: DAC DA AG�NCIA/CONTA DEBITADA
    Posi��o: 072 - 072
    CONTE�DO: NOTA 1
    Tipo: N�merico

    NOME DA EMPRESA: cEmpNome
    Descri��o: NOME DA EMPRESA
    Posi��o: 073 - 102
    CONTE�DO: 
    Tipo: N�merico

    NOME DO BANCO: cBcoNome
    Descri��o: NOME DA BANCO
    Posi��o: 103 - 132
    CONTE�DO: 
    Tipo: N�merico

    BRANCOS: cBranco 
    Descri��o: COMPLEMENTO DE REGISTRO 
    Posi��o: 133 - 142
    CONTE�DO: Space(10)
    Tipo: Alfa

    ARQUIVO-C�DIGO: nArqCod
    Descri��o: C�DIGO REMESSA/RETORNO
    Posi��o: 143 - 143
    CONTE�DO:   1=REMESSA
                2=RETORNO
    Tipo: N�merico

    DATA DE GERA��O : nDtGerado
    Descri��o: DATA DE GERA��O DO ARQUIVO
    Posi��o: 144 - 151
    CONTE�DO:   DDMMAAAA
    Tipo: N�merico

    HORA DA GERA��O: nHrGerado
    Descri��o: HORA DE GERA��O DO ARQUIVO 
    Posi��o: 152 - 157
    CONTE�DO: HHMMSS
    Tipo: N�merico

    ZEROS: nZeros
    Descri��o: COMPLEMENTO DE REGISTRO
    Posi��o: 158 - 166
    CONTE�DO: 000000000
    Tipo: N�merico

    UNIDADE DE DENSIDADE: nUnDens
    Descri��o:  DENSIDADE DE GRAVA��O DO ARQUIVO
    Posi��o: 167 - 171
    CONTE�DO: NOTA 2
    Tipo: N�merico

    BRANCOS: cBranco 
    Descri��o: COMPLEMENTO DE REGISTRO 
    Posi��o: 172 - 240
    CONTE�DO: Space(69)
    Tipo: Alfa
*/
/*  
    Igor Gomes OLiveira 03/10/2022
    CNAB SISPAG ITAU 
*/
User Function VASISPAG()
    Local aArea         := GetArea()
    Local cTxt          := ""
    Local lTemDados		:= .T.
    Local nJ
    Local cCTxt         := ""
    Local cCcAnt        := ""
    Local nTamBuff      := 584//252
    Local cLinha        := Space(nTamBuff)
    Local aTot          := {}
    Local lGrv          := .F. 
    Local cTimeINI      := Time()
    Local lCancela      := .F.
    

    private ProcN       := ProcName(6)
    Private cPerg		:= SubS(ProcName(),3)
    Private cPath 	 	:= "C:\totvs_relatorios\"
    Private cArquivo   	:= cPath  + cPerg  +; // _cUserID+""+;
								DtoS(dDataBase)+; 
								"_"+; 
								StrTran(SubS(Time(),1,5),":","")+;
								".txt"
    Private _cAlias 	:= GetNextAlias()

    Private nCodBco := '341'
    Private nCodLt  := '1'
    Private nTpReg  := ''
    Private cBranco
    Private nLayServ
    Private nEmpInc
    Private nIncNum
    Private nAgeDeb
    Private nCtaDeb
    Private nDac
    Private cEmpNome
    Private cBcoNome
    Private nArqCod
    Private nDtGerado
    Private nHrGerado
    Private nZeros
    Private nUnDens

    GeraX1(cPerg)

    If Pergunte(cPerg, .T.)
	    U_PrintSX1(cPerg)

        If Len( Directory(cPath + ".","D") ) == 0
            If Makedir(cPath) == 0
                ConOut('Diretorio Criado com Sucesso.')
            Else	
                ConOut( "Não foi possivel criar o diretório. Erro: " + cValToChar( FError() ) )
            EndIf
        EndIf

        FWMsgRun(, {|| lTemDados := fLoadSql( @_cAlias ) },'Por Favor Aguarde...' , 'Processando Banco de Dados')
        
        If lTemDados
            nHandle := FCreate(cArquivo)
            if nHandle = -1
                conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
            else
                
                SA2->(DbSelectArea("SA2"))
                SA2->(DbSetOrder(1))

                SEA->(DbSelectArea("SEA"))
                SEA->(DbSetOrder(1))

                (_cAlias)->(DbGoTop())
                while !(_cAlias) -> (EOF())
                    if SA2->(DbSeek(xFilial("SA2")+(_cAlias)->E2_FORNECE+(_cAlias)->E2_LOJA))
                        
                        SEA->(DbSeek(xFilial("SEA")+;
                                (_cAlias)->E2_NUMBOR+;
                                (_cAlias)->E2_PREFIXO+;
                                (_cAlias)->E2_NUM+;
                                (_cAlias)->E2_PARCELA+;
                                (_cAlias)->E2_TIPO+;
                                (_cAlias)->E2_FORNECE+;
                                (_cAlias)->E2_LOJA))
                        
                    ELSE 

                    ENDIF 
                ENDDO
            ENDIF
        ENDIF

        If lower(cUserName) $ 'ioliveira,atoshio,admin, administrador'
            Alert('Tempo de processamento: ' + ElapTime( cTimeINI, Time() ) )
        EndIf

        ConOut('Activate: ' + Time())
    ENDIF

RestArea(aArea) 
Return 

Static Function GeraX1(cPerg)

Local _aArea	:= GetArea()
Local aRegs     := {}
Local nX		:= 0
Local nPergs	:= 0
Local i := 0, j := 0

//Conta quantas perguntas existem ualmente.
DbSelectArea('SX1')
DbSetOrder(1)
SX1->(DbGoTop())
If SX1->(DbSeek(cPerg))
	While !SX1->(Eof()) .And. X1_GRUPO = cPerg
		nPergs++
		SX1->(DbSkip())
	EndDo
EndIf

aAdd(aRegs,{cPerg, "01", "Bordero de    ?", "", "", "MV_CH1", "C", TamSx3("E2_NUMBOR")[1]   , TamSx3("E2_NUMBOR")[2]    , 0, "G", "", "MV_PAR01", "", "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "02", "Bordero ate   ?", "", "", "MV_CH2", "C", TamSx3("E2_NUMBOR")[1]   , TamSx3("E2_NUMBOR")[2]    , 0, "G", "", "MV_PAR02", "", "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})

//Se quantidade de perguntas for diferente, apago todas
SX1->(DbGoTop())
If nPergs <> Len(aRegs)
	For nX:=1 To nPergs
		If SX1->(DbSeek(cPerg))		
			If RecLock('SX1',.F.)
				SX1->(DbDelete())
				SX1->(MsUnlock())
			EndIf
		EndIf
	Next nX
EndIf

// gravação das perguntas na tabela SX1
If nPergs <> Len(aRegs)
	dbSelectArea("SX1")
	dbSetOrder(1)
	For i := 1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
				For j := 1 to FCount()
					If j <= Len(aRegs[i])
						FieldPut(j,aRegs[i,j])
					Endif
				Next j
			MsUnlock()
		EndIf
	Next i
EndIf

RestArea(_aArea)

Return nil

Static Function fLoadSql(_cAlias)
    Local _cQry 		:= ""

    _cQry := " select * "+ CRLF
    _cQry += " from "+RetSqlName("SE2")+" E2 " + CRLF
    _cQry += " LEFT JOIN "+RetSqlName("SA2")+" A2 ON A2_COD = E2_FORNECE" + CRLF
    _cQry += " AND A2.D_E_L_E_T_ = ''" + CRLF
    _cQry += " WHERE E2_FILIAL = '"+FWxFilial("SE2")+"'" + CRLF
    _cQry += " AND E2_NUMBOR BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'" + CRLF
    _cQry += " AND E2.D_E_L_E_T_ = '' " + CRLF

    If lower(cUserName) $ 'ioliveira,mbernardo,atoshio,admin,administrador'
        MemoWrite(StrTran(cArquivo,".xml","")+"Quadro.sql" , _cQry)
    EndIf

    dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.) 

Return !(_cAlias)->(Eof())
