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


/* Totvs@Protheus2022*

    Variavel:       cItireg
    Descrição:      Tipo Registro:
                        'D' - REGISTRO DE DETALHE
                        'C' - REGISTRO DE CONTROLE
    Requerido:      S
    Tipo:			C
    Tamanho:		1
    Decimal:		00
    Posição:        1-1

    Variavel:       cItiTra
    Descrição:      Tipo de Transferência:  
                        '01' - Pagamento de Salario
                        '02' - Pago a Proveedore
                        '03' - Cobro de Factura/Cuota
                        '04' - Débitos comandados
    Requerido:      S
    Tipo:			C
    Tamanho:		2
    Decimal:		00
    Posição:        2-3

    Variavel:       nIcdsrv
    Descrição:      Código empresa (asignado por el Banco)
    Requerido:      S
    Tipo:			N
    Tamanho:		3
    Decimal:		00
    Posição:        4-6

    Variavel:       nIctdeb
    Descrição:      Nro. de cuenta para débito/Cuenta empresa
    Requerido:      S
                    N - Cobro Cuotas
    Tipo:			N
    Tamanho:		10
    Decimal:		00
    Posição:        7-16
    
    Variavel:       cIbcocr
    Descrição:      ro. de Banco para crédito Obs: siempre 017
    Requerido:      S
    Tipo:			N
    Tamanho:		3
    Decimal:		00
    Posição:        17-19
    
    Variavel:       nICtCre
    Descrição:      Nro. de cuenta para crédito Obs: Si pago en cheque relleno con ceros
    Requerido:      S
                    N - Cobro Cuotas
    Tipo:			N
    Tamanho:		10
    Decimal:		00
    Posição:        20-29
    
    Variavel:       cItCrDb
    Descrição:      Tipo débito/crédito
                        ‘D’ Débito
                        ‘C’ Crédito
                        ‘H’ Cheque
                        ‘F’ Cobro de Factura/Cuota
    Requerido:      S
    Tipo:			C
    Tamanho:		1
    Decimal:		00
    Posição:        30-30

    Variavel:       nIMoned
    Descrição:      Moneda correspondiente al monto
                        0 Guaraníes
                        1 Dolares
                        Obs: Para transferencias la cuenta origen debe ser de la misma moneda que la cuenta destino.
    Requerido:      S-Pgo.Proveedor.
                    N-demas casos
    Tipo:			N
    Tamanho:		1
    Decimal:		00
    Posição:        81-81

    Variavel:       nImTotr
    Descrição:      Monto Transferencia/Monto Factura, cuota Obs: últimos dos dígitos corresponde a decimales.
    Requerido:      S
    Tipo:			N
    Tamanho:		15
    Decimal:		2
    Posição:        82-96
    
    Variavel:       nImTot2
    Descrição:      Monto Transferencia (segundo vencimiento)
                        Obs: últimos dos dígitos corresponde a decimales. Solo para Cobro de Factura/Cuota.Demas 0
    Requerido:      S
    Tipo:			N
    Tamanho:		15
    Decimal:		2
    Posição:        97-111

    Variavel:       nInRodo
    Descrição:      Nro. de documento 
                    Obs: cédula de identidad, RUC, Pasaporte, otros. Del beneficiario, proveedor, cliente
    Requerido:      S-Cobro Fact/Cuo
                    N-Demás casos
    Tipo:			C
    Tamanho:		12
    Decimal:		00
    Posição:        112-123

    Variavel:       nItiFac
    Descrição:      Tipo Factura
                        1 Factura Contado
                        2 Factura Crédito
                        Solo para Pago a Proveedores. Demás 0
    Requerido:      S-Pgo.Proveedor.
                    N-demas casos
    Tipo:			N
    Tamanho:		1
    Decimal:		00
    Posição:        124-124

    Variavel:       cInrFac
    Descrição:      Nro. de Factura 
                    Obs:Para pago a proveedores.Demás blancos
    Requerido:      N-Pago Salario
                    S-Demás casos
    Tipo:			C
    Tamanho:		20
    Decimal:		00
    Posição:        125-144

    Variavel:       nInrCuo
    Descrição:      Nro. de Cuota pagada/a cobrar. Solo para ‘F’ Cobro de Factura/Cuota
    Requerido:      S-Cobro Fact/Cuo
                        N-Demás casos
    Tipo:			N
    Tamanho:		3
    Decimal:		00
    Posição:        145-147

    Variavel:       nIfChCr
    Descrição:      Fecha para realizar el crédito/Fecha vencimiento
    Requerido:      S-Cobro Fact/Cuo
                        N-Demás casos
    Tipo:			N
    Tamanho:		8
    Formato:        Aaaammdd 
    Decimal:		00
    Posição:        148-155

    Variavel:       nIfChC2
    Descrição:      Fecha segundo vencimiento. Solo para ’ F’ Cobro de Factura/Cuota
    Requerido:      N
    Tipo:			N
    Tamanho:		8
    Formato:        Aaaammdd 
    Decimal:		00
    Posição:        156-163

    Variavel:       cIcePto
    Descrição:      Comentario de concepto cobrado/pagado
    Requerido:      N
    Tipo:			C
    Tamanho:		50
    Decimal:		00
    Posição:        164-213

    Variavel:       cInrRef
    Descrição:      Referencia operación empresa
    Requerido:      N
    Tipo:			C
    Tamanho:		15
    Decimal:		00
    Posição:        214-228
 
    Variavel:       nIFecCa
    Descrição:      Fecha de carga de transacción
    Requerido:      N
    Tipo:			N
    Tamanho:		8
    Decimal:		00
    Formato:        Aaaammdd 
    Posição:        229-236

    Variavel:       nIHorCa
    Descrição:      Hora de carga de transacción
    Requerido:      N
    Tipo:			N
    Tamanho:		8
    Decimal:		00
    Formato:        Hhmmss 
    Posição:        237-242

    Variavel:       cIuSuCa
    Descrição:      Nombre del usuario que cargó
    Requerido:      N
    Tipo:			C
    Tamanho:		10
    Decimal:		00
    Posição:        243-252
    
    Variavel:       cINRFA2
    Descrição:      Nro. de facturas adicionales, 
                    Obs:Para pago a proveedores, tipo débito/crédito = ‘H’ Cheque. Demás blancos.
    Requerido:      N
    Tipo:			C
    Tamanho:		100
    Decimal:		00
    Posição:        253-352

    Variavel:       cINRDR1
    Descrição:      Nro. documento del cobrador,
                    Obs:Para pago a proveedores, .Demás blancos
    Requerido:      N
    Tipo:			C
    Tamanho:		15
    Decimal:		00
    Posição:        353-367

    Variavel:       cINOMR1
    Descrição:      Nombre del cobrador.
                    Obs:Para pago a proveedores, tipo débito/crédito = ‘H’ Cheque. Demás blancos
    Requerido:      N
    Tipo:			C
    Tamanho:		50
    Decimal:		00
    Posição:        368-417
 
    Variavel:       cINRDR2
    Descrição:      Nro. documento del cobrador.
                    Obs:Para pago a proveedores, tipo débito/crédito = ‘H’ Cheque. Demás blancos
    Requerido:      N
    Tipo:			C
    Tamanho:		15
    Decimal:		00
    Posição:        418-432
 
    Variavel:       cINOMR2
    Descrição:      Nombre del cobrador.
                    Obs:Para pago a proveedores, tipo débito/crédito = ‘H’ Cheque. Demás blancos
    Requerido:      N
    Tipo:			C
    Tamanho:		50
    Decimal:		00
    Posição:        433-482
 
    Variavel:       cICOMEN
    Descrição:      Comentario adicional del cliente
    Requerido:      N
    Tipo:			C
    Tamanho:		100
    Decimal:		00
    Posição:        482-582


 */

