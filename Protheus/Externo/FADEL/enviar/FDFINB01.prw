#include "Fileio.ch"
#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "RWMAKE.CH"
#include "colors.ch"
#INCLUDE "TBICONN.CH"

#define PAD_LEFT          0
#define PAD_RIGHT         1
#define PAD_CENTE         2

#DEFINE IMP_SPOOL 2

#DEFINE VBOX       080
#DEFINE HMARGEM    030
#DEFINE VMARGEM    030


/* 
    Variavel:       cItireg
    Descri��o:      Tipo Registro:
                        'D' - REGISTRO DE DETALHE
                        'C' - REGISTRO DE CONTROLE
    Requerido:      S
    Tipo:			C
    Tamanho:		1
    Decimal:		00
    Posi��o:        1-1

    Variavel:       cItiTra
    Descri��o:      Tipo de Transfer�ncia:  
                        '01' - Pagamento de Salario
                        '02' - Pago a Proveedore
                        '03' - Cobro de Factura/Cuota
                        '04' - D�bitos comandados
    Requerido:      S
    Tipo:			C
    Tamanho:		2
    Decimal:		00
    Posi��o:        2-3

    Variavel:       nIcdsrv
    Descri��o:      C�digo empresa (asignado por el Banco)
    Requerido:      S
    Tipo:			N
    Tamanho:		3
    Decimal:		00
    Posi��o:        4-6

    Variavel:       nIctdeb
    Descri��o:      Nro. de cuenta para d�bito/Cuenta empresa
    Requerido:      S
                    N - Cobro Cuotas
    Tipo:			N
    Tamanho:		10
    Decimal:		00
    Posi��o:        7-16
    
    Variavel:       cIbcocr
    Descri��o:      ro. de Banco para cr�dito Obs: siempre 017
    Requerido:      S
    Tipo:			N
    Tamanho:		3
    Decimal:		00
    Posi��o:        17-19
    
    Variavel:       nICtCre
    Descri��o:      Nro. de cuenta para cr�dito Obs: Si pago en cheque relleno con ceros
    Requerido:      S
                    N - Cobro Cuotas
    Tipo:			N
    Tamanho:		10
    Decimal:		00
    Posi��o:        20-29
    
    Variavel:       cItCrDb
    Descri��o:      Tipo d�bito/cr�dito
                        �D� D�bito
                        �C� Cr�dito
                        �H� Cheque
                        �F� Cobro de Factura/Cuota
    Requerido:      S
    Tipo:			C
    Tamanho:		1
    Decimal:		00
    Posi��o:        30-30

    Variavel:       nIMoned
    Descri��o:      Moneda correspondiente al monto
                        0 Guaran�es
                        1 Dolares
                        Obs: Para transferencias la cuenta origen debe ser de la misma moneda que la cuenta destino.
    Requerido:      S-Pgo.Proveedor.
                    N-demas casos
    Tipo:			N
    Tamanho:		1
    Decimal:		00
    Posi��o:        81-81

    Variavel:       nImTotr
    Descri��o:      Monto Transferencia/Monto Factura, cuota Obs: �ltimos dos d�gitos corresponde a decimales.
    Requerido:      S
    Tipo:			N
    Tamanho:		15
    Decimal:		2
    Posi��o:        82-96
    
    Variavel:       nImTot2
    Descri��o:      Monto Transferencia (segundo vencimiento)
                        Obs: �ltimos dos d�gitos corresponde a decimales. Solo para Cobro de Factura/Cuota.Demas 0
    Requerido:      S
    Tipo:			N
    Tamanho:		15
    Decimal:		2
    Posi��o:        97-111

    Variavel:       nInRodo
    Descri��o:      Nro. de documento 
                    Obs: c�dula de identidad, RUC, Pasaporte, otros. Del beneficiario, proveedor, cliente
    Requerido:      S-Cobro Fact/Cuo
                    N-Dem�s casos
    Tipo:			C
    Tamanho:		12
    Decimal:		00
    Posi��o:        112-123

    Variavel:       nItiFac
    Descri��o:      Tipo Factura
                        1 Factura Contado
                        2 Factura Cr�dito
                        Solo para Pago a Proveedores. Dem�s 0
    Requerido:      S-Pgo.Proveedor.
                    N-demas casos
    Tipo:			N
    Tamanho:		1
    Decimal:		00
    Posi��o:        124-124

    Variavel:       cInrFac
    Descri��o:      Nro. de Factura 
                    Obs:Para pago a proveedores.Dem�s blancos
    Requerido:      N-Pago Salario
                    S-Dem�s casos
    Tipo:			C
    Tamanho:		20
    Decimal:		00
    Posi��o:        125-144

    Variavel:       nInrCuo
    Descri��o:      Nro. de Cuota pagada/a cobrar. Solo para �F� Cobro de Factura/Cuota
    Requerido:      S-Cobro Fact/Cuo
                        N-Dem�s casos
    Tipo:			N
    Tamanho:		3
    Decimal:		00
    Posi��o:        145-147

    Variavel:       nIfChCr
    Descri��o:      Fecha para realizar el cr�dito/Fecha vencimiento
    Requerido:      S-Cobro Fact/Cuo
                        N-Dem�s casos
    Tipo:			N
    Tamanho:		8
    Formato:        Aaaammdd 
    Decimal:		00
    Posi��o:        148-155

    Variavel:       nIfChC2
    Descri��o:      Fecha segundo vencimiento. Solo para � F� Cobro de Factura/Cuota
    Requerido:      N
    Tipo:			N
    Tamanho:		8
    Formato:        Aaaammdd 
    Decimal:		00
    Posi��o:        156-163

    Variavel:       cIcePto
    Descri��o:      Comentario de concepto cobrado/pagado
    Requerido:      N
    Tipo:			C
    Tamanho:		50
    Decimal:		00
    Posi��o:        164-213

    Variavel:       cInrRef
    Descri��o:      Referencia operaci�n empresa
    Requerido:      N
    Tipo:			C
    Tamanho:		15
    Decimal:		00
    Posi��o:        214-228
 
    Variavel:       nIFecCa
    Descri��o:      Fecha de carga de transacci�n
    Requerido:      N
    Tipo:			N
    Tamanho:		8
    Decimal:		00
    Formato:        Aaaammdd 
    Posi��o:        229-236

    Variavel:       nIHorCa
    Descri��o:      Hora de carga de transacci�n
    Requerido:      N
    Tipo:			N
    Tamanho:		8
    Decimal:		00
    Formato:        Hhmmss 
    Posi��o:        237-242

    Variavel:       cIuSuCa
    Descri��o:      Nombre del usuario que carg�
    Requerido:      N
    Tipo:			C
    Tamanho:		10
    Decimal:		00
    Posi��o:        243-252
 */

