#Include "TOTVS.ch"
#Include "TopConn.ch"
#INCLUDE 'FWMVCDEF.CH'
  
User Function TImpCSV()
    Local aArea     := GetArea()
    Local lRet      := .T.
    Private cArqOri := ""
    Private aDados  := {}

    Private nInteressado    := 1 // Interessaddo
    Private nPropriedade    := 2// Propriedade
    Private nMunicipio      := 3// Municipio
    Private nLocalidade     := 4// Localidade
    Private nMaterial       := 5// Material
    Private nSolicit        := 6// Solicitante
    Private nDtEntrada      := 7// Data Entrada 
    Private nDtSaida        := 8// Data Saida
    Private nProtocolo      := 9// Protocolo
    Private nLaudo          := 10// Laudo
    Private nPedido         := 11// Pedido
    Private nAmostra        := 12// Amostra
    Private nProfundidade   := 13// Profundidade
    Private nPhH2o          := 14// PH H2O
    Private nPhCaCl2        := 15// PH CaCl2
    Private nPmgDm3         := 16// P mg/dm3
    Private nKmgDm3         := 17// K mg/dm3
    Private nKcDm3          := 18// K cmolc/dm3
    Private nCaMg           := 19// Ca+Mg cmolc/dm3
    Private nCacDm3         := 20// Ca cmolc/dm3
    Private nMgcDm3         := 21// Mg cmolc/dm3
    Private nAlcDm3         := 22// Al cmolc/dm3
    Private nHcDm3          := 23// H cmolc/dm3
    Private nHAlcDm3        := 24// H+Al cmolc/dm3
    Private nMOgDm3         := 25// M.O g/dm3
    Private nAreia          := 26// Areia
    Private nSilte          := 27// Silte
    Private nArgila         := 28// Argila 
    Private nSB             := 29// SB cmolc/dm3
    Private nTcDm3          := 30// T cmolc/dm3
    Private nVPerc          := 31// V %
    Private nKPerc          := 32// K %
    Private nCaPerc         := 33// Ca %
    Private nMgPerc         := 34// Mg %
    Private nHPerc          := 35// H %
    Private nAlPerc         := 36// Al %
    Private nMPerc          := 37// M % 
    Private nCaMgRel        := 38// Ca/Mg RelaÁ„o 
    Private nCaKRel         := 39// Ca/K RelaÁ„o
    Private nMgKRel         := 40// Mg/K RelaÁ„o
    Private nCaMgK          := 41// Ca/Mg RelaÁ„o
    Private nZn             := 42// ZN mg/dm3
    Private nCu             := 43// Cu mg/dm3
    Private nFe             := 44// Fe mg/dm3
    Private nMn             := 45// Mn mg/dm3
    Private nB              := 46// B mg/dm3
    Private nS              := 47// S mg/dm3
    Private cLineMemo       := ''
    //Mostra o Prompt para selecionar arquivos
    
    cArqOri := tFileDialog( "CSV files (*.csv) ", 'SeleÁ„o de Arquivos', , , .F., )
      
    //Se tiver o arquivo de origem
    If ! Empty(cArqOri)
        //Somente se existir o arquivo e for com a extens„o CSV
        If File(cArqOri) .And. Upper(SubStr(cArqOri, RAt('.', cArqOri) + 1, 3)) == 'CSV'
            Processa({|| lRet := fImporta() }, "Lendo Arquivo...")

            if lRet 
                Processa({|| GravArq()}, "Gravando Tabela...")		
            else 
                MsgStop("N„o foi possÌvel ler o arquivo", "AtenÁ„o")
            endif 
        Else
            MsgStop("Arquivo e/ou extens„o inv·lida!", "AtenÁ„o")
        EndIf
    EndIf
    RestArea(aArea)
Return
  
/*-------------------------------------------------------------------------------*
 | Func:  fImporta                                                               |
 | Desc:  FunÁ„o que importa os dados                                            |
 *-------------------------------------------------------------------------------*/
  
