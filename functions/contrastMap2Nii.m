function contrastNifti = contrastMap2Nii(map,fileName,functionalNifti)
%
% Conversion of a contrast map stored as an array to a nifti structure
%
% contrastNifti = contrastMap2Nii(map,fileName,functionalNifti)
%
% INPUTS
% 1) map: contrast map to be stored as a nifti, for instance from hidden 
%         inplane hi.map{1} (three dimensional array)
% 2) fileName: filename for the nifti to be created (string)
% 3) functionalNifti: nifti structure produced by the vistasoft function
%                     readFileNifti on a nifti of a functional scan. This
%                     structure will be used to designate data fields for
%                     contrastNifti (struct)
%
% OUTPUT
% 1) contrastNifti: structure that can be written into a nifti using the
%                   vistasoft function writeFileNifti (struct)

% use data fields already defined in functionalNifti
contrastNifti = functionalNifti;

% assign map to contrastNifti's data, and reorganizing the array for view
% in itkgray
%contrastNifti.data = permute(map,[2 1 3]);
%contrastNifti.data = flip(contrastNifti.data,2);
contrastNifti.data = map;

% assigning filename
contrastNifti.fname = fileName;

% recalculating number of dimensions, max and min
contrastNifti.ndim = length(size(contrastNifti.data));
contrastNifti.dim = size(contrastNifti.data);
contrastNifti.pixdim = contrastNifti.pixdim(1:contrastNifti.ndim);
contrastNifti.cal_min = min(contrastNifti.data(:));
contrastNifti.cal_max = max(contrastNifti.data(:));
end