User Function F050ROT()
Local aRotina := aClone(ParamIXB)	

    SetKey( VK_F10,                       {|| U_fCnabFI() } )
    AAdd(aRotina, { "Gerar CNAB (F10)", "U_fCnabFI", 0 , 4, 0, .f.})

return aRotina

User Function fCnabFI()

    Local aArea         := GetArea()
    Local cTxt          := ""
    Local lTemDados		:= .T.
    Local nJ
    Local cCTxt         := ""
    Local cCcAnt        := ""
    Local nTamBuff      := 254//252
    Local cLinha        := Space(nTamBuff)
    Local aTot          := {}
    Local lGrv          := .F. 
    Local cTimeINI      := Time()
    

    private ProcN       := ProcName(6)
    Private cPerg		:= SubS(ProcName(),3)
    Private cPath 	 	:= "C:\totvs_relatorios\"
    Private cArquivo   	:= cPath  + cPerg  +; // __cUserID+"_"+;
								DtoS(dDataBase)+; 
								"_"+; 
								StrTran(SubS(Time(),1,5),":","")+;
								".txt"
    Private _cAlias 	:= GetNextAlias()  

    Private cITiReg := ""
    Private cITiTra := ""
    Private nICdSrv := 0
    Private nICtDeb := 0
    Private nIBcoCr := 0
    Private nICtCre := 0
    Private cItCrDb := ""
    Private cIOrdem := ""
    Private nIMoned := 0
    Private nImTotr := 0
    Private nImTot2 := 0
    Private nInRodo := 0
    Private nItiFac := 0
    Private cInrFac := ""
    Private nInrCuo := 0
    Private nIfChCr := 0
    Private nIfChC2 := 0
    Private cIcePto := ""
    Private cInrRef := ""
    Private nIFecCa := 0
    Private nIHorCa := 0
    Private cIuSuCa := ""
    Private cLin    := "" 

    GeraX1(cPerg)

    If Pergunte(cPerg, .T.)
	    U_PrintSX1(cPerg)

        If Len( Directory(cPath + "*.*","D") ) == 0
            If Makedir(cPath) == 0
                ConOut('Diretorio Criado com Sucesso.')
            Else	
                ConOut( "N�o foi possivel criar o diret�rio. Erro: " + cValToChar( FError() ) )
            EndIf
        EndIf

        FWMsgRun(, {|| lTemDados := fLoadSql( @_cAlias ) },'Por Favor Aguarde...' , 'Processando Banco de Dados')

        If lTemDados

        nHandle := FCreate(cArquivo)
        if nHandle = -1
            conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
        else
            (_cAlias)->(DbGoTop())

            while !(_cAlias) -> (EOF())

                nICtDeb := "123"        //AllTrim((_cAlias)->E1_CONTA)
                nICtCre := "1234567890"//"0000000000" //AllTrim((_cAlias)->E1_AGEDEP)
                nIMoned := AllTrim(Str((_cAlias)->E2_MOEDA))
                nImTotr := StrTran( Subs( AllTrim(str((_cAlias)->E2_VALOR)),1, len(AllTrim(Str((_cAlias)->E2_VALOR)))),".","")
                nInRodo := StrZero(Val(AllTrim((_cAlias)->A2_CGC)),12,0)
                nIfChCr := AllTrim((_cAlias)->E2_VENCTO)
                nItiFac := AllTrim((_cAlias)->E2_FATURA)

                cTxt := "D"
                cTxt += "02"
                cTxt += RIGHT("000"+nICtDeb,3)
                cTxt += RIGHT("0000000000"+nICtCre,10)
                // cTxt += RIGHT("0000000000"+AllTrim((_cAlias)->E1_CONTA),10)
                cTxt += "017"
                IF Alltrim((_cAlias)->E2_CTACHQ) != ''
                    cTxt += RIGHT("0000000000"+"0",10)
                    cTxt += "H"
                ELSE 
                    cTxt += RIGHT("0000000000"+nICtCre,10)
                    cTxt += "C"
                ENDIF

                cTxt += Space(50) // ADICIONAR NOME FORNECEDOR
                cTxt += nIMoned
                cTxt += Right("000000000000000"+nImTotr,15)
                cTxt += Right("000000000000000"+"0", 15)
                cTxt += nInRodo

                cTxt += "2"

                cTxt += Padr(" ",20,nItiFac)
                if SubStr(cTxt,30,1) == 'F'
                    cTxt += "000"     // sOMENTE PARA cItCrDb = 'F'
                ELSE 
                    cTxt += "000"
                ENDIF 
                cTxt += nIfChCr
                if SubStr(cTxt,30,1) == 'F'
                    cTxt += "00000000"     // sOMENTE PARA cItCrDb = 'F'
                ELSE 
                    cTxt += "00000000"
                ENDIF 
                cTxt += Space(50)
                cTxt += Space(15) 
                cTxt += dToS(dDataBase)
                cTxt += StrTran(SubS(Time(),1,8),":","")
                cTxt += PadL(lower(cUserName),10," ")
                cTxt += CRLF

                FWrite(nHandle,  cTxt)

                (_cAlias)->(DbSkip())
            ENDDO
            (_cAlias)->(DbCloseArea())
            
            nLength := FSEEK(nHandle, 0, FS_END)

            fSeek( nHandle, 0, FS_SET)
            fRead( nHandle, @cCTxt, nTamBuff)

            While !Empty(cCTxt)
                if Len(aTot) == 0
                        aADD(aTot,{SubStr(cCTxt,7,10) ,;
                                    Val(SubStr(cCTxt,82,15)) }) // nICtDeb
                else 
                    for nJ := 1 to len(aTot)
                        if aTot[nJ][1] == cCcAnt
                            aTot[nJ][2] +=  Val(SubStr(cCTxt,82,15))

                            lGrv := .T.
                        ENDIF
                    next nJ 
                    if !lGrv
                        aADD(aTot,{SubStr(cCTxt,7,10)  ,;
                                    Val(SubStr(cCTxt,82,15))})  // nICtDeb
                    ENDIF
                ENDIF
                cCcAnt := SubStr(cCTxt,7,10)
                FRead( nHandle, @cCTxt, nTamBuff )
                lGrv := .F.
            EndDo

            for nJ := 1 to len(aTot)
                cLinha := "C" //cITiReg
                cLinha += SPACE(2) //cITiTra
                cLinha += "000" //nICdSrv
                cLinha += RIGHT("0000000000"+AllTrim(aTot[nJ][1]),10) //aTot[nJ][1] // Conta CC E1_CONTA nICtDeb //
                cLinha += "000" //
                cLinha += "0000000000" //
                cLinha += SPACE(1) //
                cLinha += Space(50) //
                cLinha += "0" //
                cLinha += Right("000000000000000"+AllTrim(Str(aTot[nJ][2])), 15)// aTot[nJ][2] // Valor  nImTotr //
                cLinha += "000000000000000"  //
                cLinha += "000000000000" //
                cLinha += "0" //
                cLinha += Space(20) // nuMERO DA FATURA //
                cLinha += "000"     // sOMENTE PARA cItCrDb = 'F' //
                cLinha += "00000000" //
                cLinha += "00000000" // // sOMENTE PARA cItCrDb = 'F' //
                cLinha += Space(50) //
                cLinha += Space(15) //
                cLinha += "00000000" //
                cLinha += "000000" //
                cLinha += Space(10) //
                cLinha += CRLF
                FWrite(nHandle,  cLinha)
            next nJ 

            FClose(nHandle)
        ENDIF
        

        If lower(cUserName) $ 'ioliveira,atoshio,admin, administrador'
            Alert('Tempo de processamento: ' + ElapTime( cTimeINI, Time() ) )
        EndIf
    
        ConOut('Activate: ' + Time())
    ENDIF