User Function F050ROT()
Local aRotina := aClone(ParamIXB)	

    SetKey( VK_F10,                       {|| U_FDFINB02() } )
    AAdd(aRotina, { "Gerar CNAB (F10)", "U_FDFINB02", 0 , 4, 0, .f.})

return aRotina

User Function FDFINB02()

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
    Private cINRFA2 := ""
    Private cINRDR1 := ""
    Private cINOMR1 := ""
    Private cINRDR2 := ""
    Private cINOMR2 := ""
    Private cICOMEN := ""
    Private cLin    := "" 

    GeraX1(cPerg)

    If Pergunte(cPerg, .T.)
	    PrintSX1(cPerg)

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

                            
                            nIcdsrv := "FU2"

                            if SEA->EA_TIPOPAG == '20'
                                cItiTra := "02"
                            ELSEIF SEA->EA_TIPOPAG == '30'
                                cItiTra := "01"
                            ELSEIF SEA->EA_TIPOPAG == '98'
                                cItiTra := "03"
                            ENDIF

                            nICtDeb := PADL(AllTrim(SEA->EA_NUMCON),10,"0") //E2_X_CONTA
                            nIBcoCr := PADL(AllTrim(SA2->A2_BANCO),3,"0")
                            nICtCre := PADL(AllTrim(SA2->A2_CONTA),10,"0")
                            
                            nIMoned := AllTrim( Posicione('SA6',1,xFilial('SA6')+ SEA->EA_PORTADO + SEA->EA_AGEDEP + SEA->EA_NUMCON,'A6_MOEDA'))

                            //nIMoned := AllTrim(Str((_cAlias)->E2_MOEDA))
                            nImTotr := StrTran( Subs( AllTrim(str((_cAlias)->E2_VALOR)),1, len(AllTrim(Str((_cAlias)->E2_VALOR)))),".","")
                            nIMTOT2 := ""         
                            nInRodo := PADR( AllTrim(Posicione("SA2",1,xFilial("SA2")+(_cAlias)->E2_FORNECE+(_cAlias)->E2_LOJA,"A2_CGC")),12," ")
                            nIFCHC2 := "00000000" // 156-163
                            
                            nIfChCr := PADL(AllTrim((_cAlias)->E2_VENCTO),8,"0")

                            cInrFac := PADL(AllTrim((_cAlias)->E2_NUM),8," ")
                            
                            if SEA->EA_MODELO $ '01,05'
                                cItCrDb := "C"
                            ELSEif SEA->EA_MODELO == '02'
                                cItCrDb := "H"
                            ELSEif SEA->EA_MODELO $ '41,43,45,47'
                                cItCrDb := "D"
                            else 
                                cItCrDb := "F"
                            ENDIF

                            cTxt := "D" // 1-1
                            cTxt += cItiTra // 2-3
                            cTxt += nIcdsrv // 4-6
                            cTxt += RIGHT("0000000000"+nICtDeb,10) // 7-16
                            cTxt += nIBcoCr //17-19
                            IF cItCrDb == "H"
                                cTxt += RIGHT("0000000000"+"0",10) // 20-29
                                cTxt += cItCrDb // 30-30
                            ELSE
                                cTxt += RIGHT("0000000000"+nICtCre,10) // 20-29
                                cTxt += cItCrDb // 30-30
                            ENDIF

                            cTxt += PADR("FADEL MERCOSUL S.A.",50," ") // 31-80
                            cTxt += nIMoned // 81-81
                            cTxt += Right("000000000000000"+nImTotr,15) //82-96
                            
                            IF SubStr(cTxt,30,1) = 'F'
                                cTxt += Right("000000000000000"+nIMTOT2, 15) //97-111
                            else 
                                cTxt += Right("000000000000000"+"0", 15) //97-111
                            endif

                            cTxt += nInRodo //112-123
                            
                            if SubStr(cTxt,2,2) == '02'
                                if SubStr(cTxt,30,1) == 'D' 
                                    cTxt += "1" //124-124
                                elseif SubStr(cTxt,30,1) == 'C' 
                                    cTxt += "2" //124-124
                                endif 
                                cTxt += Padr("",20,cInrFac) //125-144
                            else
                                cTxt += "0" //124-124
                                cTxt += Space(20) //125-144
                            endif

                            cTxt += "000" // 145-147     // sOMENTE PARA cItCrDb = 'F'

                            cTxt += nIfChCr // 148-155
                            cTxt += nIFCHC2 // 156-163    / sOMENTE PARA cItCrDb = 'F'

                            cTxt += Space(50)  // 164-213
                            cTxt += Space(15)  // 214-228
                            cTxt += dToS(dDataBase) // 229-236
                            cTxt += StrTran(SubS(Time(),1,8),":","") //  237-242
                            cTxt += PadL(lower(cUserName),10," ") //  243-252
                            
 /*                            if SubStr(cTxt,2,2) == '02' 
                                cINRDR1 := Padr(AllTrim(""),15, " ") // 353-367
                                if SubStr(cTxt,30,1) == 'H'

                                    cINRFA2 := Padr(AllTrim(""),100, "") // 253-352
                                    cINOMR1 := Padr(AllTrim(""),50, "") // 368-417
                                    cINRDR2 := Padr(AllTrim(""),15, "") // 418-432
                                    cINOMR2 := Padr(AllTrim(""),50, " ") // 433-482

                                endif
                            else  */
                                cINRFA2 := Space(100) // 253-352
                                cINRDR1 := Space(15) // 353-367
                                cINOMR1 := Space(50) // 368-417
                                cINRDR2 := Space(15) // 418-432
                                cINOMR2 := Space(50) // 433-482
                            /* endif  */

                            /* if AllTrim(MV_PAR05) != ''
                                cICOMEN := PadR(AllTrim(MV_PAR05), 100, " ") // 483-582
                            else  */
                                cICOMEN := Space(100) // 483-582
                            /* endif */

                            cTxt += cINRFA2 // 253-352
                            cTxt += cINRDR1 // 353-367
                            cTxt += cINOMR1 // 368-417
                            cTxt += cINRDR2 // 418-432
                            cTxt += cINOMR2 // 433-482
                            cTxt += cICOMEN // 483-582

                            cTxt += CRLF

                            FWrite(nHandle,  cTxt)

                            (_cAlias)->(DbSkip())
                    ELSE 
                        IF MsgYesNo("Conta não encontrada para o Fornecedor: " + CRLF +;
                                "Código: " + (_cAlias)->E2_FORNECE + " " +CRLF+;
                                "Razão Social: " + Posicione("SA2",1,xFilial("SA2")+(_cAlias)->E2_FORNECE+(_cAlias)->E2_LOJA) + " " + CRLF +;
                                "Cancela BORDERÔ ?",;
                                "Atenção!!" )
                                lCancela := .T.
                            exit
                        ENDIF 
                    ENDIF 
                ENDDO
                if !lCancela
                    SEA->(DbCloseArea())
                    SA2->(DbCloseArea())
                    (_cAlias)->(DbCloseArea())
                    
                    FSEEK(nHandle, 0, FS_END)

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
                        cLinha += "0000000000"//
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
                        cLinha += Space(340) //
                        if nJ < len(aTot)
                            cLinha += CRLF
                        endif 
                        FWrite(nHandle,  cLinha)
                    next nJ 

                    FClose(nHandle)
                ENDIF
            ENDIF
        ENDIF

        If lower(cUserName) $ 'ioliveira,atoshio,admin, administrador'
            Alert('Tempo de processamento: ' + ElapTime( cTimeINI, Time() ) )
        EndIf
        ConOut('Activate: ' + Time())
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

