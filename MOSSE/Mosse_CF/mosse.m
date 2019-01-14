%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function is correlation filter
%Visual Object Tracking using Adaptive Correlation Filters
%MOSSE
%date:2016-11-10
%author:WeiQin
%E-mail:285980893@qq.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;clc;
%% ������Ƶ�ļ�
% videoDir = 'D:\ImageData\David';
% [videoData,ground_truth] = Load_video(videoDir);%���ú�����ȡ��Ƶ����ȡgroundtruth����
% img = read(videoData,1);% ��ȡ��һ֡
%% ����ͼƬ�ļ�
imgDir= 'D:\objectTracking\configSeqs\OTB-100\Basketball';%ͼƬ�ļ���·����
[ground_truth,img_path,img_files]=Load_image(imgDir);%���ú�����ȡͼƬ֡����ȡgroundtruth����
img = imread([img_path img_files{1}]);%��ȡĿ��֡
%% ��ʼ֡����ֹ֡
startFrame=1;%��ʼ֡
endFrame=length(img_files);%����ͼƬ�ļ�Load_imageʱ����ֹ֡
% endFrame=videoData.NumberOfFrames;%������Ƶ�ļ�Load_vedioʱ����ֹ֡
%% ת��Ϊ�Ҷ�ͼ��
if(size(img,3)==1) %�Ҷ�ͼ��
    im=img;
else
    im = rgb2gray(img);%ת��Ϊ�Ҷ�ͼ
end
%% ��ȡĿ��λ�úͿ��С
%% set initial position and size
target_sz = [ground_truth(1,4), ground_truth(1,3)];%Ŀ��height��width
pos = [ground_truth(1,2), ground_truth(1,1)] + floor(target_sz/2);%Ŀ�����ĵ�λ�á�floor-���������ȡ������
positions = zeros(numel(img_files), 2);  %to calculate precision��numel����������Ԫ�ظ���,����һ��ͼ��numel����������������
%������˹����ģ��
F_response=templateGauss(target_sz,im);%��˹����ģ��
%% ��ѭ����ȡȫ��ͼ��֡
time = clock;  %to calculate FPS
eta = 0.125;
for frame=startFrame:endFrame
       %% trainingѵ�����ģ��
        img = imread([img_path img_files{frame}]);%��ȡĿ��֡(����ͼƬ�ļ�Load_imageʱ)
%         img = read(videoData,frame);% ��ȡĿ��֡(������Ƶ�ļ�Load_vedioʱ)
       %% ת��Ϊ�Ҷ�ͼ��
        if(size(img,3)==1) %�Ҷ�ͼ��
            im=img;
        else
            im = rgb2gray(img);%ת��Ϊ�Ҷ�ͼ
        end
        target_box=getsubbox(pos,target_sz,im);%��ȡĿ���
        tic()
       %% ѵ��������ʼ���ٲ�����ģ��
    if frame>startFrame
        newPoint=real(ifft2(F_Template.*fft2(target_box)));%���з��任
%         newPoint=uint8(newPoint);
%         subplot(1,2,1)
%         imshow(256.*newPoint);
        [row, col,~] = find(newPoint == max(newPoint(:)), 1);%�����ֵλ����Ϊ�µ�Ŀ��λ��
        pos = pos - target_sz/2 + [row, col]; 
    end
    %%
    %save position and calculate FPS
	positions(frame,:) = pos;
    F_im= fft2(getsubbox(pos,target_sz,im));%�Լ��г���Ŀ��ͼ����и���Ҷ�任,����FFT��F_im�����˸�ֵ
%     F_im=templateGauss(target_sz,F_im);%�������Լ��ӵ�������Ը���Ҷ�任���ͼ����и�˹������ͨ�����и������ݼ�����һ�����⣬
                       %��ԭ����������ʱ�����������Դ��λ����Ϊ��Ӧ���ֵ�������ע��һ���ǣ�����Դ���ʱ���Ư�Ʋ���Ŀ�����ĵ㡣
                       %���ڲ�δ����һ֡ͼ�����κδ�����������������֡�����ڸ��������ڣ��������������˵������֡�ڱ�������������ֵҲ��ܸߣ�������
                       %ֵ����Ŀ�����ĵ��ֵ����ô�ͻ����Ư�ƣ������ͻ�����Ա���Ϊ���ˣ������ĻᶪʧĿ�ꡣ����һ���������������г�����Ŀ��������ֵ
                       %һ����(��RedTeam���ݼ��������а�ɫ����������ɫ���߸�ʱ�ͻ�����Ϊ���߸�ΪĿ��)����Ϊ���߸�����Ҳ�ǰ�ɫ��������������ʱ���������ֵ
                       %Ҳ��ܴ󣬾ͻᱻ����ΪĿ�꣬���ƺ���Ŀ���������һ�����⣬����Ŀ���뱳����ɫ������о���
                       %���Ǽ��ϸ�˹�����󣬲������������ǣ�Ŀ������α����תʱ�����ڻ����Ŀ�������ƶ�����˸���Ч���᲻�á�
    F_Template=(conj(F_im.*conj(F_response))./(F_im.*conj(F_im)+eps));%����˲���$H^*$����
    %% �����ٿ�
%         subplot(1,2,2)
    rect_position = [pos([2,1]) - (target_sz([2,1])/2), (target_sz([2,1]))]; %�¸��ٿ�λ��y,x,height,width,
    if frame == 1  %first frame, create GUI
            figure
            im_handle = imagesc(uint8(img));%�������е�Ԫ����ֵ����Сת��Ϊ��ͬ��ɫ�������������Ӧλ�ô���������ɫȾɫ��
            rect_handle = rectangle('Position',rect_position,'LineWidth',2,'EdgeColor','r');
            tex_handle = text(5, 18, strcat('#',num2str(frame)), 'Color','y', 'FontWeight','bold', 'FontSize',20);
            drawnow;
    else
        try  %subsequent frames, update GUI
			set(im_handle, 'CData', img)%CData ��MATLAB����ͼ�����ݵ�һ������ �����ʹ��get���ȥ�õ����ľ����Ȼ������Ӧ��ͼ������
			set(rect_handle, 'Position', rect_position)
            set(tex_handle, 'string', strcat('#',num2str(frame)))
%             pause(0.001);
            drawnow;
		catch  % #ok, user has closed the window
			return
        end
    end
%         imagesc(uint8(img))
%         colormap(gray)
%         rect_position = [pos([2,1]) - (target_sz([2,1])/2), (target_sz([2,1]))]; 
%         rectangle('Position',rect_position,'LineWidth',4,'EdgeColor','r');
%         hold on;
%         text(5, 18, strcat('#',num2str(frame)), 'Color','y', 'FontWeight','bold', 'FontSize',20);
% %         set(gca,'position',[0 0 1 1]); 
%         pause(0.001); 
%         hold off;
%         drawnow;
end
disp(['Frames-per-second: ' num2str(numel(img_files) / etime(clock,time))])

%show the precisions plot
show_precision(positions, ground_truth, imgDir)