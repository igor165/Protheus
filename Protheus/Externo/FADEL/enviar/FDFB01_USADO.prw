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

#define F_BLOCK  512

/* 
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
 */

User Function FA040ROT()
Local aRotina := {} // ParamIXB	

    SetKey( VK_F10,                       {|| U_fCnabFA() } )
    AAdd(aRotina, { "Gerar CNAB (F10)", "U_fCnabFA", 0 , 4, 0, .f.})

return aRotina

User Function fCnabFA()

    Local aArea         := GetArea()
    Local cTxt          := ""
    Local aItens        := {}
    Local lTemDados		:= .T.
    Local nI, nJ
    Local cCTxt         := ""
    Local cCcAnt        := ""
    Local nTamBuff      := 254//252
    Local cLinha        := Space(nTamBuff)
    Local aTot          := {}
    Local lGrv          := .F. 
    Local cTimeINI      := Time()

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
              //  MsgAlert('Diretorio Criado com Sucesso: ' + cPath, 'Aviso')
            Else	
                ConOut( "Não foi possivel criar o diretório. Erro: " + cValToChar( FError() ) )
          //      MsgAlert( "Não foi possivel criar o diretório. Erro: " + cValToChar( FError() ), 'Aviso' )
            EndIf
        EndIf

        nHandle := FCreate(cArquivo)
	    if nHandle = -1
		    conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
	    else
            FWMsgRun(, {|| lTemDados := fLoadSql( @_cAlias ) },'Por Favor Aguarde...' , 'Processando Banco de Dados')

            If lTemDados

              /*   (_cAlias)->(DbEval({|| nRegistros++ })) */

                (_cAlias)->(DbGoTop())

                while !(_cAlias) -> (EOF())
                    cTxt := "D"                                                 //ITIREG
                    cTxt += "02"                                                //ITITRA
                    cTxt += RIGHT("000"+AllTrim((_cAlias)->E1_AGEDEP),3)        //ICDSRV
                    cTxt += RIGHT("0000000000"+AllTrim((_cAlias)->E1_CONTA),10) //ICTDEB
                    cTxt += "000"//AllTrim((_cAlias)->E1_PORTADO)               //IBCOCR

                    IF AllTrim((_cAlias)->E1_BCOCHQ) == ''
                        cTxt += RIGHT("0000000000"+"0",10)                              // ICTCRE
                        cTxt += "C"                                                     // ITCRDB
                    ELSE 
                        cTxt += RIGHT("0000000000"+AllTrim((_cAlias)->E1_CTACHQ),10)    // ICTCRE
                        cTxt += "H"                                                     // ITCRDB
                    ENDIF
                    
                    cTxt += Space(50)                           // IORDEN
                    cTxt += AllTrim(Str((_cAlias)->E1_MOEDA))   // IMONED
                    cTxt += Right("000000000000000"+StrTran( Subs( AllTrim(str((_cAlias)->E1_VALOR)),1,;
                                                                   len(AllTrim(Str((_cAlias)->E1_VALOR)))),".",""),15) //IMTOTR
                    cTxt += Right("000000000000000"+"0", 15)    // IMTOT2 (SOMENTE PARA COBRANÇA DE FATURAS, RESTO 0)

                    if SubStr(cTxt,2,2) == '03' 
                        cTxt += StrZero(Val(AllTrim((_cAlias)->A1_CGC)),12,0) // INRODO ((SOMENTE PARA COBRANÇA DE FATURAS, RESTO BRANCO))
                    else 
                        cTxt += Space(12) // INRODO
                    endif

                    if SubStr(cTxt,2,2) == '02'
                        cTxt += "0"      //AllTrim((_cAlias)->E1_TIPOFAT)       // ITIFAC   (SOMENTE PARA PAGAMENTOS DE FONECEDORES, RESTO 0)
                        cTxt += Space(20)//PadL((_cAlias)->E1_FATURA , 20, " ") // INRFAC   (SOMENTE PARA PAGAMENTOS DE FONECEDORES, RESTO 0)
                    else 
                        cTxt += "0"                                             // ITIFAC   (SOMENTE PARA PAGAMENTOS DE FONECEDORES, RESTO 0)
                        cTxt += Space(20) // nuMERO DA FATURA                   // INRFAC   (SOMENTE PARA PAGAMENTOS DE FONECEDORES, RESTO 0)
                    endif

                    if SubStr(cTxt,30,1) != 'F'
                        cTxt += "000"                           //INRCUO
                        cTxt += AllTrim((_cAlias)->E1_VENCTO)   //IFCHCR
                        cTxt += "00000000"                      // data de vencimento da Fatura Alterar //IFCHC2
                    else
                        cTxt += "000"                           //INRCUO
                        cTxt += AllTrim((_cAlias)->E1_VENCTO)   //IFCHCR
                        cTxt += "00000000"                      //IFCHC2
                    ENDIF
                    
                    cTxt += Space(50) //ICEPTO
                    cTxt += Space(15) //INRREF
                    cTxt += dToS(dDataBase) // IFECCA
                    cTxt += StrTran(SubS(Time(),1,8),":","") //IHORCA
                    cTxt += PadL(lower(cUserName),10," ") // IUSUCA
                    cTxt += CRLF
                  /*   FSEEK(nHandle, 0, FS_END) */
                    FWrite(nHandle,  cTxt)

            /*         nTot   += (_cAlias)->E1_VALOR

                        if cAntCC == (_cAlias)->E1_CONTA .and. lInicio
                            for nI := 1 to len(aTot)
                            aAdd()
                        else 
                        endif  */
                    
            /*         cAntCC := (_cAlias)->E1_CONTA
                    */
                /*     lInicio := .T.  */
                    (_cAlias)->(DbSkip())
                ENDDO

                /* cTxt := CnabTxt() */