Static Function fImporta()
    Local nTotLinhas := 0
    Local cLinAtu    := ""
    Local nLinhaAtu  := 0
    Local aLinha     := {}
    Local aFiliais     := {}
    Local lRet       := .F.

    Private oArquivo
    Private cDirLog    := GetTempPath() + "x_importacao\"
    Private cLog       := ""

    //Se a pasta de log n„o existir, cria ela
    If ! ExistDir(cDirLog)
        MakeDir(cDirLog)
    EndIf
  
    //Definindo o arquivo a ser lido
    oArquivo := FWFileReader():New(cArqOri)
      
    //Se o arquivo pode ser aberto
    If (oArquivo:Open())
  
        //Se n„o for fim do arquivo
        If ! (oArquivo:EoF())

            //Definindo o tamanho da rÈgua
            aLinhas := oArquivo:GetAllLines()
            nTotLinhas := Len(aLinhas)
            ProcRegua(nTotLinhas)
              
            //MÈtodo GoTop n„o funciona (dependendo da vers„o da LIB), deve fechar e abrir novamente o arquivo
            oArquivo:Close()
            oArquivo := FWFileReader():New(cArqOri)
            oArquivo:Open()
  
            _cQry := "select * from SYS_COMPANY"

            MpSysOpenQry(_cQry,"TMP")
                WHILE !TMP->(EOF())
                    aAdd(aFiliais,{TMP->M0_CODFIL,TMP->M0_FILIAL})
                    TMP->(DBSkip())
                ENDDO

            TMP->(DBCLOSEAREA(  ))
            //Enquanto tiver linhas
            While (oArquivo:HasLine())
  
                //Incrementa na tela a mensagem
                nLinhaAtu++
                IncProc("Analisando linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")
                  
                //Pegando a linha atual e transformando em array
                cLinAtu := oArquivo:GetLine()
                aLinha  := Separa(cLinAtu,';',.t.) //StrTokArr(cLinAtu, ";")

                cLineMemo += cLinAtu + CHR(13) + CHR(10)
                
                //Se n„o for o cabeÁalho (encontrar o texto "CÛdigo" na linha atual)
                If !("interessado" $ Lower(cLinAtu))

                    RemoveAcento(@aLinha[nInteressado])
                    RemoveAcento(@aLinha[nPropriedade])
                    RemoveAcento(@aLinha[nMunicipio])
                    RemoveAcento(@aLinha[nLocalidade])
                    RemoveAcento(@aLinha[nMaterial])
                    RemoveAcento(@aLinha[nSolicit])
                    RemoveAcento(@aLinha[nProtocolo])
                    RemoveAcento(@aLinha[nAmostra])
                    TrocaData(@aLinha[nDtEntrada])
                    TrocaData(@aLinha[nDtSaida])
                    TrocaVirgula(@aLinha[nProfundidade])
                    TrocaVirgula(@aLinha[nPhH2o])
                    TrocaVirgula(@aLinha[nPhCaCl2])
                    TrocaVirgula(@aLinha[nPmgDm3])
                    TrocaVirgula(@aLinha[nKmgDm3])
                    TrocaVirgula(@aLinha[nKcDm3])
                    TrocaVirgula(@aLinha[nCaMg])
                    TrocaVirgula(@aLinha[nCacDm3])
                    TrocaVirgula(@aLinha[nMgcDm3])
                    TrocaVirgula(@aLinha[nAlcDm3])
                    TrocaVirgula(@aLinha[nHcDm3])
                    TrocaVirgula(@aLinha[nHAlcDm3])
                    TrocaVirgula(@aLinha[nMOgDm3])
                    TrocaVirgula(@aLinha[nAreia])
                    TrocaVirgula(@aLinha[nSilte])
                    TrocaVirgula(@aLinha[nArgila])
                    TrocaVirgula(@aLinha[nSB])
                    TrocaVirgula(@aLinha[nTcDm3])
                    TrocaVirgula(@aLinha[nVPerc])
                    TrocaVirgula(@aLinha[nKPerc])
                    TrocaVirgula(@aLinha[nCaPerc])
                    TrocaVirgula(@aLinha[nMgPerc])
                    TrocaVirgula(@aLinha[nHPerc])
                    TrocaVirgula(@aLinha[nAlPerc])
                    TrocaVirgula(@aLinha[nMPerc])
                    TrocaVirgula(@aLinha[nCaMgRel])
                    TrocaVirgula(@aLinha[nCaKRel])
                    TrocaVirgula(@aLinha[nMgKRel])
                    TrocaVirgula(@aLinha[nCaMgK])
                    TrocaVirgula(@aLinha[nZn])
                    TrocaVirgula(@aLinha[nCu])
                    TrocaVirgula(@aLinha[nFe])
                    TrocaVirgula(@aLinha[nMn])
                    TrocaVirgula(@aLinha[nB])
                    TrocaVirgula(@aLinha[nS])

                    aAdd(aDados,aLinha)
                EndIf
            EndDo
        Else
            MsgStop("Arquivo n„o tem conte˙do!", "AtenÁ„o")
        EndIf
  
        //Fecha o arquivo
        oArquivo:Close()
    Else
        MsgStop("Arquivo n„o pode ser aberto!", "AtenÁ„o")
    EndIf

    if !Empty(aDados)
        lRet := .T. 
    else 
        MsgStop("Arquivo Vazio", "AtenÁ„o")
    endif
    
