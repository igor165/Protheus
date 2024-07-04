ZAL->ZAL_FILIAL
ZAL->ZAL_FILDES
ZAL->ZAL_MUN   
ZAL->ZAL_LOCAL 
ZAL->ZAL_MATERI
ZAL->ZAL_SOLICT
ZAL->ZAL_DTENT 
ZAL->ZAL_DTSAID
ZAL->ZAL_PROTOC
ZAL->ZAL_LAUDO 
ZAL->ZAL_PEDIDO
ZAL->ZAL_AMOSTR
ZAL->ZAL_PROFUN
ZAL->ZAL_PHH20 
ZAL->ZAL_PHCL2 
ZAL->ZAL_PMGDM3
ZAL->ZAL_KMGDM3
ZAL->ZAL_KCMOLC
ZAL->ZAL_CAMGCM
ZAL->ZAL_CACMOL
ZAL->ZAL_MGCMOL
ZAL->ZAL_ALCMOL
ZAL->ZAL_HCMOLC
ZAL->ZAL_HALCMO
ZAL->ZAL_MOGDM3
ZAL->ZAL_AREIA 
ZAL->ZAL_SILTE 
ZAL->ZAL_ARGILA
ZAL->ZAL_SBCMOL
ZAL->ZAL_V     
ZAL->ZAL_K     
ZAL->ZAL_CA    
ZAL->ZAL_MG    
ZAL->ZAL_H     
ZAL->ZAL_AL    
ZAL->ZAL_M     
ZAL->ZAL_CAMG  
ZAL->ZAL_CAK   
ZAL->ZAL_MGK   
ZAL->ZAL_CAMGK 
ZAL->ZAL_ZN    
ZAL->ZAL_CU    
ZAL->ZAL_FE    
ZAL->ZAL_MN    
ZAL->ZAL_B     
ZAL->ZAL_S     
ZAL->ZAL_COD   


//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"
  
//PosiÁıes do Array
Static nPosCodigo := 1 //Coluna A no Excel
Static nPosLojFor := 2 //Coluna B no Excel
Static nPosRazSoc := 3 //Coluna C no Excel
Static nPosObserv := 4 //Coluna D no Excel
  
/*/{Protheus.doc} zImpCSV
FunÁ„o para importar informaÁıes do fornecedor via csv
@author Atilio
@since 07/06/2021
@version 1.0
@type function
/*/
  
User Function zImpCSV()
    Local aArea     := GetArea()
    Local lRet      := .T.
    Private cArqOri := ""
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
    Local lRet       := .F.
    Local nI         := 0

    Private oArquivo
    Private cDirLog    := GetTempPath() + "x_importacao\"
    Private cLog       := ""

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
    Private aDados          := {}

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
  
            //Enquanto tiver linhas
            While (oArquivo:HasLine())
  
                //Incrementa na tela a mensagem
                nLinhaAtu++
                IncProc("Analisando linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")
                  
                //Pegando a linha atual e transformando em array
                cLinAtu := oArquivo:GetLine()
                aLinha  := StrTokArr(cLinAtu, ";")

                //Se n„o for o cabeÁalho (encontrar o texto "CÛdigo" na linha atual)
                If !("interessado" $ Lower(cLinAtu))

                   // For nI := 1 to Len(aLinha)
                   //     RemoveAcento(@aLinha[nI])
                   // Next nI
//
                    //Zera as variaveis                    
                 