/*                 If !Empty(cTxt)
				    FWrite(nHandle,  cTxt  )
				    cTxt := ""
			    EndIf
 */
                nLength := FSEEK(nHandle, 0, FS_END)
                /* FSEEK(nHandle, 0) */
               /*  fClose(nHandle) */

                /* nHandle := FT_FUse(cArquivo) */
    /*             
                if nHandle = -1
                    return
                endif */

                /* FSeek(nHandle, 0, FS_SET)  */

               /*  nLength := FT_FLastRec() */
                            
                fSeek( nHandle, 0, FS_SET)
                fRead( nHandle, @cCTxt, nTamBuff)

                While !Empty(cCTxt)
                  /*   if !FT_FEOF() */
                        //if nCcAnt != SubStr(cCTxt,7,10)
                            if Len(aTot) == 0
                                    aADD(aTot,{SubStr(cCTxt,7,10) ,;
                                               Val(SubStr(cCTxt,82,15)) }) // nICtDeb
                                    /* aAdd(aTot,{SubStr(cCTxt,82,15)}) */
                            else 
                                for nJ := 1 to len(aTot)
                                    if aTot[nJ][1] == cCcAnt
                                        aTot[nJ][2] += Val(SubStr(cCTxt,82,15))

                                        lGrv := .T.
                                    ENDIF
                                next nJ 
                                if !lGrv
                                    aADD(aTot,{SubStr(cCTxt,7,10)  ,;
                                               Val(SubStr(cCTxt,82,15))})  // nICtDeb
                                    /* aAdd(aTot,{SubStr(cCTxt,82,15)}) */
                                ENDIF
                            ENDIF
                        cCcAnt := SubStr(cCTxt,7,10)
                        //ENDIF
                            /* nTot  += (_cAlias)->E1_CONTA */
                        FRead( nHandle, @cCTxt, nTamBuff )
                        lGrv := .F.
                  /*   endif  */
                EndDo
                   /*  FSEEK(nHandle, 0, FS_END) */

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
                        //cLinha += CRLF  //
                    next nJ 
                
               /*  FT_FGoto( nLength + 1 ) */

                

                /* FT_FUSE() */
                FClose(nHandle)
            ENDIF
            (_cAlias)->(DbCloseArea())

            If lower(cUserName) $ 'ioliveira,atoshio,admin, administrador'
			    Alert('Tempo de processamento: ' + ElapTime( cTimeINI, Time() ) )
		    EndIf
		
		    ConOut('Activate: ' + Time())
        ENDIF
    ENDIF