ENDIF

RestArea(aArea)
Return nil

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
aAdd(aRegs,{cPerg, "03", "Num Conta     ?", "", "", "MV_CH3", "C", TamSx3("E1_CONTA")[1]    , TamSx3("E1_CONTA")[2]     , 0, "G", "", "MV_PAR03", "", "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "04", "Agencia       ?", "", "", "MV_CH4", "C", TamSx3("E1_AGEDEP")[1]   , TamSx3("E1_AGEDEP")[2]    , 0, "G", "", "MV_PAR04", "", "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})

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

// grava��o das perguntas na tabela SX1
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
Static Function fLoadSql( _cAlias)
    Local _cQry 		:= ""

    _cQry := " select E2_NUM" + CRLF
    _cQry += " , E2_NUMBOR" + CRLF
    _cQry += " , E2_FORNECE" + CRLF
    _cQry += " , E2_NOMFOR" + CRLF
    _cQry += " , E2_EMISSAO" + CRLF
    _cQry += " , E2_VENCTO" + CRLF
    _cQry += " , E2_VENCREA" + CRLF
    _cQry += " , E2_VALOR" + CRLF
    _cQry += " , E2_MOEDA" + CRLF
    _cQry += " , E2_AGECHQ" + CRLF
    _cQry += " , E2_CTACHQ" + CRLF
    _cQry += " , E2_OCORREN" + CRLF
    _cQry += " , E2_FATURA" + CRLF
    _cQry += " , E2_TIPOFAT" + CRLF
    _cQry += " , E2_CONTAD" + CRLF
    _cQry += " , A2_CGC" + CRLF
    _cQry += " from "+RetSqlName("SE2")+" E2 " + CRLF
    _cQry += " LEFT JOIN "+RetSqlName("SA2")+" A2 ON A2_COD = E2_FORNECE" + CRLF
    _cQry += " AND A2.D_E_L_E_T_ = ''" + CRLF
    _cQry += " WHERE E2_FILIAL = '"+FWxFilial("SE2")+"'" + CRLF
    _cQry += " AND E2_NUMBOR BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'" + CRLF
    _cQry += " AND E2.D_E_L_E_T_ = '' " + CRLF

    If lower(cUserName) $ 'ioliveira,mbernardo,atoshio,admin,administrador'
        MemoWrite(StrTran(cArquivo,".xml","")+"_Quadro_.sql" , _cQry)
    EndIf

    dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.) 