/* nInteressado  := aScan(aLinha, { |x| Upper(x) == 'INTERESSADO'})
                    nPropriedade  := aScan(aLinha, { |x| Upper(x) == 'PROPRIEDADE'})
                    nMunicipio    := aScan(aLinha, { |x| Upper(x) == 'MUNICIPIO'})
                    nLocalidade   := aScan(aLinha, { |x| Upper(x) == 'LOCALIDADE'})
                    nMaterial     := aScan(aLinha, { |x| Upper(x) == 'MATERIAL ANALISADO'})
                    nSolicit      := aScan(aLinha, { |x| Upper(x) == 'SOLICITANTE'})
                    nDtEntrada    := aScan(aLinha, { |x| Upper(x) == 'DATA ENTRADA'})
                    nDtSaida      := aScan(aLinha, { |x| Upper(x) == 'DATA SAIDA'})
                    nProtocolo    := aScan(aLinha, { |x| Upper(x) == 'PROTOCOLO'})
                    nLaudo        := aScan(aLinha, { |x| Upper(x) == 'LAUDO'})
                    nPedido       := aScan(aLinha, { |x| Upper(x) == 'PEDIDO'})
                    nAmostra      := aScan(aLinha, { |x| Upper(x) == 'AMOSTRA'})
                    nProfundidade := aScan(aLinha, { |x| Upper(x) == 'PROFUNDIDADE'})
                    nPhH2o        := aScan(aLinha, { |x| Upper(x) == 'PH H2O'})
                    nPhCaCl2      := aScan(aLinha, { |x| Upper(x) == 'PH CACL2'})
                    nPmgDm3       := aScan(aLinha, { |x| Upper(x) == 'P'})
                    nKmgDm3       := aScan(aLinha, { |x| Upper(x) == 'K'})  // NOME IGUAL
                    nKcDm3        := aScan(aLinha, { |x| Upper(x) == 'K'}) // NOME IGUAL
                    nCaMg         := aScan(aLinha, { |x| Upper(x) == 'CA+MG'})
                    nCacDm3       := aScan(aLinha, { |x| Upper(x) == 'CA'}) //CORRIGIR DAQUI PRA BAIXO
                    nMgcDm3       := aScan(aLinha, { |x| Upper(x) == 'MG'})
                    nAlcDm3       := aScan(aLinha, { |x| Upper(x) == 'AL'})
                    nHcDm3        := aScan(aLinha, { |x| Upper(x) == 'H'}) //
                    nHAlcDm3      := aScan(aLinha, { |x| Upper(x) == 'H+AL'})
                    nMOgDm3       := aScan(aLinha, { |x| Upper(x) == 'M.O.'})
                    nAreia        := aScan(aLinha, { |x| Upper(x) == 'AREIA'})
                    nSilte        := aScan(aLinha, { |x| Upper(x) == 'SILTE'})
                    nArgila       := aScan(aLinha, { |x| Upper(x) == 'ARGILA'})
                    nSB           := aScan(aLinha, { |x| Upper(x) == 'S.B.'})
                    nTcDm3        := aScan(aLinha, { |x| Upper(x) == 'T'})
                    nVPerc        := aScan(aLinha, { |x| Upper(x) == 'V'})
                    nKPerc        := aScan(aLinha, { |x| Upper(x) == 'K'}) //
                    nCaPerc       := aScan(aLinha, { |x| Upper(x) == 'CA'})//
                    nMgPerc       := aScan(aLinha, { |x| Upper(x) == 'MG'})//
                    nHPerc        := aScan(aLinha, { |x| Upper(x) == 'H'}) //
                    nAlPerc       := aScan(aLinha, { |x| Upper(x) == 'AL'})
                    nMPerc        := aScan(aLinha, { |x| Upper(x) == 'M%'})
                    nCaMgRel      := aScan(aLinha, { |x| Upper(x) == 'CA/MG'})
                    nCaKRel       := aScan(aLinha, { |x| Upper(x) == 'CA/K'})
                    nMgKRel       := aScan(aLinha, { |x| Upper(x) == 'MG/K'})
                    nCaMgK        := aScan(aLinha, { |x| Upper(x) == 'CA+MG/K'})
                    nZn           := aScan(aLinha, { |x| Upper(x) == 'ZN'})
                    nCu           := aScan(aLinha, { |x| Upper(x) == 'CU'})
                    nFe           := aScan(aLinha, { |x| Upper(x) == 'FE'})
                    nMn           := aScan(aLinha, { |x| Upper(x) == 'MN'})
                    nB            := aScan(aLinha, { |x| Upper(x) == 'B'})
                    nS            := aScan(aLinha, { |x| Upper(x) == 'S'})
*/
                //Else
                    RemoveAcento(@aLinha[nInteressado])
                    RemoveAcento(@aLinha[nPropriedade])
                    RemoveAcento(@aLinha[nMunicipio])
                    RemoveAcento(@aLinha[nLocalidade])
                    RemoveAcento(@aLinha[nMaterial])
                    RemoveAcento(@aLinha[nSolicit])
                    RemoveAcento(@aLinha[nProtocolo])
                    RemoveAcento(@aLinha[nAmostra])

                    TrocaData(Lower(@aLinha[nDtEntrada]))
                    TrocaData(Lower(@aLinha[nDtSaida]))

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
    Local cCodigo := ''
    Local nI 
    
    Begin Transaction
    
        DBSelectArea("ZAL")
        ZAL->(DBSetOrder(1))
    
        DBSelectArea("ZAG")
        ZAL->(DBSetOrder(1))
        
            cQry := "SELECT MAX(ZAL_CODIGO) as COD FROM "+RetSqlName("ZAL")+" WHERE D_E_L_E_T_ = ''"
            
            MpOpenSysQry(cQry, "TMP")

            if !TMP->(EOF())
                cCodigo := StrZero((Val(TMP->COD) + 1),TamSX3("ZAL_CODIGO")[1])
            else
                cCodigo := "000001"
            endif
            TMP->(DBCloseArea())
            
            RecLock("ZAG", .F.)
                ZAG->ZAG_FILIAL := FwxFilial("ZAG")
                ZAG->ZAG_USER   := cUserName
                ZAG->ZAG_DATA   := Date()
                ZAG->ZAG_CODIGO := cCodigo
            ZAG->(MSUNLOCK())

            For nI := 1 to Len(aDados)
                RecLock("ZAL", .F.)
                    ZAL->ZAL_FILIAL := FwxFilial("ZAL")
                    ZAL->ZAL_FILDES := aDados[nI][nPropriedade]
                    ZAL->ZAL_MUN    := aDados[nI][nMunicipio]
                    ZAL->ZAL_LOCAL  := aDados[nI][nLocalidade]
                    ZAL->ZAL_MATERI := aDados[nI][nMaterial]
                    ZAL->ZAL_SOLICT := aDados[nI][nSolicit]
                    ZAL->ZAL_DTENT  := aDados[nI][nDtEntrada]
                    ZAL->ZAL_DTSAID := aDados[nI][nDtSaida]
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
                    //ZAL->ZAL_T      := aDados[nI][nTcDm3] // CRIAR CAMPO ZAL_T
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
                    ZAL->ZAL_S      := aDados[nI][nS]
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