Return lRet

Static Function GravArq()
    Local cCodigo   := ''
    Local nI 
    Local cBakLocal :=''
    Local cBakFil := ''
    
    Begin Transaction
    
        DBSelectArea("ZAL")
        ZAL->(DBSetOrder(1))
    
        DBSelectArea("ZAG")
        ZAG->(DBSetOrder(1))
        
            cQry := "SELECT MAX(ZAG_CODIGO) as COD FROM "+RetSqlName("ZAG")+" WHERE D_E_L_E_T_ = ''"
            
            MpSysOpenQry(cQry, "TMP")

            if !TMP->(EOF())
                cCodigo := StrZero((Val(TMP->COD) + 1),TamSX3("ZAG_CODIGO")[1])
            else
                cCodigo := "000001"
            endif
            TMP->(DBCloseArea())
            
            cQry := ""
            RecLock("ZAG", .T.)
                ZAG->ZAG_FILIAL := FwxFilial("ZAG")
                ZAG->ZAG_USER   := cUserName
                ZAG->ZAG_DATA   := Date()
                ZAG->ZAG_CODIGO := cCodigo
            ZAG->(MSUNLOCK())

            cQry := " update "+RetSqlName("ZAG")+""
            cQry += " SET	ZAG_DADOS  = CONVERT(VARBINARY(MAX), '"+cLineMemo+"') "
            cQry += " where ZAG_CODIGO = '"+cCodigo+"' "
            
            If (TCSqlExec(cQry) < 0)
                lErro := .T.
                MsgInfo(TCSqlError())
                DisarmTransaction()
                Break
            EndIf

            For nI := 1 to Len(aDados)
                if cBakLocal != aDados[nI][nPropriedade]
                    cQry := "SELECT * FROM SYS_COMPANY WHERE UPPER(M0_FILIAL) LIKE ('%"+UPPER(AllTrim(aDados[nI][nPropriedade]))+"%')"

                    MpSysOpenQry(cQry,"TMP")
                    if !TMP->(EOF())
                        cBakLocal := aDados[nI][nPropriedade]
                        cBakFil   := TMP->M0_CODFIL
                    endif
                    
                    TMP->(DBCloseArea())
                endif
            
                RecLock("ZAL", .T.)
                    
                    ZAL->ZAL_FILIAL := FwxFilial("ZAL")
                    ZAL->ZAL_FILDES := cBakLocal
                    ZAL->ZAL_MUN    := aDados[nI][nMunicipio]
                    ZAL->ZAL_LOCAL  := aDados[nI][nLocalidade]
                    ZAL->ZAL_MATERI := aDados[nI][nMaterial]
                    ZAL->ZAL_SOLICT := aDados[nI][nSolicit]
                    ZAL->ZAL_DTENT  := cToD(aDados[nI][nDtEntrada])
                    ZAL->ZAL_DTSAID := cToD(aDados[nI][nDtSaida])
                    ZAL->ZAL_PROTOC := aDados[nI][nProtocolo]
                    ZAL->ZAL_LAUDO  := aDados[nI][nLaudo]
                    ZAL->ZAL_PEDIDO := aDados[nI][nPedido]
                    ZAL->ZAL_AMOSTR := aDados[nI][nAmostra]
                    ZAL->ZAL_PROFUN := aDados[nI][nProfundidade]
                    ZAL->ZAL_PHH20  := aDados[nI][nPhH2o]
                    ZAL->ZAL_PHCL2  := aDados[nI][nPhCaCl2]
                    ZAL->ZAL_PMGDM3 := aDados[nI][nPmgDm3]
                    ZAL->ZAL_KMGDM3 := aDados[nI][nKmgDm3]
                    ZAL->ZAL_KCMOLC := aDados[nI][nKcDm3]
                    ZAL->ZAL_CAMGCM := aDados[nI][nCaMg]
                    ZAL->ZAL_CACMOL := aDados[nI][nCacDm3]
                    ZAL->ZAL_MGCMOL := aDados[nI][nMgcDm3]
                    ZAL->ZAL_ALCMOL := aDados[nI][nAlcDm3]
                    ZAL->ZAL_HCMOLC := aDados[nI][nHcDm3]
                    ZAL->ZAL_HALCMO := aDados[nI][nHAlcDm3]
                    ZAL->ZAL_MOGDM3 := aDados[nI][nMOgDm3]
                    ZAL->ZAL_AREIA  := aDados[nI][nAreia]
                    ZAL->ZAL_SILTE  := aDados[nI][nSilte]
                    ZAL->ZAL_ARGILA := aDados[nI][nArgila]
                    ZAL->ZAL_SBCMOL := aDados[nI][nSB]
                    ZAL->ZAL_TDM3   := aDados[nI][nTcDm3]
                    ZAL->ZAL_V      := aDados[nI][nVPerc]
                    ZAL->ZAL_K      := aDados[nI][nKPerc]
                    ZAL->ZAL_CA     := aDados[nI][nCaPerc]
                    ZAL->ZAL_MG     := aDados[nI][nMgPerc]
                    ZAL->ZAL_H      := aDados[nI][nHPerc]
                    ZAL->ZAL_AL     := aDados[nI][nAlPerc]
                    ZAL->ZAL_M      := aDados[nI][nMPerc]
                    ZAL->ZAL_CAMG   := aDados[nI][nCaMgRel]
                    ZAL->ZAL_CAK    := aDados[nI][nCaKRel]
                    ZAL->ZAL_MGK    := aDados[nI][nMgKRel]
                    ZAL->ZAL_CAMGK  := aDados[nI][nCaMgK]
                    ZAL->ZAL_ZN     := aDados[nI][nZn]
                    ZAL->ZAL_CU     := aDados[nI][nCu]
                    ZAL->ZAL_FE     := aDados[nI][nFe]
                    ZAL->ZAL_MN     := aDados[nI][nMn]
                    ZAL->ZAL_B      := aDados[nI][nB]
                    ZAL->ZAL_S      := IIF(ValType(aDados[nI][nS]) != "C","",aDados[nI][nS])
                    ZAL->ZAL_COD    := cCodigo
                ZAL->(MSUnlock())
            Next nI

        ZAG->(dbCloseArea())
        ZAL->(dbCloseArea())
    End Transaction