Return !(_cAlias)->(Eof())

Static Function CnabTxt()
    Local nRegistros	:= 0
    Local cTxt      := ""
    Local cDTxt     := ""
    Local cCTxt     := ""
    Local nTot      := 0
    Local cAntCC    := ""
    Local aTot      := {}
    Local lInicio   := .f.

    (_cAlias)->(DbEval({|| nRegistros++ }))

    (_cAlias)->(DbGoTop())

    while !(_cAlias) -> (EOF())
        if Len(cTxt) == 0 
            cTxt := "D"
        else 
            cTxt += "D"
        ENDIF
        cTxt += "02"
        cTxt += "000"           //RIGHT("000"+AllTrim((_cAlias)->E1_AGEDEP),3)
        cTxt += "1234567890"//"0000000000"    // RIGHT("0000000000"+AllTrim((_cAlias)->E1_CONTA),10)
        cTxt += "017"

        cTxt += "D"

        cTxt += Space(50)

        cTxt += AllTrim(Str((_cAlias)->E2_MOEDA))
        cTxt += Right("000000000000000"+StrTran( Subs( AllTrim(str((_cAlias)->E2_VALOR)),1, len(AllTrim(Str((_cAlias)->E2_VALOR)))),".",""),15) 
        cTxt += Right("000000000000000"+"0", 15) 
        cTxt += StrZero(Val(AllTrim((_cAlias)->A1_CGC)),12,0) //LEFT("000000000000"+AllTrim((_cAlias)->A1_CGC), 12)
        cTxt += "0"
        cTxt += Space(20) // nuMERO DA FATURA
        cTxt += "000"     // sOMENTE PARA cItCrDb = 'F'
        cTxt += AllTrim((_cAlias)->E2_VENCTO)
        cTxt += "00000000" // // sOMENTE PARA cItCrDb = 'F'
        cTxt += Space(50)
        cTxt += Space(15) 
        cTxt += dToS(dDataBase)
        cTxt += StrTran(SubS(Time(),1,8),":","")
        cTxt += lower(cUserName)//AllTrim(SubStr(cUsuario,7,15))
        cTxt += CRLF

        (_cAlias)->(DbSkip())
    ENDDO

RETURN cTxt
