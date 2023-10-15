%% parte 1: apertura della time series

% uigetfile apre una finestra di dialogo per selezionare un file
% (tiff o multitiff)
% se non è già stata selezionata una cartella, inizializziamo 'cartella'
% con l'attuale directory di matlab
if ~exist('cartella','var')
    cartella=[pwd filesep];
end
[nome,newdir]=uigetfile([cartella '*.tif']);
% se è stato premuto 'cancel', nome e newdir saranno uguali a zero, quindi
% saranno dei double. In tal caso fermiamo l'esecuzione del programma. 
% Altrimenti, salviamo la cartella selezionata 'newdir' come 'cartella'.
% Questa sarà la cartella predefinita in future esecuzioni di questo script
if isa(newdir,'double')
    return
else
    cartella=newdir;
end

% concateniamo 'cartella' e 'nome' per ricreare un array di caratteri col
% percorso completo
completo = [cartella nome];

% otteniamo le info del file
info = imfinfo(completo);
numeroImmagini = length(info);

% capiamo quanti canali ci sono
descriz = info(1).ImageDescription;
% trova il numero di canali nella stringa di descrizione si trova 
trovato = regexp(descriz,'channels=\d*','match');
% separa ciò che sta prima e dopo dall'uguale
splittato=strsplit(trovato{1},'=');
% prendi ciò che sta dopo e trasformalo da stringa a numero
n_canali=str2double(splittato{2});
% controllo di qualità: numeroImmagini deve essere multiplo di n_canali.
% la funzione 'rem' calcola il resto della divisione intera tra due numeri
assert(rem(numeroImmagini,n_canali)==0,'number of images and number of channels not consistent')

% preallocazione. La variabile stack sarà una matrice 4D con dimensioni
% canale*y*x*tempo
ny=info(1).Height;
nx=info(1).Width;
numeroFrames = length(info)/n_canali;
stack=nan(n_canali,ny,nx,numeroFrames);

% in un ciclo for leggiamo i frame. Scorriamo le immagini a passi di
% "n_canali"
for i = 1:n_canali:numeroImmagini
    % siamo posizionati sull'immagine i-esima. Sappiamo che ora troveremo
    % le immagini degli n_canali in fila: leggiamole e salviamole.
    for canale=1:n_canali
        % leggi l'immagine i-esima e collocala in stack
        stack(canale,:,:,ceil(i/n_canali)) = imread(completo, i+canale-1);
    end
end	

%% parte 2: plot
% plottare la proiezione media di tutti i canali usando subplot. 
% 'figure' apre una nuova figura. E' possibile fornire delle specifiche
% (proprietà dell'oggetto figura) come argomenti, sottoforma di coppie
% 'nome_della_proprietà',valore.
figure('name','Before registration','position',[528   291   895   371])
% for loop che scorre i canali
for i=1:n_canali
    subplot(1,n_canali,i)
    % calcola average projection. 'squeeze' rimuove le dimensioni
    % cosiddette singleton, ovvero costituite da un unico elemento
    mp=mean(squeeze(stack(i,:,:,:)),3);
    % la funzione imagesc plotta un'immagine
    imagesc(mp)
    % set(obj,'prop',value) assegna alla proprietà 'prop' dell'oggetto obj
    % il valore value. gca è una funzione che restituisce il 'current axes'
    set(gca,'plotboxaspectratio',[1 1 1])
    % mostra la colorbar
    colorbar
    % imposta la colormap
    colormap(turbo)
    % scrivi il numero del canale nel titolo del subplot
    title(sprintf('ch %i',i))
end

%% parte 3: allineamento su uno dei canali

% seleziona interattivamente il canale su cui allineare
in=inputdlg('Channel for registration','Choose a channel',1,{'1'});
if isempty(in)
    c_allin=1;
else
    c_allin = str2double(in{1}); % converte la stringa in un numero
end
if c_allin<=0 || c_allin>n_canali
    c_allin=1;
end

% la funzione myregistration allinea uno stack 3D (primo input) su un template 2D
% (secondo input). Permette inoltre di disegnare una ROI rettangolare da
% usare per l'allineamento, per velocizzare i calcoli.
% Restituisce in 'deltas' gli offset che verranno usati per la traslazione
% di ogni frame
[~,deltas] = myregistration(squeeze(stack(c_allin,:,:,:)),squeeze(stack(c_allin,:,:,1)));

% prealloca la matrice 3D 'registered'
registered=nan(size(stack));
% per ogni canale effettua l'allineamento traslando ogni frame di 'deltas'
for i=1:n_canali
    registered(i,:,:,:)=imreg_trasl(squeeze(stack(i,:,:,:)),deltas);
end
% portiamo a NaN tutta la sezione interessata dallo slittamento del campo
registered(repmat(any(isnan(registered),4),1,1,1,numeroFrames))=nan;

%% parte 4: plotta di nuovo i canali per verificare l'allineamento
figure('name','After registration','position',[528   291   895   371])

% for loop che scorre i 3 canali
for i=1:n_canali
    subplot(1,n_canali,i)
    % calcola max proj
    mp=mean(squeeze(registered(i,:,:,:)),3);
    % la funzione imagesc plotta un'immagine
    imagesc(mp)
    % set(obj,'prop',value) assegna alla proprietà 'prop' dell'oggetto obj
    % il valore value. gca è una funzione che restituisce il 'current axes'
    set(gca,'plotboxaspectratio',[1 1 1])
    % mostra la colorbar
    colorbar
    % imposta la colormap
    colormap(turbo)
    % scrivi il numero del canale nel titolo del subplot
    title(sprintf('ch %i',i))
end
%% parte 3: salvataggio

% nome file output
newname = insertBefore(nome,'.tif','_reg');

% salva separatamente i canali allineati
for i=1:n_canali
    newname_ch = insertBefore(newname,'.tif',['_ch' num2str(i)]);
    t = Tiff([cartella,newname_ch],'w');
    tagstruct.ImageLength = nx;
    tagstruct.ImageWidth = ny;
    tagstruct.SampleFormat = 1; % uint
    tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample = info.BitDepth;
    tagstruct.SamplesPerPixel = 1;
    tagstruct.Compression = Tiff.Compression.Deflate;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    for ii=1:numeroFrames
       setTag(t,tagstruct);
       write(t,uint16(squeeze(registered(i,:,:,ii))));
       writeDirectory(t);
    end
end
close(t)