/*     aItens := {{ xFilial("SA6"),;   // 01 // SA6->A6_FILIAL,;
                (_cAlias)->E1_PORTADO,; // 02 // SA6->A6_COD,;
                (_cAlias)->E1_AGEDEP ,; // 03 // SA6->A6_AGENCIA,;
                (_cAlias)->E1_CONTA  ,; // 04 // SA6->A6_NUMCON,;
                (_cAlias)->E1_FILIAL ,; // 05
                (_cAlias)->E1_PREFIXO,; // 06
                (_cAlias)->E1_NUM    ,; // 07
                (_cAlias)->E1_PARCELA,; // 08
                (_cAlias)->E1_TIPO   ,; // 09
                xFilial("SA1") }} // 11
 */
/*     Begin Transaction
        U_FDFB01(aItens, {}, 0)
    End Transaction */
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

aAdd(aRegs,{cPerg, "01", "Bordero de  ?", "", "", "MV_CH1", "C", 6, 0, 0, "G", "", "MV_PAR01", "", "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})
aAdd(aRegs,{cPerg, "02", "Bordero ate ?", "", "", "MV_CH2", "C", 6, 0, 0, "G", "", "MV_PAR02", "", "","",""      ,"",""   ,"","","","","","","","","","","","","","","","","","","   ","","","","",""})

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

    _cQry := " select E1_PORTADO" + CRLF
    _cQry += "	, E1_AGEDEP" + CRLF
    _cQry += "	, E1_CONTA  " + CRLF
    _cQry += "	, E1_FILIAL " + CRLF
    _cQry += "	, E1_PREFIXO" + CRLF
    _cQry += "	, E1_NUM    " + CRLF
    _cQry += "	, E1_PARCELA" + CRLF
    _cQry += "	, E1_TIPO   " + CRLF
    _cQry += "	, E1_FATURA    " + CRLF
    _cQry += "	, E1_TIPOFAT   " + CRLF
    _cQry += "	, E1_VALOR" + CRLF
    _cQry += "	, E1_CLIENTE" + CRLF
    _cQry += "	, E1_LOJA" + CRLF
    _cQry += "	, E1_NOMCLI" + CRLF
    _cQry += "	, E1_EMISSAO" + CRLF
    _cQry += "	, E1_VENCTO" + CRLF
    _cQry += "	, E1_VENCREA" + CRLF
    _cQry += "	, E1_VALOR" + CRLF
    _cQry += "	, E1_NUMBOR" + CRLF
    _cQry += "	, E1_DATABOR" + CRLF
    _cQry += "	, E1_NUMBCO" + CRLF
    _cQry += "	, E1_DVNSNUM" + CRLF
    _cQry += "	, E1_MOEDA" + CRLF
    _cQry += "	, E1_BCOCHQ" + CRLF
    _cQry += "	, E1_CTACHQ" + CRLF
    _cQry += "	, A1_CGC" + CRLF
    _cQry += "	from "+RetSqlName("SE1")+" E1 " + CRLF
    _cQry += "	left join "+RetSqlName("SA1")+" A1 ON E1_CLIENTE = A1_COD" + CRLF
	_cQry += "    AND E1_LOJA = A1_LOJA " + CRLF
	_cQry += "    AND A1.D_E_L_E_T_ = '' " + CRLF
    _cQry += "	WHERE E1_FILIAL = '"+FWxFilial("SE1")+"'" + CRLF
    _cQry += "	AND E1_NUMBOR BETWEEN '000043' AND '000043'" + CRLF
    _cQry += "	AND E1.D_E_L_E_T_ = ''" + CRLF
    If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
        MemoWrite(StrTran(cArquivo,".xml","")+"_Quadro_" + cTipo + ".sql" , _cQry)
    EndIf

    dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.) 

Return !(_cAlias)->(Eof())

/*/{Protheus.doc} FADELFB01()
    
    (long_description
    @type  Function
    @author Miguel Martins Bernardo Junior
    @since date
    @version 1.0
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function FDFB01(aItens, aLog, nTipoCart)
    Local cBuffer       := SPACE(F_BLOCK)
    Local nOutfile      := FCREATE("Newfile.txt", FC_NORMAL)
    Local lDone         := .F.
    Local nBytesR       := 0
    Local aArea         := GetArea()
    Local cFileTxt      := NIL
    Local aDados        := {}
    Local nI 
    Local nHandle       := 0
     
    If aItens[1][5] + aItens[1][6] + aItens[1][7] + aItens[1][8] + aItens[1][9] <> ;
    (_cAlias)->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
		// Carregando dados do Documento
		DbSelectArea("SE1")
		DbSetOrder(1) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		If !DbSeek( aItens[1][5] + aItens[1][6] + aItens[1][7] + aItens[1][8] + aItens[1][9] )
			AAdd( aLog, "Erro Título " + aItens[1][6] + "-" + aItens[1][7] + ". Título não encontrado. Filial: " + aItens[1][5] + ", Prefíxo: " + aItens[1][6] + ", Numero: " + aItens[1][7] + ", Parcela: " + aItens[1][8] )
			Return .F.
		EndIf
	EndIf

	// Carregando dados do banco
	DbSelectArea("SA6")
	DbSetOrder(1) // A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
	If !DbSeek( aItens[1][1]+aItens[1][2]+aItens[1][3]+aItens[1][4] )
		AAdd( aLog, "Erro Título " + aItens[1][6] + "-" + aItens[1][7] + ". Banco não encontrado. Filial: " + aItens[1][1] + ", Banco: " + aItens[1][2] + ", Agencia: " + aItens[1][3] + ", Conta: " + aItens[1][4] )
		Return .F.
	EndIf

	// Carregando dados do Sacado
	DbSelectArea("SA1")
	DbSetOrder(1)
	If !DbSeek(aItens[1][10]+(_cAlias)->E1_CLIENTE+(_cAlias)->E1_LOJA)
		AAdd( aLog, "Erro Título " + aItens[1][6] + "-" + aItens[1][7] + ". Cliente não cadastrado. Filial: " + aItens[1][5] + ", Prefíxo: " + aItens[1][6] + ", Numero: " + aItens[1][7] + ", Parcela: " + aItens[1][8] )
		Return .F.
	EndIf
        
        aDados := GetLin(aItens, @aLog)
	
    /* If ( aDados > 0 ) */
        nHandle := fCreate(cArquivo) 
        if fError() != 0 
             UserException("Não foi possivel criar o arquivo " + cArquivo + ". Erro retornado: " + Str(fError(), 4) + ".")
        endif 
        fClose(nHandle)

        nHandle := FOpen(cArquivo, FO_WRITE)
        
        if FError() != 0 .and. nHandle == -1
            UserException("Não foi possivel abrir o arquivo " + cArquivo + ". Erro retornado: " + Str(fError(), 4) + ".")
        endif
/*         
        FT_FUse(cArquivo)   //abre o arquivo 
        FT_FGOTOP()  */        //posiciona na primeira linha do arquivo      
        /* nTamLinha := Len(FT_FREADLN()) //Ve o tamanho da linha */


        for nI := 1 to len(aDados)
            cLin := aDadoS[nI][1]
            IF FWrite(nHandle, cLin,nTamBuff) < nTamBuff
                MsgAlert("Erro de gravação: " + STR(FERROR()))
                EXIT
            ENDIF
        next nI

        fClose(nHandle)
	If !Empty( aArea )
		RestArea( aArea )
	EndIf
Return .T.

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
        cTxt += RIGHT("000"+AllTrim((_cAlias)->E1_AGEDEP),3)
        cTxt += RIGHT("0000000000"+AllTrim((_cAlias)->E1_CONTA),10)
        cTxt += "017"
        IF (_cAlias)->E1_BCOCHQ != ''
            cTxt += RIGHT("0000000000"+"0",10)
            cTxt += "H"
        ELSE 
            cTxt += RIGHT("0000000000"+AllTrim((_cAlias)->E1_CONTA),10)
            cTxt += "C"
        ENDIF
        cTxt += Space(50)
        cTxt += AllTrim(Str((_cAlias)->E1_MOEDA))
        cTxt += Right("000000000000000"+StrTran( Subs( AllTrim(str((_cAlias)->E1_VALOR)),1, len(AllTrim(Str((_cAlias)->E1_VALOR)))),".",""),15) 
        cTxt += Right("000000000000000"+"0", 15) 
        cTxt += StrZero(Val(AllTrim((_cAlias)->A1_CGC)),12,0) //LEFT("000000000000"+AllTrim((_cAlias)->A1_CGC), 12)
        cTxt += "0"
        cTxt += Space(20) // nuMERO DA FATURA
        cTxt += "000"     // sOMENTE PARA cItCrDb = 'F'
        cTxt += AllTrim((_cAlias)->E1_VENCTO)
        cTxt += "00000000" // // sOMENTE PARA cItCrDb = 'F'
        cTxt += Space(50)
        cTxt += Space(15) 
        cTxt += dToS(dDataBase)
        cTxt += StrTran(SubS(Time(),1,8),":","")
        cTxt += Space(10)//AllTrim(SubStr(cUsuario,7,15))
        cTxt += CRLF

/*         nTot   += (_cAlias)->E1_VALOR

            if cAntCC == (_cAlias)->E1_CONTA .and. lInicio
                for nI := 1 to len(aTot)
                aAdd()
            else 
            endif  */
        
/*         cAntCC := (_cAlias)->E1_CONTA
         */
    /*     lInicio := .T.  */
        (_cAlias)->(DbSkip())
    ENDDO

RETURN cTxt
/* Static FUnction GetLin(aItens, aLog)
    Local aRet := {}
    Local nI
    Local cLinha 

    for nI := 1 to len(aItens)

        fGetDados(/* aItens[nI][1] )

        cLinha := AllTrim(cITiReg)
        cLinha += AllTrim(cITiTra)//(_cAlias)->E1_OCORREN 
        cLinha += AllTrim(str(nICdSrv))
        cLinha += AllTrim(str(nICtDeb))
        cLinha += AllTrim(str(nIBcoCr))
        cLinha += AllTrim(str(nICtCre))
        cLinha += AllTrim(cItCrDb)   
        cLinha += cIOrdem   
        cLinha += Alltrim(str(nIMoned))
        cLinha += Alltrim(nImTotr)  
        cLinha += Alltrim(nImTot2)
        cLinha += Alltrim(nInRodo)
        cLinha += str(nItiFac)
        cLinha += AllTrim(cInrFaFSEEK(nHandle, 0)c)
        cLinha += AllTrim(str(nInrCuo))
        cLinha += AllTrim(str(nIfChCr))
        cLinha += AllTrim(str(nIfChC2))
        cLinha += cIcePto
        cLinha += cInrRef
        cLinha += AllTrim(str(nIFecCa))
        cLinha += AllTrim(str(nIHorCa))
        cLinha += cIuSuCa

        aAdd(aRet,{cLinha})
    next nI
RETURN aRet */
/* 
Static Function fGetDados()
    cITiReg := "D"
    cITiTra := "02"
    nICdSrv := RIGHT("000"+(_cAlias)->E1_AGEDEP,3)
    nICtDeb := RIGHT("0000000000"+(_cAlias)->E1_CONTA,10)
    nIBcoCr := 017
    nICtCre := RIGHT("0000000000"+(_cAlias)->E1_CONTA,10)
    cItCrDb := "D"
    cIOrdem := Space(50)
    nIMoned := (_cAlias)->E1_MOEDA
    nImTotr := Right("000000000000000"+(_cAlias)->E1_VALOR, 15)
    nImTot2 := Right("000000000000000"+"0", 15)
    nInRodo := LEFT("000000000000"+SA1->A1_CGC, 12)
    nItiFac := 0
    cInrFac := Space(20) // nuMERO DA FATURA
    nInrCuo := 000     // sOMENTE PARA cItCrDb = 'F'
    nIfChCr := (_cAlias)->E1_VENCTO
    nIfChC2 := 00000000 // // sOMENTE PARA cItCrDb = 'F'
    cIcePto := Space(50)
    cInrRef := Space(15)
    nIFecCa := dToS(dDataBase)
    nIHorCa := Time()
    cIuSuCa := UPPER(cUsuario)
RETURN .T. 
 */