Return 

Static Function fTratStr( cTexto )
    cRetorno := EncodeUTF8( cTexto )
    cRetorno := Encode64( cTexto )
    cRetorno := Replace( cTexto, " ", "" )
    cRetorno := Replace( cTexto, "\", "-" )
    cRetorno := Replace( cTexto, "/", "-" )
    cRetorno := Replace( cTexto, "=", "" )
Return cRetorno

Static Function RemoveAcento(cString)
    cString := StrTran( cString, "√ù", "A")
    cString := StrTran( cString, "√°", "a")
    cString := StrTran( cString, "√Ä", "A")
    cString := StrTran( cString, "√†", "a")
    cString := StrTran( cString, chr(195)+chr(131), "A")
    cString := StrTran( cString, "√£", "a")
    cString := StrTran( cString, "√¢", "a")
    cString := StrTran( cString, "√â", "E")
    cString := StrTran( cString, "√©", "e")
    cString := StrTran( cString, "√à", "E")
    cString := StrTran( cString, "√®", "e")
    cString := StrTran( cString, "√å", "I")
    cString := StrTran( cString, "√¨", "i")
    cString := StrTran( cString, "√ù", "I")
    cString := StrTran( cString, chr(195)+chr(141), "I")
    cString := StrTran( cString, "√≠", "i")
    cString := StrTran( cString, "√ï", "O")
    cString := StrTran( cString, "√µ", "o")
    cString := StrTran( cString, "√ú", "U")
    cString := StrTran( cString, "√º", "u")
    cString := StrTran( cString, "Ô", "")
    cString := StrTran( cString, "ª", "")
    cString := StrTran( cString, "ø", "")
Return cString

Static Function TrocaData(cString)
    cString := Replace( cString, "jan", "01" )
    cString := Replace( cString, "fev", "02" )
    cString := Replace( cString, "mar", "03" )
    cString := Replace( cString, "abr", "04" )
    cString := Replace( cString, "mai", "05" )
    cString := Replace( cString, "jun", "06" )
    cString := Replace( cString, "jul", "07" )
    cString := Replace( cString, "ago", "08" )
    cString := Replace( cString, "set", "09" )
    cString := Replace( cString, "out", "10" )
    cString := Replace( cString, "nov", "11" )
    cString := Replace( cString, "dez", "12" )
Return cString

Static Function TrocaVirgula(cString)
    cString := Replace( cString, ",", "." )
Return cString