STATIC Function PrintSX1(cPerg)
	Local cPrint := ""
	DbSelectArea('SX1')
	DbSetOrder(1)
	SX1->(DbGoTop())
	If SX1->(DbSeek(cPerg))
		While !SX1->(Eof()) .And. X1_GRUPO = cPerg 
			
			cPrint += IIf(Empty(cPrint),"",CRLF) + ;
					PadR(AllTrim(SX1->X1_PERGUNT), 30, "_") + ;
					": " + ;
					cValToChar(&(SX1->X1_VAR01))
			
			SX1->(DbSkip())
		EndDo
	EndIf
	MemoWrite(StrTran(cArquivo,".xml","")+"_Parametros.txt" , cPrint)
Return nil

Static Function fLoadSql( _cAlias)
    Local _cQry 		:= ""

/*     _cQry := " select E2_NUM" + CRLF
    _cQry += " , E2_NUMBOR" + CRLF
    _cQry += " , E2_FORNECE" + CRLF
    _cQry += " , E2_LOJA" + CRLF
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
    _cQry += " , E2_DEBITO" + CRLF
    _cQry += " , E2_CREDIT" + CRLF
    _cQry += " , E2_DEBITO" + CRLF
    _cQry += " from "+RetSqlName("SE2")+" E2 " + CRLF
    _cQry += " LEFT JOIN "+RetSqlName("SA2")+" A2 ON A2_COD = E2_FORNECE" + CRLF
    _cQry += " AND A2.D_E_L_E_T_ = ''" + CRLF
    _cQry += " WHERE E2_FILIAL = '"+FWxFilial("SE2")+"'" + CRLF
    _cQry += " AND E2_NUMBOR BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'" + CRLF
    _cQry += " AND E2.D_E_L_E_T_ = '' " + CRLF */
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

Static Function CnabTxt()
    Local nRegistros	:= 0
    Local cTxt      := ""

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
